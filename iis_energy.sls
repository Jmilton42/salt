download_php:
  cmd.run:
    - name: Invoke-WebRequest -Uri "https://windows.php.net/downloads/releases/php-8.3.28-nts-Win32-vs16-x64.zip" -OutFile "C:\php.zip"
    - shell: powershell
    - unless: if (Test-Path "C:\php.zip") { exit 0 } else { exit 1 }

extract_php:
  archive.extracted:
    - name: C:\php
    - source: C:\php.zip
    - enforce_toplevel: False
    - require:
      - cmd: download_php

install_iis_features:
  win_servermanager.installed:
    - features:
      - Web-Server
      - Web-CGI
    - require:
      - cmd: download_php

configure_php_ini:
  file.managed:
    - name: C:\php\php.ini
    - source: C:\php\php.ini-production
    - require:
      - archive: extract_php

enable_php_extensions:
  file.replace:
    - name: C:\php\php.ini
    - pattern: ';extension=pgsql'
    - repl: 'extension=pgsql'
    - require:
      - file: configure_php_ini

enable_php_pdo_sqlite:
  file.replace:
    - name: C:\php\php.ini
    - pattern: ';extension=pdo_pgsql'
    - repl: 'extension=pdo_pgsql'
    - require:
      - file: enable_php_extensions

set_extension_dir:
  file.replace:
    - name: C:\php\php.ini
    - pattern: ';extension_dir = "ext"'
    - repl: 'extension_dir = "C:\\php\\ext"'
    - require:
      - file: configure_php_ini

unlock_handlers_section:
  cmd.run:
    - name: C:\Windows\System32\inetsrv\appcmd.exe unlock config -section:system.webServer/handlers
    - shell: cmd
    - require:
      - archive: extract_php

configure_iis_fastcgi:
  cmd.run:
    - name: C:\Windows\System32\inetsrv\appcmd.exe set config -section:system.webServer/fastCgi /+[fullPath='C:\php\php-cgi.exe'] /commit:apphost
    - shell: cmd
    - unless: C:\Windows\System32\inetsrv\appcmd.exe list config -section:system.webServer/fastCgi | findstr /C:"php-cgi.exe"
    - require:
      - cmd: unlock_handlers_section
      - file: enable_php_extensions
      - file: enable_php_pdo_sqlite

configure_iis_php_handler:
  cmd.run:
    - name: C:\Windows\System32\inetsrv\appcmd.exe set config -section:system.webServer/handlers /+[name='PHP-FastCGI',path='*.php',verb='GET,HEAD,POST',modules='FastCgiModule',scriptProcessor='C:\php\php-cgi.exe',resourceType='Either'] /commit:apphost
    - shell: cmd
    - unless: C:\Windows\System32\inetsrv\appcmd.exe list config -section:system.webServer/handlers | findstr /C:"PHP-FastCGI"
    - require:
      - cmd: configure_iis_fastcgi

set_default_document:
  cmd.run:
    - name: |
        & $env:windir\system32\inetsrv\appcmd.exe set config -section:system.webServer/defaultDocument /enabled:"True" /commit:apphost
        & $env:windir\system32\inetsrv\appcmd.exe set config -section:system.webServer/defaultDocument /+"files.[value='index.php']" /commit:apphost
        & $env:windir\system32\inetsrv\appcmd.exe set config -section:system.webServer/defaultDocument /-"files.[value='index.php']" /commit:apphost
        & $env:windir\system32\inetsrv\appcmd.exe set config -section:system.webServer/defaultDocument /+"files.[value='index.php']" /commit:apphost
    - shell: powershell
    - require:
      - cmd: configure_iis_php_handler

delete_default_iis_files:
  file.absent:
    - names:
      - C:\inetpub\wwwroot\iisstart.htm
      - C:\inetpub\wwwroot\iisstart.png

deploy_web_config:
  file.managed:
    - name: C:\inetpub\wwwroot\web.config
    - source: salt://energy_stock/web.config
    - require:
      - file: delete_default_iis_files

deploy_index_php:
  file.managed:
    - name: C:\inetpub\wwwroot\index.php
    - source: salt://energy_stock/index.php
    - require:
      - file: deploy_web_config

deploy_admin_php:
  file.managed:
    - name: C:\inetpub\wwwroot\admin.php
    - source: salt://energy_stock/admin.php
    - require:
      - file: delete_default_iis_files

deploy_style_css:
  file.managed:
    - name: C:\inetpub\wwwroot\style.css
    - source: salt://energy_stock/style.css
    - require:
      - file: delete_default_iis_files

set_file_ownership:
  cmd.run:
    - name: |
        icacls "C:\inetpub\wwwroot\index.php" /setowner "IIS_IUSRS"
        icacls "C:\inetpub\wwwroot\admin.php" /setowner "IIS_IUSRS"
        icacls "C:\inetpub\wwwroot\style.css" /setowner "IIS_IUSRS"
    - shell: powershell
    - require:
      - file: deploy_index_php
      - file: deploy_admin_php
      - file: deploy_style_css

set_iis_permissions_reset:
  cmd.run:
    - name: |
        icacls "C:\inetpub\wwwroot\*.php" /reset
        icacls "C:\inetpub\wwwroot\*.css" /reset
    - shell: powershell
    - require:
      - cmd: set_file_ownership

set_iis_permissions_iusrs:
  cmd.run:
    - name: cmd.exe /c 'icacls "C:\inetpub\wwwroot\*.php" /grant "IIS_IUSRS:(F)"'
    - shell: powershell
    - require:
      - cmd: set_iis_permissions_reset

set_iis_permissions_iusr:
  cmd.run:
    - name: cmd.exe /c 'icacls "C:\inetpub\wwwroot\*.php" /grant "IUSR:(F)"'
    - shell: powershell
    - require:
      - cmd: set_iis_permissions_iusrs

set_iis_permissions_css:
  cmd.run:
    - name: cmd.exe /c 'icacls "C:\inetpub\wwwroot\*.css" /grant "IIS_IUSRS:(F)" /grant "IUSR:(F)"'
    - shell: powershell
    - require:
      - cmd: set_iis_permissions_iusr

enable_anonymous_auth:
  cmd.run:
    - name: |
        & $env:windir\system32\inetsrv\appcmd.exe set config /section:anonymousAuthentication /enabled:true
    - shell: powershell
    - require:
      - cmd: set_iis_permissions_css

# 1. Download the installer to a temp folder on the Windows minion
download_vc_redist:
  file.managed:
    - name: 'C:\Windows\Temp\vc_redist.x64.exe'
    - source: https://aka.ms/vs/17/release/vc_redist.x64.exe
    # Ideally, host this file internally and change the source URL to your internal web server or salt://
    - skip_verify: True

# 2. Run the installer with the specific flags for this executable
install_vc_redist_exe:
  cmd.run:
    - name: 'C:\Windows\Temp\vc_redist.x64.exe /install /quiet /norestart'
    - check_cmd:
      - 'reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" /v Version'
    - require:
      - file: download_vc_redist

restart_iis:
  cmd.run:
    - name: iisreset /restart
    - shell: powershell
    - require:
      - cmd: configure_iis_php_handler
      - cmd: set_iis_permissions_iusr

