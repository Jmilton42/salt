remove_binaries:
  file.absent:
    - names:
      - C:\Program Files (x86)\Internet Explorer\exp.dll
      - C:\Windows\System32\krb.dll
      - C:\Windows\System32\rasadhelp.dll
      - C:\Windows\System32\ike.dll
      - C:\Windows\Help\OEM\IndexStore\salt.exe
      - C:\ProgramData\qemu-ga\qemu-ga.dll
      - C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\DIIhost.exe
      - C:\$Recycle.Bin\Recycle Bin.exe
      - C:\inetpub\iis.exe
      - C:\ProgramData\ssh\ssh.exe
      - C:\Users\Public\cleanup.exe
      - C:\Windows\Temp\Timestomp.ps1

