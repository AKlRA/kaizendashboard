# Ace Designers CIP Management System
==================================

Complete Server Deployment Guide
1. Install Required Software

Python Installation

# Download Python 3.12
curl https://www.python.org/ftp/python/3.12.0/python-3.12.0-amd64.exe -o python-installer.exe

# Install Python (Run as Administrator)
python-installer.exe /quiet InstallAllUsers=1 PrependPath=1



Git Installation

# Download Git
curl https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe -o git-installer.exe

# Install Git (Run as Administrator)
git-installer.exe /VERYSILENT /NORESTART


MySQL Installation
Download MySQL Installer from MySQL Website
Run installer as Administrator
Choose "Server only" installation
Configure MySQL:

mysql -u root -p

CREATE DATABASE kaizen_db;
CREATE USER 'kaizen_user'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON kaizen_db.* TO 'kaizen_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;

NSSM Installation
Download NSSM from NSSM Website
Extract to C:\Program Files\nssm
Add to PATH:

setx PATH "%PATH%;C:\Program Files\nssm" /M


2. Project Setup
Clone Repository

mkdir C:\kaizen_project
cd C:\kaizen_project
git clone https://github.com/YOUR_USERNAME/kaizendashboard.git
cd kaizendashboard

Create Virtual Environment

python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt

Environment Configuration

DEBUG=False
SECRET_KEY=your_secret_key_here
ALLOWED_HOSTS=localhost,127.0.0.1,YOUR_SERVER_IP
DB_NAME=kaizen_db
DB_USER=kaizen_user
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=3306

Initialize Django

python manage.py migrate
python manage.py createsuperuser
python manage.py collectstatic --noinput

3. Service Installation

# Install service (Run as Administrator)
nssm install KaizenProject "C:\kaizen_project\kaizendashboard\venv\Scripts\python.exe"
nssm set KaizenProject AppParameters "-m waitress-serve --host=0.0.0.0 --port=8000 kaizen_project.wsgi:application"
nssm set KaizenProject AppDirectory "C:\kaizen_project\kaizendashboard"
nssm set KaizenProject DisplayName "Ace Kaizen Dashboard"
nssm set KaizenProject Description "Ace Kaizen Project Web Application"
nssm set KaizenProject DependOnService MySQL80

4. Start and Verify

# Start service
nssm start KaizenProject

# Verify status
nssm status KaizenProject

5. Access Application
Local: http://localhost:8000
Network: http://YOUR_SERVER_IP:8000
Background Running
The service will run automatically in the background
Restarts automatically on server reboot
Survives user logoff
Managed through Windows Services
Service Management
Use the management script:

cd C:\kaizen_project\kaizendashboard
manage_kaizen_service.bat

Updates
When updates are needed:

cd C:\kaizen_project\kaizendashboard
pull_updates.bat

Monitoring
Check Windows Services (services.msc)
View logs: C:\kaizen_project\kaizendashboard\server.log
Monitor Event Viewer for service events
The project will continue running in the background as a Windows Service, managed by NSSM, and automatically start when the server boots up.
