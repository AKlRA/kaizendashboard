REM filepath: c:\Users\Bhuvan\Desktop\work\backup_test\Ace_kaizen_project\kaizen_project\uninstall_service.bat
@echo off
echo Removing Kaizen Dashboard Service...

:: Stop and remove service
net stop KaizenDashboard
sc delete KaizenDashboard

echo Service removed.
pause