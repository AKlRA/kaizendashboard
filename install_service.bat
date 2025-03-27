@echo off
setlocal EnableDelayedExpansion

echo Installing Kaizen Dashboard Service...

:: Set paths
set "PROJECT_PATH=%~dp0"
set "VENV_PATH=%PROJECT_PATH%venv"
set "SERVICE_NAME=KaizenDashboard"
set "LOG_PATH=%PROJECT_PATH%logs"

:: Create logs directory if it doesn't exist
if not exist "%LOG_PATH%" mkdir "%LOG_PATH%"

:: Kill any processes using port 8000
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8000') do (
    taskkill /F /PID %%a 2>nul
)

:: Remove existing service
echo Removing existing service...
sc stop %SERVICE_NAME% >nul 2>&1
sc delete %SERVICE_NAME% >nul 2>&1
timeout /t 10 /nobreak > nul

:: Create wrapper script for better service control
echo Creating service wrapper...
(
    echo @echo off
    echo cd /d "%PROJECT_PATH%"
    echo set PATH=%VENV_PATH%\Scripts;%%PATH%%
    echo set PYTHONPATH=%PROJECT_PATH%
    echo set DJANGO_SETTINGS_MODULE=kaizen_project.settings
    echo call "%VENV_PATH%\Scripts\activate.bat"
    echo echo Starting Kaizen Dashboard Service at %%date%% %%time%% ^> "%LOG_PATH%\service.log"
    echo "%VENV_PATH%\Scripts\python.exe" -m waitress-serve --host=0.0.0.0 --port=8000 kaizen_project.wsgi:application ^>^> "%LOG_PATH%\service.log" 2^>^> "%LOG_PATH%\service_error.log"
) > "%PROJECT_PATH%start_service.bat"

:: Create service with dependencies
echo Installing service...
sc create %SERVICE_NAME% ^
    binPath= "cmd.exe /c \"%PROJECT_PATH%start_service.bat\"" ^
    DisplayName= "Ace Kaizen Dashboard" ^
    start= auto ^
    depend= Tcpip/Dhcp/Dnscache/RpcSs ^
    obj= LocalSystem ^
    type= own

:: Configure service
sc description %SERVICE_NAME% "Ace Kaizen Project Web Application Server"

:: Set recovery options
sc failure %SERVICE_NAME% actions= restart/60000/restart/60000/restart/60000 reset= 86400

:: Fix permissions
echo Setting permissions...
icacls "%PROJECT_PATH:~0,-1%" /grant "SYSTEM:(OI)(CI)F" /T
icacls "%LOG_PATH%" /grant "Users:(OI)(CI)F" /T
icacls "%LOG_PATH%" /grant "SYSTEM:(OI)(CI)F" /T

:: Start service
echo Starting service...
net start %SERVICE_NAME%
timeout /t 10 /nobreak > nul

:: Display status
sc queryex %SERVICE_NAME%

:: Check for errors
echo.
echo Checking service logs...
if exist "%LOG_PATH%\service_error.log" (
    echo Error Log Contents:
    type "%LOG_PATH%\service_error.log"
)

echo.
echo Installation complete!
echo.
echo Troubleshooting steps:
echo 1. Check services.msc for service status
echo 2. Check logs in: %LOG_PATH%
echo 3. Dependencies required:
echo    - TCP/IP Protocol Driver
echo    - DHCP Client
echo    - DNS Client
echo    - Remote Procedure Call (RPC)
echo 4. Try commands:
echo    sc queryex %SERVICE_NAME%
echo    net start %SERVICE_NAME%
echo    eventvwr.msc ^(Check Windows Logs ^> Application^)
pause

endlocal