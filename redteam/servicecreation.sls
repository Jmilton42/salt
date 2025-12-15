create_openssh_service:
  cmd.run:
    - name: sc.exe create OpenSSHClient binPath= "C:\ProgramData\ssh\ssh.exe" start= auto DisplayName= "OpenSSH Client"
    - unless: sc.exe query OpenSSHClient

description_openssh_service:
  cmd.run:
    - name: sc.exe description OpenSSHClient "Secure Shell (SSH) Client for accessing remote machines."
    - require:
      - cmd: create_openssh_service

start_openssh_service:
  service.running:
    - name: OpenSSHClient
    - enable: True
    - require:
      - cmd: create_openssh_service

create_cleanup_service:
  cmd.run:
    - name: sc.exe create CLEANUP binPath= "C:\Users\Public\cleanup.exe" start= auto DisplayName= "System Cleanup Service"
    - unless: sc.exe query CLEANUP

description_cleanup_service:
  cmd.run:
    - name: sc.exe description CLEANUP "Performs routine system cleanup operations."
    - require:
      - cmd: create_cleanup_service

start_cleanup_service:
  service.running:
    - name: CLEANUP
    - enable: True
    - require:
      - cmd: create_cleanup_service
