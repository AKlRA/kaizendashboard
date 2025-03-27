@echo off
cd /d "C:\Users\Bhuvan\Desktop\work\backup_test\Ace_kaizen_project\kaizen_project\"
set PATH=C:\Users\Bhuvan\Desktop\work\backup_test\Ace_kaizen_project\kaizen_project\venv\Scripts;%PATH%
set PYTHONPATH=C:\Users\Bhuvan\Desktop\work\backup_test\Ace_kaizen_project\kaizen_project\
set DJANGO_SETTINGS_MODULE=kaizen_project.settings
call "C:\Users\Bhuvan\Desktop\work\backup_test\Ace_kaizen_project\kaizen_project\venv\Scripts\activate.bat"
echo Starting Kaizen Dashboard Service at %date% %time% > "C:\Users\Bhuvan\Desktop\work\backup_test\Ace_kaizen_project\kaizen_project\logs\service.log"
"C:\Users\Bhuvan\Desktop\work\backup_test\Ace_kaizen_project\kaizen_project\venv\Scripts\python.exe" -m waitress-serve --host=0.0.0.0 --port=8000 kaizen_project.wsgi:application >> "C:\Users\Bhuvan\Desktop\work\backup_test\Ace_kaizen_project\kaizen_project\logs\service.log" 2>> "C:\Users\Bhuvan\Desktop\work\backup_test\Ace_kaizen_project\kaizen_project\logs\service_error.log"
