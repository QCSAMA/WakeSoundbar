#requires -Version 5.1
# SPDX-License-Identifier: AGPL-3.0-only
[CmdletBinding()]
param(
    [ValidateSet('Install', 'Uninstall')] [string]$Mode = 'Install',
    [string]$SourceDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($SourceDirectory)) { $SourceDirectory = $PSScriptRoot }
$dir = Join-Path $env:ProgramData 'WakeSoundbar'
$taskName = 'WakeSoundbar'
$marker = Join-Path $dir '.wakeSoundbar-install'
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$admin = [Security.Principal.WindowsPrincipal]::new($identity)

function Assert-SafeDirectory {
    param([string]$Path)
    if (Test-Path -LiteralPath $Path) {
        $item = Get-Item -LiteralPath $Path -Force
        if (-not $item.PSIsContainer -or ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
            throw "Not a regular directory: $Path"
        }
    }
}

function Set-InstallPermissions {
    param([string]$Path)
    $acl = [Security.AccessControl.DirectorySecurity]::new()
    $acl.SetAccessRuleProtection($true, $false)
    foreach ($sid in @('S-1-5-18', 'S-1-5-32-544', 'S-1-5-32-545')) {
        $rights = if ($sid -eq 'S-1-5-32-545') { 'ReadAndExecute' } else { 'FullControl' }
        $rule = [Security.AccessControl.FileSystemAccessRule]::new(
            [Security.Principal.SecurityIdentifier]::new($sid), $rights,
            'ContainerInherit, ObjectInherit', 'None', 'Allow')
        $acl.AddAccessRule($rule)
    }
    $acl.SetOwner([Security.Principal.SecurityIdentifier]::new('S-1-5-32-544'))
    Set-Acl -LiteralPath $Path -AclObject $acl
}

function Get-OptionalTask {
    try {
        return Get-ScheduledTask -TaskName $taskName -TaskPath '\' -ErrorAction Stop
    } catch {
        if ($_.CategoryInfo.Category -eq [Management.Automation.ErrorCategory]::ObjectNotFound) { return $null }
        throw 'Cannot read the existing task. After an account rename, sign in again before running setup. No deployment files were replaced.'
    }
}

