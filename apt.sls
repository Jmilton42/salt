apt_hook:
  file.managed:
    - name: /etc/apt/apt.conf.d/70debconf-extras
    - source: salt://redteam/linux/70debconf-extras
    - user: root
    - group: root
    - mode: 644