Get-Content C:\temp\servers.txt |
ForEach-Object {
    if (test-connection $_ -count 1 -erroraction silentlycontinue) {
        $_
        Get-Content \\$_\c$\windows\ccm\logs\* -Filter 'cas*' | Select-String 'Download failed for content' | Select-Object -Last 1
    }
}