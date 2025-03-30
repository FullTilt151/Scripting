#$WKID='WKPC127X5C'
$WKIDS = Get-Content -Path C:\Temp\WKIDs.txt
$LogName='System'

$StartTime = Get-Date -Year 2020 -Month 10 -Day 28 -Hour 00 -Minute 00
$EndTime = Get-Date -Year 2020 -Month 10 -Day 29 -Hour 12 -Minute 00

ForEach ($WKID in $WKIDS) {
    If (Test-Connection -ComputerName $WKID -Count 2) {
        $DATA = Get-WinEvent -ComputerName $WKID -FilterHashtable @{
            LogName = "$LogName";
            StartTime = $StartTime; EndTime = $EndTime;
            ID = 6005, 6006
        }
        $PWROn = $DATA | Where-Object Id -EQ 6005 | Select-Object -First 1 | Select-Object -ExpandProperty TimeCreated
        $PWROff = $DATA | Where-Object Id -EQ 6006 | Select-Object -First 1 | Select-Object -ExpandProperty TimeCreated
        Write-Output "$WKID, $PWROff, $PWROn" | Out-File -FilePath C:\CIS_Temp\WinEvent.txt -Append -NoClobber
        Clear-Variable -Name PWROn -ErrorAction SilentlyContinue
        Clear-Variable -Name PWROff -ErrorAction SilentlyContinue
    }
    Else {
        Write-Output "$WKID, Offline" | Out-File -FilePath C:\CIS_Temp\WinEvent.txt -Append -NoClobber
        Clear-Variable -Name PWROn -ErrorAction SilentlyContinue
        Clear-Variable -Name PWROff -ErrorAction SilentlyContinue
    }
    Clear-Variable -Name PWROn -ErrorAction SilentlyContinue
    Clear-Variable -Name PWROff -ErrorAction SilentlyContinue
}
Clear-Variable -Name PWROn -ErrorAction SilentlyContinue
Clear-Variable -Name PWROff -ErrorAction SilentlyContinue
