# PowerShell Script to Install AD DS and Create MACHINE.PLACE Domain
# Automatically uses third octet of IP address for domain name

param(
    [string]$SafeModePassword = "Password123!"
)

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Domain Controller Setup Script" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Get the third octet from the primary IP address
Write-Host "`n[INFO] Detecting IP address..." -ForegroundColor Yellow

$ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
    $_.IPAddress -notlike "127.*" -and 
    $_.IPAddress -notlike "169.254.*" -and 
    $_.IPAddress -notlike "10.45.70.*" 
}

if ($ipAddresses.Count -eq 0) {
    Write-Host "[ERROR] Could not find valid IP address" -ForegroundColor Red
    exit 1
}

# Get the first valid IP
$primaryIP = $ipAddresses[0].IPAddress
Write-Host "[INFO] Primary IP address: $primaryIP" -ForegroundColor Yellow

# Extract third octet
$octets = $primaryIP.Split('.')
$thirdOctet = $octets[2]

# Remove leading zeros (e.g., 101 -> 101, 011 -> 11, 001 -> 1)
$thirdOctetClean = [int]$thirdOctet

# Build domain name
$DomainName = "MACHINE.PLACE$thirdOctetClean"
$NetBIOSName = "MACHINE$thirdOctetClean"

Write-Host "[INFO] Third octet: $thirdOctetClean" -ForegroundColor Yellow
Write-Host "[INFO] Domain Name: $DomainName" -ForegroundColor Cyan
Write-Host "[INFO] NetBIOS Name: $NetBIOSName" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Check if already a domain controller
try {
    $domain = Get-ADDomain -ErrorAction Stop
    Write-Host "[INFO] Server is already a domain controller for: $($domain.DNSRoot)" -ForegroundColor Yellow
    if ($domain.DNSRoot -eq $DomainName) {
        Write-Host "[SUCCESS] Domain $DomainName is already configured" -ForegroundColor Green
        exit 0
    }
    else {
        Write-Host "[ERROR] Server is DC for different domain: $($domain.DNSRoot)" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "[INFO] Server is not yet a domain controller" -ForegroundColor Yellow
}

# Step 1: Install AD DS Feature
Write-Host "`n[STEP 1] Installing Active Directory Domain Services..." -ForegroundColor Cyan
$addsFeature = Get-WindowsFeature -Name AD-Domain-Services
if ($addsFeature.Installed) {
    Write-Host "[INFO] AD DS feature already installed" -ForegroundColor Yellow
}
else {
    Write-Host "[INFO] Installing AD DS feature..." -ForegroundColor Yellow
    $result = Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
    if ($result.Success) {
        Write-Host "[SUCCESS] AD DS feature installed successfully" -ForegroundColor Green
    }
    else {
        Write-Host "[ERROR] Failed to install AD DS feature" -ForegroundColor Red
        exit 1
    }
}

# Step 2: Install DNS Feature
Write-Host "`n[STEP 2] Installing DNS Server..." -ForegroundColor Cyan
$dnsFeature = Get-WindowsFeature -Name DNS
if ($dnsFeature.Installed) {
    Write-Host "[INFO] DNS feature already installed" -ForegroundColor Yellow
}
else {
    Write-Host "[INFO] Installing DNS feature..." -ForegroundColor Yellow
    $result = Install-WindowsFeature -Name DNS -IncludeManagementTools
    if ($result.Success) {
        Write-Host "[SUCCESS] DNS feature installed successfully" -ForegroundColor Green
    }
    else {
        Write-Host "[ERROR] Failed to install DNS feature" -ForegroundColor Red
        exit 1
    }
}

# Step 3: Promote to Domain Controller
Write-Host "`n[STEP 3] Promoting server to Domain Controller..." -ForegroundColor Cyan
Write-Host "[WARNING] Server will reboot after promotion!" -ForegroundColor Yellow
Write-Host "[INFO] Creating new forest: $DomainName" -ForegroundColor Yellow

$SecurePassword = ConvertTo-SecureString $SafeModePassword -AsPlainText -Force

try {
    Install-ADDSForest `
        -DomainName $DomainName `
        -DomainNetbiosName $NetBIOSName `
        -ForestMode "WinThreshold" `
        -DomainMode "WinThreshold" `
        -InstallDns `
        -SafeModeAdministratorPassword $SecurePassword `
        -Force `
        -NoRebootOnCompletion:$false
    
    Write-Host "[SUCCESS] Domain Controller promotion initiated" -ForegroundColor Green
    Write-Host "[INFO] Server will reboot shortly..." -ForegroundColor Yellow
}
catch {
    Write-Host "[ERROR] Failed to promote to Domain Controller: $_" -ForegroundColor Red
    exit 1
}

exit 0
