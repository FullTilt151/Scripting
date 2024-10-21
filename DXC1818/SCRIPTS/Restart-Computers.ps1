#Requires -Version 7.0
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Windows.Forms.MessageBox]::Show('Paste the WKIDs in the notepad that will open automatically.') 
$InputPath = "filesystem::C:\Temp\WKIDs.txt"
Start-Process notepad C:\Temp\WKIDs.txt -Wait

#Import-Module 'C:\Program Files (x86)\ConfigMgr10\bin\ConfigurationManager.psd1'

$wkids = Get-Content -Path $InputPath
$wkids | ForEach-Object -Parallel {
    if (Test-Connection -ComputerName $_ -Count 2 -ErrorAction SilentlyContinue) {
        Restart-Computer -ComputerName $_ -Force }
    }