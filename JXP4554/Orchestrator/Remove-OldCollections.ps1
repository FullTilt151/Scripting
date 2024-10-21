Function Remove-OldCollections {
    <#
    .SYNOPSIS

    .DESCRIPTION
        Description goes here

    .PARAMETER cimSession
        This is a variable containing the cim session to the site server
        
    .PARAMETER siteCode
        String of the 3 charachter site code (so we can build the namespace)

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
        [Parameter(Mandatory = $true, HelpMessage = 'Cim Session to the site server')]
        [PSObject]$cimSession,

        [Parameter(Mandatory = $true, HelpMessage = 'Site code for site server')]
        [String]$siteCode,

        [Parameter(Mandatory = $false, HelpMessage = 'Number of days since colleciton updated to be considered old. Default is 365')]
        [Int32]$daysOldThreshold = 365,

        [Parameter(Mandatory = $false, HelpMessage = 'Remove unused collections. If not selected, will only return a list of collecitons that would have been removed')]
        [Switch]$removeOldCollections,

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
        #Assign a value to logEntries
        if ($PSBoundParameters['logEntries']) { $logEntries = $true }
        else { $logEntries = $false }
        if($PSBoundParameters['removeOldCollections']){$removeOldCollectionsAction = 'Delete'}
        else{$removeOldCollectionsAction = 'Not Deleted'}

        #Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'Remove-OldCollections';
            logEntries    = $logEntries;
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        #Build nameSpace variable
        $nameSpace = "Root/SMS/Site_$siteCode"

        #Create a hashtable with your output info
        $returnArray = New-Object -TypeName System.Collections.ArrayList

        New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        New-CMNLogEntry -entry "cimSession.Computerame = $($cimSession.ComputerName)" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "siteCode = $siteCode" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "daysOldThreshold = $daysOldThreshold" -type 1 @NewLogEntry
        New-CMNDailySchedule -entry "removeOldCollections = $($PSBoundParameters['removeOldCollections'].IsPresent)" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
    }

    process {
        New-CMNLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry
        # We need to get collections that haven't been updated in over $daysOldThreshold, do not start with SMS, and have no deployments.
        $collections = Get-CimInstance -CimSession $cimSession -Namespace $nameSpace -Query "SELECT * FROM SMS_Collection WHERE CollectionType=2" | Where-Object{(New-TimeSpan -Start ($_.LastMemberChangeTime) -End (Get-Date)).Days -ge $daysOldThreshold -and $_.collectionID -notmatch 'SMS.*'}
        foreach($collection in $collections){
            $result = New-Object -TypeName PSObject -Property @{
                CollectionID = $collection.CollectionID;
                CollectionName = $collection.Name;
                LastMemberChangeTime = $collection.LastMemberChangeTime;
                MemberCount = $collection.MemberCount;
                Action = $removeOldCollectionsAction
            }
            if($PSBoundParameters['removeOldCollections']){
                try{
                    $collection | Remove-CimInstance
                }

                catch{
                    $result.Action = $Error
                }
            }
            $returnArray += $result
        }
    }

    End {
        New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        Return $returnArray
    }
} #End Remove-OldCollections