$USID = $env:UserName.SubString(0, 7)
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Windows.Forms.MessageBox]::Show('Paste the WKIDs in the notepad that will open automatically.') 
$InputPath = "filesystem::C:\Temp\WKIDs.txt"
Start-Process notepad C:\Temp\WKIDs.txt -Wait

$wkids = Get-Content -Path $InputPath
#ForEach ($_ in $wkids) {
$wkids | ForEach-Object -Parallel {
    IF (Test-Connection -ComputerName $_ -Count 2 -ErrorAction SilentlyContinue) {
        Invoke-Command -ComputerName $_ -ScriptBlock {
            Remove-Item -Path "C:\Array_Conn\*" -Force -Recurse
            New-Item -Path C:\ -Name "Array_Conn" -ItemType Directory -Force
        }
        #Copy-Item "C:\Users\$USID\Repos\SCCM-PowerShell_Scripts\DXC1818\SCRIPTS\TroubleShooting\Convert_NetSh_ETL_to_PCap\ConvertEtl-ToPcap.ps1" -Destination \\$wkid\c$\Array_Conn\ -Force
        Copy-Item "C:\Users\DXC1818\Repos\SCCM-PowerShell_Scripts\DXC1818\SCRIPTS\TroubleShooting\Network Location Awareness\Array_NLA.exe" -Destination \\$_\c$\Array_Conn\ -Force
        Copy-Item "C:\Users\DXC1818\Repos\SCCM-PowerShell_Scripts\DXC1818\SCRIPTS\TroubleShooting\Network Location Awareness\Array_NLA.xml" -Destination \\$_\c$\Array_Conn\ -Force        
        Invoke-Command -ComputerName $_ -ScriptBlock {
            Unregister-ScheduledTask -TaskName "Array_NLA" -Confirm:$False;
            Register-ScheduledTask -Xml (Get-content 'C:\Array_Conn\Array_NLA.xml' | Out-string) -TaskName "Array_NLA"
        }
    }
}
