@echo off
echo Starting Kaizen Project Server...
cd /d "%~dp0"

@echo off
echo Starting Kaizen Project Server...
cd /d "%~dp0"

:: Create and activate virtual environment
if not exist venv (
    python -m venv venv
)
call venv\Scripts\activate

:: Install requirements
pip install -r requirements.txt

:: Run Django commands
python manage.py collectstatic --noinput --clear
python manage.py migrate

:: Start server using waitress
python -c "from waitress import serve; from kaizen_project.wsgi import application; serve(application, host='0.0.0.0', port=8000)"
pause