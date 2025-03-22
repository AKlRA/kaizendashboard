@echo off
setlocal EnableDelayedExpansion
echo Fixing Kaizen Service...
echo ====================================

:: Set paths
set NSSM_PATH="C:\Program Files\nssm\win64\nssm.exe"
set PROJECT_PATH="C:\kaizen_project\kaizendashboard"
set VENV_PATH="%PROJECT_PATH%\venv"

:: Install waitress in virtual environment
echo Installing waitress...
call %VENV_PATH%\Scripts\activate
pip install waitress

:: Stop and remove existing service
echo Stopping and removing existing service...
net stop KaizenProject 2>nul
%NSSM_PATH% remove KaizenProject confirm 2>nul
sc delete KaizenProject 2>nul
timeout /t 10 /nobreak > nul

:: Install service using the batch file
echo Installing service...
%NSSM_PATH% install KaizenProject %VENV_PATH%\Scripts\python.exe
%NSSM_PATH% set KaizenProject AppParameters "%PROJECT_PATH%\run_waitress.bat"
%NSSM_PATH% set KaizenProject AppDirectory %PROJECT_PATH%
%NSSM_PATH% set KaizenProject DisplayName "Ace Kaizen Dashboard"
%NSSM_PATH% set KaizenProject Description "Ace Kaizen Project Web Application"

:: Configure environment
%NSSM_PATH% set KaizenProject AppEnvironmentExtra "PATH=%VENV_PATH%\Scripts;%PATH%"
%NSSM_PATH% set KaizenProject AppEnvironmentExtra "PYTHONPATH=%PROJECT_PATH%"
%NSSM_PATH% set KaizenProject AppEnvironmentExtra "DJANGO_SETTINGS_MODULE=kaizen_project.settings"

:: Configure logging
if not exist "%PROJECT_PATH%\logs" mkdir "%PROJECT_PATH%\logs"
%NSSM_PATH% set KaizenProject AppStdout "%PROJECT_PATH%\logs\service.log"
%NSSM_PATH% set KaizenProject AppStderr "%PROJECT_PATH%\logs\service.error.log"

:: Set service account
%NSSM_PATH% set KaizenProject ObjectName LocalSystem

:: Start service
echo Starting service...
%NSSM_PATH% start KaizenProject
timeout /t 5 /nobreak > nul

:: Check service status
echo Checking service status...
sc query KaizenProject

if exist "%PROJECT_PATH%\logs\service.error.log" (
    echo.
    echo Error Log Contents:
    type "%PROJECT_PATH%\logs\service.error.log"
)

echo.
echo Manual Test Steps:
echo 1. Try running: %PROJECT_PATH%\run_waitress.bat
echo 2. Check logs in: %PROJECT_PATH%\logs\
echo 3. Service status: sc query KaizenProject
pause

endlocal