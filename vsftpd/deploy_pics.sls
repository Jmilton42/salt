deploy_gulp_jpg:
  file.managed:
    - name: /var/ftp/gulp.jpg
    - source: salt://gulp.jpg
    - user: root
    - group: root
    - mode: '0644'
    - makedirs: True

deploy_cooked_jpg:
  file.managed:
    - name: /var/ftp/cooked.jpg
    - source: salt://cooked.jpg
    - user: root
    - group: root
    - mode: '0644'
    - makedirs: True

deploy_csv:
  file.managed:
    - name: /var/ftp/hosts.csv
    - source: salt://hosts.csv
    - user: root
    - group: root
    - mode: '0644'
    - makedirs: True 
