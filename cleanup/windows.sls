Clear_Temp:
    file.directory:
      - name: C:\Users\Administrator\AppData\Local\Temp
      - clean: True
      - order: 1
Delete_PS_History:
    cmd.run:
      - name: for /d %x in (C:\Users\*) do @(del /q "%x\AppData\Roaming\Microsoft\Windows\PowerShell\PsReadLine\ConsoleHost_history.txt")
      - shell: cmd
      - order: 2
Clear_Salt_Cache:
    module.run:
      - name: saltutil.clear_cache
      - order: 3
Clear_Salt_Logs:
    cmd.run:
      - name: break>C:\Salt\var\log\salt\minion
      - order: 4
