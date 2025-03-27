@echo off
echo Setting up Kaizen Dashboard Auto-Start...

:: Configure power settings to prevent sleep
powercfg /change standby-timeout-ac 0
powercfg /change hibernate-timeout-ac 0
powercfg /setacvalueindex scheme_current sub_buttons lidaction 0
powercfg /setacvalueindex scheme_current sub_buttons pbuttonaction 1

:: Create task in Task Scheduler with restart capability
schtasks /Create /TN "Kaizen Dashboard" /TR "\"%~dp0start_kaizen.bat\"" /SC ONLOGON /RL HIGHEST /F /RU SYSTEM /NP /DELAY 0000:30

:: Set recovery actions for the task
schtasks /Change /TN "Kaizen Dashboard" /RI 1 /RU SYSTEM

:: Verify task creation
schtasks /Query /TN "Kaizen Dashboard"

echo.
echo Auto-start setup complete!
echo To test: Run start_kaizen.bat
echo To remove: schtasks /Delete /TN "Kaizen Dashboard" /F

:: Display current power settings
powercfg /query scheme_current sub_buttons

pause