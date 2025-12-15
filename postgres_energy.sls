deploy_install_script:
  file.managed:
    - name: C:\install_postgres.ps1
    - source: salt://install_postgres.ps1
    - makedirs: True

install_postgresql:
  cmd.run:
    - name: C:\install_postgres.ps1
    - shell: powershell
    - unless: Test-Path "C:\Program Files\PostgreSQL\16\bin\postgres.exe"
    - require:
      - file: deploy_install_script
    - timeout: 900

wait_for_postgres:
  cmd.run:
    - name: |
        Start-Sleep -Seconds 10
        $count = 0
        while ($count -lt 30) {
          try {
            & "C:\Program Files\PostgreSQL\16\bin\pg_isready.exe" -h localhost -p 5432
            if ($LASTEXITCODE -eq 0) { exit 0 }
          } catch {}
          Start-Sleep -Seconds 2
          $count++
        }
        exit 1
    - shell: powershell
    - require:
      - cmd: install_postgresql

deploy_setup_sql:
  file.managed:
    - name: C:\setup.sql
    - source: salt://energy_stock/setup.sql
    - require:
      - cmd: wait_for_postgres

create_energy_database:
  cmd.run:
    - name: |
        $env:PGPASSWORD = 'postgres'
        & "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -h localhost -p 5432 -f "C:\setup.sql"
    - shell: powershell
    - unless: |
        $env:PGPASSWORD = 'postgres'
        & "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -h localhost -p 5432 -lqt | Select-String -Pattern "energy_stock"
    - require:
      - file: deploy_setup_sql

configure_pg_hba:
  file.managed:
    - name: C:\Program Files\PostgreSQL\16\data\pg_hba.conf
    - source: salt://pg_hba.conf
    - makedirs: True
    - require:
      - cmd: install_postgresql

restart_postgresql:
  cmd.run:
    - name: |
        $service = Get-Service | Where-Object { $_.Name -like 'postgresql*' } | Select-Object -First 1
        if ($service) {
          Restart-Service -Name $service.Name -Force
        }
    - shell: powershell
    - require:
      - file: configure_pg_hba

