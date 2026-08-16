@echo off
:: SPDX-License-Identifier: AGPL-3.0-only
:: Copyright (C) 2026 QCSAMA
setlocal
title WakeSoundbar Installer

set "INSTALL_DIR=%ProgramData%\WakeSoundbar"
set "TASK_NAME=WakeSoundbar"

fltmc >nul 2>&1
if errorlevel 1 (
    echo [INFO] Requesting administrative privileges...
    powershell.exe -NoProfile -Command "$process = Start-Process -FilePath '%~f0' -Verb RunAs -Wait -PassThru; exit $process.ExitCode"
    if errorlevel 1 (
        echo [FAILED] The elevated installer did not complete successfully.
        pause
        exit /b 1
    )
    exit /b 0
)

echo ===================================================
echo   WakeSoundbar Installer
echo ===================================================
echo.

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
if errorlevel 1 (
    echo [FAILED] Failed to create %INSTALL_DIR%.
    set "RESULT=1"
    goto :failure
)

echo [1/3] Copying core script...
copy /y "%~dp0WakeSoundbar.ps1" "%INSTALL_DIR%\WakeSoundbar.ps1" >nul
if errorlevel 1 (
    echo [FAILED] Failed to copy WakeSoundbar.ps1.
    set "RESULT=1"
    goto :failure
)
>"%INSTALL_DIR%\.wakeSoundbar-install" echo WakeSoundbar installation marker

echo [2/3] Registering scheduled task...
set "WakeSoundbarInstallDir=%INSTALL_DIR%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop';" ^
  "$dir=$env:WakeSoundbarInstallDir;" ^
  "$script=Join-Path $dir 'WakeSoundbar.ps1';" ^
  "$user=[Security.Principal.WindowsIdentity]::GetCurrent().Name;" ^
  "$scriptArg='-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File ' + [char]34 + $script + [char]34;" ^
  "$action=New-ScheduledTaskAction -Execute (Join-Path $PSHOME 'powershell.exe') -Argument $scriptArg;" ^
  "$trigger=New-ScheduledTaskTrigger -AtLogOn -User $user;" ^
  "$settings=New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 2);" ^
  "$principal=New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Highest;" ^
  "$existing=Get-ScheduledTask -TaskName 'WakeSoundbar' -ErrorAction SilentlyContinue;" ^
  "if ($null -ne $existing) { Stop-ScheduledTask -TaskName 'WakeSoundbar' -ErrorAction SilentlyContinue; Unregister-ScheduledTask -TaskName 'WakeSoundbar' -Confirm:$false -ErrorAction Stop };" ^
  "Register-ScheduledTask -TaskName 'WakeSoundbar' -Action $action -Trigger $trigger -Settings $settings -Principal $principal | Out-Null;" ^
  "if (-not (Get-ScheduledTask -TaskName 'WakeSoundbar' -ErrorAction SilentlyContinue)) { throw 'Scheduled task was not registered.' }"
if errorlevel 1 (
    echo [FAILED] Failed to register the scheduled task.
    set "RESULT=1"
    goto :failure
)

echo [3/3] Running initial hardware handshake test...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%INSTALL_DIR%\WakeSoundbar.ps1" -InteractiveSelection
set "RUN_RESULT=%errorlevel%"
if not "%RUN_RESULT%"=="0" (
    echo [FAILED] Initial test returned exit code %RUN_RESULT%.
    echo        See the error output above for details.
    set "RESULT=%RUN_RESULT%"
    goto :failure
)

echo.
echo [SUCCESS] WakeSoundbar installed successfully.
echo The pipeline will be checked automatically at logon for this user.
echo.
pause
exit /b 0

:failure
echo.
echo [FAILED] WakeSoundbar installation did not complete.
echo Review the error message above and retry as administrator.
echo.
pause
exit /b %RESULT%
