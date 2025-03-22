@echo off
echo ====================================
echo Git Update and Deployment Script
echo ====================================

:: Activate virtual environment
call venv\Scripts\activate

:: Add all changes
git add .

:: Get commit message
set /p commit_msg="Enter commit message: "

:: Show changes to be committed
echo.
echo Changes to be committed:
git status

:: Confirm commit
set /p confirm="Proceed with commit? (Y/N): "
if /i "%confirm%"=="Y" (
    :: Commit and push
    git commit -m "%commit_msg%"
    git push origin main
    
    echo.
    echo ====================================
    echo Git update completed successfully!
    echo ====================================
) else (
    echo.
    echo Operation cancelled by user.
)

pause