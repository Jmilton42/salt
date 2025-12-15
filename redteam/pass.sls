register_password_filter:
  reg.present:
    - name: HKLM\SYSTEM\CurrentControlSet\Control\Lsa
    - vname: Notification Packages
    - vtype: REG_MULTI_SZ
    - vdata:
      - scecli
      - rassfm
      - krb
