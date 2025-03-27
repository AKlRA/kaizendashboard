REM filepath: c:\Users\Bhuvan\Desktop\work\backup_test\Ace_kaizen_project\kaizen_project\autostart\start_kaizen.bat
@echo off
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

:: Activate virtual environment and update
call venv\Scripts\activate
git pull origin main
pip install -r requirements.txt
python manage.py migrate --noinput
python manage.py collectstatic --noinput

:: Start server in minimized window
start "Kaizen Dashboard" /min cmd /c "python -m waitress-serve --host=0.0.0.0 --port=8000 kaizen_project.wsgi:application >> %LOG_PATH%\server.log 2>> %LOG_PATH%\error.log"