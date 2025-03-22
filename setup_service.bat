@echo off
set DJANGO_SETTINGS_MODULE=kaizen_project.settings
set PYTHONPATH=C:\kaizen_project\kaizendashboard
call venv\Scripts\activate
python -m waitress-serve --host=0.0.0.0 --port=8000 kaizen_project.wsgi:application