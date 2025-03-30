$NetworkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID(‘DCB00C01-570F-4A9B-8D69-199FDBA5723B’))

$NLM_ENUM_NETWORK_CONNECTED=1
$NLM_ENUM_NETWORK_DISCONNECTED=2
$NLM_ENUM_NETWORK_ALL=3

$Networks = $NetworkListManager.GetNetworks($NLM_ENUM_NETWORK_CONNECTED)

foreach($Network in $Networks){
    $NetCategories = New-Object -TypeName System.Collections.Hashtable
    $NetCategories.Add(0x00,'PUBLIC')
    $NetCategories.Add(0x01,'PRIVATE')
    $NetCategories.Add(0x02,'DOMAIN')
    
    $DomainTypes = New-Object -TypeName System.Collections.Hashtable
    $DomainTypes.Add(0x00,'NON_DOMAIN_NETWORK')
    $DomainTypes.Add(0x01,'DOMAIN_NETWORK')
    $DomainTypes.Add(0x02,'DOMAIN_AUTHENTICATED')

    Write-Output "$($Network.GetName()),$($NetCategories.Get_Item($Network.GetCategory())),$($DomainTypes.Get_Item($Network.GetDomainType()))"
}