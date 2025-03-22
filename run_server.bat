@echo off
echo Starting Kaizen Project Server...
cd /d "%~dp0"

@echo off
echo Starting Kaizen Service...
cd /d "%~dp0"

:: Set environment variables
set DJANGO_SETTINGS_MODULE=kaizen_project.settings
set PYTHONPATH=%cd%

:: Activate virtual environment
call venv\Scripts\activate

:: Pull latest changes from Git
git pull origin main

:: Install/update requirements
pip install -r requirements.txt

:: Run database migrations
python manage.py migrate --noinput

:: Collect static files
python manage.py collectstatic --noinput

:: Start server with logging
python -c "from waitress import serve; import logging; logging.basicConfig(filename='server.log', level=logging.INFO, format='%%Y-%%m-%%d %%H:%%M:%%S %%p: %%(message)s'); from kaizen_project.wsgi import application; print('Server started successfully!'); serve(application, host='0.0.0.0', port=8000, threads=4)"
pause