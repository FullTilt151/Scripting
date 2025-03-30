$sccmCon = Get-CMNSCCMConnectionInfo -SiteServer LOUAPPWPS1658
$query = "SELECT * FROM SMS_Advertisement"
$deployments = Get-WmiObject -Query $query -ComputerName $sccmCon.ComputerName -Namespace $sccmCon.NameSpace
foreach($deployment in $deployments)
{
    #Write-Output "Checking deployment $($deployment.AdvertisementName)"
    if ($deployment.RemoteClientFlags -eq 74448896)
    {
        Write-Output "Updating deployment $($deployment.AdvertisementID) - $($deployment.AdvertisementName)"
        $deployment.get
        $deployment.RemoteClientFlags = 2128
        $deployment.Put()
    }
}
