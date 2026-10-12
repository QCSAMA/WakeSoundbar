#requires -Version 5.1
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$temp = Join-Path ([IO.Path]::GetTempPath()) ('WakeSoundbar-tests-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $temp | Out-Null
$passed = 0
try {
    foreach ($file in @('WakeSoundbar.ps1', 'locales\zh-CN\WakeSoundbar.ps1')) {
        $source = [IO.File]::ReadAllText((Join-Path $root $file))
        $tokens = $null; $errors = $null
        $ast = [Management.Automation.Language.Parser]::ParseInput($source, [ref]$tokens, [ref]$errors)
        if ($errors.Count) { throw ($errors.Message -join '; ') }
        foreach ($functionName in @('Get-DisplayManagerType', 'Invoke-TargetWake')) {
            $node = $ast.Find({ param($n) $n -is [Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq $functionName }, $true)
            $replacement = if ($functionName -eq 'Get-DisplayManagerType') {
                'function Get-DisplayManagerType {}'
            } else {
@'
function Invoke-TargetWake {
    param($Manager, $Target)
    if ($Target.Generation -lt 2) { throw 'An old target snapshot was reused.' }
    $ok = $Target.StableMonitorId -ne 'B' -or $script:Scenario -ne 'partial'
    return [pscustomobject]@{ Succeeded = $ok; Retryable = $false; Detail = 'fixture result' }
}

# Expected failing fixtures must not leave a native failure status for CI hosts.
$global:LASTEXITCODE = 0
'@
            }
            $source = $source.Replace($node.Extent.Text, $replacement)
        }
        $source = $source -replace '(?s)\$manager = \[Windows.Devices.Display.Core.DisplayManager\]::Create\(.*?\r?\n    \)', '$manager = $script:FixtureManager'
        $source = $source.Replace('[Windows.Devices.Display.DisplayMonitorUsageKind]::SpecialPurpose', "'SpecialPurpose'")
        foreach ($case in @(
            @{Name='success'; Code=0}, @{Name='empty'; Code=3},
            @{Name='wrong-id'; Code=3}, @{Name='partial'; Code=2},
            @{Name='missing-once'; Code=0}, @{Name='standard'; Code=3},
            @{Name='ambiguous'; Code=1}, @{Name='empty-selection'; Code=1}
        )) {
            $fixture = @'
$script:Scenario = 'SCENARIO'
$script:Generation = 0
$script:FixtureManager = New-Object PSObject
$script:FixtureManager | Add-Member ScriptMethod GetCurrentTargets {
    $script:Generation++
    if ($script:Scenario -eq 'empty' -or ($script:Scenario -eq 'missing-once' -and $script:Generation -eq 2)) { return @() }
    $ids = if ($script:Scenario -in @('partial', 'ambiguous')) { @('A','B') } else { @('A') }
    foreach ($id in $ids) {
        [pscustomobject]@{ IsConnected=$true; IsStale=$false; UsageKind=$(if($script:Scenario -eq 'standard'){'Standard'}else{'SpecialPurpose'}); StableMonitorId=$id; Adapter=[pscustomobject]@{Id=1}; AdapterRelativeId=$id; Generation=$script:Generation }
    }
}
$script:FixtureManager | Add-Member ScriptMethod Dispose { }
'@
            $fixture = $fixture.Replace('SCENARIO', $case.Name)
            # Insert after the param block; never change the production APIs or files.
            $tokens = $null; $errors = $null
            $caseSource = $source
            if ($case.Name -eq 'partial') { $caseSource = $source.Replace('[string[]]$StableMonitorId,', '[string[]]$StableMonitorId = @(''A'',''B''),') }
            $modifiedAst = [Management.Automation.Language.Parser]::ParseInput($caseSource, [ref]$tokens, [ref]$errors)
            $modified = $caseSource.Insert($modifiedAst.ParamBlock.Extent.EndOffset, "`r`n" + $fixture)
            $scriptPath = Join-Path $temp 'fixture.ps1'
            [IO.File]::WriteAllText($scriptPath, $modified, [Text.UTF8Encoding]::new($true))
            $selection = Join-Path $temp 'target-id.txt'
            if (Test-Path -LiteralPath $selection) { Remove-Item -LiteralPath $selection }
            if ($case.Name -eq 'empty-selection') { [IO.File]::WriteAllText($selection, '') }
            $argsList = @('-NoProfile','-File',$scriptPath,'-NoSleep','-RetryCount','2','-LogPath',(Join-Path $temp 'run.log'))
            if ($case.Name -eq 'wrong-id') { $argsList += @('-StableMonitorId','X') }
            $output = & powershell.exe @argsList 2>&1
            if ($LASTEXITCODE -ne $case.Code) { throw "$file / $($case.Name): expected $($case.Code), got $LASTEXITCODE. $output" }
            if (-not (Test-Path -LiteralPath (Join-Path $temp 'run.log'))) { throw 'Missing diagnostic log.' }
            $passed++
            Write-Host "PASS $file / $($case.Name)"
        }
    }
    Write-Host "Passed $passed runtime regression cases. No real display APIs were called."
} finally {
    # This is a unique directory created by this test under the OS temp directory.
    if ([IO.Path]::GetFullPath($temp).StartsWith([IO.Path]::GetFullPath([IO.Path]::GetTempPath()), [StringComparison]::OrdinalIgnoreCase)) {
        Remove-Item -LiteralPath $temp -Recurse -Force
    }
}
