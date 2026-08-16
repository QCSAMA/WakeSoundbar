@echo off
:: SPDX-License-Identifier: AGPL-3.0-only
:: Copyright (C) 2026 QCSAMA
setlocal
title WakeSoundbar Uninstaller

set "INSTALL_DIR=%ProgramData%\WakeSoundbar"

fltmc >nul 2>&1
if errorlevel 1 (
    echo [INFO] Requesting administrative privileges...
    powershell.exe -NoProfile -Command "$process = Start-Process -FilePath '%~f0' -Verb RunAs -Wait -PassThru; exit $process.ExitCode"
    if errorlevel 1 (
        echo [FAILED] The elevated uninstaller did not complete successfully.
        pause
        exit /b 1
    )
    exit /b 0
)

echo ===================================================
echo   WakeSoundbar Uninstaller
echo ===================================================
echo.

if not exist "%INSTALL_DIR%\.wakeSoundbar-install" (
    echo [FAILED] Installation marker not found. Nothing was removed.
    set "RESULT=1"
    goto :failure
)

echo [1/2] Removing scheduled task...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop';" ^
  "$task=Get-ScheduledTask -TaskName 'WakeSoundbar' -ErrorAction SilentlyContinue;" ^
  "if ($null -ne $task) { Stop-ScheduledTask -TaskName 'WakeSoundbar' -ErrorAction SilentlyContinue; Unregister-ScheduledTask -TaskName 'WakeSoundbar' -Confirm:$false }"
if errorlevel 1 (
    echo [FAILED] Failed to remove the scheduled task.
    set "RESULT=1"
    goto :failure
)

echo [2/2] Removing WakeSoundbar files...
rmdir /s /q "%INSTALL_DIR%"
if errorlevel 1 (
    echo [FAILED] Failed to remove %INSTALL_DIR%.
    set "RESULT=1"
    goto :failure
)

echo [SUCCESS] WakeSoundbar has been removed.
echo.
pause
exit /b 0

:failure
echo.
echo [FAILED] WakeSoundbar was not completely removed.
echo Check the message above and retry from an elevated command prompt.
echo.
pause
exit /b %RESULT%
