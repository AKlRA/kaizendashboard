@echo off
setlocal EnableDelayedExpansion
title Kaizen Dashboard Setup
cd /d "%~dp0"

:: Set environment variables
set DJANGO_SETTINGS_MODULE=kaizen_project.settings
set PYTHONPATH=%cd%
set LOG_PATH=%cd%\logs

:: Create necessary directories
if not exist "%cd%\media" mkdir "%cd%\media"
if not exist "%cd%\static" mkdir "%cd%\static"
if not exist "%LOG_PATH%" mkdir "%LOG_PATH%"

:: Activate virtual environment
call venv\Scripts\activate

:: Update dependencies
python -m pip install --upgrade pip
pip install -r requirements.txt --no-cache-dir

:: Setup database and static files
python manage.py migrate --noinput
python manage.py collectstatic --noinput --clear

echo Setup completed successfully!
pause
exit /b 0