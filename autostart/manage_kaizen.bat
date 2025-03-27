REM filepath: c:\Users\Bhuvan\Desktop\work\backup_test\Ace_kaizen_project\kaizen_project\autostart\manage_kaizen.bat
@echo off
setlocal EnableDelayedExpansion
title Kaizen Dashboard Manager

:: Set paths
set "PROJECT_PATH=%~dp0.."
set "LOG_PATH=%PROJECT_PATH%\logs"
cd /d "%PROJECT_PATH%"

:menu
cls
echo Kaizen Dashboard Manager
echo =====================
echo Current Path: %PROJECT_PATH%
echo.
echo 1. Start Server
echo 2. Stop Server
echo 3. View Logs
echo 4. Enable Auto-Start
echo 5. Disable Auto-Start
echo 6. Exit
echo.

set /p choice="Enter choice (1-6): "

if "%choice%"=="1" (
    echo Starting server...
    call "%~dp0start_kaizen.bat"
    if errorlevel 1 (
        echo Failed to start server! Check logs for details.
        pause
    )
)
if "%choice%"=="2" (
    echo Stopping server...
    taskkill /FI "WINDOWTITLE eq Kaizen Dashboard*" /F
    if errorlevel 1 (
        echo No server instance found running.
    ) else (
        echo Server stopped successfully.
    )
    timeout /t 2 >nul
)
if "%choice%"=="3" (
    if exist "%LOG_PATH%\server.log" (
        start "" notepad "%LOG_PATH%\server.log"
    ) else (
        echo No log file found!
        timeout /t 2 >nul
    )
)
if "%choice%"=="4" (
    if exist "%~dp0setup_autostart.bat" (
        call "%~dp0setup_autostart.bat"
    ) else (
        echo Setup script not found!
        timeout /t 2 >nul
    )
)
if "%choice%"=="5" (
    echo Disabling auto-start...
    schtasks /Delete /TN "Kaizen Dashboard" /F
    if errorlevel 1 (
        echo Task not found or access denied.
    ) else (
        echo Auto-start disabled successfully.
    )
    timeout /t 2 >nul
)
if "%choice%"=="6" (
    echo Exiting...
    exit /b
)

goto menu