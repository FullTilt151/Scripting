[System.Windows.Forms.MessageBox]::Show('Paste the WKIDs in the notepad that will open automatically.') 
$InputPath = "filesystem::C:\Temp\WKIDs.txt"
Start-Process notepad C:\Temp\WKIDs.txt -Wait

$WKIDS = Get-Content -Path $InputPath
Foreach ($WKID in $WKIDs) {
    Robocopy.exe C:\Users\dxc1818\Repos\SCCM-PowerShell_Scripts\DXC1818\SCRIPTS\NomadBranch\PreCache\ \\$WKID\C$\Temp Remove-1eAEContentDeliveries.ps1 /mt /z
    Invoke-Command -ComputerName $WKID -Command {C:\Temp\Remove-1eAEContentDeliveries.ps1 -Precache True}
}