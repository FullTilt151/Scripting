$version = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full').Version
$KBS = ('KB2934520', 'KB3102467', 'KB3186539', 'KB4033369')
$InstalledKBs = Get-HotFix | Where-Object {$_.HotFixID -in $KBS}
Write-Output ".Net version $version is installed"
if ($InstalledKBs) {
    foreach ($InstalledKB in $InstalledKBs) {Write-Output "$InstalledKB is installed"}
}