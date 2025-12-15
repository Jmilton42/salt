temp:
  file.directory:
    - name: C:\Temp
    - makedirs: True
    - win_owner: Administrator
    - win_perms:
      - Administrator: full_control
      - Users: read

copy:
  file.managed:
    - name: C:\Temp\ws.ps1
    - source: salt://ws.ps1
    - require:
      - file: temp

run:
  cmd.run:
    - name: powershell -ExecutionPolicy Bypass -File C:\Temp\ws.ps1
    - require:
      - file: copy

remove:
  file.absent:
    - name: C:\Temp\ws.ps1
    - require:
      - cmd: run