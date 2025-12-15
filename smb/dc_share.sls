create_checklists_folder:
  file.directory:
    - name: C:\Tools
    - makedirs: True

set_ntfs_permissions:
  cmd.run:
    - name: |
        $acl = Get-Acl "C:\Tools"
        $everyone = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::WorldSid, $null)
        $everyoneRule = New-Object System.Security.AccessControl.FileSystemAccessRule($everyone, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
        $acl.SetAccessRule($everyoneRule)
        $domainUsers = New-Object System.Security.AccessControl.FileSystemAccessRule("Domain Users", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
        $acl.SetAccessRule($domainUsers)
        Set-Acl "C:\Tools" $acl
    - shell: powershell
    - require:
      - file: create_checklists_folder

create_smb_share:
  cmd.run:
    - name: New-SmbShare -Name "Tools" -Path "C:\Tools" -FullAccess "Everyone"
    - shell: powershell
    - unless: Get-SmbShare -Name "Tools" -ErrorAction SilentlyContinue
    - require:
      - file: create_checklists_folder
      - cmd: set_ntfs_permissions

grant_domain_users_access:
  cmd.run:
    - name: |
        try {
            Grant-SmbShareAccess -Name "Tools" -AccountName "Domain Users" -AccessRight Full -Force -ErrorAction Stop
        } catch {
            Write-Warning "Could not grant 'Domain Users' access. The machine might not be on a domain or the group name is different."
            Write-Error $_
        }
    - shell: powershell
    - onlyif: Get-SmbShare -Name "Tools"
    - unless: |
        $access = Get-SmbShareAccess -Name "Tools"
        if ($access.AccountName -contains "Domain Users" -or $access.AccountName -match "\\Domain Users") { exit 0 } else { exit 1 }
    - require:
      - cmd: create_smb_share

copy_linux_zip:
  file.managed:
    - name: C:\Tools\Linux.zip
    - source: salt://smb/Linux.zip
    - makedirs: True
    - require:
      - file: create_checklists_folder

copy_windows_zip:
  file.managed:
    - name: C:\Tools\Windows.zip
    - source: salt://smb/Windows.zip
    - makedirs: True
    - require:
      - file: create_checklists_folder

copy_network_zip:
  file.managed:
    - name: C:\Tools\Network.zip
    - source: salt://smb/Network.zip
    - makedirs: True
    - require:
      - file: create_checklists_folder

copy_wazuh_zip:
  file.managed:
    - name: C:\Tools\Wazuh.zip
    - source: salt://smb/Wazuh.zip
    - makedirs: True
    - require:
      - file: create_checklists_folder

copy_users_zip:
  file.managed:
    - name: C:\Tools\Users.zip
    - source: salt://smb/Users.zip
    - makedirs: True
    - require:
      - file: create_checklists_folder

