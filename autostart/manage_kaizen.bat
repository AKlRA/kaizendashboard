REM filepath: c:\Users\Bhuvan\Desktop\work\backup_test\Ace_kaizen_project\kaizen_project\autostart\manage_kaizen.bat
@echo off
title Kaizen Dashboard Manager

:menu
cls
echo Kaizen Dashboard Manager
echo =====================
echo 1. Start Server
echo 2. Stop Server
echo 3. View Logs
echo 4. Enable Auto-Start
echo 5. Disable Auto-Start
echo 6. Exit
echo.

set /p choice="Enter choice (1-6): "

if "%choice%"=="1" call :start_server
if "%choice%"=="2" call :stop_server
if "%choice%"=="3" call :view_logs
if "%choice%"=="4" call setup_autostart.bat
if "%choice%"=="5" schtasks /Delete /TN "Kaizen Dashboard" /F
if "%choice%"=="6" exit

goto menu

:start_server
call start_kaizen.bat
goto :eof

:stop_server
taskkill /FI "WINDOWTITLE eq Kaizen Dashboard*" /F
goto :eof

:view_logs
start "" notepad "..\logs\server.log"
goto :eof