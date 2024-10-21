$query = 'Select STM.Netbios_Name0 [WKID],
    CLS.LastStatusMessage [Last communication],
    datediff(DD,LastStatusMessage,getdate()) [Days since last communication]
from v_CH_ClientSummary CLS
    join v_R_System STM on CLS.ResourceID = STM.ResourceID
where datediff(DD,LastStatusMessage,getdate()) >= 7
    and STM.Client0 = 1
    and STM.Active0 = 1
    and STM.Obsolete0 = 0
order by STM.Netbios_Name0'

$sccmConnection = Get-CMNSCCMConnectionInfo -siteServer LOUAPPWPS1825
$sccmCS = Get-CMNConnectionString -DatabaseServer $sccmConnection.SCCMDBServer -Database $sccmConnection.SCCMDB

$computers = (Get-CMNDatabaseData -connectionString $sccmCS -query $query -isSQLServer).WKID