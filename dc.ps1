$temp = "C:\Temp"
if (-not (Test-Path $temp)) {
    New-Item -ItemType Directory -Path $temp
}

$installer = "$temp\postgresql-installer.exe"

# Only download if installer does not exist
if (-not (Test-Path $installer)) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri "https://get.enterprisedb.com/postgresql/postgresql-16.11-1-windows-x64.exe" -OutFile $installer
}

$pgBin = "C:\Program Files\PostgreSQL\16\bin"
$pgData = "C:\Program Files\PostgreSQL\16\data"
$pgConf = "C:\Program Files\PostgreSQL\16\data\postgresql.conf"
$pgHBA = "C:\Program Files\PostgreSQL\16\data\pg_hba.conf"


# Leaves default postgres:enterprisedb creds
Start-Process -FilePath $installer -ArgumentList "--mode unattended --unattendedmodeui none --serverport 5432 --datadir `"$pgData`" --superaccount postgres --superpassword `"machine-PLACE-4!`"" -Wait

# Only proceed if both config files exist
if ((Test-Path $pgConf) -and (Test-Path $pgHBA)) {
    $config = Get-Content $pgConf
    if ($config -match "^#?listen_addresses") {
        $config = $config -replace "^#?listen_addresses\s*=\s*'.*'", "listen_addresses = '*'"
    }
    else {
        $config += "listen_addresses = '*'"
    }

    [System.IO.File]::WriteAllLines($pgConf, $config, (New-Object System.Text.UTF8Encoding $false))

    if (-not (Select-String -Path $pgHBA -SimpleMatch "host all all 0.0.0.0/0 scram-sha-256")) {
        $hba = Get-Content $pgHBA
        $hba += "host all all 0.0.0.0/0 scram-sha-256"
        [System.IO.File]::WriteAllLines($pgHBA, $hba, (New-Object System.Text.UTF8Encoding $false))
    }
}

$envPath = [Environment]::GetEnvironmentVariable("Path", "Machine")

if ($envPath -notlike "*$pgBin*") {
    [Environment]::SetEnvironmentVariable("Path", "$envPath;$pgBin", "Machine")
}

$env:PGPASSWORD = "machine-PLACE-4!"

Start-Process -FilePath $pgBin\psql.exe -ArgumentList "-Upostgres -f C:\Temp\setup.sql" -Wait

Remove-Item Env:PGPASSWORD

Restart-Service -Name "postgresql-x64-16" -Force
