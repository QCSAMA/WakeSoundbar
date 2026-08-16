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
    $label = switch ($Level) {
        'ERROR' { '失败' }
        'WARN' { '警告' }
        default { '信息' }
    }
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
        'TargetAccessDenied' { return '目标被其他组件占用，或受所有权限制' }
        'TargetStale' { return '目标已变化，需要重新枚举' }
        'RemoteSessionNotSupported' { return '当前会话不受支持（例如远程桌面）' }
        'UnknownFailure' { return '显示管理器发生未知故障' }
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
        Detail = 'TryApply 已完成，状态为 {0}' -f $status
    }
}

$selectionPath = Join-Path $PSScriptRoot 'target-id.txt'
$savedTargetId = $null
if ($null -eq $StableMonitorId -and -not $InteractiveSelection -and (Test-Path -LiteralPath $selectionPath)) {
    $savedTargetId = (Get-Content -LiteralPath $selectionPath -Raw).Trim()
    if (-not [string]::IsNullOrWhiteSpace($savedTargetId)) {
        $StableMonitorId = @($savedTargetId)
        Write-Status ('正在使用已保存的 StableMonitorId {0}。' -f $savedTargetId)
    }
}

$manager = $null
$wokenCount = 0
$candidateCount = 0
$failureCount = 0

try {
    if ([Environment]::OSVersion.Version.Build -lt 17763) {
        throw '需要 Windows 10 1809（内部版本 17763）或更高版本。'
    }

    Write-Status 'WakeSoundbar 正在启动。'
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

        Write-Status ('第 {0} 次扫描未找到可用目标，正在等待显示系统稳定。' -f ($scanAttempt + 1)) 'WARN'
        if (-not $NoSleep -and $RetryDelayMilliseconds -gt 0) {
            Start-Sleep -Milliseconds $RetryDelayMilliseconds
        }
    }

    if ($candidateTargets.Count -gt 1 -and -not $hasStableMonitorFilter) {
        if (-not $InteractiveSelection) {
            foreach ($candidate in $candidateTargets) {
                Write-Status ('发现多个候选目标：适配器 {0}，目标 {1}，StableMonitorId {2}。' -f $candidate.Adapter.Id, $candidate.AdapterRelativeId, $candidate.StableMonitorId) 'ERROR'
            }
            throw '找到多个 SpecialPurpose 目标。请使用 -InteractiveSelection 或 -StableMonitorId 重新运行。'
        }

        Write-Status '找到多个 SpecialPurpose 目标。请选择回音壁或功放：' 'WARN'
        for ($index = 0; $index -lt $candidateTargets.Count; $index++) {
            $candidate = $candidateTargets[$index]
            Write-Host ('  [{0}] 适配器 {1}，目标 {2}，StableMonitorId {3}' -f ($index + 1), $candidate.Adapter.Id, $candidate.AdapterRelativeId, $candidate.StableMonitorId)
        }

        $selection = 0
        $selectionText = Read-Host '请输入目标编号'
        if (-not [int]::TryParse($selectionText, [ref]$selection) -or $selection -lt 1 -or $selection -gt $candidateTargets.Count) {
            throw '目标编号无效。'
        }

        $selectedTarget = $candidateTargets[$selection - 1]
        if ([string]::IsNullOrWhiteSpace($selectedTarget.StableMonitorId)) {
            throw '所选目标没有稳定的显示器 ID，无法保存。'
        }
        $StableMonitorId = @($selectedTarget.StableMonitorId)
        $hasStableMonitorFilter = $true
        Set-Content -LiteralPath $selectionPath -Value $selectedTarget.StableMonitorId -Encoding ASCII
        $candidateTargets = @($selectedTarget)
        Write-Status ('已选择目标 {0}。' -f $selectedTarget.StableMonitorId)
    } elseif ($candidateTargets.Count -eq 1 -and $InteractiveSelection -and -not $hasStableMonitorFilter) {
        $selectedTarget = $candidateTargets[0]
        if (-not [string]::IsNullOrWhiteSpace($selectedTarget.StableMonitorId)) {
            Set-Content -LiteralPath $selectionPath -Value $selectedTarget.StableMonitorId -Encoding ASCII
            Write-Status ('已自动选择目标：{0}。' -f $selectedTarget.StableMonitorId)
        }
    }

    foreach ($target in $candidateTargets) {
        $candidateCount++
        $targetLabel = '{0}:{1}' -f $target.Adapter.Id, $target.AdapterRelativeId
        Write-Status ('候选目标 {0}（UsageKind：{1}）。' -f $targetLabel, $target.UsageKind)

        $targetSucceeded = $false
        for ($attempt = 0; $attempt -le $RetryCount; $attempt++) {
            try {
                $result = Invoke-TargetWake -Manager $manager -Target $target
                if ($result.Succeeded) {
                    Write-Status ('成功：已激活目标 {0}（第 {1} 次尝试）。' -f $targetLabel, ($attempt + 1))
                    $wokenCount++
                    $targetSucceeded = $true
                    break
                }

                $level = if ($result.Retryable -and $attempt -lt $RetryCount) { 'WARN' } else { 'ERROR' }
                Write-Status ('目标 {0} 第 {1} 次尝试失败：{2}。' -f $targetLabel, ($attempt + 1), $result.Detail) $level
                if (-not $result.Retryable -or $attempt -ge $RetryCount) {
                    break
                }
                if (-not $NoSleep -and $RetryDelayMilliseconds -gt 0) {
                    Start-Sleep -Milliseconds $RetryDelayMilliseconds
                }
            } catch {
                Write-Status ('目标 {0} 第 {1} 次尝试发生异常：{2}。' -f $targetLabel, ($attempt + 1), $_.Exception.Message) 'ERROR'
                break
            }
        }

        if (-not $targetSucceeded) {
            $failureCount++
        }
    }

    if ($candidateCount -eq 0) {
        Write-Status '未找到可用的 SpecialPurpose 目标，无需激活。' 'WARN'
    }
    Write-Status ('已完成。候选目标：{0}；已激活：{1}；失败：{2}。' -f $candidateCount, $wokenCount, $failureCount)
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
            Write-Status ('DisplayManager.Dispose 失败：{0}' -f $_.Exception.Message) 'WARN'
        }
    }
}
