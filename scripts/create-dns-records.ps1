# PowerShell Script to Add DNS Records to Domain
# Automatically extracts third octet from IP address
# Run this script on a Domain Controller

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "DNS Record Creation Script" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Check if running on a Domain Controller
try {
    $domain = Get-ADDomain -ErrorAction Stop
    Write-Host "[INFO] Domain: $($domain.DNSRoot)" -ForegroundColor Yellow
} catch {
    Write-Host "[ERROR] This script must be run on a Domain Controller" -ForegroundColor Red
    exit 1
}

# Get the third octet from the primary IP address
Write-Host "`n[INFO] Detecting IP address..." -ForegroundColor Yellow

$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
    $_.IPAddress -notlike "127.*" -and 
    $_.IPAddress -notlike "169.254.*" -and
    $_.IPAddress -notlike "10.24.70.*"
})[0].IPAddress

Write-Host "[INFO] Primary IP address: $ip" -ForegroundColor Yellow

# Extract third octet
$octets = $ip.Split('.')
$thirdOctet = [int]$octets[2]

# Build DNS records
$zoneName = "MACHINE.PLACE$thirdOctet"
$ecommerceIP = "192.168.$thirdOctet.24"
$wordpressIP = "192.168.$thirdOctet.42"
$mailIP = "192.168.$thirdOctet.15"

Write-Host "[INFO] Third octet: $thirdOctet" -ForegroundColor Yellow
Write-Host "[INFO] DNS Zone: $zoneName" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Define DNS records to create
$dnsRecords = @(
    @{Name = "ecommerce"; IP = $ecommerceIP},
    @{Name = "wordpress"; IP = $wordpressIP},
    @{Name = "mail"; IP = $mailIP}
)

# Create DNS A records
Write-Host "`n[STEP 1] Creating DNS A Records..." -ForegroundColor Cyan

foreach ($record in $dnsRecords) {
    $hostname = $record.Name
    $ipAddress = $record.IP
    
    try {
        # Check if record already exists
        $existingRecord = Get-DnsServerResourceRecord -ZoneName $zoneName -Name $hostname -RRType A -ErrorAction SilentlyContinue
        
        if ($existingRecord) {
            Write-Host "[INFO] DNS record '$hostname.$zoneName' already exists" -ForegroundColor Yellow
            
            # Update if IP is different
            if ($existingRecord.RecordData.IPv4Address.IPAddressToString -ne $ipAddress) {
                Write-Host "[INFO] Updating IP address to $ipAddress" -ForegroundColor Yellow
                Remove-DnsServerResourceRecord -ZoneName $zoneName -Name $hostname -RRType A -Force
                Add-DnsServerResourceRecordA -ZoneName $zoneName -Name $hostname -IPv4Address $ipAddress
                Write-Host "[SUCCESS] Updated '$hostname.$zoneName' -> $ipAddress" -ForegroundColor Green
            }
        } else {
            # Create new record
            Add-DnsServerResourceRecordA -ZoneName $zoneName -Name $hostname -IPv4Address $ipAddress
            Write-Host "[SUCCESS] Created '$hostname.$zoneName' -> $ipAddress" -ForegroundColor Green
        }
    } catch {
        Write-Host "[ERROR] Failed to create/update DNS record '$hostname.$zoneName': $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Display summary
Write-Host "`n======================================" -ForegroundColor Cyan
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "DNS Zone: $zoneName" -ForegroundColor Yellow
Write-Host "ecommerce.$zoneName -> $ecommerceIP" -ForegroundColor Yellow
Write-Host "wordpress.$zoneName -> $wordpressIP" -ForegroundColor Yellow
Write-Host "mail.$zoneName -> $mailIP" -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Cyan

# Verify records
Write-Host "`n[STEP 2] Verifying DNS records..." -ForegroundColor Cyan
foreach ($record in $dnsRecords) {
    $hostname = $record.Name
    try {
        $result = Resolve-DnsName "$hostname.$zoneName" -Type A -ErrorAction SilentlyContinue
        if ($result) {
            Write-Host "[SUCCESS] $hostname.$zoneName resolves to $($result.IPAddress)" -ForegroundColor Green
        }
    } catch {
        Write-Host "[WARNING] Could not verify $hostname.$zoneName" -ForegroundColor Yellow
    }
}

Write-Host "`n[INFO] DNS record creation complete!" -ForegroundColor Cyan

exit 0
