#Requires -Version 7.0
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Windows.Forms.MessageBox]::Show('Paste the WKIDs in the notepad that will open automatically.') 
$InputPath = "filesystem::C:\Temp\WKIDs.txt"
Start-Process notepad C:\Temp\WKIDs.txt -Wait

#Import-Module 'C:\Program Files (x86)\ConfigMgr10\bin\ConfigurationManager.psd1'

$wkids = Get-Content -Path $InputPath
$wkids | ForEach-Object -Parallel {
    if (Test-Connection -ComputerName $_ -Count 2 -ErrorAction SilentlyContinue) {
        $CurrentSetting = Get-CimInstance -ComputerName $_ -Namespace root\wmi -Class Lenovo_BiosSetting -Filter "CurrentSetting like 'Secure%boot%'" | Select-Object -ExpandProperty CurrentSetting
        if ($CurrentSetting -ne $null) {
            $WINSB = Invoke-Command -ComputerName $_ -ScriptBlock {Confirm-SecureBootUEFI}
            Write-Output "$_,$CurrentSetting,$WINSB" | Out-File -Path "C:\CIS_TEMP\SecureBootResults.txt" -Append -NoClobber
        } else {
            Write-Output "$_ NULL" | Out-File -Path "C:\CIS_TEMP\SecureBootResults.txt" -Append -NoClobber
        }
    } else {
        Write-Output "$_ OFFLINE" | Out-File -Path "C:\CIS_TEMP\SecureBootResults.txt" -Append -NoClobber
    }
}