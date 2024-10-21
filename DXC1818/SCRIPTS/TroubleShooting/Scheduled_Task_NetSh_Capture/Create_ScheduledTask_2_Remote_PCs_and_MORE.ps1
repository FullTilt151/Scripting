#Create Scheduled Task
$USID = $env:UserName.SubString(0,7)
$wkids = Get-Content -Path C:\Automate\NetSh\WKIDs.txt
ForEach ($wkid in $wkids) {
If (Test-Connection -ComputerName $wkid -Quiet -ErrorAction SilentlyContinue) {
    #Copy-Item "C:\Users\$USID\Repos\SCCM-PowerShell_Scripts\DXC1818\TroubleShooting\Scheduled_Task_NetSh_Capture\NetSh.ps1" -Destination \\$wkid\c$\temp
    Copy-Item "C:\Users\$USID\Repos\SCCM-PowerShell_Scripts\DXC1818\SCRIPTS\TroubleShooting\Scheduled_Task_NetSh_Capture\NetSh.ps1" -Destination \\$wkid\c$\temp
}
    Invoke-Command -ComputerName $wkid -ScriptBlock {
    c:\temp\NetSh.ps1
    Remove-Item -Path c:\temp\NetSh.ps1
    }
}

#Verify Scheduled Task was created
$wkids = Get-Content -Path C:\Automate\NetSh\WKIDs.txt
ForEach ($wkid in $wkids) {
    If (Test-Connection -ComputerName $wkid -Quiet -ErrorAction SilentlyContinue) {
    $Output = Invoke-Command -ComputerName $wkid -ScriptBlock {
    Get-ScheduledTaskInfo -TaskName "NetSh capture";
    Get-ScheduledTaskInfo -TaskName "NetSh capture stop"}}
    $Output | Out-GridView
}

#Manually start the trace
$wkids = Get-Content -Path C:\Automate\NetSh\WKIDs.txt
ForEach ($wkid in $wkids) {
    If (Test-Connection -ComputerName $wkid -Quiet -ErrorAction SilentlyContinue) {
    Invoke-Command -ComputerName $wkid -ScriptBlock {
    Start-ScheduledTask -TaskName "NetSh capture"}}
}

#Manually stop the trace
$wkids = Get-Content -Path C:\Automate\NetSh\WKIDs.txt
ForEach ($wkid in $wkids) {
    If (Test-Connection -ComputerName $wkid -Quiet -ErrorAction SilentlyContinue) {
    Invoke-Command -ComputerName $wkid -ScriptBlock {
    Start-ScheduledTask -TaskName "NetSh capture stop"}}
}

#Delete Scheduled task
$wkids = Get-Content -Path C:\Automate\NetSh\WKIDs.txt
ForEach ($wkid in $wkids) {
    If (Test-Connection -ComputerName $wkid -Quiet -ErrorAction SilentlyContinue) {
    Invoke-Command -ComputerName $wkid -ScriptBlock {
    Unregister-ScheduledTask -TaskName "NetSh capture" -Confirm:$False;
    Unregister-ScheduledTask -TaskName "NetSh capture stop" -Confirm:$False}}
}

#Delete trace files
$wkids = Get-Content -Path C:\Automate\NetSh\WKIDs.txt
ForEach ($wkid in $wkids) {
    If (Test-Connection -ComputerName $wkid -Quiet -ErrorAction SilentlyContinue) {
    Invoke-Command -ComputerName $wkid -ScriptBlock {
    Remove-Item -Path C:\NetTrace.etl -Force -ErrorAction SilentlyContinue;
    Remove-Item -Path C:\NetTrace.cab -Force -ErrorAction SilentlyContinue}}
}