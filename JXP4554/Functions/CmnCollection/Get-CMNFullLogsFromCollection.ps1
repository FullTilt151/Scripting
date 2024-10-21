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
        HelpMessage = 'Which collection ID')]
    [String]$collectionID
)

Begin
{
    #Housekeeping....
    if($fileDir -notmatch '\\$'){$fileDir = "$fileDir\"}
    $sccmCon = Get-CMNSCCMConnectionInfo -SiteServer $siteServer
    $sccmCS = Get-CMNConnectionString -DatabaseServer $sccmCon.SCCMDBServer -Database $sccmCon.SCCMDB

    $query = "SELECT SYS.netbios_name0
        FROM   v_r_system SYS
               JOIN v_fullcollectionmembership FCS
                 ON SYS.resourceid = FCS.resourceid
                    AND FCS.collectionid = '$collectionID'
        ORDER  BY SYS.netbios_name0"

    $wkids = Get-CMNDatabaseData -connectionString $sccmCS -query $query -isSQLServer
}

Process
{
    #Check for base dir
    if(-not(Test-Path -Path $fileDir))
    {
        New-Item -Path $fileDir -ItemType Directory | Out-Null
    }
    #Begin to cycle through the WKIDs
    foreach($wkid in $wkids.Netbios_Name0)
    {
        #Make sure to remove any existing data
        $wkidFileDir = "$fileDir$wkid"
        if(Test-Path $wkidFileDir)
        {
            Remove-Item -Path $wkidFileDir -Recurse -Force
        }
        #Create Clean directory
        New-Item -Path $fileDir -Name $wkid -ItemType Directory | Out-Null

        #copy SCCM Logs
        $sourcePath = "\\$wkid\c$\windows\ccm\logs\*"
        Copy-Item -Path $sourcePath -Destination $wkidFileDir -Force -Recurse

        $sourcePath = "\\$wkid\C$\windows\windowsupdate.log"
        Copy-Item -Path $sourcePath -Destination $wkidFileDir -Force -Recurse

        $sourcePath = "\\$wkid\C$\windows\logs\cbs\cbs.log"
        Copy-Item -Path $sourcePath -Destination $wkidFileDir -Force -Recurse

        $Eventlogs = Get-WmiObject -Class Win32_NTEventLogFile -ComputerName $wkid
        Foreach($log in $EventLogs)
        {
            $path = "\\{0}\c$\Temp\{1}.evt" -f $wkid,$log.LogFileName
            $ErrBackup = ($log.BackupEventLog($path)).ReturnValue
            Copy-Item -path $path -dest $wkidFileDir -force
        } #end foreach log
        $OSInfo = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $wkid
        $BootTime = $OSInfo.ConvertToDateTime($OSInfo.LastBootUpTime)
        Write-Output "$wkid was lastbooted on $BootTime"
        $OSInfo | Export-Clixml "$wkidFileDir\Win32_OperatingSystem.xml"
    }
}

End
{}