@echo off
chcp 65001 >nul
cd /d "%~dp0"
where pwsh >nul 2>nul && (pwsh -NoLogo -ExecutionPolicy Bypass -File "%~dp0start.ps1" & goto :done)
powershell.exe -NoLogo -ExecutionPolicy Bypass -File "%~dp0start.ps1"
:done
echo.
echo ==== ?????????? ====
pause >nul