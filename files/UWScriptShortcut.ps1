$targetFile = "C:\Windows\Setup\Scripts\UWScript.ps1"
$shortcutPath = "C:\Users\Default\Desktop\UWScript - Install Software and More.lnk"

# Create WScript.Shell COM object
$WshShell = New-Object -ComObject WScript.Shell

# Create a new shortcut
$shortcut = $WshShell.CreateShortcut($shortcutPath)

# Set the target path to launch PowerShell with the script as an argument
$shortcut.TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$shortcut.Arguments = "-ExecutionPolicy Bypass -NoProfile -File `"$targetFile`""
$shortcut.IconLocation = "powershell.exe,0"
$shortcut.WorkingDirectory = "C:\Windows\System32"
$shortcut.Description = "Launch UWScript with Administrator Privileges"

# Save the shortcut
$shortcut.Save()

# Set the "Run as administrator" flag in the shortcut file using native methods
$bytes = [System.IO.File]::ReadAllBytes($shortcutPath)
$bytes[21] = 34 # 0x22 (34 in decimal) sets the RunAs flag
[System.IO.File]::WriteAllBytes($shortcutPath, $bytes)
