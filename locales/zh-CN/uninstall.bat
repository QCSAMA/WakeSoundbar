@echo off
:: SPDX-License-Identifier: AGPL-3.0-only
setlocal EnableExtensions
chcp 65001 >nul
title WakeSoundbar Uninstall
set "WakeSoundbarWrapperPath=%~f0"
fltmc >nul 2>&1
if errorlevel 1 (
    echo [INFO] Requesting administrative privileges...
    powershell.exe -NoProfile -Command "$ErrorActionPreference='Stop'; try { $p=Start-Process -FilePath $env:WakeSoundbarWrapperPath -Verb RunAs -Wait -PassThru; exit $p.ExitCode } catch { Write-Host $_.Exception.Message; exit 1 }"
    if errorlevel 1 (
        echo [FAILED] Elevation or setup failed.
        pause
        exit /b 1
    )
    exit /b 0
)
call :say "V2FrZVNvdW5kYmFyIOWNuOi9veeoi+W6jw=="
set "SETUP=%~dp0Setup-WakeSoundbar.ps1"
if not exist "%SETUP%" set "SETUP=%~dp0..\..\Setup-WakeSoundbar.ps1"
if not exist "%SETUP%" (
    echo [FAILED] Setup-WakeSoundbar.ps1 is missing. Extract the entire release ZIP.
    pause
    exit /b 1
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SETUP%" -Mode Uninstall -SourceDirectory "%~dp0."
set "RESULT=%errorlevel%"
pause
exit /b %RESULT%

:say
powershell.exe -NoProfile -Command "[Console]::OutputEncoding=[Text.Encoding]::UTF8; [Console]::WriteLine([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('%~1')))"
exit /b 0
