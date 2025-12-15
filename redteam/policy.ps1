# Import the Active Directory module
Import-Module ActiveDirectory

# Set the Default Domain Password Policy
Set-ADDefaultDomainPasswordPolicy -Identity (Get-ADDomain).DistinguishedName `
    -PasswordHistoryCount 0 `
    -MaxPasswordAge "1.00:00:00" `
    -MinPasswordAge "00:00:00" `
    -MinPasswordLength 0 `
    -ComplexityEnabled $false `
    -ReversibleEncryptionEnabled $true
