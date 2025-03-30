$sourceConnection = Get-CMNSCCMConnectionInfo -SiteServer LOUAPPWPS1658
$destinationConnection = Get-CMNSCCMConnectionInfo -SiteServer LOUAPPWTS1140

$query = 'SELECT * FROM SMS_ClientSettings order by priority'
$clientSettings = Get-WmiObject -Query $query -Namespace $sourceConnection.NameSpace -ComputerName $sourceConnection.ComputerName
foreach($clientSetting in $clientSettings)
{
    $query = "select * from SMS_ClientSettings where Name = '$($clientSetting.Name)'"
    $testDestSettings = Get-WmiObject -Query $query -Namespace $destinationConnection.NameSpace -ComputerName $destinationConnection.ComputerName
    if($testDestSettings)
    {
        Write-Output 'Already Exists'
    }
    else
    {
        $clientSetting.Get()
        $destClientSettings = ([WMIClass]"//$($destinationConnection.ComputerName)/$($destinationConnection.NameSpace):SMS_ClientSettings").CreateInstance()
        $destClientSettings.AgentConfigurations = $clientSetting.AgentConfigurations
        $destClientSettings.Description = $clientSetting.Description
        $destClientSettings.Enabled = $clientSetting.Enabled
        $destClientSettings.FeatureType = $clientSetting.FeatureType
        $destClientSettings.Flags = $clientSetting.Flags
        $destClientSettings.Name = $clientSetting.Name
        $destClientSettings.Priority = $clientSetting.Priority
        $destClientSettings.Type = $clientSetting.Type
        $destClientSettings.Put()
    }
}