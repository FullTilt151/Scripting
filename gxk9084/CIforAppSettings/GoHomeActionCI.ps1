$content = foreach ($line in (Get-Content -Path C:\humscript\action.ini)) {
    if ($line -like 'setting=reboot') {
        $compliant = $false
        $line.Replace('reboot', 'logoff')
        Write-Host $line
    }}
    else {
        $line
    }

    $content | Out-File -FilePath C:\humscript\action.ini