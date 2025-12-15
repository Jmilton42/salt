iis_autorun_all_users:
  reg.present:
    - name: HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
    - vname: IISMonitor
    - vdata: C:\inetpub\iis.exe
    - vtype: REG_SZ
