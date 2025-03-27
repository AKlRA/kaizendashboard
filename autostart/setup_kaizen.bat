@echo off
setlocal EnableDelayedExpansion
title Kaizen Dashboard Setup
cd /d "%~dp0\.."

:: Set environment variables
set DJANGO_SETTINGS_MODULE=kaizen_project.settings
set PYTHONPATH=%cd%
set LOG_PATH=%cd%\logs

:: Create logs directory if not exists
if not exist "%LOG_PATH%" mkdir "%LOG_PATH%"

:: Log setup time
echo [%date% %time%] Running Kaizen Dashboard Setup... >> "%LOG_PATH%\setup.log"

:: Activate virtual environment and update
call venv\Scripts\activate

:: Fix pip and requirements
python -m pip install --upgrade pip
pip install -r requirements.txt --no-cache-dir

:: Update database
python manage.py migrate --noinput
python manage.py collectstatic --noinput --clear

echo Setup completed successfully!
pause
exit /b 0