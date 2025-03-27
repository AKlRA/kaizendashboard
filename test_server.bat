@echo off
cd /d "%~dp0"
call venv\Scripts\activate
set DJANGO_SETTINGS_MODULE=kaizen_project.settings
set PYTHONPATH=%CD%
waitress-serve --host=0.0.0.0 --port=8000 kaizen_project.wsgi:application