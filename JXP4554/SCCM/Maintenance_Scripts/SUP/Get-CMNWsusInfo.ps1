Function Get-CMNWsusInfo {
    <#
    .SYNOPSIS

    .DESCRIPTION
        All my functions assume you are using the Get-CMNSCCMConnectoinInfo and New-CMNLogEntry functions for these scripts, 
        please make sure you account for that.

    .PARAMETER sccmConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNsccmConnectionInfo in a variable and passing that variable.

    .PARAMETER logFile
        File for writing logs to, default is c:\temp\eror.log

    .PARAMETER logEntries
         Switch to say if we write to the log file. Otherwise, it will just be write-verbose

    .PARAMETER maxLogSize
        Max size for the log. Defaults to 5MB.

    .PARAMETER maxLogHistory
            Specifies the number of history log files to keep, default is 5

    .EXAMPLE

    .LINK
        http://configman-notes.com

    .NOTES
        Author:	    Jim Parris
        Email:	    Jim@ConfigMan-Notes.com
        Date:	    yyyy-mm-dd
        Updated:    
        PSVer:	    3.0
        Version:    1.0.0		
	#>

    [CmdletBinding(ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'Update server, should be the upstream server')]
        [PSObject]$updateServer,

        [Parameter(Mandatory = $false, HelpMessage = 'Get child server info')]
        [Switch]$getChildServerInfo,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int]$maxLogHistory = 5
    )

    begin {
        # Create a hashtable with your output info
        $returnHashTable = @{ }
    }

    Process {
        $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $updateServer)
        $RegKey = $Reg.OpenSubKey("SOFTWARE\\Microsoft\\Update Services\\Server\\Setup")
        if ($RegKey.GetValue('UsingSSL') -eq 1) { $useSSL = $true }
        else { $useSSL = $false }
        $port = $RegKey.GetValue('PortNumber')
        $sqlServerName = $RegKey.GetValue('SqlServerName')
        [reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | out-null
        $wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer($updateServer, $useSSL, $port);
        $childServers = $wsus.GetChildServers()
        if ($childServers.Count -gt 0 -and $PSBoundParameters['getChildServerInfo']) {
            for ($x = 0 ; $x -lt $childServers.Count ; $x++) {
                $returnHashTable.Add("ChildServer$($x)-FullDomainName",$childServers[$x].FullDomainName)
                $returnHashTable.Add("ChildServer$($x)-LastSyncTime",$childServers[$x].LastSyncTime)
                $returnHashTable.Add("ChildServer$($x)-IsReplica",$childServers[$x].IsReplica)
            }
        }
        $status = $wsus.GetStatus()
        $configuration = $wsus.GetConfiguration()
        # $cleanupmanager = $wsus.GetCleanupManager(Microsoft.UpdateServices.Administration.CleanupProgressEventHandler ProgressHandler(System.Object, Microsoft.UpdateServices.Administration.CleanupEventArgs)
        # $wsus.GetSynchronizationInfo($configuration.ServerId.Guid)
        $returnHashTable.Add('WsusServerName', $configuration.UpdateServer.ServerName)
        $returnHashTable.Add('SqlServerName', $sqlServerName)
        $returnHashTable.Add('UseSSL', $configuration.UpdateServer.UseSecureConnection)
        $returnHashTable.Add('Port', $configuration.UpdateServer.PortNumber)
        # $configuration.LastConfigChange
        # $configuration.ServerId
        # $configuration.SyncFromMicrosoftUpdate
        $returnHashTable.Add('IsReplicaServer', $configuration.IsReplicaServer)
        $returnHashTable.Add('UpstreamWsusServerName', $configuration.UpstreamWsusServerName)
        $returnHashTable.Add('UpstreamWsusServerPortNumber', $configuration.UpstreamWsusServerPortNumber)
        $returnHashTable.Add('UpstreamWsusServerUseSsl', $configuration.UpstreamWsusServerUseSsl)
        $returnHashTable.Add('LocalContentCachePath', $configuration.LocalContentCachePath)
        # $configuration.DownloadUpdateBinariesAsNeeded
        # $configuration.DownloadExpressPackages
        # $configuration.MaxDeltaSyncPeriod
        # $configuration.MaxSimultaneousFileDownloads
        # $configuration.BitsDownloadPriorityForeground
        # $configuration.BitsHealthScanningInterval
        # $configuration.WsusInstallType
        # $configuration.LogFilePath
        # $configuration.RevisionDeletionSizeThreshold
        # $configuration.RevisionDeletionTimeThreshold
        # $childServers[0].FullDomainName
        # $childServers[0].LastRollupTime
        # $childServers[0].LastSyncTime
        # $childServers[0].SyncsFromDownstreamServer
        # $childServers[0].Version
        # $childServers[0].IsReplica
        $returnHashTable.Add('UpdateCount', $status.UpdateCount)
        $returnHashTable.Add('DeclinedUpdateCount', $status.DeclinedUpdateCount)
        $returnHashTable.Add('ApprovedUpdateCount', $status.ApprovedUpdateCount)
        $returnHashTable.Add('NotApprovedUpdateCount', $status.NotApprovedUpdateCount)
        $returnHashTable.Add('ExpiredUpdateCount', $status.ExpiredUpdateCount)
    }

    End {
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.WsusConfiguration')
        Return $obj	
    }
} #End Get-CMNWsusInfo

$OutFile = 'C:\Temp\WSUSConfig.csv'
$WSUSServers = ('louappwps1405.rsc.humad.com', 'louappwps1642.rsc.humad.com', 'louappwps1643.rsc.humad.com', 'louappwps1644.rsc.humad.com', 'louappwps1645.rsc.humad.com', 'louappwps1646.rsc.humad.com', 'louappwps1647.rsc.humad.com', 'louappwps1648.rsc.humad.com', 'louappwps1649.rsc.humad.com', 'louappwps1653.rsc.humad.com', 'louappwps1740.rsc.humad.com', 'louappwps1741.rsc.humad.com', 'louappwps1742.rsc.humad.com', 'louappwps1821.rsc.humad.com', 'louappwps1822.rsc.humad.com', 'louappwqs1020.rsc.humad.com', 'louappwqs1021.rsc.humad.com', 'louappwqs1022.rsc.humad.com', 'louappwqs1023.rsc.humad.com', 'louappwqs1024.rsc.humad.com', 'louappwqs1025.rsc.humad.com', 'louappwts1150.rsc.humad.com', 'louappwts1151.rsc.humad.com', 'louappwts1152.rsc.humad.com', 'ltlscmdpwts01.loutap.loutms.tree')
foreach($WSUSServer in $WSUSServers){
    Write-output "Grabbing $WSUSServer"
    Get-CMNWsusInfo -updateServer $WSUSServer | Select-Object -Property WsusServerName, Port, UseSSL, SqlServerName, LocalContentCachePath, IsReplicaServer, UpstreamWsusServerName, UpstreamWsusServerUseSsl, UpstreamWsusServerPortNumber, UpdateCount, ApprovedUpdateCount, NotApprovedUpdateCount, DeclinedUpdateCount | Export-Csv -Path $outFile -Encoding Ascii -Append -NoTypeInformation
}