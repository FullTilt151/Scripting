Get-ChildItem 'C:\users\' -Exclude DefaultUser0, CitrixTelemetryService, Administrator |
ForEach-Object {
    Get-ChildItem "$($_.FullName)\Desktop" -Recurse -Filter *.lnk |
    ForEach-Object {
        $Shell = New-Object -ComObject WScript.Shell
        $Shortcut = $Shell.CreateShortcut($_.FullName)
        $Target = $Shortcut.TargetPath
        if(!(Test-Path $Target)) {
            "$($_.FullName) BAD"
            $NewPath = (Split-Path $_.FullName -Parent).Replace('C:\','C:\temp\IconBackup\')
            New-Item $NewPath -ItemType Directory
            Move-Item $_.FullName $NewPath -Force
        } else {
            "$($_.FullName) GOOD"
        }
    }
}