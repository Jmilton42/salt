# /srv/salt/troubleshoot.sls

deploy_troubleshoot_script:
  file.managed:
    - name: /usr/local/bin/troubleshoot_domain.sh
    - source: salt://scripts/troubleshoot_domain.sh
    - mode: 700
    - user: root
    - group: root

run_troubleshoot_script:
  cmd.run:
    - name: /usr/local/bin/troubleshoot_domain.sh
    - require:
      - file: deploy_troubleshoot_script

