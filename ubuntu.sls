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
    - name: mysql -e "CREATE DATABASE wordpress;"
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
    - cwd: /var/www/html

wp_extract:
  cmd.run:
    - name: tar -xvf wordpress-6.3.1.tar.gz
    - cwd: /var/www/html
    - require:
      - cmd: wp_download

apache_index_delete:
  file.absent:
    - name: /var/www/html/index.html

wp_move:
  cmd.run:
    - name: cp -r wordpress/* . && cp wordpress/.htaccess . 2>/dev/null; rm -rf wordpress
    - cwd: /var/www/html
    - require:
      - cmd: wp_extract

wp_setup:
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

wp_delete:
  file.absent:
    - name: /var/www/html/wordpress-6.3.1.tar.gz

wp-cli_download:
  cmd.run:
    - name: wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp
    - unless: test -f /usr/local/bin/wp
    - require:
      - file: wp_setup
  file.managed:
    - name: /usr/local/bin/wp
    - mode: 755

wp_install:
  cmd.run:
    - name: wp core install --url=$(hostname -I | awk '{print $1}') --title="Gabe's Hardware Hacking" --admin_user=admin --admin_password="machine-PLACE-4!" --admin_email=admin@example.com --allow-root
    - cwd: /var/www/html
    - require:
      - file: /var/www/html/wp-config.php
      - cmd: wp-cli_download
      - file: wp_setup

ultimate_member_download:
  cmd.run:
    - name: wget https://downloads.wordpress.org/plugin/ultimate-member.2.6.6.zip
    - cwd: /var/www/html/wp-content/plugins
    - require:
      - cmd: wp_install

ultimate_member_setup:
  cmd.run:
    - name: unzip -o ultimate-member.2.6.6.zip
    - cwd: /var/www/html/wp-content/plugins
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
    - require:
      - pkg: install

apache_config:
  file.managed:
    - name: /etc/apache2/sites-available/wordpress.conf
    - source: salt://wordpress.conf
    - user: root
    - group: root
    - mode: 755

wp_enable:
  cmd.run:
    - name: a2ensite wordpress.conf
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
