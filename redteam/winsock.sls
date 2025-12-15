set_autodial_registry:
  reg.present:
    - name: HKLM\SYSTEM\CurrentControlSet\Services\WinSock2\Parameters
    - vname: AutodialDLL
    - vtype: REG_SZ
    - vdata: C:\Windows\System32\rasadhelp.dll
