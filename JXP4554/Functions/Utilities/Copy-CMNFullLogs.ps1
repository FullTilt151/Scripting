<#

$fileDir = 'D:\MoveIssue'
$startDate = '1/10/2017 07:00 PM'
$endDate = '1/11/2017 02:00 PM'
$siteServer = 'LOUAPPWPS1658'
2952664
3184143
#>

[CmdletBinding(SupportsShouldProcess = $true)]
PARAM
(
    [Parameter(Mandatory = $true,
        HelpMessage = 'SiteServer')]
    [String]$siteServer,

    [Parameter(Mandatory = $true,
        HelpMessage = 'Directory to put log files')]
    [String]$fileDir
)

Function Copy-Log
{
    PARAM
    (
        [Parameter(Mandatory = $true)]
        [String]$sourceLog,

        [Parameter(Mandatory = $true)]
        [String]$destinationLog
    )
    if(Test-Path -Path $destinationLog){Remove-Item -Path $destinationLog}
    if(Test-Path -Path $sourceLog){Copy-Item -Path $sourceLog -Destination $destinationLog -Force}
}


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
                            WHERE  FCM.collectionid = 'WP1000CC') ) 
       AND ( UCS.status = 2 ) 
       AND ( citype_id = 8 ) 
       AND ( UII.articleid = '2952664' 
              OR UII.articleid = '3184143' ) 
ORDER  BY sys.Netbios_Name0"

#$wkids = (Get-CMNDatabaseData -connectionString $sccmCS -query $query -isSQLServer).Netbios_Name0
$wkids = ('LOUXDWDEVC2305','SIMXDWAETB0008','SIMXDWDEVA0069','SIMXDWAETB0010','SIMXDWDEVA0196')


for($p=0;$p -lt $wkids.Count;$p++)
{
    Write-Progress -Activity "Gathering Logs between $startDate and $endDate" -Status "Working machine $($p + 1) of $($wkids.Count)" -PercentComplete ($p / $wkids.Count * 100)
    $currentPath = "$fileDir\$($wkids[$p])"
    if(Test-Connection -ComputerName $wkids[$p] -Count 1)
    {
        #WindowsUpdate.log
        if(-not (Test-Path -Path $currentPath)){New-Item -Path "$fileDir" -Name $wkids[$p] -ItemType Container | Out-Null}
        $WindowsUpdateLog = "\\$($wkids[$p])\c$\windows\WindowsUpdate.log"
        Copy-Log -sourceLog $WindowsUpdateLog -destinationLog "$currentPath\WindowsUpdate.log"

        $CBSLog = "\\$($wkids[$p])\c$\windows\logs\CBS\CBS.log"
        Copy-Log -sourceLog $CBSLog -destinationLog "$currentPath\CBS.log"
        
        $Log = "\\$($wkids[$p])\c$\windows\ccm\logs\*"
        Copy-Item -Path $Log -Destination "$currentPath\"
    }
}
Write-Progress -Activity "Gathering Logs between $startDate and $endDate" -Completed

<#

        $CASLog = "\\$($wkids[$p].netbios_name0)\c$\windows\ccm\logs\CAS.log"
        Copy-Log -sourceLog $CASLog -destinationLog "$currentPath\CAS.log"

        $CcmExecLog = "\\$($wkids[$p].netbios_name0)\c$\windows\ccm\logs\CcmExec.log"
        Copy-Log -sourceLog $CcmExecLog -destinationLog "$currentPath\CcmExec.log"

        $ExecMgrLog = "\\$($wkids[$p].netbios_name0)\c$\windows\ccm\logs\ExecMgr.log"
        Copy-Log -sourceLog $ExecMgrLog -destinationLog "$currentPath\ExecMgr.log"

        $ScanAgent = "\\$($wkids[$p].netbios_name0)\c$\windows\ccm\logs\ScanAgent.log"
        Copy-Log -sourceLog $ScanAgent -destinationLog "$currentPath\ScanAgent.log"

        $UpdatesHandlerLog = "\\$($wkids[$p].netbios_name0)\c$\windows\ccm\logs\UpdatesHandler.log"
        Copy-Log -sourceLog $UpdatesHandlerLog -destinationLog "$currentPath\UpdatesHandler.log"

        $WUAHandlerLog = "\\$($wkids[$p].netbios_name0)\c$\windows\ccm\logs\WUAHandler.log"
        Copy-Log -sourceLog $WUAHandlerLog -destinationLog "$currentPath\WUAHandler.log"

#>