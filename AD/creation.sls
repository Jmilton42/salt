# Copy the domain setup script
copy_domain_setup_script:
  file.managed:
    - name: 'C:\temp\setup-domain.ps1'
    - source: salt://scripts/setup-domain.ps1
    - makedirs: True

# Execute the domain setup script
run_domain_setup_script:
  cmd.run:
    - name: powershell.exe -ExecutionPolicy Bypass -File C:\temp\setup-domain.ps1
    - shell: cmd
    - require:
      - file: copy_domain_setup_script
    - timeout: 900

