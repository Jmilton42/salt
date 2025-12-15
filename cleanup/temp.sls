cleanup_windows_temp:
  cmd.run:
    - name: del /F /S /Q C:\Windows\Temp\* 2>nul & rd /S /Q C:\Windows\Temp 2>nul & mkdir C:\Windows\Temp
    - shell: cmd

cleanup_c_temp:
  cmd.run:
    - name: del /F /S /Q C:\temp\* 2>nul & rd /S /Q C:\temp 2>nul
    - onlyif: if exist C:\Temp exit 0 else exit 1
    - shell: cmd
