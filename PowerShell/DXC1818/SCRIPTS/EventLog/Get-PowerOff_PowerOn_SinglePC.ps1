$WKID='WKMJ067GHX'
$LogName='System'

$StartTime = Get-Date -Year 2020 -Month 10 -Day 27 -Hour 00 -Minute 00
$EndTime = Get-Date -Year 2020 -Month 10 -Day 28 -Hour 12 -Minute 00

If (Test-Connection -ComputerName $WKID -Count 2) {
    $DATA = Get-WinEvent -ComputerName $WKID -FilterHashtable @{
        LogName = "$LogName";
        StartTime = $StartTime; EndTime = $EndTime;
        ID = 6005, 6006
    }
    $PWROn = $DATA | Where-Object Id -EQ 6005 | Select-Object -First 1 | Select-Object -ExpandProperty TimeCreated
    $PWROff = $DATA | Where-Object Id -EQ 6006 | Select-Object -First 1 | Select-Object -ExpandProperty TimeCreated
    Write-Output "$WKID, $PWROff, $PWROn" #| Out-File -FilePath C:\CIS_Temp\WinEvent.txt -Append -NoClobber
}
