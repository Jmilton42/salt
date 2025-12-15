copy_domain_join_script:
  file.managed:
    - name: 'C:\temp\join-domain.ps1'
    - source: salt://scripts/join-domain.ps1
    - makedirs: True

run_domain_join_script:
  cmd.run:
    - name: powershell.exe -ExecutionPolicy Bypass -File C:\temp\join-domain.ps1
    - shell: cmd
    - require:
      - file: copy_domain_join_script
    - timeout: 300
