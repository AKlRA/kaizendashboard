@echo off
echo Setting up Kaizen Dashboard Auto-Start...

:: Configure power settings to prevent sleep and handle lid/power buttons
powercfg /change standby-timeout-ac 0
powercfg /change hibernate-timeout-ac 0
powercfg /setacvalueindex scheme_current sub_buttons lidaction 0
powercfg /setacvalueindex scheme_current sub_buttons pbuttonaction 1

:: Remove existing task if present
schtasks /Delete /TN "Kaizen Dashboard" /F 2>nul

:: Create primary task for logon (simplified command)
schtasks /Create /TN "Kaizen Dashboard" /TR "\"%~dp0start_kaizen.bat\"" /SC ONLOGON /DELAY 0000:30 /RL HIGHEST /F /RU SYSTEM

:: Configure recovery settings
schtasks /Change /TN "Kaizen Dashboard" /RI 1

:: Create additional startup trigger using XML
set "xmlFile=%TEMP%\KaizenTask.xml"
echo ^<?xml version="1.0" encoding="UTF-16"?^>> "%xmlFile%"
echo ^<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"^>> "%xmlFile%"
echo   ^<Triggers^>> "%xmlFile%"
echo     ^<BootTrigger^>> "%xmlFile%"
echo       ^<Enabled^>true^</Enabled^>> "%xmlFile%"
echo       ^<Delay^>PT30S^</Delay^>> "%xmlFile%"
echo     ^</BootTrigger^>> "%xmlFile%"
echo   ^</Triggers^>> "%xmlFile%"
echo ^</Task^>> "%xmlFile%"

schtasks /Change /TN "Kaizen Dashboard" /XML "%xmlFile%"

:: Enable task history
wevtutil set-log "Microsoft-Windows-TaskScheduler/Operational" /enabled:true

:: Verify task creation and settings
echo.
echo Task Status:
schtasks /Query /TN "Kaizen Dashboard" 2>nul
if %errorlevel% equ 0 (
    echo Auto-start setup completed successfully!
    echo Server will start:
    echo - 30 seconds after system startup
    echo - 30 seconds after user login
) else (
    echo Error: Task creation failed!
    echo Please ensure you're running with administrative privileges
)

:: Display current power settings
echo.
echo Power Management Settings:
powercfg /query scheme_current sub_buttons

:: Create log entry
if not exist "logs" mkdir logs
echo [%date% %time%] Auto-start configuration updated >> logs\setup.log

echo.
echo To test: Run start_kaizen.bat
echo To remove: schtasks /Delete /TN "Kaizen Dashboard" /F
echo.

pause