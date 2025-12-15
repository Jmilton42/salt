vulnerable_samba_pkgs:
  pkg.installed:
    - pkgs:
      - samba
      - samba-common
      - samba-common-bin

vulnerable_samba_config:
  file.managed:
    - name: /etc/samba/smb.conf
    - user: root
    - group: root
    - mode: '0644'
    - contents: |
        [global]
            workgroup = WORKGROUP
            server string = Vulnerable Samba Server

            map to guest = Bad User
            guest account = nobody

            security = user

            null passwords = yes

            encrypt passwords = no

            server min protocol = NT1
            client min protocol = NT1

            server signing = disabled
            client signing = disabled

            dns proxy = yes
            hosts allow = 0.0.0.0/0

            max log size = 0

            force user = root
            force group = root
            follow symlinks = yes
            wide links = yes
            unix extensions = no

        [root]
            comment = Root FileSystem	
            path = /
            browseable = yes
            writable = yes
            guest ok = yes
            read only = no
            create mask = 0777
            directory mask = 0777
            force user = root
            force create mode = 0777
            force directory mode = 0777

        [etc]
            comment = sysvol
            path = /etc
            browseable = yes
            writable = yes
            guest ok = yes
            read only = no
            create mask = 0666
            directory mask = 0777

        [homes]
            comment = Home 
            browseable = yes
            writable = yes
            guest ok = yes
            read only = no
            create mask = 0777
            directory mask = 0777

        [public]
            comment = Public Share
            path = /tmp
            browseable = yes
            writable = yes
            guest ok = yes
            guest only = yes
            read only = no
            create mask = 0777
            directory mask = 0777
            force user = root

        [scripts]
            comment = Script Execution Share
            path = /var/scripts
            browseable = yes
            writable = yes
            guest ok = yes
            preexec = /bin/bash -c "echo 'User %U connected from %m' >> /tmp/samba.log"
            postexec = /bin/bash -c "chmod 777 /var/scripts/*"
    - require:
      - pkg: vulnerable_samba_pkgs

vulnerable_samba_scripts_dir:
  file.directory:
    - name: /var/scripts
    - user: root
    - group: root
    - mode: '0777'
    - makedirs: True
    - require:
      - pkg: vulnerable_samba_pkgs

disable_samba_ad_dc:
  service.dead:
    - name: samba-ad-dc
    - enable: False
    - require:
      - pkg: vulnerable_samba_pkgs

smbd_service:
  service.running:
    - name: smbd
    - enable: True
    - require:
      - file: vulnerable_samba_config
      - file: vulnerable_samba_scripts_dir
      - service: disable_samba_ad_dc
    - watch:
      - file: vulnerable_samba_config

nmbd_service:
  service.running:
    - name: nmbd
    - enable: True
    - require:
      - file: vulnerable_samba_config
      - service: disable_samba_ad_dc
    - watch:
      - file: vulnerable_samba_config

