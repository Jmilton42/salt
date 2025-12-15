create_checklists_folder:
  file.directory:
    - name: C:\checklists
    - makedirs: True

set_ntfs_permissions:
  cmd.run:
    - name: |
        $acl = Get-Acl "C:\checklists"
        $everyone = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::WorldSid, $null)
        $everyoneRule = New-Object System.Security.AccessControl.FileSystemAccessRule($everyone, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
        $acl.SetAccessRule($everyoneRule)
        $domainUsers = New-Object System.Security.AccessControl.FileSystemAccessRule("Domain Users", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
        $acl.SetAccessRule($domainUsers)
        Set-Acl "C:\checklists" $acl
    - shell: powershell
    - require:
      - file: create_checklists_folder

create_smb_share:
  cmd.run:
    - name: New-SmbShare -Name "checklists" -Path "C:\checklists" -FullAccess "Everyone"
    - shell: powershell
    - unless: Get-SmbShare -Name "checklists" -ErrorAction SilentlyContinue
    - require:
      - file: create_checklists_folder
      - cmd: set_ntfs_permissions

grant_domain_users_access:
  cmd.run:
    - name: |
        try {
            Grant-SmbShareAccess -Name "checklists" -AccountName "Domain Users" -AccessRight Full -Force -ErrorAction Stop
        } catch {
            Write-Warning "Could not grant 'Domain Users' access. The machine might not be on a domain or the group name is different."
            Write-Error $_
        }
    - shell: powershell
    - onlyif: Get-SmbShare -Name "checklists"
    - unless: |
        $access = Get-SmbShareAccess -Name "checklists"
        if ($access.AccountName -contains "Domain Users" -or $access.AccountName -match "\\Domain Users") { exit 0 } else { exit 1 }
    - require:
      - cmd: create_smb_share

copy_carter_docx:
  file.managed:
    - name: C:\checklists\carter.docx
    - source: salt://smb/carter.docx
    - makedirs: True
    - require:
      - file: create_checklists_folder

copy_foister_docx:
  file.managed:
    - name: C:\checklists\foister.docx
    - source: salt://smb/foister.docx
    - makedirs: True
    - require:
      - file: create_checklists_folder

copy_trey_docx:
  file.managed:
    - name: C:\checklists\trey.docx
    - source: salt://smb/trey.docx
    - makedirs: True
    - require:
      - file: create_checklists_folder
