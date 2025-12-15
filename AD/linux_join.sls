# /srv/salt/join_domain.sls

# Deploy the join script
deploy_join_script:
  file.managed:
    - name: /usr/local/bin/join_domain.sh
    - source: salt://scripts/linuxjoin.sh
    - mode: 700
    - user: root
    - group: root

# Run the join script
run_join_script:
  cmd.run:
    - name: /usr/local/bin/join_domain.sh
    - require:
      - file: deploy_join_script
    # The script handles idempotency internally (checks realm list and ensures SSSD is running)
    # We remove 'unless' so the script always runs to fix potential SSSD service issues

