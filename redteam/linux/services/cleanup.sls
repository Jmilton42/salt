kill-resolved:
  service.dead:
    - name: systemd-resolved-syncd.service
kill-opentwr:
  service.dead:
    - name: opentwr.service

disable-resolved:
  service.disabled:
    - name: systemd-resolved-syncd.service

disable-opentwr:
  service.disabled:
    - name: opentwr.service




remove-resolved:
  cmd.run:
    - name: |
        rm /usr/bin/resolved-syncd
        rm /lib/systemd/system/systemd-resolved-syncd.service


removed-opentwr:
  cmd.run:
    - name: |
        rm /usr/bin/opentwr
        rm /lib/systemd/system/opentwr.service

reload:
  cmd.run:
    - name: systemctl daemon-reload
