@echo off
netstat -ano | findstr :8000
if %ERRORLEVEL% EQU 0 (
    echo Port 8000 is in use
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8000') do (
        echo Terminating process: %%a
        taskkill /F /PID %%a
    )
)