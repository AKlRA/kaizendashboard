@echo off
echo Restarting Kaizen Project Server...
cd /d "%~dp0"

:: Activate virtual environment
call venv\Scripts\activate

:: Start server with verbose output
echo Server starting on http://acekaizen.local:8000
echo Your server IP is:
ipconfig | findstr "IPv4"
echo Access URLs:
echo Local: http://localhost:8000
echo Network: http://acekaizen.local:8000
echo Press Ctrl+C to stop the server

:: Start server with basic logging
python -c "from waitress import serve; import logging; logging.basicConfig(level=logging.INFO); from kaizen_project.wsgi import application; print('Server started successfully!'); serve(application, host='0.0.0.0', port=8000, threads=4)"
pause