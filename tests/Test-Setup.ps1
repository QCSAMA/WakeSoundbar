#requires -Version 5.1
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$temp = Join-Path ([IO.Path]::GetTempPath()) ('WakeSoundbar-setup-tests-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $temp | Out-Null
try {
    $setup = [IO.File]::ReadAllText((Join-Path $root 'Setup-WakeSoundbar.ps1'))
    $tokens = $null; $errors = $null
    $ast = [Management.Automation.Language.Parser]::ParseInput($setup, [ref]$tokens, [ref]$errors)
    if ($errors.Count) { throw ($errors.Message -join '; ') }
    foreach ($scenario in @('success', 'default-source', 'hardware-failure', 'registration-failure', 'scheduled-failure', 'wrong-user')) {
        $caseDir = Join-Path $temp $scenario
        $sourceDir = Join-Path $caseDir 'source'
        $installed = Join-Path $caseDir 'WakeSoundbar'
        New-Item -ItemType Directory -Path $sourceDir, $installed -Force | Out-Null
        Set-Content -LiteralPath (Join-Path $installed '.wakeSoundbar-install') -Value 'WakeSoundbar installation marker' -Encoding ASCII
        Set-Content -LiteralPath (Join-Path $installed 'WakeSoundbar.ps1') -Value '# original script' -Encoding ASCII
        Set-Content -LiteralPath (Join-Path $installed 'target-id.txt') -Value 'original-target' -Encoding ASCII
        $candidate = @'
param([switch]$InteractiveSelection, [string]$LogPath)
if ($env:WakeSoundbarTestScenario -eq 'hardware-failure') { exit 3 }
Set-Content -LiteralPath (Join-Path $PSScriptRoot 'target-id.txt') -Value 'test-target' -Encoding ASCII
exit 0
'@
        Set-Content -LiteralPath (Join-Path $sourceDir 'WakeSoundbar.ps1') -Value $candidate -Encoding ASCII
        if ($scenario -eq 'default-source') {
            Set-Content -LiteralPath (Join-Path $caseDir 'WakeSoundbar.ps1') -Value $candidate -Encoding ASCII
        }
        $mock = @'
$env:ProgramData = $env:WakeSoundbarTestDirectory
$script:Registered = $false
$script:Started = $false
$script:VerifiedTask = [pscustomobject]@{ State='Ready' }
function Get-CimInstance { param($ClassName)
    $user = [Security.Principal.WindowsIdentity]::GetCurrent().Name
    if ($env:WakeSoundbarTestScenario -eq 'wrong-user') { $user = 'NT AUTHORITY\SYSTEM' }
    [pscustomobject]@{UserName=$user}
}

# Expected failing fixtures must not leave a native failure status for CI hosts.
$global:LASTEXITCODE = 0
function Get-Service { param($Name) [pscustomobject]@{Status='Running'} }
function New-ScheduledTaskAction { param($Execute,$Argument,$WorkingDirectory) [pscustomobject]@{Execute=$Execute;Arguments=$Argument;WorkingDirectory=$WorkingDirectory} }
function New-ScheduledTaskTrigger { param([switch]$AtLogOn,$User) [pscustomobject]@{UserId=$User;Delay=$null} }
function New-ScheduledTaskPrincipal { param($UserId,$LogonType,$RunLevel) [pscustomobject]@{UserId=$UserId;LogonType=$LogonType;RunLevel=$RunLevel} }
function New-ScheduledTaskSettingsSet { param([switch]$AllowStartIfOnBatteries,[switch]$DontStopIfGoingOnBatteries,$ExecutionTimeLimit,$RestartCount,$RestartInterval) [pscustomobject]@{Enabled=$true;RestartCount=$RestartCount} }
function Get-ScheduledTask { param($TaskName,$TaskPath,$ErrorAction) $script:VerifiedTask }
function Export-ScheduledTask { param($TaskName,$TaskPath) 'old-task-xml' }
function Stop-ScheduledTask { param($InputObject,$TaskName,$TaskPath,$ErrorAction) }
function Unregister-ScheduledTask { param($TaskName,$TaskPath,$Confirm,$ErrorAction) }
function Register-ScheduledTask {
    param($TaskName,$TaskPath,$Action,$Trigger,$Principal,$Settings,$Xml,[switch]$Force)
    if ($Xml) {
        Set-Content -LiteralPath (Join-Path $env:ProgramData 'restored-task.txt') -Value $Xml
        return
    }
    if ($env:WakeSoundbarTestScenario -eq 'registration-failure') { throw 'Simulated registration failure' }
    $script:Registered = $true
    $script:VerifiedTask = [pscustomobject]@{Actions=$Action;Triggers=$Trigger;Principal=$Principal;Settings=$Settings;State='Ready'}
}
function Start-ScheduledTask { param($InputObject) $script:Started = $true }
function Get-ScheduledTaskInfo { param($TaskName,$TaskPath)
    $result = if ($env:WakeSoundbarTestScenario -eq 'scheduled-failure') {2} else {0}
    [pscustomobject]@{LastRunTime=$(if($script:Started){[datetime]'2026-01-02'}else{[datetime]'2026-01-01'});LastTaskResult=$result}
}
'@
        # All scheduler operations, including definition constructors, are test doubles.
        $fixture = $setup.Insert($ast.ParamBlock.Extent.EndOffset, "`r`n" + $mock)
        $fixturePath = Join-Path $caseDir 'setup-fixture.ps1'
        Set-Content -LiteralPath $fixturePath -Value $fixture -Encoding ASCII
        $env:WakeSoundbarTestDirectory = $caseDir
        $env:WakeSoundbarTestScenario = $scenario
        $arguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $fixturePath)
        if ($scenario -ne 'default-source') { $arguments += @('-SourceDirectory', $sourceDir) }
        $output = & powershell.exe @arguments 2>&1
        $success = $scenario -in @('success', 'default-source')
        $expected = if ($success) {0} else {1}
        if ($LASTEXITCODE -ne $expected) { throw "$scenario returned $LASTEXITCODE; expected $expected. $output" }
        $value = (Get-Content -LiteralPath (Join-Path $installed 'target-id.txt') -Raw).Trim()
        $expectedId = if ($success) {'test-target'} else {'original-target'}
        if ($value -ne $expectedId) { throw "$scenario did not preserve the expected selection." }
        if (-not $success -and (Get-Content -LiteralPath (Join-Path $installed 'WakeSoundbar.ps1') -Raw).Trim() -ne '# original script') {
            throw "$scenario failed to restore the original script."
        }
        if ($scenario -in @('registration-failure','scheduled-failure') -and -not (Test-Path -LiteralPath (Join-Path $caseDir 'restored-task.txt'))) {
            throw "$scenario did not restore the original task."
        }
        Write-Host "PASS setup / $scenario"
    }
} finally {
    Remove-Item Env:WakeSoundbarTestDirectory,Env:WakeSoundbarTestScenario -ErrorAction SilentlyContinue
    if ([IO.Path]::GetFullPath($temp).StartsWith([IO.Path]::GetFullPath([IO.Path]::GetTempPath()), [StringComparison]::OrdinalIgnoreCase)) {
        Remove-Item -LiteralPath $temp -Recurse -Force
    }
}
