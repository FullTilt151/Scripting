$comps = get-content c:\temp\wkids.txt

$HardwareInventoryID = '{00000000-0000-0000-0000-000000000001}'

foreach ($wkid in $comps) {
    if (Test-Connection $wkid -Count 1 -ErrorAction SilentlyContinue) {
        Get-Service NomadBranch -ComputerName $wkid | Stop-Service -Force -PassThru
        Get-Service CcmExec -ComputerName $wkid | Stop-Service -Force -PassThru
        Start-Sleep -Seconds 15
        Get-ChildItem \\$wkid\c$\windows\ccm\logs | Remove-Item -Force -Verbose -ErrorAction SilentlyContinue
        Get-Service NomadBranch -ComputerName $wkid | Start-Service -PassThru
        Get-Service CcmExec -ComputerName $wkid | Start-Service -PassThru
        Start-Sleep -Seconds 30
        Get-WmiObject -Namespace 'Root\CCM\INVAGT' -Class 'InventoryActionStatus' -Filter "InventoryActionID='$HardwareInventoryID'" -ComputerName $wkid -Verbose | Remove-WmiObject
        Invoke-WmiMethod -Namespace root\ccm -Class sms_client -Name TriggerSchedule -ComputerName $wkid -ArgumentList "{00000000-0000-0000-0000-000000000001}"
    } else {
        write-host "$wkid offline"
    }
}