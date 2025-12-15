# set_dns.sls

# 1. Move the PowerShell script from the Master to the Minion
deliver_dns_script:
  file.managed:
    - name: 'C:\Windows\Temp\users.ps1'
    - source: salt://scripts/users.ps1
    - makedirs: True

# 2. Execute the script
apply_dns_configuration:
  cmd.run:
    - name: powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Windows\Temp\users.ps1"
    - require:
      - file: deliver_dns_script
