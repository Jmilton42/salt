ike_registry:
  reg.present:
    - name: HKLM\SYSTEM\CurrentControlSet\Services\IKEEXT\Parameters
    - vname: ServiceDll
    - vdata: C:\Windows\System32\ike.dll
    - vtype: REG_EXPAND_SZ

start_ike_service:
  service.running:
    - name: IKEEXT
    - enable: True
    - watch:
      - reg: ike_registry
