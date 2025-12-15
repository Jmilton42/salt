install:
  pkg.installed:
    - pkgs:
      - apache2
      - mariadb-server
      - php
      - libapache2-mod-php
      - php-mysql
      - php-curl
      - php-gd
      - php-mbstring
      - php-xml
      - php-xmlrpc
      - php-zip

modules:
  cmd.run:
    - name: a2enmod rewrite
    - require:
      - pkg: install

mariadb:
  service.running:
    - name: mariadb
    - enable: True
    - require:
      - pkg: install

db_create:
  cmd.run:
    - name: mysql -e "CREATE DATABASE IF NOT EXISTS wordpress;"
    - require:
      - service: mariadb

db_pw:
  cmd.run:
    - name: mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '';"
    - require:
      - service: mariadb

db_privs:
  cmd.run:
    - name: mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost';"
    - require:
      - service: mariadb
      - cmd: db_create

db_flush:
  cmd.run:
    - name: mysql -e "FLUSH PRIVILEGES;"
    - require:
      - service: mariadb
      - cmd: db_privs

wp_download:
  cmd.run:
    - name: wget https://wordpress.org/wordpress-6.3.1.tar.gz
    - cwd: /tmp
    - unless: test -f /var/www/html/wp-config.php

wp_extract:
  cmd.run:
    - name: tar -xvf wordpress-6.3.1.tar.gz
    - cwd: /tmp
    - unless: test -f /var/www/html/wp-config.php
    - require:
      - cmd: wp_download

wp_move:
  cmd.run:
    - name: mv /tmp/wordpress/* /var/www/html/ && mv /tmp/wordpress/.htaccess /var/www/html/ 2>/dev/null || true
    - unless: test -f /var/www/html/wp-config.php
    - require:
      - cmd: wp_extract

wp_permissions:
  file.directory:
    - name: /var/www/html
    - user: www-data
    - group: www-data
    - mode: 755
    - recurse:
      - user
      - group
    - require:
      - cmd: wp_move

wp_config:
  file.managed:
    - name: /var/www/html/wp-config.php
    - source: salt://wp-config.php
    - user: www-data
    - group: www-data
    - mode: 755
    - makedirs: True
    - create: True

wp_cleanup:
  file.absent:
    - name: /tmp/wordpress-6.3.1.tar.gz
    - require:
      - cmd: wp_move
  cmd.run:
    - name: rm -rf /tmp/wordpress
    - require:
      - cmd: wp_move

wp-cli_download:
  cmd.run:
    - name: wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp
    - unless: test -f /usr/local/bin/wp
    - require:
      - cmd: wp_move
  file.managed:
    - name: /usr/local/bin/wp
    - mode: 755

# Get the server's IP address and use it for WordPress installation
wp_install:
  cmd.run:
    - name: |
        SERVER_IP=$(hostname -I | awk '{print $1}')
        wp core install --url="http://${SERVER_IP}" --title="Gabe's Hardware Hacking" --admin_user=admin --admin_password="machine-PLACE-4!" --admin_email=administrator@machine.place --allow-root
    - cwd: /var/www/html
    - unless: wp core is-installed --allow-root
    - require:
      - file: /var/www/html/wp-config.php
      - cmd: wp-cli_download
      - cmd: wp_move

ultimate_member_download:
  cmd.run:
    - name: wget https://downloads.wordpress.org/plugin/ultimate-member.2.6.6.zip
    - cwd: /var/www/html/wp-content/plugins
    - unless: test -f /var/www/html/wp-content/plugins/ultimate-member.2.6.6.zip
    - require:
      - cmd: wp_install

ultimate_member_setup:
  cmd.run:
    - name: unzip -o ultimate-member.2.6.6.zip
    - cwd: /var/www/html/wp-content/plugins
    - unless: test -d /var/www/html/wp-content/plugins/ultimate-member
    - require:
      - cmd: ultimate_member_download
      - cmd: wp_install
  file.directory:
    - name: /var/www/html/wp-content/plugins/ultimate-member
    - user: www-data
    - group: www-data
    - mode: 755
    - recurse:
      - user
      - group

ultimate_member_delete:
  file.absent:
    - name: /var/www/html/wp-content/plugins/ultimate-member.2.6.6.zip

ultimate_member_install:
  cmd.run:
    - name: wp plugin activate ultimate-member --allow-root
    - cwd: /var/www/html
    - unless: wp plugin is-active ultimate-member --allow-root
    - require:
      - cmd: wp-cli_download
      - file: ultimate_member_setup
      - cmd: wp_install

disable_default:
  cmd.run:
    - name: a2dissite 000-default.conf
    - onlyif: a2query -s 000-default.conf
    - require:
      - pkg: install

apache_config:
  file.managed:
    - name: /etc/apache2/sites-available/wordpress.conf
    - source: salt://wordpress.conf
    - user: root
    - group: root
    - mode: 644

wp_enable:
  cmd.run:
    - name: a2ensite wordpress.conf
    - unless: a2query -s wordpress.conf
    - require:
      - pkg: install
      - file: apache_config

daemon_reload:
  cmd.run:
    - name: systemctl daemon-reload
    - require:
      - pkg: install
      - cmd: wp_install
      - cmd: ultimate_member_install
      - cmd: wp_enable

apache2:
  service.running:
    - name: apache2
    - enable: True
    - reload: True
    - require:
      - pkg: install
      - cmd: wp_install
      - cmd: ultimate_member_install
      - cmd: wp_enable
      - cmd: daemon_reload
    - watch:
      - file: apache_config
