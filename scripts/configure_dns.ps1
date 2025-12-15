# configure_dns.ps1

$ErrorActionPreference = "Stop"

try {
    # 1. Find the adapter specifically on the 192.168.x.x subnet
    $targetAdapter = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like '192.168.*' } | Select-Object -First 1

    if (-not $targetAdapter) {
        Write-Error "No network adapter found with an IP starting with 192.168."
        exit 1
    }

    $currentIP = $targetAdapter.IPAddress
    $interfaceAlias = $targetAdapter.InterfaceAlias
    
    Write-Output "Target Adapter Found: $interfaceAlias"
    Write-Output "Current IP: $currentIP"

    # 2. Parse the IP to get the third octet
    $octets = $currentIP.Split('.')
    $thirdOctet = $octets[2]

    # 3. Build the DNS String
    $primaryDNS = "192.168.$thirdOctet.86"
    $secondaryDNS = "8.8.8.8"

    Write-Output "Calculated DNS: Primary=$primaryDNS, Secondary=$secondaryDNS"

    # 4. Apply the configuration
    Set-DnsClientServerAddress -InterfaceAlias $interfaceAlias -ServerAddresses ($primaryDNS, $secondaryDNS)

    # 5. Verify and print result for Salt output
    $finalConfig = Get-DnsClientServerAddress -InterfaceAlias $interfaceAlias
    Write-Output "SUCCESS. Final Settings: $($finalConfig.ServerAddresses -join ', ')"

} catch {
    Write-Error "Script Failed: $_"
    exit 1
}
