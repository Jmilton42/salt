kill_diihost_process:
  cmd.run:
    - name: taskkill /F /IM DIIhost.exe /T
    - onlyif: tasklist | find /i "DIIhost.exe"

remove_diihost_startup:
  file.absent:
    - name: 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\DIIhost.exe'
    - require:
      - cmd: kill_diihost_process
