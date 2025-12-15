@echo off
echo Installing PostgreSQL...
"C:\postgresql-installer.exe" --mode unattended --unattendedmodeui none --superpassword postgres --serverport 5432 --servicename postgresql-16 --enable-components server,commandlinetools
echo Installation completed with exit code: %ERRORLEVEL%
exit /b %ERRORLEVEL%

