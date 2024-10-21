param(
[switch]$Restart
)

Import-Module ServerManager -ErrorAction SilentlyContinue
if ($Restart) {
    Get-WindowsFeature rds* | Remove-Windowsfeature -Restart
} else {
    Get-WindowsFeature rds* | Remove-Windowsfeature
}