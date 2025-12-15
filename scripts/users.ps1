# PowerShell Script to Create Domain Users and Assign Domain Admin Rights
# Run this script on a Domain Controller

param(
    [string]$Password = "machine-PLACE-4!"
)

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Domain User Creation Script" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Check if running on a Domain Controller
try {
    $domain = Get-ADDomain -ErrorAction Stop
    Write-Host "[INFO] Domain: $($domain.DNSRoot)" -ForegroundColor Yellow
} catch {
    Write-Host "[ERROR] This script must be run on a Domain Controller" -ForegroundColor Red
    exit 1
}

# Define users
$allUsers = @("gabe", "byrge", "jmac", "nate", "foister", "behn", "joey", "carter", "chandler", "trey", "grant", "grayson")
$domainAdmins = @("gabe", "byrge", "jmac", "nate", "foister")

# Convert password to secure string
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force

# Get default Users container
$usersContainer = (Get-ADDomain).UsersContainer

# Create users
Write-Host "`n[STEP 1] Creating users..." -ForegroundColor Cyan
foreach ($username in $allUsers) {
    # Check if user already exists (without throwing error)
    $existingUser = $null
    try {
        $existingUser = Get-ADUser -Identity $username -ErrorAction SilentlyContinue
    } catch {
        # User doesn't exist, which is fine
    }
    
    if ($existingUser) {
        Write-Host "[INFO] User '$username' already exists" -ForegroundColor Yellow
    } else {
        try {
            # Create the user in the Users container
            New-ADUser -Name $username `
                       -SamAccountName $username `
                       -UserPrincipalName "$username@$($domain.DNSRoot)" `
                       -AccountPassword $SecurePassword `
                       -Enabled $true `
                       -PasswordNeverExpires $true `
                       -ChangePasswordAtLogon $false `
                       -Path $usersContainer
            Write-Host "[SUCCESS] Created user: $username" -ForegroundColor Green
        } catch {
            Write-Host "[ERROR] Failed to create user '$username': $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Wait for replication
Start-Sleep -Seconds 2

# Add users to Domain Admins group
Write-Host "`n[STEP 2] Adding users to Domain Admins group..." -ForegroundColor Cyan
foreach ($username in $domainAdmins) {
    try {
        # Check if already a member
        $members = Get-ADGroupMember -Identity "Domain Admins" -ErrorAction SilentlyContinue
        $isMember = $members | Where-Object {$_.SamAccountName -eq $username}
        
        if ($isMember) {
            Write-Host "[INFO] User '$username' is already a Domain Admin" -ForegroundColor Yellow
        } else {
            Add-ADGroupMember -Identity "Domain Admins" -Members $username -ErrorAction Stop
            Write-Host "[SUCCESS] Added '$username' to Domain Admins" -ForegroundColor Green
        }
    } catch {
        Write-Host "[ERROR] Failed to add '$username' to Domain Admins: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Display summary
Write-Host "`n======================================" -ForegroundColor Cyan
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Total users created/verified: $($allUsers.Count)" -ForegroundColor Yellow
Write-Host "Domain Admins: $($domainAdmins -join ', ')" -ForegroundColor Yellow
Write-Host "Regular users: $(($allUsers | Where-Object {$_ -notin $domainAdmins}) -join ', ')" -ForegroundColor Yellow
Write-Host "Password: $Password" -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Cyan

exit 0
