
Function Get-CMNDeploymentUpdates {
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
        Switch for logging entries, default is $false

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
        SMS_SoftwareUpdate - CIID -> Update
        SMS_CIAssignemtnToCI -> Update to deployment.
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

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
        # Assign a value to logEntries
        if ($PSBoundParameters['logEntries']) {$logEntries = $true}
        else {$logEntries = $false}

        #Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'Get-CMNDeploymentUpdates';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        #Build splat for WMIQueries
        $WMIQueryParameters = $sccmConnectionInfo.WMIQueryParameters

        # Create a hashtable with your output info
        $returnHashTable = @{}

        if ($logEntries) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "sccmConnectionInfo = $sccmConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
        }
    }

    process {
        if ($logEntries) {New-CMNLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry}

        if ($PSCmdlet.ShouldProcess($sccmConnectionInfo.ComputerName)) {
            if ($logEntries) {New-CMNLogEntry -entry 'Getting list of updates deployed' -type 1 @NewLogEntry}
            $cimSession = New-CimSession -ComputerName $sccmConnectionInfo.ComputerName
            $updates = Get-CimInstance -CimSession $cimSession -ClassName SMS_SoftwareUpdate -Namespace $sccmConnectionInfo.NameSpace | Where-Object {$_.IsDeployed -eq $true}
            if ($logEntries) {New-CMNLogEntry -entry "Beggining looping through $($updates.Count) updates" -type 1 @NewLogEntry}
            foreach ($update in $updates) {
                if ($update.ArticleID -ne $null -and $update.ArticleID -ne '') {
                    if ($logEntries) {New-CMNLogEntry -entry "Adding KB$($update.ArticleID) - $($update.LocalizedDisplayName)" -type 1 @NewLogEntry}
                    $returnHashTable.Add('Article', [Array]$update.ArticleID)
                }
                if ($update.BulletinID -ne $null -and $update.BulletinID -ne '') {
                    if ($logEntries) {New-CMNLogEntry -entry "Adding Bulletin $(update.BulletinID) - $($update.LocalizedDisplayName)" -type 1 @NewLogEntry}
                    $returnHashTable.Add('Bulletin', [Array]$update.BulletinID)
                }
            }
        }
    }

    End {
        if ($logEntries) {New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.DeploymentUpdates')
        Return $obj	
    }
} #End Get-CMNDeploymentUpdates
$src = Get-CMNSCCMConnectionInfo -siteServer LOUAPPWPS1825
Get-CMNDeploymentUpdates -sccmConnectionInfo $src -logFile 'C:\Temp\Get-CMNDeploymentUpdates.log' -logEntries