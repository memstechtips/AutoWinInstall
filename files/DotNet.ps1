function Enable-DotNetFramework {
    $sourceFound = $false
    $sourceCabFile = ""

    # Dynamically search through all filesystem drives
    foreach ($drive in Get-PSDrive -PSProvider FileSystem) {
        $driveLetter = "$($drive.Name):"
        $sxsFolderPath = "$driveLetter\sources\sxs"
        
        # Check if the folder exists
        if (Test-Path $sxsFolderPath) {
            Write-Host "Found sources folder at $sxsFolderPath" -ForegroundColor Green

            # Search for the .cab file
            $cabFile = Get-ChildItem -Path $sxsFolderPath -Filter "*.cab" -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "netfx3.*ondemand-package" }

            if ($cabFile) {
                $sourceCabFile = $sxsFolderPath
                Write-Host "Found .NET Framework 3.5 CAB file in folder: $sxsFolderPath" -ForegroundColor Green
                $sourceFound = $true
                break
            }
        }
        else {
            Write-Host "Sources folder not found at $sxsFolderPath" -ForegroundColor Yellow
        }
    }

    if ($sourceFound) {
        $dismCommand = "/Online /Enable-Feature /FeatureName:NetFx3 /All /LimitAccess /Source:$sourceCabFile"
        Write-Host "Executing DISM command: $dismCommand" -ForegroundColor Yellow

        Start-Process -FilePath dism.exe -ArgumentList $dismCommand -Wait -NoNewWindow

        Write-Host "DISM command completed." -ForegroundColor Green
    }
    else {
        Write-Host "Source .cab file for .NET Framework 3.5 not found." -ForegroundColor Red
    }
    Write-Host ".NET3.5 Enabled. You can close this window . . ." -BackgroundColor Green
}

Enable-DotNetFramework
exit
