<#
.SYNOPSIS
 
.DESCRIPTION
 
.PARAMETER SCCMConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of 
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.
		
.PARAMETER logFile
	File for writing logs to

.PARAMETER logEntries
    Switch to say whether or not to create a log file

.PARAMETER ShowProgress
	Show a progressbar displaying the current operation.
 
.EXAMPLE
     
.LINK
	http://configman-notes.com

.NOTES
	FileName:    FileName.ps1
	Author:      James Parris
	Contact:     jim@ConfigMan-Notes.com
	Created:     2016-03-22
	Updated:     2016-03-22
	Version:     1.0.0
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
	
PARAM
(
    [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info')]
    [Alias('computerName')]
    [Alias('hostName')]
    [String]$siteServer,

    [Parameter(Mandatory = $false, HelpMessage = 'Kill blocking Spids')]
    [Switch]$killSpids,

    [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
    [String]$logFile = 'C:\Temp\Error.log',

    [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
    [Switch]$logEntries,

    [Parameter(Mandatory = $false, HelpMessage = 'Clear Log File')]
    [Switch]$clearLog
)
Begin {
    # Disable Fast parameter usage check for Lazy properties
    $NewLogEntry = @{
        LogFile   = $logFile;
        Component = 'Show-CMBlocking'
    }
    $sccmConnectionInfo = Get-CMNSCCMConnectionInfo -siteServer $siteServer
    $sccmCS = Get-CMNConnectionString -DatabaseServer $sccmConnectionInfo.SCCMDBServer -Database $sccmConnectionInfo.SCCMDB
    if ($PSBoundParameters['clearLog']) {if (Test-Path -Path $logFile) {Remove-Item -Path $logFile}}
    if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry}
    $sccmConnectionInfo = Get-CMNSCCMConnectionInfo -SiteServer $siteServer
    $message = "ComputerName: $($sccmConnectionInfo.ComputerName)"
    $message += "`r`nNameSpace: $($sccmConnectionInfo.NameSpace)"
    $message += "`rSCCMDB: $($sccmConnectionInfo.SCCMDB)"
    $message += "`r`nSCCMDBServer: $($sccmConnectionInfo.SCCMDBServer)"
    $message += "`r`nSiteCode: $($sccmConnectionInfo.SiteCode)"
    $message += "`r`nSCCMCS: $sccmCS"
    if ($PSBoundParameters["logEntries"]) {New-CMNLogEntry -entry $message -type 1 @NewLogEntry}
}
	
Process {
    if ($logEntries) {New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry}
    $message += "`r`n**********************"
    $blockingHT = @{}
    $query = 'exec sp_who2'
    $spwho2s = Get-CMNDatabaseData -connectionString $sccmCS -query $query -isSQLServer
    foreach ($spwho2 in $spwho2s) {
        if ($spwho2.BlkBy -notmatch '\.') {
            if (-not($blockingHT.ContainsKey($spwho2.SPID))) {
                $blockingHT.Add($spwho2.SPID, $spwho2.BlkBy)
                $message += "`r`nSPID:$($spwho2.SPID) BlkBy:$($spwho2.BlkBy) Status:$(($spwho2.Status).Trim()) Login:$($spwho2.Login) HostName:$($spwho2.HostName) DBName:$($spwho2.DBName) CPUTime:$($spwho2.CPUTime) PrgmName:$($spwho2.ProgramName)"
                if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "SPID:$($spwho2.SPID) BlkBy:$($spwho2.BlkBy) Status:$(($spwho2.Status).Trim()) Login:$($spwho2.Login) HostName:$($spwho2.HostName) DBName:$($spwho2.DBName) CPUTime:$($spwho2.CPUTime) PrgmName:$($spwho2.ProgramName)" -type 1 @NewLogEntry}
            }
        }
    }
    $message += "`r`n**********************"
    if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry '**********************' -type 1 @NewLogEntry}
    $queryHT = @{}
    foreach ($spid in $blockingHT.GetEnumerator()) {
        if (-not($queryHT.ContainsKey($spid.Value))) {
            $key = ($spid.Value).Trim()
            $query = "DBCC InputBuffer($key)"
            $results = Get-CMNDatabaseData -connectionString $sccmCS -query $query -isSQLServer
            $queryHT.Add($spid.Value, $results.EventInfo)
            $message += "`r`n$($spid.Value) - $($results.EventInfo)"
            if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "$($spid.Value) - $($results.EventInfo)" -type 1 @NewLogEntry}
        }
        if (-not($queryHT.ContainsKey($spid.Name))) {
            $key = ($spid.Name).Trim()
            $query = "DBCC InputBuffer($key)"
            $results = Get-CMNDatabaseData -connectionString $sccmCS -query $query -isSQLServer
            $queryHT.Add($spid.Key, $results.EventInfo)
            $message += "`r`n$($spid.Name) - $($results.EventInfo)"
            if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "$($spid.Name) - $($results.EventInfo)" -type 1 @NewLogEntry}
        }
    }
    if ($PSBoundParameters['killSpids']) {
        $message += "`r`n**********************"
        $message += "`r`nKilling spids"
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry '**********************' -type 1 @NewLogEntry
            New-CMNLogEntry -entry 'Killing spids' -type 1 @NewLogEntry
        }
        $SPIDS = $blockingHT.Values | Sort-Object -Unique
        foreach ($spid in $SPIDS) {
            $query = "Kill $spid"
            $message += $query
            if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry $query -type 2 @NewLogEntry}
            Invoke-CMNDatabaseQuery -connectionString $sccmCS -query $query -isSQLServer | Out-Null
        }
    }
}
    

End {
    Write-Output $message
    if ($logEntries) {New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
}
