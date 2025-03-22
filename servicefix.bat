@echo off
echo Fixing Kaizen Service...
echo ====================================

:: Set paths
set NSSM_PATH="C:\Program Files\nssm\win64\nssm.exe"
set PROJECT_PATH="C:\kaizen_project\kaizendashboard"

:: Stop and remove existing service
echo Stopping and removing existing service...
%NSSM_PATH% stop KaizenProject
%NSSM_PATH% remove KaizenProject confirm
sc delete KaizenProject
timeout /t 5 /nobreak > nul

:: Clean up any residual service entries
sc query KaizenProject > nul 2>&1
if not errorlevel 1 (
    echo Forcing service removal...
    sc stop KaizenProject
    sc delete KaizenProject
    timeout /t 5 /nobreak > nul
)

:: Install service with specific user account
echo Installing service...
%NSSM_PATH% install KaizenProject "C:\Users\administrator.AMSLINDIA\AppData\Local\Programs\Python\Python313\python.exe"
%NSSM_PATH% set KaizenProject AppParameters "-m waitress-serve --host=0.0.0.0 --port=8000 kaizen_project.wsgi:application"
%NSSM_PATH% set KaizenProject AppDirectory %PROJECT_PATH%
%NSSM_PATH% set KaizenProject DisplayName "Ace Kaizen Dashboard"
%NSSM_PATH% set KaizenProject Description "Ace Kaizen Project Web Application"

:: Set service to run as Network Service
%NSSM_PATH% set KaizenProject ObjectName "NT AUTHORITY\NetworkService"
%NSSM_PATH% set KaizenProject Start SERVICE_AUTO_START

:: Configure logging
echo Setting up logging...
%NSSM_PATH% set KaizenProject AppStdout "%PROJECT_PATH%\logs\service.log"
%NSSM_PATH% set KaizenProject AppStderr "%PROJECT_PATH%\logs\service.error.log"

:: Set required permissions
echo Setting permissions...
icacls "%PROJECT_PATH%" /grant "NT AUTHORITY\NetworkService":(OI)(CI)F /T

:: Start service
echo Starting service...
%NSSM_PATH% start KaizenProject
timeout /t 5 /nobreak > nul

:: Check service status
sc query KaizenProject

:: Display logs if service fails
if not exist "%PROJECT_PATH%\logs\service.error.log" goto :check_status
type "%PROJECT_PATH%\logs\service.error.log"

:check_status
echo.
echo Service Status:
sc query KaizenProject | findstr "STATE"
echo.
echo If service is still not running, check these:
echo 1. Run 'sc query KaizenProject' for status
echo 2. Check logs in %PROJECT_PATH%\logs\
echo 3. Verify Python path: C:\Python312\python.exe
echo 4. Test Django manually: python manage.py runserver
pause