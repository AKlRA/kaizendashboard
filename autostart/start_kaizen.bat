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

:: Activate virtual environment
call venv\Scripts\activate

:: Display server information
echo Server starting on http://acekaizen.local:8000
echo Your server IP is:
ipconfig | findstr "IPv4"
echo Access URLs:
echo Local: http://localhost:8000
echo Network: http://acekaizen.local:8000

:: Start server with improved reliability and static file serving
python -c "from waitress import serve; import logging; from django.core.wsgi import get_wsgi_application; from django.conf import settings; from django.contrib.staticfiles.handlers import StaticFilesHandler; logging.basicConfig(level=logging.INFO); application = StaticFilesHandler(get_wsgi_application()) if settings.DEBUG else get_wsgi_application(); print('Server started successfully!'); serve(application, host='0.0.0.0', port=8000, threads=4)" >> "%LOG_PATH%\server.log" 2>> "%LOG_PATH%\error.log"

echo Press any key to return to menu...
pause > nul
exit /b 0