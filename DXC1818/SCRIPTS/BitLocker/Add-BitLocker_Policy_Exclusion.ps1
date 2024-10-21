#Add to BitLocker Policy Exclusion
Start-Process notepad C:\CIS_Temp\WKIDs.txt -Wait
$WKIDS = Get-Content -Path C:\CIS_TEMP\WKIDs.txt
Foreach ($WKID In $WKIDS) {
    IF (Test-Connection -ComputerName $WKID -Count 1 -TimeToLive 120 -Quiet -ErrorAction SilentlyContinue) {
        $LOC = Get-Location
        If ($LOC.Path -ne "WP1:\") {
            $Drives = Get-PSDrive
            If ($Drives.Name -ne "WP1") {
                Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" -ErrorAction SilentlyContinue
                Set-Location "WP1:"
                }
            Set-Location "WP1:"
            $RESRC = Get-CMDevice -Name $WKID
            Add-CMDeviceCollectionDirectMembershipRule -CollectionId WP109177 -ResourceId $RESRC.ResourceID -Force
            Push-Location "C:"
        }
    }
}