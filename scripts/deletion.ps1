# Use the ACTUAL domain administrator password
$LocalAdminPassword = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
$DomainAdminPassword = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force

try {
    $domain = Get-ADDomain -ErrorAction Stop
    $domainName = $domain.NetBIOSName
    
    Write-Output "Domain: $($domain.DNSRoot), NetBIOS: $domainName"
    
    # Try with domain\administrator format
    $DomainAdminUser = "$domainName\Administrator"
    $Credential = New-Object System.Management.Automation.PSCredential($DomainAdminUser, $DomainAdminPassword)
    
    Write-Output "Authenticating as: $DomainAdminUser"
    
    Uninstall-ADDSDomainController `
        -LocalAdministratorPassword $LocalAdminPassword `
        -Credential $Credential `
        -LastDomainControllerInDomain `
        -RemoveApplicationPartitions `
        -RemoveDnsDelegation:$false `
        -IgnoreLastDCInDomainMismatch `
        -IgnoreLastDnsServerForZone `
        -Force `
        -NoRebootOnCompletion:$false `
        -Confirm:$false
    
    Write-Output "Demotion complete."
} catch {
    Write-Output "Error: $_"
    exit 1
}
