@echo off
echo Fixing Kaizen Service...
echo ====================================

:: Set paths
set NSSM_PATH="C:\Program Files\nssm\win64\nssm.exe"
set PROJECT_PATH="C:\kaizen_project\kaizendashboard"
set VENV_PATH="%PROJECT_PATH%\venv"

:: Verify waitress installation
echo Checking waitress installation...
"%VENV_PATH%\Scripts\python.exe" -c "import waitress" > nul 2>&1
if errorlevel 1 (
    echo Installing waitress...
    "%VENV_PATH%\Scripts\pip.exe" install waitress
)

:: Stop and remove existing service
echo Stopping and removing existing service...
%NSSM_PATH% stop KaizenProject
%NSSM_PATH% remove KaizenProject confirm
sc delete KaizenProject
timeout /t 5 /nobreak > nul

:: Install service with virtual environment Python
echo Installing service...
%NSSM_PATH% install KaizenProject "%VENV_PATH%\Scripts\python.exe"

:: Configure service
echo Configuring service...
%NSSM_PATH% set KaizenProject AppParameters "-m waitress.cli --listen=0.0.0.0:8000 kaizen_project.wsgi:application"
%NSSM_PATH% set KaizenProject AppDirectory %PROJECT_PATH%
%NSSM_PATH% set KaizenProject DisplayName "Ace Kaizen Dashboard"
%NSSM_PATH% set KaizenProject Description "Ace Kaizen Project Web Application"

:: Set environment variables
%NSSM_PATH% set KaizenProject AppEnvironmentExtra VIRTUAL_ENV=%VENV_PATH%
%NSSM_PATH% set KaizenProject AppEnvironmentExtra PATH=%VENV_PATH%\Scripts;%PATH%
%NSSM_PATH% set KaizenProject AppEnvironmentExtra PYTHONPATH=%PROJECT_PATH%

:: Configure logging
if not exist "%PROJECT_PATH%\logs" mkdir "%PROJECT_PATH%\logs"
%NSSM_PATH% set KaizenProject AppStdout "%PROJECT_PATH%\logs\service.log"
%NSSM_PATH% set KaizenProject AppStderr "%PROJECT_PATH%\logs\service.error.log"

:: Set service account
%NSSM_PATH% set KaizenProject ObjectName LocalSystem
%NSSM_PATH% set KaizenProject Start SERVICE_AUTO_START

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
echo Service Configuration:
echo 1. Python Path: %VENV_PATH%\Scripts\python.exe
echo 2. Project Path: %PROJECT_PATH%
echo 3. Log Files: %PROJECT_PATH%\logs\
pause