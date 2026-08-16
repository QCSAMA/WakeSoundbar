#requires -Version 5.1
# SPDX-License-Identifier: AGPL-3.0-only
# Copyright (C) 2026 QCSAMA
<##
.SYNOPSIS
    Wakes connected special-purpose display targets at user logon.

.DESCRIPTION
    Uses Windows.Devices.Display.Core to acquire and apply a display path for
    a SpecialPurpose target. This is intended for HDMI-connected soundbars and
    AVRs configured as displays removed from the Windows desktop.

    The default target filter is deliberately narrow. Use
    -IncludeStandardTargets only for diagnostics on a controlled machine.
#>
[CmdletBinding()]
param(
    [ValidateRange(0, 60000)]
    [int]$StartupDelayMilliseconds = 2500,

    [ValidateRange(0, 10)]
    [int]$RetryCount = 2,

    [ValidateRange(0, 60000)]
    [int]$RetryDelayMilliseconds = 1000,

    [string[]]$StableMonitorId,

    [switch]$IncludeStandardTargets,

    [switch]$InteractiveSelection,

    [switch]$NoSleep
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:ExitCodes = @{
    Success = 0
    InitializationFailure = 1
    TargetFailure = 2
}

function Write-Status {
    param(
        [Parameter(Mandatory)] [string]$Message,
        [ValidateSet('INFO', 'WARN', 'ERROR')] [string]$Level = 'INFO'
    )

    $color = switch ($Level) {
        'ERROR' { 'Red' }
        'WARN' { 'Yellow' }
        default { 'Gray' }
    }
    $label = if ($Level -eq 'ERROR') { 'FAILED' } else { $Level }
    Write-Host ('[{0}] {1}' -f $label, $Message) -ForegroundColor $color
}

function Get-DisplayManagerType {
    Add-Type -AssemblyName System.Runtime.WindowsRuntime

    [Windows.Devices.Display.Core.DisplayManager, Windows.Devices.Display.Core, ContentType = WindowsRuntime] | Out-Null
    [Windows.Devices.Display.Core.DisplayManagerOptions, Windows.Devices.Display.Core, ContentType = WindowsRuntime] | Out-Null
    [Windows.Devices.Display.Core.DisplayManagerResult, Windows.Devices.Display.Core, ContentType = WindowsRuntime] | Out-Null
    [Windows.Devices.Display.Core.DisplayStateApplyOptions, Windows.Devices.Display.Core, ContentType = WindowsRuntime] | Out-Null
    [Windows.Devices.Display.Core.DisplayStateOperationStatus, Windows.Devices.Display.Core, ContentType = WindowsRuntime] | Out-Null
    [Windows.Devices.Display.DisplayMonitorUsageKind, Windows.Devices.Display, ContentType = WindowsRuntime] | Out-Null
}

function Get-AcquireErrorDescription {
    param([Parameter(Mandatory)] $ErrorCode)

    switch ($ErrorCode.ToString()) {
        'TargetAccessDenied' { return 'target is owned by another component or has ownership restrictions' }
        'TargetStale' { return 'target changed; it must be re-enumerated' }
        'RemoteSessionNotSupported' { return 'current session is not supported (for example, Remote Desktop)' }
        'UnknownFailure' { return 'unknown display-manager failure' }
        default { return $ErrorCode.ToString() }
    }
}

function Invoke-TargetWake {
    param(
        [Parameter(Mandatory)] $Manager,
        [Parameter(Mandatory)] $Target
    )

    $targetList = [System.Collections.Generic.List[Windows.Devices.Display.Core.DisplayTarget]]::new()
    [void]$targetList.Add($Target)

    $acquireResult = $Manager.TryAcquireTargetsAndCreateEmptyState($targetList)
    $success = [Windows.Devices.Display.Core.DisplayManagerResult]::Success
    if ($acquireResult.ErrorCode -ne $success) {
        return [pscustomobject]@{
            Succeeded = $false
            Retryable = $false
            Status = $acquireResult.ErrorCode.ToString()
            Detail = Get-AcquireErrorDescription $acquireResult.ErrorCode
        }
    }

    $state = $acquireResult.State
    [void]$state.ConnectTarget($Target)
    $applyResult = $state.TryApply([Windows.Devices.Display.Core.DisplayStateApplyOptions]::None)
    $applySuccess = [Windows.Devices.Display.Core.DisplayStateOperationStatus]::Success
    $status = $applyResult.Status.ToString()

    return [pscustomobject]@{
        Succeeded = $applyResult.Status -eq $applySuccess
        Retryable = $status -eq 'SystemStateChanged' -or $status -eq 'TargetOwnershipLost'
        Status = $status
        Detail = 'TryApply completed with status {0}' -f $status
    }
}

$selectionPath = Join-Path $PSScriptRoot 'target-id.txt'
$savedTargetId = $null
if ($null -eq $StableMonitorId -and -not $InteractiveSelection -and (Test-Path -LiteralPath $selectionPath)) {
    $savedTargetId = (Get-Content -LiteralPath $selectionPath -Raw).Trim()
    if (-not [string]::IsNullOrWhiteSpace($savedTargetId)) {
        $StableMonitorId = @($savedTargetId)
        Write-Status ('Using saved StableMonitorId {0}.' -f $savedTargetId)
    }
}

$manager = $null
$wokenCount = 0
$candidateCount = 0
$failureCount = 0

try {
    if ([Environment]::OSVersion.Version.Build -lt 17763) {
        throw 'Windows 10 version 1809 (build 17763) or newer is required.'
    }

    Write-Status 'WakeSoundbar starting.'
    if (-not $NoSleep -and $StartupDelayMilliseconds -gt 0) {
        Start-Sleep -Milliseconds $StartupDelayMilliseconds
    }

    Get-DisplayManagerType
    $manager = [Windows.Devices.Display.Core.DisplayManager]::Create(
        [Windows.Devices.Display.Core.DisplayManagerOptions]::None
    )
    $specialPurpose = [Windows.Devices.Display.DisplayMonitorUsageKind]::SpecialPurpose
    $hasStableMonitorFilter = $null -ne $StableMonitorId -and @($StableMonitorId).Count -gt 0
    $candidateTargets = @()

    for ($scanAttempt = 0; $scanAttempt -le $RetryCount; $scanAttempt++) {
        $targets = @($manager.GetCurrentTargets())
        $candidateTargets = @($targets | Where-Object {
            $_.IsConnected -and
            -not $_.IsStale -and
            ($IncludeStandardTargets -or $_.UsageKind -eq $specialPurpose) -and
            (-not $hasStableMonitorFilter -or $StableMonitorId -contains $_.StableMonitorId)
        })

        if ($candidateTargets.Count -gt 0 -or $scanAttempt -ge $RetryCount) {
            break
        }

        Write-Status ('No eligible targets in scan {0}; waiting for the display stack to settle.' -f ($scanAttempt + 1)) 'WARN'
        if (-not $NoSleep -and $RetryDelayMilliseconds -gt 0) {
            Start-Sleep -Milliseconds $RetryDelayMilliseconds
        }
    }

    if ($candidateTargets.Count -gt 1 -and -not $hasStableMonitorFilter) {
        if (-not $InteractiveSelection) {
            foreach ($candidate in $candidateTargets) {
                Write-Status ('Multiple target candidate: Adapter {0}, Target {1}, StableMonitorId {2}.' -f $candidate.Adapter.Id, $candidate.AdapterRelativeId, $candidate.StableMonitorId) 'ERROR'
            }
            throw 'Multiple SpecialPurpose targets found. Re-run with -InteractiveSelection or -StableMonitorId.'
        }

        Write-Status 'Multiple SpecialPurpose targets found. Select the soundbar or AVR:' 'WARN'
        for ($index = 0; $index -lt $candidateTargets.Count; $index++) {
            $candidate = $candidateTargets[$index]
            Write-Host ('  [{0}] Adapter {1}, Target {2}, StableMonitorId {3}' -f ($index + 1), $candidate.Adapter.Id, $candidate.AdapterRelativeId, $candidate.StableMonitorId)
        }

        $selection = 0
        $selectionText = Read-Host 'Enter target number'
        if (-not [int]::TryParse($selectionText, [ref]$selection) -or $selection -lt 1 -or $selection -gt $candidateTargets.Count) {
            throw 'Invalid target selection.'
        }

        $selectedTarget = $candidateTargets[$selection - 1]
        if ([string]::IsNullOrWhiteSpace($selectedTarget.StableMonitorId)) {
            throw 'The selected target has no stable monitor ID and cannot be persisted.'
        }
        $StableMonitorId = @($selectedTarget.StableMonitorId)
        $hasStableMonitorFilter = $true
        Set-Content -LiteralPath $selectionPath -Value $selectedTarget.StableMonitorId -Encoding ASCII
        $candidateTargets = @($selectedTarget)
        Write-Status ('Selected target {0}.' -f $selectedTarget.StableMonitorId)
    } elseif ($candidateTargets.Count -eq 1 -and $InteractiveSelection -and -not $hasStableMonitorFilter) {
        $selectedTarget = $candidateTargets[0]
        if (-not [string]::IsNullOrWhiteSpace($selectedTarget.StableMonitorId)) {
            Set-Content -LiteralPath $selectionPath -Value $selectedTarget.StableMonitorId -Encoding ASCII
            Write-Status ('Selected target automatically: {0}.' -f $selectedTarget.StableMonitorId)
        }
    }

    foreach ($target in $candidateTargets) {
        $candidateCount++
        $targetLabel = '{0}:{1}' -f $target.Adapter.Id, $target.AdapterRelativeId
        Write-Status ('Candidate target {0} (UsageKind: {1}).' -f $targetLabel, $target.UsageKind)

        $targetSucceeded = $false
        for ($attempt = 0; $attempt -le $RetryCount; $attempt++) {
            try {
                $result = Invoke-TargetWake -Manager $manager -Target $target
                if ($result.Succeeded) {
                    Write-Status ('SUCCESS: activated target {0} (attempt {1}).' -f $targetLabel, ($attempt + 1))
                    $wokenCount++
                    $targetSucceeded = $true
                    break
                }

                $level = if ($result.Retryable -and $attempt -lt $RetryCount) { 'WARN' } else { 'ERROR' }
                Write-Status ('Target {0} attempt {1} failed: {2}.' -f $targetLabel, ($attempt + 1), $result.Detail) $level
                if (-not $result.Retryable -or $attempt -ge $RetryCount) {
                    break
                }
                if (-not $NoSleep -and $RetryDelayMilliseconds -gt 0) {
                    Start-Sleep -Milliseconds $RetryDelayMilliseconds
                }
            } catch {
                Write-Status ('Target {0} attempt {1} raised: {2}.' -f $targetLabel, ($attempt + 1), $_.Exception.Message) 'ERROR'
                break
            }
        }

        if (-not $targetSucceeded) {
            $failureCount++
        }
    }

    if ($candidateCount -eq 0) {
        Write-Status 'No eligible SpecialPurpose targets found; nothing to activate.' 'WARN'
    }
    Write-Status ('Completed. Candidates: {0}; activated: {1}; failed: {2}.' -f $candidateCount, $wokenCount, $failureCount)
    if ($failureCount -gt 0 -and $wokenCount -eq 0) {
        exit $script:ExitCodes.TargetFailure
    }
    exit $script:ExitCodes.Success
} catch {
    Write-Status $_.Exception.Message 'ERROR'
    exit $script:ExitCodes.InitializationFailure
} finally {
    if ($null -ne $manager) {
        try {
            $manager.Dispose()
        } catch {
            Write-Status ('DisplayManager.Dispose failed: {0}' -f $_.Exception.Message) 'WARN'
        }
    }
}
