@echo off
setlocal EnableDelayedExpansion

echo Setting up Kaizen Dashboard Service...
echo ====================================

:: Set paths
set NSSM_PATH="C:\Program Files\nssm\win64\nssm.exe"
set PROJECT_PATH="C:\kaizen_project\kaizendashboard"
set PYTHON_PATH="C:\Users\administrator.AMSLINDIA\AppData\Local\Programs\Python\Python313\python.exe"

:: Get server IP for network access
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4 Address"') do (
    set SERVER_IP=%%a
    set SERVER_IP=!SERVER_IP:~1!
    goto :found_ip
)
:found_ip

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

:: Create/Update .env file
echo Creating environment configuration...
(
echo DEBUG=False
echo SECRET_KEY=your-secure-secret-key-here
echo ALLOWED_HOSTS=localhost,127.0.0.1,%SERVER_IP%
echo.
echo # Database settings
echo DB_NAME=kaizen_db
echo DB_USER=kaizen_user
echo DB_PASSWORD=your_password_here
echo DB_HOST=localhost
echo DB_PORT=3306
) > "%PROJECT_PATH%\.env"

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

:: Set environment variables
echo Configuring environment...
%NSSM_PATH% set KaizenProject AppEnvironmentExtra PATH=%PATH%;C:\Python312;C:\Python312\Scripts
%NSSM_PATH% set KaizenProject AppEnvironmentExtra PYTHONPATH=%PROJECT_PATH%
%NSSM_PATH% set KaizenProject AppEnvironmentExtra DJANGO_SETTINGS_MODULE=kaizen_project.settings
%NSSM_PATH% set KaizenProject AppEnvironmentExtra DJANGO_DEBUG=False

:: Configure firewall rule
echo Setting up firewall rule...
netsh advfirewall firewall delete rule name="Django Kaizen Server" > nul 2>&1
netsh advfirewall firewall add rule name="Django Kaizen Server" dir=in action=allow protocol=TCP localport=8000

:: Start the service
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
echo http://%SERVER_IP%:8000
echo.
echo Share this URL with other computers on the network:
echo http://%SERVER_IP%:8000

:end
echo ====================================
pause

endlocal