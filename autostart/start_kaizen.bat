REM filepath: c:\Users\Bhuvan\Desktop\work\backup_test\Ace_kaizen_project\kaizen_project\autostart\start_kaizen.bat
@echo off
setlocal EnableDelayedExpansion
title Kaizen Dashboard Server
cd /d "%~dp0\.."

:: Set environment variables
set DJANGO_SETTINGS_MODULE=kaizen_project.settings
set PYTHONPATH=%cd%
set LOG_PATH=%cd%\logs

:: Create logs directory if not exists
if not exist "%LOG_PATH%" mkdir "%LOG_PATH%"

:: Log startup time
echo [%date% %time%] Starting Kaizen Dashboard... >> "%LOG_PATH%\startup.log"

:: Kill any existing server instances
taskkill /FI "WINDOWTITLE eq Kaizen Dashboard*" /F >nul 2>&1

:: Activate virtual environment and update
call venv\Scripts\activate

:: Fix pip and requirements
python -m pip install --upgrade pip
pip install -r requirements.txt --no-cache-dir

:: Update database
python manage.py migrate --noinput
python manage.py collectstatic --noinput --clear

:: Start server in minimized window
start "Kaizen Dashboard" /min cmd /c "python -m waitress-serve --host=0.0.0.0 --port=8000 kaizen_project.wsgi:application >> "%LOG_PATH%\server.log" 2>> "%LOG_PATH%\error.log""

:: Verify server started
timeout /t 3 > nul
netstat -ano | findstr ":8000" > nul
if errorlevel 1 (
    echo Server failed to start! Check logs for details.
    type "%LOG_PATH%\error.log"
    pause
    exit /b 1
) else (
    echo.
    echo Server started successfully!
    echo Access URLs:
    echo - Local: http://localhost:8000
    echo - Network: http://%COMPUTERNAME%:8000
    echo.
    echo Press any key to return to menu...
    pause > nul
)

exit /b 0