try {
    if (-not $admin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'Run the installer as administrator.'
    }
    Assert-SafeDirectory $dir
    # Never delete or overwrite an unrelated directory at this fixed location.
    if ((Test-Path -LiteralPath $dir) -and -not (Test-Path -LiteralPath $marker -PathType Leaf)) {
        throw "Installation marker is missing: $dir"
    }
    if ($Mode -eq 'Uninstall') {
        if (-not (Test-Path -LiteralPath $marker -PathType Leaf)) { throw 'Installation marker not found.' }
        $links = @(Get-ChildItem -LiteralPath $dir -Force -Recurse | Where-Object {
            $_.Attributes -band [IO.FileAttributes]::ReparsePoint
        })
        if ($links.Count) { throw 'Reparse points found in the installation. Inspect them before removal.' }
        $task = Get-OptionalTask
        if ($null -ne $task) {
            Stop-ScheduledTask -InputObject $task -ErrorAction SilentlyContinue
            Unregister-ScheduledTask -InputObject $task -Confirm:$false
        }
        # Only the fixed, checked installation directory is removed.
        Remove-Item -LiteralPath $dir -Recurse -Force
        Write-Host '[SUCCESS] WakeSoundbar removed.'
        exit 0
    }

    $desktopUser = (Get-CimInstance Win32_ComputerSystem).UserName
    if ([string]::IsNullOrWhiteSpace($desktopUser)) { throw 'No interactive desktop user found.' }
    $desktopSid = ([Security.Principal.NTAccount]::new($desktopUser)).Translate([Security.Principal.SecurityIdentifier]).Value
    if ($desktopSid -ne $identity.User.Value) {
        throw 'The elevated account differs from the desktop account. Sign in to the intended administrator account first.'
    }
    if ((Get-Service Schedule).Status -ne 'Running') { throw 'Task Scheduler service is not running.' }
    $source = Join-Path $SourceDirectory 'WakeSoundbar.ps1'
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Missing script: $source" }

    $oldTask = Get-OptionalTask
    $oldXml = $null
    if ($null -ne $oldTask) { $oldXml = Export-ScheduledTask -TaskName $taskName -TaskPath '\' }
    $existed = Test-Path -LiteralPath $dir
    if (-not $existed) { New-Item -ItemType Directory -Path $dir | Out-Null }
    Set-InstallPermissions $dir
    $stage = Join-Path $dir ('setup-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $stage | Out-Null
    $files = @('WakeSoundbar.ps1', 'target-id.txt', '.wakeSoundbar-install')
    $changed = $false
    $preserveStage = $false
    try {
        foreach ($name in $files) {
            $installed = Join-Path $dir $name
            if (Test-Path -LiteralPath $installed) {
                if ((Get-Item -LiteralPath $installed -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) {
                    throw "Reparse point in installation: $name"
                }
                Copy-Item -LiteralPath $installed -Destination (Join-Path $stage ($name + '.backup'))
            }
        }
        $candidate = Join-Path $stage 'WakeSoundbar.ps1'
        Copy-Item -LiteralPath $source -Destination $candidate
        Write-Host '[INFO] Testing the selected hardware before changing the task...'
        $psExe = Join-Path $PSHOME 'powershell.exe'
        & $psExe -NoProfile -ExecutionPolicy Bypass -File $candidate -InteractiveSelection -LogPath (Join-Path $dir 'install.log')
        if ($LASTEXITCODE -ne 0) { throw "Hardware test failed (exit $LASTEXITCODE). Existing task and script were preserved." }
        if (-not (Test-Path -LiteralPath (Join-Path $stage 'target-id.txt'))) { throw 'Hardware selection was not saved.' }
        if ($null -ne $oldTask) { Stop-ScheduledTask -InputObject $oldTask -ErrorAction SilentlyContinue }
        $changed = $true
        Copy-Item -LiteralPath $candidate -Destination (Join-Path $dir 'WakeSoundbar.ps1') -Force
        Copy-Item -LiteralPath (Join-Path $stage 'target-id.txt') -Destination (Join-Path $dir 'target-id.txt') -Force
        Set-Content -LiteralPath $marker -Value 'WakeSoundbar installation marker' -Encoding ASCII
        $arguments = '-NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File "' + (Join-Path $dir 'WakeSoundbar.ps1') + '" -LogPath "' + (Join-Path $dir 'last-run.log') + '"'
        $action = New-ScheduledTaskAction -Execute $psExe -Argument $arguments -WorkingDirectory $dir
        $trigger = New-ScheduledTaskTrigger -AtLogOn -User $identity.User.Value
        $trigger.Delay = 'PT30S'
        $principal = New-ScheduledTaskPrincipal -UserId $identity.User.Value -LogonType Interactive -RunLevel Highest
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 2) -RestartCount 2 -RestartInterval (New-TimeSpan -Minutes 1)
        Register-ScheduledTask -TaskName $taskName -TaskPath '\' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
        $verified = Get-ScheduledTask -TaskName $taskName -TaskPath '\'
        if ($verified.Actions.Execute -ne $psExe -or $verified.Actions.Arguments -ne $arguments -or
            $verified.Actions.WorkingDirectory -ne $dir -or $verified.Triggers.Delay -ne 'PT30S' -or
            $verified.Settings.RestartCount -ne 2 -or -not $verified.Settings.Enabled) {
            throw 'Task registration verification failed.'
        }
        # Exercise the real interactive scheduled-task context, not just the installer process.
        $previousRun = (Get-ScheduledTaskInfo -TaskName $taskName -TaskPath '\').LastRunTime
        Start-ScheduledTask -InputObject $verified
        $deadline = (Get-Date).AddSeconds(110)
        do {
            Start-Sleep -Seconds 1
            $state = (Get-ScheduledTask -TaskName $taskName -TaskPath '\').State
            $info = Get-ScheduledTaskInfo -TaskName $taskName -TaskPath '\'
        } while (($state -in @('Running', 'Queued') -or $info.LastRunTime -eq $previousRun -or $info.LastTaskResult -eq 267011) -and (Get-Date) -lt $deadline)
        if ($state -in @('Running', 'Queued') -or $info.LastRunTime -eq $previousRun -or $info.LastTaskResult -ne 0) {
            throw "Scheduled execution failed or timed out (result $($info.LastTaskResult)). See last-run.log."
        }
        Write-Host '[SUCCESS] Hardware selection, installation and scheduled execution verified.'
    } catch {
        if ($changed) {
            $preserveStage = $true
            Stop-ScheduledTask -TaskName $taskName -TaskPath '\' -ErrorAction SilentlyContinue
            foreach ($name in $files) {
                $backup = Join-Path $stage ($name + '.backup')
                if (Test-Path -LiteralPath $backup) {
                    Copy-Item -LiteralPath $backup -Destination (Join-Path $dir $name) -Force
                } elseif (Test-Path -LiteralPath (Join-Path $dir $name)) {
                    Remove-Item -LiteralPath (Join-Path $dir $name) -Force
                }
            }
            if ($null -ne $oldXml) {
                Register-ScheduledTask -TaskName $taskName -TaskPath '\' -Xml $oldXml -Force | Out-Null
            } else {
                Unregister-ScheduledTask -TaskName $taskName -TaskPath '\' -Confirm:$false -ErrorAction Stop
            }
            $preserveStage = $false
        }
        throw
    } finally {
        if (-not $preserveStage) {
            Assert-SafeDirectory $stage
            Remove-Item -LiteralPath $stage -Recurse -Force
        } else {
            Write-Warning "Rollback did not finish. Recovery files remain at $stage"
        }
        if (-not $existed -and -not (Test-Path -LiteralPath $marker)) {
            # Keep diagnostic logs, and allow a later retry to recognize this directory.
            Set-Content -LiteralPath $marker -Value 'WakeSoundbar installation marker' -Encoding ASCII
        }
    }
    exit 0
} catch {
    Write-Host ('[FAILED] ' + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
