configure_dns_specific_subnet:
  cmd.run:
    - name: |
        $ErrorActionPreference = 'Stop'
        
        # 1. Find the specific adapter where the IP starts with '192.168.'
        $targetConfig = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like '192.168.*' } | Select-Object -First 1
        
        if (-not $targetConfig) {
            Write-Error "Could not find any adapter with an IP starting with 192.168!"
            # List available IPs to help debug if it fails
            Get-NetIPAddress -AddressFamily IPv4 | Select-Object InterfaceAlias, IPAddress | Format-Table
            exit 1
        }

        $currentIP = $targetConfig.IPAddress
        $alias = $targetConfig.InterfaceAlias

        Write-Output "MATCHED ADAPTER: $alias"
        Write-Output "MATCHED IP: $currentIP"

        # 2. Extract the third octet
        $octets = $currentIP.Split('.')
        $thirdOctet = $octets[2]

        # 3. Construct the Target DNS
        $primaryDNS = "192.168.$thirdOctet.86"
        
        Write-Output "SETTING DNS TO: $primaryDNS and 8.8.8.8"

        # 4. Force the setting on THAT specific adapter
        Set-DnsClientServerAddress -InterfaceAlias $alias -ServerAddresses ($primaryDNS, '8.8.8.8')

        # 5. Verify
        $finalCheck = Get-DnsClientServerAddress -InterfaceAlias $alias
        Write-Output "FINAL DNS SETTINGS: $($finalCheck.ServerAddresses)"

    - shell: powershell
