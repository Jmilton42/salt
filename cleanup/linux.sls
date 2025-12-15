Clear_Temp:
  file.directory:
    - name: /tmp
    - clean: True
    - order: 1
Clear_Salt_Cache:
  module.run:
    - name: saltutil.clear_cache
    - order: 2
Clear_Salt_Logs:
  cmd.run:
    - name: echo > /var/log/salt/minion
    - order: 3
