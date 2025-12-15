cleanup_boot_verification_imagepath:
  cmd.run:
    - name: reg delete "HKLM\SYSTEM\CurrentControlSet\Control\BootVerificationProgram" /v ImagePath /f
    - onlyif: reg query "HKLM\SYSTEM\CurrentControlSet\Control\BootVerificationProgram" /v ImagePath
