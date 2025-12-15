    openssh-server:
      pkg.installed:
        - name: openssh-server # Or the appropriate package name for your OS (e.g., openssh-server on Debian/Ubuntu, openssh on CentOS/RHEL)
      service.running:
        - name: sshd # Or the appropriate service name (e.g., sshd on most Linux systems)
        - enable: True
        - require:
          - pkg: openssh-server
