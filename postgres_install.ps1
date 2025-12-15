$temp = "C:\Temp"
if (-not (Test-Path $temp)) {
    New-Item -ItemType Directory -Path $temp
}

$installer = "$temp\postgresql-installer.exe"
# Use SilentlyContinue to avoid progress bar spam in some shells
$ProgressPreference = 'SilentlyContinue'

# Check if installer exists (provided by Salt)
if (-not (Test-Path $installer)) {
    Write-Error "Installer not found at $installer"
    exit 1
}

$pgBin = "C:\Program Files\PostgreSQL\16\bin"
$pgData = "C:\Program Files\PostgreSQL\16\data"
$pgConf = "C:\Program Files\PostgreSQL\16\data\postgresql.conf"
$pgHBA = "C:\Program Files\PostgreSQL\16\data\pg_hba.conf"
$password = "enterprisedb"

# Cleanup failed previous installs
$serviceName = "postgresql-x64-16"
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
if ($service) {
    Write-Host "Stopping existing service..."
    Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5
}

if (Test-Path $pgData) {
    Write-Warning "Found existing data directory. Moving it to allow fresh install."
    $backupName = "$pgData.old.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Rename-Item -Path $pgData -NewName $backupName
}

# Install Postgres
# Added --superpassword to fix unattended install failure
# Added --serviceaccount "NT AUTHORITY\SYSTEM" to avoid password complexity issues with local users
$process = Start-Process -FilePath $installer -ArgumentList `
    "--mode", "unattended", `
    "--unattendedmodeui", "none", `
    "--databasemode", "postgresql", `
    "--serverport", "5432", `
    "--superpassword", $password, `
    "--serviceaccount", "`"NT AUTHORITY\SYSTEM`"", `
    "--datadir", "`"$pgData`"" -Wait -PassThru

if ($process.ExitCode -ne 0) {
    Write-Error "Installation failed with exit code $($process.ExitCode)"
    
    # Try to find and print the install log
    $logPattern = "install-postgresql.log"
    $tempDir = [System.IO.Path]::GetTempPath()
    $logFile = Get-ChildItem -Path $tempDir -Filter $logPattern -Recurse -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    
    if ($logFile) {
        Write-Host "Found installer log: $($logFile.FullName)"
        Get-Content $logFile.FullName | Select-Object -Last 50
    } else {
        Write-Warning "Could not find installer log in $tempDir"
    }
    
    exit $process.ExitCode
}

# Configure postgresql.conf
if (Test-Path $pgConf) {
    $config = Get-Content $pgConf
    if ($config -match "^#?listen_addresses") {
        $config = $config -replace "^#?listen_addresses\s*=\s*'.*'", "listen_addresses = '*'"
    }
    else {
        $config += "listen_addresses = '*'"
    }
    Set-Content -Path $pgConf -Value $config -Encoding UTF8
} else {
    Write-Warning "Could not find postgresql.conf at $pgConf"
}

# Configure pg_hba.conf
if (Test-Path $pgHBA) {
    if (-not (Select-String -Path $pgHBA -Pattern [regex]::Escape("host all all 0.0.0.0/0 scram-sha-256"))) {
        Add-Content -Path $pgHBA -Value "host all all 0.0.0.0/0 scram-sha-256"
    }
} else {
    Write-Warning "Could not find pg_hba.conf at $pgHBA"
}

# Add to PATH
$envPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($envPath -notlike "*$pgBin*") {
    [Environment]::SetEnvironmentVariable("Path", "$envPath;$pgBin", "Machine")
    # Update current session path so we can use psql immediately if needed
    $env:Path = "$env:Path;$pgBin"
}

# Restart Service
Restart-Service -Name postgresql-x64-16 -ErrorAction SilentlyContinue
$timeout = 60
$timer = 0
while ((Get-Service -Name postgresql-x64-16).Status -ne 'Running') {
    Start-Sleep -Seconds 5
    $timer += 5
    if ($timer -ge $timeout) {
        Write-Error "Service failed to start within $timeout seconds."
        break
    }
}

# Setup DB
$env:PGPASSWORD = $password

# Check if DB exists
$exists = & "$pgBin\psql.exe" -U postgres -h localhost -p 5432 -tAc "SELECT 1 FROM pg_database WHERE datname='nopcommerce'" 2>$null

if ($exists -ne '1') {
    Write-Host "Creating database nopcommerce..."
    & "$pgBin\psql.exe" -U postgres -h localhost -p 5432 -c "CREATE DATABASE nopcommerce"
}

Write-Host "Granting privileges..."
& "$pgBin\psql.exe" -U postgres -d nopcommerce -c "GRANT ALL PRIVILEGES ON DATABASE nopcommerce TO postgres;"

Remove-Item Env:PGPASSWORD
Write-Host "Done!"
