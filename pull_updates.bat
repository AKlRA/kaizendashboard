@echo off
echo ====================================
echo Pulling Updates from Git Repository
echo ====================================

:: Stop the service if running
echo Stopping Kaizen service...
nssm stop KaizenProject

:: Activate virtual environment
call venv\Scripts\activate

:: Pull latest changes
echo.
echo Pulling latest changes...
git pull origin main

:: Install/update requirements
echo.
echo Updating dependencies...
pip install -r requirements.txt

:: Run migrations
echo.
echo Applying database migrations...
python manage.py migrate --noinput

:: Collect static files
echo.
echo Collecting static files...
python manage.py collectstatic --noinput

:: Restart the service
echo.
echo Starting Kaizen service...
nssm start KaizenProject

echo.
echo ====================================
echo Update completed successfully!
echo ====================================
pause