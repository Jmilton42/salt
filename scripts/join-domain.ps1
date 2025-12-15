# PowerShell Script to Join Domain Based on Third Octet
# Automatically joins MACHINE.PLACExxx domain based on IP address

param(
    [string]$DomainAdminUser = "Administrator",
    [string]$DomainAdminPassword = "P@ssw0rd"
)

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Domain Join Script" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Get the third octet from the primary IP address
Write-Host "`n[INFO] Detecting IP address..." -ForegroundColor Yellow

$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
    $_.IPAddress -notlike "127.*" -and 
    $_.IPAddress -notlike "169.254.*" -and
    $_.IPAddress -notlike "10.45.70*" 
})[0].IPAddress

Write-Host "[INFO] Primary IP address: $ip" -ForegroundColor Yellow

# Extract third octet
$octets = $ip.Split('.')
$thirdOctet = [int]$octets[2]

# Build domain name
$DomainName = "MACHINE.PLACE$thirdOctet"
$DomainController = "192.168.$thirdOctet.86"

Write-Host "[INFO] Third octet: $thirdOctet" -ForegroundColor Yellow
Write-Host "[INFO] Domain Name: $DomainName" -ForegroundColor Cyan
Write-Host "[INFO] Domain Controller: $DomainController" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Check if already joined to a domain
$computerSystem = Get-WmiObject -Class Win32_ComputerSystem
if ($computerSystem.PartOfDomain) {
    Write-Host "[INFO] Computer is already joined to domain: $($computerSystem.Domain)" -ForegroundColor Yellow
    if ($computerSystem.Domain -eq $DomainName) {
        Write-Host "[SUCCESS] Already joined to correct domain: $DomainName" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "[WARNING] Computer is joined to different domain: $($computerSystem.Domain)" -ForegroundColor Yellow
        Write-Host "[INFO] You may need to unjoin first" -ForegroundColor Yellow
        exit 1
    }
}

# Set DNS to point to domain controller
Write-Host "`n[STEP 1] Setting DNS to domain controller..." -ForegroundColor Cyan
try {
    netsh interface ipv4 set dnsservers 6 static $DomainController primary
    netsh interface ipv4 add dnsservers 6 8.8.8.8 index=2
    Write-Host "[SUCCESS] DNS configured to $DomainController" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to set DNS: $_" -ForegroundColor Red
}

# Wait for DNS to propagate
Write-Host "[INFO] Waiting for DNS to propagate..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Test domain connectivity
Write-Host "`n[STEP 2] Testing domain connectivity..." -ForegroundColor Cyan
$pingResult = Test-Connection -ComputerName $DomainController -Count 2 -Quiet
if ($pingResult) {
    Write-Host "[SUCCESS] Domain controller is reachable" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Cannot reach domain controller at $DomainController" -ForegroundColor Red
    exit 1
}

# Create credential object
Write-Host "`n[STEP 3] Joining domain..." -ForegroundColor Cyan
$SecurePassword = ConvertTo-SecureString $DomainAdminPassword -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential("$DomainName\$DomainAdminUser", $SecurePassword)

# Join the domain

# At the end of the join-domain.ps1 script, replace the Add-Computer line with:
try {
    Add-Computer -DomainName $DomainName -Credential $Credential -Force
    Write-Host "[SUCCESS] Successfully joined domain: $DomainName" -ForegroundColor Green
    Write-Host "[INFO] Restarting computer in 10 seconds..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    Restart-Computer -Force
} catch {
    Write-Host "[ERROR] Failed to join domain: $_" -ForegroundColor Red
    Write-Host "[ERROR] Details: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}



exit 0
