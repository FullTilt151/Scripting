$content = foreach ($line in (Get-Content -Path C:\humscript\action.ini)) {
    if ($line -eq 'setting=shutdown') {
        $line.Replace('shutdown', 'logoff')
    }
    else {
        $line
    }
}
$content | Out-File -FilePath C:\humscript\action.ini
