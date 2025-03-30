[CmdletBinding(SupportsShouldProcess = $true)]
PARAM
(
    [Parameter(Mandatory = $true,
        HelpMessage = 'SiteServer')]
    [String]$siteServer,

    [Parameter(Mandatory = $true,
        HelpMessage = 'Collection ID')]
    [String]$collectionID
)

$sccmCon = Get-CMNSCCMConnectionInfo -SiteServer $siteServer
$sccmCS = Get-CMNConnectionString -DatabaseServer $sccmCon.SCCMDBServer -Database $sccmCon.SCCMDB

$query = "SELECT DISTINCT SYS.netbios_name0
       --UII.CI_UniqueID,
       --UCS.ci_id, 
       --UII.bulletinid, 
       --UII.articleid, 
       --UII.title, 
       --UII.description, 
       --UCS.status, 
       --UII.citype_id 
FROM   v_updatecompliancestatus UCS 
       INNER JOIN v_r_system SYS 
               ON UCS.resourceid = SYS.resourceid 
       INNER JOIN v_updateinfo UII 
               ON UCS.ci_id = UII.ci_id 
WHERE  ( UCS.resourceid IN (SELECT resourceid 
                            FROM   v_fullcollectionmembership FCM 
                            WHERE  FCM.collectionid = '$collectionID') ) 
       AND ( UCS.status = 2 ) 
       AND ( citype_id = 8 ) 
       AND ( UII.articleid = '2952664' 
              OR UII.articleid = '3184143' ) 
ORDER  BY sys.Netbios_Name0"

$MWs = @{}
$wkids = Get-CMNDatabaseData -connectionString $sccmCS -query $query -isSQLServer
foreach($wkid in $wkids)
{
    $query = "SELECT     v_ServiceWindow.Name, v_R_System.Netbios_Name0, v_FullCollectionMembership.CollectionID, v_ServiceWindow.Description, v_ServiceWindow.StartTime, 
                      v_ServiceWindow.Duration
FROM         v_ServiceWindow INNER JOIN
                      v_FullCollectionMembership ON v_ServiceWindow.CollectionID = v_FullCollectionMembership.CollectionID INNER JOIN
                      v_R_System ON v_FullCollectionMembership.ResourceID = v_R_System.ResourceID
WHERE     (v_R_System.Netbios_Name0 LIKE '$($wkid.netbios_name0)')
ORDER BY v_ServiceWindow.Name, v_R_System.Netbios_Name0"
    $maintenanceWindows = Get-CMNDatabaseData -connectionString $sccmCS -query $query -isSQLServer
    if($maintenanceWindows -eq $null)
    {
        $MWs['None'] += [array]$wkid.netbios_name0
        Write-Output "$($wkid.netbios_name0) has no maintenance window"
    }
    else
    {
        foreach($maintenanceWindow in $maintenanceWindows)
        {
            $MWs[$maintenanceWindow.Name] += [array]$wkid.netbios_name0
        }
    }
}