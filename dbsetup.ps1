$pgBin = "C:\Program Files\PostgreSQL\16\bin"
$pgData = "C:\Program Files\PostgreSQL\16\data"
$pgConf = "C:\Program Files\PostgreSQL\16\data\postgresql.conf"
$pgHBA = "C:\Program Files\PostgreSQL\16\data\pg_hba.conf"


$env:PGPASSWORD = "machine-PLACE-4!"

Start-Process -FilePath $pgBin\psql.exe -ArgumentList "-Upostgres -f C:\Temp\setup.sql" -Wait

Remove-Item Env:PGPASSWORD

Restart-Service -Name "postgresql-x64-16" -Force
