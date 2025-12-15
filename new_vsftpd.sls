###############################################
# Install vsftpd
###############################################
vulnerable_vsftpd_pkg:
  pkg.installed:
    - name: vsftpd

###############################################
# Allow root login (Just in case)
###############################################
allow_root_ftp:
  file.managed:
    - name: /etc/ftpusers
    - contents: ""
    - mode: '0644'
    - require:
      - pkg: vulnerable_vsftpd_pkg

###############################################
# Create secure chroot directory
###############################################
vulnerable_vsftpd_chroot_dir:
  file.directory:
    - name: /var/run/vsftpd/empty
    - user: root
    - group: root
    - mode: '0755'
    - makedirs: True
    - require:
      - pkg: vulnerable_vsftpd_pkg

###############################################
# Create /var/ftp just to be sure it exists
###############################################
ftp_root_dir:
  file.directory:
    - name: /var/ftp
    - user: root
    - group: root
    - mode: '0777'
    - makedirs: True

###############################################
# VULNERABLE FILESYSTEM PERMISSIONS
###############################################
vulnerable_shadow:
  file.managed:
    - name: /etc/shadow
    - mode: '0666'
    - replace: False

vulnerable_etc:
  file.directory:
    - name: /etc
    - mode: '0777'
    - replace: False

vulnerable_home:
  file.directory:
    - name: /home
    - mode: '0777'
    - replace: False

vulnerable_root:
  file.directory:
    - name: /root
    - mode: '0777'
    - replace: False

vulnerable_var:
  file.directory:
    - name: /var
    - mode: '0777'
    - replace: False

###############################################
# Deploy vulnerable vsftpd.conf
###############################################
vulnerable_vsftpd_config:
  file.managed:
    - name: /etc/vsftpd.conf
    - user: root
    - group: root
    - mode: '0644'
    - contents: |
        listen=NO
        listen_ipv6=YES
        
        # ---------------------------------------------------------
        # VULNERABLE CONFIGURATION
        # ---------------------------------------------------------
        
        # 1. Enable Anonymous
        anonymous_enable=YES
        no_anon_password=YES
        
        # 1b. Enable Local Users (root, test, etc.)
        local_enable=YES
        
        # 2. Set Root
        # Anonymous sees / (System Root)
        anon_root=/
        # Locals see /var/ftp (but can cd .. because chroot is NO)
        local_root=/var/ftp
        
        # 3. Disable Security Checks
        # Allow downloading files even if they are not world-readable
        # (As long as the 'ftp' user has read access)
        anon_world_readable_only=NO
        
        # 4. Enable Full Write Access
        write_enable=YES
        anon_upload_enable=YES
        anon_mkdir_write_enable=YES
        anon_other_write_enable=YES
        
        # 5. Permissions
        # umask 000 means created files have 777 permissions
        anon_umask=000
        file_open_mode=0777
        
        # 6. Logging & Misc
        dirmessage_enable=YES
        use_localtime=YES
        xferlog_enable=YES
        connect_from_port_20=YES
        pam_service_name=vsftpd
        ssl_enable=NO
        pasv_enable=YES
        pasv_min_port=10000
        pasv_max_port=10100
        
        # 7. Disable User List
        userlist_enable=NO
    - require:
      - pkg: vulnerable_vsftpd_pkg
      - file: allow_root_ftp
      - file: ftp_root_dir

###############################################
# Enable + start vsftpd
###############################################
vulnerable_vsftpd_service:
  service.running:
    - name: vsftpd
    - enable: True
    - require:
      - file: vulnerable_vsftpd_config
      - file: vulnerable_vsftpd_chroot_dir
    - watch:
      - file: vulnerable_vsftpd_config
      - file: allow_root_ftp
