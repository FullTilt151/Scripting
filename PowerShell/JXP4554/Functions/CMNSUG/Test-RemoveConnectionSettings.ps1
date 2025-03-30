$sccmConnectionInfo = Get-CMNSCCMConnectionInfo -siteServer LOUAPPWTS1140
$WMIQueryParameters = $sccmConnectionInfo.WMIQueryParameters
$CIMQueryParameters = @{
    ComputerName = $sccmConnectionInfo.ComputerName;
    NameSpace = $sccmConnectionInfo.NameSpace;
}
$cimSsn = new-CimSession -ComputerName $sccmConnectionInfo.ComputerName
$CollectionSettings = Get-CimInstance -query "Select * from SMS_CollectionSettings where CollectionID = 'MT100237'" -CimSession $cimSsn  -Namespace $sccmConnectionInfo.NameSpace
$CollectionSettings = $CollectionSettings | Get-CimInstance
#$CollectionSettings = Get-WmiObject -Query "Select * from SMS_CollectionSettings WHERE CollectionID = 'MT100237'" @WMIQueryParameters
#$CollectionSettings.Get()
$ServiceWindows = $CollectionSettings.ServiceWindows
foreach($ServiceWindow in $ServiceWindows){
    $ServiceWindows.Remove($ServiceWindow)
    $CollectionSettings
}