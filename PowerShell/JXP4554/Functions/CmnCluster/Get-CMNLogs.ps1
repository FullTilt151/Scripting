<#

$fileDir = 'D:\MoveIssue'
$startDate = '1/10/2017 07:00 PM'
$endDate = '1/11/2017 02:00 PM'
$siteServer = 'LOUAPPWPS1658'2952664
3184143

WindowsUpdate.log - Time is in the first 24 charcters of the line. Looks to be tab seperated


#>

[CmdletBinding(SupportsShouldProcess = $true)]
PARAM
(
    [Parameter(Mandatory = $true,
        HelpMessage = 'SiteServer')]
    [String]$siteServer,

    [Parameter(Mandatory = $true,
        HelpMessage = 'Directory to put log files')]
    [String]$fileDir,

    [Parameter(Mandatory = $true,
        HelpMessage = 'Start Date/Time')]
    [DateTime]$startDate,

    [Parameter(Mandatory = $true,
        HelpMessage = 'End Date/Time')]
    [DateTime]$endDate,

    [Parameter(Mandatory = $true,
        HelpMessage = 'Is this a SCCM LOG?')]
    [Switch]$isSccmLog
)
Function Get-LogEntries
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    PARAM
    (
        [Parameter(Mandatory = $true)]
        [String]$sourceLog,

        [Parameter(Mandatory = $true)]
        [String]$destinationLog,

        [Parameter(Mandatory = $true)]
        [DateTime]$startDate,

        [Parameter(Mandatory = $true)]
        [DateTime]$endDate
    )

    Begin
    {
        #Housekeeping....
        $tabChar = [char]9
        if(Test-Path -Path $destinationLog){Remove-Item -Path $destinationLog}
    }

    Process
    {
        if(Test-Path -Path $sourceLog) #Make sure the log exists, otherwise we just exit, no errors.
        {
            #Pull in the log and lets go through it.
            $inRange = $false
            $log = Get-Content -Path $sourceLog
            $x = 0
            do
            {
                if($log[$x] -notmatch '^<!\[LOG\[.*\]LOG\]!>') #Not a complete line.
                {
                    Write-Output $sourceLog
                    Write-Output $log[$x] 
                    Write-Output $x
                    #exit
                }
                if($log[$x] -match '\]LOG\]!>.*date="([\d-]*).*')
                {
                    $date = ($log[$x] -replace '.*date="([\d-]*).*','$1') + ' ' + ($log[$x] -replace '.*time="([\d:]*).*','$1')
                    $offset = $log[$x] -replace '.*time="[\d\.:]*([+-]\d*).*','$1'
                    if($offset -match '000')
                    {
                        $date = (Get-Date $date).ToLocalTime()
                    }
                    if((Get-Date $date) -ge (Get-Date $startDate) -and (Get-Date $date) -le (Get-Date $endDate))
                    {
                        $log[$x] | Out-File $destinationLog -Encoding ascii
                        $inRange = $true 
                    }
                    else
                    {
                        $inRange = $false
                    }
                }
                elseif($inRange -eq $true)
                {
                    $log[$x] | Out-File $destinationLog -Encoding ascii
                }
            } while($x -lt $log.Count)
        }
    }

    End
    {}
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

$wkids = Get-CMNDatabaseData -connectionString $sccmCS -query $query -isSQLServer

for($p=0;$p -lt $wkids.Count;$p++)
{
    Write-Progress -Activity "Gathering Logs between $startDate and $endDate" -Status "Working machine $($p + 1) of $($wkids.Count)" -PercentComplete ($p / $wkids.Count * 100)
    $currentPath = "$fileDir\$($wkids[$p].Netbios_Name0)"
    if(Test-Connection -ComputerName $wkids[$p].Netbios_Name0)
    {
        #WindowsUpdate.log
        if(-not (Test-Path -Path $currentPath)){New-Item -Path "$fileDir" -Name $wkids[$p].Netbios_Name0 -ItemType Container | Out-Null}
        if(Test-Path -Path "$currentPath\WindowsUpdate.log"){Remove-Item -Path "$currentPath\WindowsUpdate.log"}
        $WindowsUpdateLog = Get-Content -Path "\\$($wkids[$p].netbios_name0)\c$\windows\WindowsUpdate.log"
        for($x = 0;$x -lt $WindowsUpdateLog.Count;$x++)
        {
            $date = $WindowsUpdateLog[$x].Substring(0,19)
            if((Get-Date $date) -ge (Get-Date $startDate) -and (Get-Date $date) -le (Get-Date $endDate))
            {
                $WindowsUpdateLog[$x] | Out-File "$currentPath\WindowsUpdate.log" -Encoding ascii -Append
            }
        } #End of WindowsUpdate.log

        $CASLog = "\\$($wkids[$p].netbios_name0)\c$\windows\ccm\logs\CAS.log"
        Get-LogEntries -sourceLog $CASLog -destinationLog "$currentPath\CAS.log" -startDate $startDate -endDate $endDate

        $CcmExecLog = "\\$($wkids[$p].netbios_name0)\c$\windows\ccm\logs\CcmExec.log"
        Get-LogEntries -sourceLog $CcmExecLog -destinationLog "$currentPath\CcmExec.log" -startDate $startDate -endDate $endDate

        $ExecMgrLog = "\\$($wkids[$p].netbios_name0)\c$\windows\ccm\logs\ExecMgr.log"
        Get-LogEntries -sourceLog $ExecMgrLog -destinationLog "$currentPath\ExecMgr.log" -startDate $startDate -endDate $endDate

        $ScanAgent = "\\$($wkids[$p].netbios_name0)\c$\windows\ccm\logs\ScanAgent.log"
        Get-LogEntries -sourceLog $ScanAgent -destinationLog "$currentPath\ScanAgent.log" -startDate $startDate -endDate $endDate

        $UpdatesHandlerLog = "\\$($wkids[$p].netbios_name0)\c$\windows\ccm\logs\UpdatesHandler.log"
        Get-LogEntries -sourceLog $UpdatesHandlerLog -destinationLog "$currentPath\UpdatesHandler.log" -startDate $startDate -endDate $endDate

        $WUAHandlerLog = "\\$($wkids[$p].netbios_name0)\c$\windows\ccm\logs\WUAHandler.log"
        Get-LogEntries -sourceLog $WUAHandlerLog -destinationLog "$currentPath\WUAHandler.log" -startDate $startDate -endDate $endDate
    }
}
Write-Progress -Activity "Gathering Logs between $startDate and $endDate" -Completed