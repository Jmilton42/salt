copy_dns_records_script:
  file.managed:
    - name: 'C:\temp\create-dns-records.ps1'
    - source: salt://scripts/create-dns-records.ps1
    - makedirs: True

run_dns_records_script:
  cmd.run:
    - name: powershell.exe -ExecutionPolicy Bypass -File C:\temp\create-dns-records.ps1
    - shell: cmd
    - require:
      - file: copy_dns_records_script
    - timeout: 300
