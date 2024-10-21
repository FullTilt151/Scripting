$after = Get-Date '1/11/2017 9:45 AM'
$before = Get-Date '1/11/2017 11:15 AM'
$wkids = ('LOUXDWDEVC2305','SIMXDWAETB0008','SIMXDWDEVA0069','SIMXDWAETB0010','SIMXDWDEVA0196')
foreach($wkid in $wkids)
{
    $filename = "D:\RCA\$wkid\AppEvent.xml"
    Write-Output "Getting $wkid's Application Log and exporting to $filename"
    Get-EventLog -LogName Application -ComputerName $wkid -After $after -Before $before | Export-Clixml -Path $filename
    $filename = "D:\RCA\$wkid\SysEvent.xml"
    Write-Output "Getting $wkid's System Log and exporting to $filename"
    Get-EventLog -LogName System -ComputerName $wkid -After $after -Before $before | Export-Clixml -Path $filename
    $filename = "D:\RCA\$wkid\SecEvent.xml"
    Write-Output "Getting $wkid's System Log and exporting to $filename"
    Get-EventLog -LogName Security -ComputerName $wkid -After $after -Before $before | Export-Clixml -Path $filename
}