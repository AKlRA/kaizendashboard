@echo off
setlocal EnableDelayedExpansion
echo Fixing Kaizen Service...
echo ====================================

:: Set paths
set NSSM_PATH="C:\Program Files\nssm\win64\nssm.exe"
set PROJECT_PATH="C:\kaizen_project\kaizendashboard"
set PYTHON_PATH="C:\Users\administrator.AMSLINDIA\AppData\Local\Programs\Python\Python313\python.exe"
set VENV_PATH="%PROJECT_PATH%\venv"

:: Stop and remove existing service
echo Stopping and removing existing service...
net stop KaizenProject 2>nul
%NSSM_PATH% remove KaizenProject confirm 2>nul
sc delete KaizenProject 2>nul
timeout /t 10 /nobreak > nul

:: Install service with venv Python
echo Installing service...
%NSSM_PATH% install KaizenProject "%VENV_PATH%\Scripts\python.exe"
if errorlevel 1 goto :error

:: Configure service
echo Configuring service...
%NSSM_PATH% set KaizenProject AppParameters "-m waitress-serve --host=0.0.0.0 --port=8000 kaizen_project.wsgi:application"
%NSSM_PATH% set KaizenProject AppDirectory %PROJECT_PATH%
%NSSM_PATH% set KaizenProject DisplayName "Ace Kaizen Dashboard"
%NSSM_PATH% set KaizenProject Description "Ace Kaizen Project Web Application"

:: Configure environment
echo Setting up environment...
%NSSM_PATH% set KaizenProject AppEnvironmentExtra PYTHONPATH=%PROJECT_PATH%
%NSSM_PATH% set KaizenProject AppEnvironmentExtra PATH=%PATH%;%VENV_PATH%\Scripts;C:\Python312;C:\Python312\Scripts
%NSSM_PATH% set KaizenProject AppEnvironmentExtra DJANGO_SETTINGS_MODULE=kaizen_project.settings
%NSSM_PATH% set KaizenProject AppEnvironmentExtra VIRTUAL_ENV=%VENV_PATH%

:: Configure logging
if not exist "%PROJECT_PATH%\logs" mkdir "%PROJECT_PATH%\logs"
%NSSM_PATH% set KaizenProject AppStdout "%PROJECT_PATH%\logs\service.log"
%NSSM_PATH% set KaizenProject AppStderr "%PROJECT_PATH%\logs\service.error.log"

:: Set service account and permissions
%NSSM_PATH% set KaizenProject ObjectName LocalSystem
%NSSM_PATH% set KaizenProject Start SERVICE_AUTO_START

:: Grant permissions
echo Setting permissions...
icacls "%PROJECT_PATH%" /grant "LocalSystem":(OI)(CI)F /T
icacls "%PROJECT_PATH%\logs" /grant "LocalSystem":(OI)(CI)F /T

:: Start service
echo Starting service...
%NSSM_PATH% start KaizenProject
timeout /t 5 /nobreak > nul

:: Check service status
echo Checking service status...
sc query KaizenProject

:: Display logs if service fails
if exist "%PROJECT_PATH%\logs\service.error.log" (
    echo.
    echo Error Log Contents:
    type "%PROJECT_PATH%\logs\service.error.log"
)

echo.
echo Troubleshooting Steps:
echo 1. Check if virtual environment is activated
echo 2. Verify python path: %VENV_PATH%\Scripts\python.exe
echo 3. Test Django manually: %VENV_PATH%\Scripts\python.exe manage.py runserver
echo 4. Check log files in: %PROJECT_PATH%\logs\
echo 5. Run: sc qc KaizenProject
pause

:error
echo Error occurred during service installation!
exit /b 1