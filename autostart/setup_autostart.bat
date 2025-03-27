@echo off
echo Setting up Kaizen Dashboard Auto-Start...

:: Create task in Task Scheduler
schtasks /Create /TN "Kaizen Dashboard" /TR "\"%~dp0start_kaizen.bat\"" /SC ONLOGON /RL HIGHEST /F

:: Verify task creation
schtasks /Query /TN "Kaizen Dashboard"

echo.
echo Auto-start setup complete!
echo To test: Run start_kaizen.bat
echo To remove: schtasks /Delete /TN "Kaizen Dashboard" /F
pause