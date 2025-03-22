@echo off
echo Setting up Kaizen Dashboard Service...
echo ====================================

:: Set paths
set NSSM_PATH="C:\Program Files\nssm-2.24-101-g897c7ad\win64\nssm.exe"
set PROJECT_PATH="C:\Users\Bhuvan\Desktop\work\backup_test\Ace_kaizen_project\kaizen_project"
set PYTHON_PATH="C:\Python312\python.exe"

:: Verify Python installation
echo Verifying Python installation...
%PYTHON_PATH% --version > nul 2>&1
if errorlevel 1 (
    echo Error: Python not found at %PYTHON_PATH%
    goto :error
)

:: Verify waitress installation
echo Checking waitress installation...
%PYTHON_PATH% -c "import waitress" > nul 2>&1
if errorlevel 1 (
    echo Installing waitress...
    %PYTHON_PATH% -m pip install waitress
)

:: Create logs directory
if not exist "%PROJECT_PATH%\logs" mkdir "%PROJECT_PATH%\logs"

:: Remove existing service completely
echo Cleaning up existing service...
net stop KaizenProject 2>nul
%NSSM_PATH% remove KaizenProject confirm 2>nul
sc delete KaizenProject 2>nul
timeout /t 10 /nobreak > nul

:: Install new service
echo Installing new service...
%NSSM_PATH% install KaizenProject %PYTHON_PATH%
if errorlevel 1 goto :error

:: Configure service with detailed error checking
echo Configuring service...
%NSSM_PATH% set KaizenProject AppParameters "-m waitress-serve --host=0.0.0.0 --port=8000 kaizen_project.wsgi:application"
%NSSM_PATH% set KaizenProject AppDirectory %PROJECT_PATH%
%NSSM_PATH% set KaizenProject DisplayName "Ace Kaizen Dashboard"
%NSSM_PATH% set KaizenProject Description "Ace Kaizen Project Web Application"
%NSSM_PATH% set KaizenProject ObjectName LocalSystem
%NSSM_PATH% set KaizenProject Start SERVICE_AUTO_START

:: Configure logging
echo Setting up logging...
%NSSM_PATH% set KaizenProject AppStdout "%PROJECT_PATH%\logs\service.log"
%NSSM_PATH% set KaizenProject AppStderr "%PROJECT_PATH%\logs\service.error.log"

:: Set environment with system Python path
echo Configuring environment...
%NSSM_PATH% set KaizenProject AppEnvironmentExtra PATH=%PATH%;C:\Python312;C:\Python312\Scripts
%NSSM_PATH% set KaizenProject AppEnvironmentExtra PYTHONPATH=%PROJECT_PATH%
%NSSM_PATH% set KaizenProject AppEnvironmentExtra DJANGO_SETTINGS_MODULE=kaizen_project.settings

:: Start the service with error checking
echo Starting service...
%NSSM_PATH% start KaizenProject
timeout /t 5 /nobreak > nul

:: Verify service status
echo Checking service status...
sc query KaizenProject | findstr "RUNNING"
if errorlevel 1 (
    echo Service failed to start. Checking logs...
    if exist "%PROJECT_PATH%\logs\service.error.log" type "%PROJECT_PATH%\logs\service.error.log"
    goto :error
)

goto :success

:error
echo ====================================
echo ERROR: Service installation failed!
echo 1. Check if Python is installed correctly
echo 2. Verify waitress is installed
echo 3. Run 'services.msc' to check service status
echo 4. Check logs in: %PROJECT_PATH%\logs\
goto :end

:success
echo ====================================
echo Service installed successfully!
echo Access the application at:
echo http://localhost:8000

:end
echo ====================================
pause