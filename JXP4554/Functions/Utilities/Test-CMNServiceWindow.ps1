Function Test-CMNServiceWindow {
    <#
    .SYNOPSIS

    .DESCRIPTION

    .PARAMETER computerNames
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNcomputerNames in a variable and passing that variable.

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
        Email:	    Jim@ConfigMan-Notes
        Date:	    yyyy-mm-dd
        Updated:    
        PSVer:	    3.0
        Version:    1.0.0		
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'Computers to check')]
        [String[]]$computerNames,

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
            Component     = 'Test-CMNServiceWindow';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        #Build splat for WMIQueries
        $WMIQueryParameters = $sccmConnectionInfo.WMIQueryParameters

        #Build database connection string
        $dbCon = Get-CMNConnectionString -DatabaseServer $sccmConnectionInfo.SCCMDBServer -Database $sccmConnectionInfo.SCCMDB

        # Create a hashtable with your output info
        $returnHashTable = @{}

        if ($logEntries) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "sccmConnectionInfo = $sccmConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "computerNames = $computerNames" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
        }
    }

    process {
        if ($logEntries) {New-CMNLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry}

        if ($PSCmdlet.ShouldProcess($computerNames)) {
            foreach ($computerName in $computerNames) {
                if ($logEntries) {
                    New-CMNLogEntry -entry "Working on computer $computername" -type 1 @NewLogEntry
                    New-CMNLogEntry -entry 'Getting service windows in WMI' -type 1 @NewLogEntry
                }
                try {
                    $serviceWindowsOnComputer = Get-CimInstance -ClassName CCM_ServiceWindow -Namespace root\ccm\Policy\Machine\ActualConfig -ComputerName $computerName -Filter "ServiceWindowType !=6"
                }
                catch {
                    if ($logEntries) {New-CMNLogEntry -entry "Unable to get WMI information from $computerName" -type 3 @NewLogEntry}
                    Continue
                }
                if ($logEntries) {New-CMNLogEntry -entry 'Getting service windows from SCCM' -type 1 @NewLogEntry}
                $query = "Select Svc.ServiceWindowID, SVC.Name, SVC.Description
                from v_R_System STM
                join v_FullCollectionMembership FCM on STM.ResourceID = FCM.ResourceID
                join v_ServiceWindow Svc on FCM.CollectionID = SVC.CollectionID
                where STM.Netbios_Name0 = '$computerName'"
                try {
                    $serviceWindowsOnSCCM = Get-CMNDatabaseData -connectionString $dbCon -query $query -isSQLServer
                }
                catch{
                    if($logEntries){New-CMNLogEntry -entry "Unable to get SCCM information for $computerName" -type 3  @NewLogEntry}
                    Continue
                }
                $allMatch = $true
                foreach ($serviceWindowOnComputer in $serviceWindowsOnComputer) {
                    $hasMatch = $false
                    foreach ($serviceWindowOnSCCM in $serviceWindowsOnSCCM) {
                        if ($serviceWindowOnComputer.ServiceWindowID -eq $serviceWindowOnSCCM.ServiceWindowID) {
                            $hasMatch = $true
                            $returnHashTable[$serviceWindowOnComputer.ServiceWindowID] = "$($serviceWindowOnSCCM.Name) - $($serviceWindowOnSCCM.Description)"
                            if($logEntries){New-CMNLogEntry -entry "Found match: $($returnHashTable[$serviceWindowOnComputer.ServiceWindowID])" -type 1 @NewLogEntry}
                        }
                    }
                    if(!$hasMatch){
                        New-CMNLogEntry -entry "We have a miss" -type 3 @NewLogEntry
                    }
                }
            }
        }
    }

    End {
        if ($logEntries) {New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.ObjectType')
        Return $obj	
    }
} #End Test-CMNServiceWindow

$scm = Get-CMNSCCMConnectionInfo -siteServer LOUAPPWPS1825
Test-CMNServiceWindow -sccmConnectionInfo $scm -computerNames 'LOUSQLWBS05' -logFile 'C:\Temp\Test-CMNServiceWindow.log' -logEntries