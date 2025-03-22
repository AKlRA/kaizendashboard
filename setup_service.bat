@echo off
set DJANGO_SETTINGS_MODULE=kaizen_project.settings
set PYTHONPATH=C:\kaizen_project\kaizendashboard
call venv\Scripts\activate

:: Start Waitress server
python -m waitress.cli --listen=*:8000 kaizen_project.wsgi:application