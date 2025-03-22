@echo off
echo ====================================
echo Ace Kaizen Service Management Console
echo ====================================

:menu
cls
echo Current Status: 
nssm status KaizenProject
echo.
echo Management Options:
echo ------------------
echo 1. Start Service
echo 2. Stop Service
echo 3. Restart Service
echo 4. View Detailed Status
echo 5. View Application Logs
echo 6. Pull Updates from Git
echo 7. View Service Settings
echo 8. Exit
echo.

set /p choice="Select option (1-8): "

if "%choice%"=="1" (
    echo Starting Kaizen service...
    nssm start KaizenProject
    timeout /t 2 >nul
    goto menu
)
if "%choice%"=="2" (
    echo Stopping Kaizen service...
    nssm stop KaizenProject
    timeout /t 2 >nul
    goto menu
)
if "%choice%"=="3" (
    echo Restarting Kaizen service...
    nssm restart KaizenProject
    timeout /t 2 >nul
    goto menu
)
if "%choice%"=="4" (
    echo.
    echo Detailed Status:
    echo ---------------
    nssm status KaizenProject
    echo.
    sc query KaizenProject
    pause
    goto menu
)
if "%choice%"=="5" (
    if exist server.log (
        start notepad server.log
    ) else (
        echo Log file not found!
        timeout /t 2 >nul
    )
    goto menu
)
if "%choice%"=="6" (
    call pull_updates.bat
    goto menu
)
if "%choice%"=="7" (
    echo.
    echo Service Configuration:
    echo --------------------
    nssm get KaizenProject AppParameters
    nssm get KaizenProject AppDirectory
    nssm get KaizenProject DisplayName
    nssm get KaizenProject Description
    pause
    goto menu
)
if "%choice%"=="8" (
    exit
)

goto menu