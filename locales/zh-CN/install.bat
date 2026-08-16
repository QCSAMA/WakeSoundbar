@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
title WakeSoundbar CN Installer

set "INSTALL_DIR=%ProgramData%\WakeSoundbar"

fltmc >nul 2>&1
if errorlevel 1 (
    call :say "5q2j5Zyo6K+35rGC566h55CG5ZGY5p2D6ZmQLi4u"
    powershell.exe -NoProfile -Command "$process = Start-Process -FilePath '%~f0' -Verb RunAs -Wait -PassThru; exit $process.ExitCode"
    if errorlevel 1 (
        call :say "5o+Q5p2D5ZCO55qE5a6J6KOF56iL5bqP5rKh5pyJ5oiQ5Yqf5a6M5oiQ44CC"
        call :say "6K+35p+l55yL5LiK5pa55L+h5oGv44CC"
        call :wait
        exit /b 1
    )
    exit /b 0
)

echo ===================================================
call :say "V2FrZVNvdW5kYmFyIOWuieijheeoi+W6jw=="
echo ===================================================
echo.

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
if errorlevel 1 (
    call :say "5peg5rOV5Yib5bu65a6J6KOF55uu5b2V44CC"
    set "RESULT=1"
    goto :failure
)

call :say "WzEvM10g5q2j5Zyo5aSN5Yi25qC45b+D6ISa5pysLi4u"
copy /y "%~dp0WakeSoundbar.ps1" "%INSTALL_DIR%\WakeSoundbar.ps1" >nul
if errorlevel 1 (
    call :say "5peg5rOV5aSN5Yi2IFdha2VTb3VuZGJhci5wczHjgII="
    set "RESULT=1"
    goto :failure
)
>"%INSTALL_DIR%\.wakeSoundbar-install" echo WakeSoundbar installation marker

call :say "WzIvM10g5q2j5Zyo5rOo5YaM6K6h5YiS5Lu75YqhLi4u"
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
  "if (-not (Get-ScheduledTask -TaskName 'WakeSoundbar' -ErrorAction SilentlyContinue)) { throw 'Scheduled task registration verification failed.' }"
if errorlevel 1 (
    call :say "5peg5rOV5rOo5YaM6K6h5YiS5Lu75Yqh44CC"
    set "RESULT=1"
    goto :failure
)

call :say "WzMvM10g5q2j5Zyo5omn6KGM6aaW5qyh56Gs5Lu25o+h5omL5rWL6K+VLi4u"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%INSTALL_DIR%\WakeSoundbar.ps1" -InteractiveSelection
set "RUN_RESULT=%errorlevel%"
if not "%RUN_RESULT%"=="0" (
    call :say "6aaW5qyh5rWL6K+V5aSx6LSl44CC"
    call :say "6K+35p+l55yL5LiK5pa555qE6ZSZ6K+v5L+h5oGv44CC"
    set "RESULT=%RUN_RESULT%"
    goto :failure
)

echo.
call :say "V2FrZVNvdW5kYmFyIOW3suWuieijheWujOaIkOOAgg=="
call :say "55m75b2V5ZCO5Lya5qOA5p+l5bm25ZSk6YaSIEhETUkg6Z+z6aKR6ZO+6Lev44CC"
call :wait
exit /b 0

:failure
echo.
call :say "V2FrZVNvdW5kYmFyIOWuieijheayoeacieWujOaIkOOAgg=="
call :say "6K+35p+l55yL5LiK5pa55L+h5oGv77yM5bm25Lul566h55CG5ZGY6Lqr5Lu96YeN6K+V44CC"
call :wait
exit /b %RESULT%

:say
powershell.exe -NoProfile -Command "[Console]::OutputEncoding=[Text.Encoding]::UTF8; [Console]::WriteLine([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('%~1')))"
exit /b 0

:wait
    call :say "6K+35oyJ5Lu75oSP6ZSu57un57utLi4u"
pause >nul
exit /b 0
