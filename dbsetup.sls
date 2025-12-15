temp:
  file.directory:
    - name: C:\Temp
    - makedirs: True
    - win_owner: Administrator
    - win_perms:
      Administrator:
        perms: full_control
      Users:
        perms: read

copy:
  file.managed:
    - name: C:\Temp\dbsetup.ps1
    - source: salt://dbsetup.ps1
    - makedirs: True
    - require:
      - file: temp

run:
  cmd.run:
    - name: powershell -ExecutionPolicy Bypass -File C:\Temp\dbsetup.ps1
    - require:
      - file: copy

remove:
  file.absent:
    - name: C:\Temp\dbsetup.ps1
    - require:
      - cmd: run
