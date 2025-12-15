# PostgreSQL Installation Script
$ErrorActionPreference = "Stop"
$InstallerPath = "C:\postgresql-installer.exe"
$PostgresBin = "C:\Program Files\PostgreSQL\16\bin\postgres.exe"
$Url = "https://get.enterprisedb.com/postgresql/postgresql-16.1-1-windows-x64.exe"

# 1. Check if already installed
if (Test-Path $PostgresBin) {
    Write-Host "PostgreSQL is already installed at $PostgresBin"
    exit 0
}

# 2. Enable TLS 1.2 for download
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 3. Download Installer if missing
if (-not (Test-Path $InstallerPath)) {
    Write-Host "Downloading PostgreSQL installer from $Url..."
    try {
        Invoke-WebRequest -Uri $Url -OutFile $InstallerPath
    } catch {
        Write-Error "Failed to download installer: $_"
        exit 1
    }
}

# 4. Verify Download
$Size = (Get-Item $InstallerPath).Length
if ($Size -lt 1000000) {
    Write-Error "Installer file is too small ($Size bytes). It may be corrupt."
    exit 1
}
Write-Host "Installer ready: $Size bytes"

# 5. Cleanup previous failed installs
$DataDir = "C:\Program Files\PostgreSQL\16\data"
if (Test-Path $DataDir) {
    Write-Host "Cleaning up existing data directory at $DataDir..."
    Remove-Item -Path $DataDir -Recurse -Force -ErrorAction SilentlyContinue
}

# 6. Install PostgreSQL
Write-Host "Starting unattended installation..."
$InstallArgs = @(
    "--mode", "unattended",
    "--unattendedmodeui", "none",
    "--superpassword", "postgres",
    "--serverport", "5432",
    "--servicename", "postgresql-16",
    "--enable-components", "server,commandlinetools"
)

$Process = Start-Process -FilePath $InstallerPath -ArgumentList $InstallArgs -Wait -PassThru -NoNewWindow

if ($Process.ExitCode -ne 0) {
    Write-Error "Installation failed with exit code $($Process.ExitCode)"
    exit 1
}

Write-Host "Installation completed successfully."
exit 0

