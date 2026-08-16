@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
title WakeSoundbar CN Uninstaller

set "INSTALL_DIR=%ProgramData%\WakeSoundbar"

fltmc >nul 2>&1
if errorlevel 1 (
    call :say "5q2j5Zyo6K+35rGC566h55CG5ZGY5p2D6ZmQLi4u"
    powershell.exe -NoProfile -Command "$process = Start-Process -FilePath '%~f0' -Verb RunAs -Wait -PassThru; exit $process.ExitCode"
    if errorlevel 1 (
        call :say "5o+Q5p2D5ZCO55qE5Y246L2956iL5bqP5rKh5pyJ5oiQ5Yqf5a6M5oiQ44CC"
        call :say "6K+35p+l55yL5LiK5pa555qE6ZSZ6K+v5L+h5oGv44CC"
        call :wait
        exit /b 1
    )
    exit /b 0
)

echo ===================================================
call :say "V2FrZVNvdW5kYmFyIOWNuOi9veeoi+W6jw=="
echo ===================================================
echo.

if not exist "%INSTALL_DIR%\.wakeSoundbar-install" (
    call :say "5pyq5om+5Yiw5a6J6KOF5qCH6K6w77yM5rKh5pyJ5Yig6Zmk5Lu75L2V5YaF5a6544CC"
    set "RESULT=1"
    goto :failure
)

call :say "5q2j5Zyo5Yig6Zmk6K6h5YiS5Lu75YqhLi4u"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop';" ^
  "$task=Get-ScheduledTask -TaskName 'WakeSoundbar' -ErrorAction SilentlyContinue;" ^
  "if ($null -ne $task) { Stop-ScheduledTask -TaskName 'WakeSoundbar' -ErrorAction SilentlyContinue; Unregister-ScheduledTask -TaskName 'WakeSoundbar' -Confirm:$false }"
if errorlevel 1 (
    call :say "5peg5rOV5Yig6Zmk6K6h5YiS5Lu75Yqh44CC"
    set "RESULT=1"
    goto :failure
)

call :say "5q2j5Zyo5Yig6ZmkIFdha2VTb3VuZGJhciDmlofku7YuLi4="
rmdir /s /q "%INSTALL_DIR%"
if errorlevel 1 (
    call :say "5peg5rOV5Yig6Zmk5a6J6KOF55uu5b2V44CC"
    set "RESULT=1"
    goto :failure
)

call :say "V2FrZVNvdW5kYmFyIOW3suWNuOi9veOAgg=="
call :wait
exit /b 0

:failure
echo.
call :say "V2FrZVNvdW5kYmFyIOayoeacieWujOWFqOWNuOi9veOAgg=="
call :say "6K+35p+l55yL5LiK5pa55L+h5oGv77yM5bm25Zyo566h55CG5ZGY5ZG95Luk5o+Q56S656ym5Lit6YeN6K+V44CC"
call :wait
exit /b %RESULT%

:say
powershell.exe -NoProfile -Command "[Console]::OutputEncoding=[Text.Encoding]::UTF8; [Console]::WriteLine([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('%~1')))"
exit /b 0

:wait
call :say "6K+35oyJ5Lu75oSP6ZSu57un57utLi4u"
pause >nul
exit /b 0
