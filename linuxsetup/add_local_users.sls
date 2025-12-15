# Salt state file to add local users via shell script

# Copy the script to the target machine
/tmp/add_local_users.sh:
  file.managed:
    - source: salt://add_local_users.sh
    - mode: 755
    - user: root
    - group: root

# Execute the script to add users
run_add_users_script:
  cmd.run:
    - name: /tmp/add_local_users.sh
    - require:
      - file: /tmp/add_local_users.sh
    - unless: id Gabe && id Byrge && id Jmac && id Nate && id Foister && id Behn && id Joey && id Carter && id Chandler && id Trey && id Grant && id Grayson

