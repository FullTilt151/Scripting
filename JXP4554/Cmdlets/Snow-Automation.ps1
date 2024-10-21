Function New-CmnLogEntry {
    <#
		.SYNOPSIS
			Writes log entry that can be read by CMTrace.exe

		.DESCRIPTION
			If you specify 'logEntries' writes log entries to a file. If the file is larger then MaxFileSize, it will rename it to *yyyymmdd-HHmmss.log and start a new file.
			You can specify if it's an (1) informational, (2) warning, or (3) error message as well. It will also add time zone information, so if you
            have machines in multiple time zones, you can convert to UTC and make sure you know exactly when things happened.
            
            Will always write the entry verbose for troubleshooting

		.PARAMETER entry
			This is the text that is the log entry.

		.PARAMETER type
			Defines the type of message, 1 = Informational (default), 2 = Warning, and 3 = Error.

		.PARAMETER component
			Specifies the Component information. This could be the name of the function, or thread, or whatever you like,
			to further help identify what is being logged.

		.PARAMETER logFile
            File for writing logs to.
            
        .PARAMETER logEntries
            Switch to say if we write to the log file. Otherwise, it will just be write-verbose

		.PARAMETER maxLogSize
			Specifies, in bytes, how large the file should be before rolling log over.

		.PARAMETER maxLogHistory
			Specifies the number of history log files to keep, default is 5

		.EXAMPLE
			New-CmnLogEntry -entry "Machine $computerName needs a restart." -type 2 -component 'Installer' -logFile $logFile -logEntries -MaxLogSize 10485760
			This will add a warning entry, after expanding $computerName from the compontent Installer to the logfile and roll it over if it exceeds 10MB

		.LINK
			http://configman-notes.com

		.NOTES
			FileName:    Copy-CmnApplicationDeployment.ps1
			Author:      James Parris
			Contact:     jim@ConfigMan-Notes.com
			Created:     2016-03-22
            Updated:     2017-03-01 - Added log rollover
                         2018-10-23 - Added Write-Verbose
                                      Added adjustment in TimeZone for Daylight Savings Time
                                      Corrected time format for renaming logs because I'm an idiot and put 3 digits in the minute field.
			Version:     2.0
    #>
    
    [CmdletBinding(ConfirmImpact = 'Low')]

    Param
    (
        [Parameter(Mandatory = $false, HelpMessage = 'Entry for the log')]
        [String]$entry = '',

        [Parameter(Mandatory = $true, HelpMessage = 'Type of message, 1 = Informational, 2 = Warning, 3 = Error')]
        [ValidateSet(1, 2, 3)]
        [INT32]$type,

        [Parameter(Mandatory = $true, HelpMessage = 'Component')]
        [String]$component,

        [Parameter(Mandatory = $true, HelpMessage = 'Log File')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int32]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int32]$maxLogHistory = 5
    )

    #Get Timezone info
    $now = Get-Date
    $tzInfo = [System.TimeZoneInfo]::Local
    #Get Timezone Offset
    $tzOffset = $tzInfo.BaseUTcOffset.Negate().TotalMinutes
    #If it's daylight savings time, we need to adjust
    if ($tzInfo.IsDaylightSavingTime($now)) {
        $tzAdjust = ((($tzInfo.GetAdjustmentRules()).DaylightDelta).TotalMinutes)[0]
        $tzOffset -= $tzAdjust
    }
    #Now, to figure out the format. if the timezone adjustment is posative, we need to represent it as +###
    if ($tzOffset -ge 0) {
        $tzOffset = "$(Get-Date -Format "HH:mm:ss.fff")+$($tzOffset)"
    }
    #Otherwise, we need to represent it as -###
    else {
        $tzOffset = "$(Get-Date -Format "HH:mm:ss.fff")$tzOffset"
    }

    #Create entry line, properly formatted
    $cmEntry = "<![LOG[{0}]LOG]!><time=""{2}"" date=""{1}"" component=""{5}"" context="""" type=""{4}"" thread=""{3}"">" -f $entry, (Get-Date -Format "MM-dd-yyyy"), $tzOffset, $pid, $type, $component

    if ($PSBoundParameters['logEntries']) {
        #Now, see if we need to roll the log
        if (Test-Path $logFile) {
            #File exists, now to check the size
            if ((Get-Item -Path $logFile).Length -gt $MaxLogSize) {
                #Rename file
                $backupLog = ($logFile -replace '\.log$', '') + "-$(Get-Date -Format "yyyymmdd-HHmmss").log"
                Rename-Item -Path $logFile -NewName $backupLog -Force
                #Get filter information
                #First, we do a regex search, and just get the text before the .log and after the \
                $logFile -match '(\w*).log' | Out-Null
                #Now, we add a trailing * for the filter
                $logFileName = "$($Matches[1])*"
                #Get the path for the log so we know where to search
                $logPath = Split-Path -Path $logFile
                #And we remove any extra rollover logs.
                Get-ChildItem -Path $logPath -filter $logFileName | Where-Object {$_.Name -notin (Get-ChildItem -Path $logPath -Filter $logFileName | Sort-Object -Property LastWriteTime -Descending | Select-Object -First $maxLogHistory).name} | Remove-Item
            }
        }
        #Finally, we write the entry
        $cmEntry | Out-File $logFile -Append -Encoding ascii
    }
    #Also, we write verbose, just incase that's turned on.
    Write-Verbose $entry
} #End New-CmnLogEntry

#List collections in Maintenance Window folder
Function Show-MaintenanceWindows {
    <#
    .SYNOPSIS
        This function returns all the collections under the Maintenance Windows folder and their CollectionID's.

    .DESCRIPTION
        This function returns all the collections under the Maintenance Windows folder and their CollectionID's. The Name can be presented to the user, 
        but the other functions need the CollectionID as a parameter.

    .PARAMETER cimSession
        This is a variable with an existing CimSession opened to the site server

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
        Date:	    2019-04-02
        Updated:    
        PSVer:	    3.0
        Version:    1.0.0		
	#>

    [CmdletBinding(ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'CimSession for queries')]
        [PSObject]$cimSession,  
    
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
            Component     = 'Show-MaintenanceWindows';
            logEntries    = $logEntries;
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        #Get Site Code
        $siteCode = (Get-CimInstance -CimSession $cimSession -Namespace root/sms -ClassName SMS_ProviderLocation).SiteCode

        #Set Cim parameters
        $Namespace = "root/sms/Site_$siteCode"

        New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        New-CMNLogEntry -entry "cimSession.ComputerName = $($cimSession.ComputerName)" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
    }

    process {
        New-CMNLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry
        $results = Get-CimInstance -CimSession $cimSession -Namespace $Namespace -ClassName SMS_Collection -Filter "ObjectPath = '/Maintenance Windows'" | Select-Object -Property CollectionID, Name
    }

    End {
        New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        foreach($result in $results){
            New-CmnLogEntry -entry "$($result.CollectionID) - $($result.Name)" -type 1 @NewLogEntry
        }
        Return $results	
    }
} #End Show-MaintenanceWindows

# Find a Maintenance Window a server is in
Function Get-MaintenanceWindows {
    <#
    .SYNOPSIS
        This gets the CollectionID and maintenance window(s) for the computername provided.

    .DESCRIPTION
        This gets the CollectionID and maintenance window(s) for the computername provided.

    .PARAMETER cimSession
        This is a variable with an existing CimSession opened to the site server
    
    .PARAMETER computerName
        Name of computer to retrieve the maintenance windows for

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
        Date:	    2019-04-02
        Updated:    
        PSVer:	    3.0
        Version:    1.0.0		
	#>

    [CmdletBinding(ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'CimSession for queries')]
        [PSObject]$cimSession,

        [Parameter(Mandatory = $true, HelpMessage = 'Computer to search for Maintenance Window Collecitons')]
        [String]$computerName,

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
            Component     = 'Get-MaintenanceWindows';
            logEntries    = $logEntries;
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        #Get Site Code
        $siteCode = (Get-CimInstance -CimSession $cimSession -Namespace root/sms -ClassName SMS_ProviderLocation).SiteCode

        #Set Cim parameters
        $Namespace = "root/sms/Site_$siteCode"

        New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        New-CMNLogEntry -entry "cimSession.ComputerName = $($cimSession.ComputerName)" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "computerName = $computerName" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
    }

    process {
        New-CMNLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry
        $mwCollectionIDs = (Get-CimInstance -CimSession $cimSession -Namespace $Namespace -ClassName SMS_Collection -Filter "ObjectPath = '/Maintenance Windows'").CollectionID
        $query = "Select SMS_Collection.* from SMS_R_SYSTEM join SMS_FullCollectionMembership on SMS_R_SYSTEM.ResourceID = SMS_FullCollectionMembership.ResourceID join SMS_Collection on SMS_FullCollectionMembership.CollectionID = SMS_Collection.CollectionID where SMS_R_SYSTEM.Netbios_Name0 = '$computerName'"
        $mwMemberIDs = Get-CimInstance -CimSession $cimSession -Namespace $Namespace -Query $query | Where-Object {$_.ObjectPath -eq '/Maintenance Windows'} | Select-Object -Property CollectionID, Name
    }

    End {
        New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        foreach($mwMemberID in $mwMemberIDs){
        New-CMNLogEntry -entry "$($mwMemberID.CollectionID) - $($mwMemberID.Name)" -type 1 @NewLogEntry
        }
        Return $mwMemberIDs
    }
} #End Get-MaintenanceWindows

# Add a server to a Maintenance WIndow
Function Add-ServerToMaintenanceWindow {
    <#
    .SYNOPSIS
        Adds a server to a maintenance window.
    .DESCRIPTION
        Adds a server to a maintenance window. You will need to provide the computerName and collectionID of the maintenance window.

    .PARAMETER cimSession
        This is a variable with an existing CimSession opened to the site server
    
    .PARAMETER computerName
        Name of computer to retrieve the maintenance windows for

    .PARAMETER collectionID
        CollectionID of the collection to add the computer to

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
        Date:	    2019-04-02
        Updated:    
        PSVer:	    3.0
        Version:    1.0.0		
	#>

    [CmdletBinding(ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'CimSession for queries')]
        [PSObject]$cimSession,

        [Parameter(Mandatory = $true, HelpMessage = 'Computer to search for Maintenance Window Collecitons')]
        [String]$computerName,

        [Parameter(Mandatory = $true, HelpMessage = 'CollectionID to add computer to')]
        [String]$collectionID,

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
            Component     = 'Add-ServerToMaintenanceWindow';
            logEntries    = $logEntries;
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        #Get Site Code
        $siteCode = (Get-CimInstance -CimSession $cimSession -Namespace root/sms -ClassName SMS_ProviderLocation).SiteCode

        #Set Cim parameters
        $Namespace = "root/sms/Site_$siteCode"

        # Create a hashtable with your output info
        $returnHashTable = @{}

        New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        New-CMNLogEntry -entry "cimSession.ComputerName = $($cimSession.ComputerName)" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "computerName = $computerName" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "collectionID = $collectionID" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
    }

    process {
        New-CMNLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry
        $collection = get-CimInstance -cimSession $cimSession -Namespace $Namespace -query "Select * from SMS_Collection where CollectionID = '$collectionID'" | get-CimInstance
        $queryRule = $collection.CollectionRules.QueryExpression
        if($queryRule){
            New-CMNLogEntry -entry "$($collection.Name) has a rule, checking for servername" -type 1 @NewLogEntry
            if($queryRule.Contains($computerName)){
                New-CMNLogEntry "Collection $($collection.Name) already contains $computerName" -type 2 @NewLogEntry
                $results = "Collection $($collection.Name) already contains $computerName"
        
            }
            else{
                try{
                    New-CMNLogEntry -entry 'Creating rule' -type 1 @NewLogEntry
                    $queryRule = "$($queryRule.Substring(0,$queryRule.Length - 1)),'$computerName')"
                    while ($queryRule.Contains('"')){$queryRule = $queryRule -replace '"',''''}
                    New-CMNLogEntry -entry "Query = $queryRule" -type 1 @NewLogEntry
                    New-CMNLogEntry -entry 'Getting class' -type 1 @NewLogEntry
                    $collectionRuleQueryClass = Get-CimClass -ClassName SMS_CollectionRuleQuery -CimSession $cimSession -Namespace $Namespace
                    New-CMNLogEntry -entry 'Creating new ciminstance' -type 1 @NewLogEntry
                    $queryMemberRule = new-CimInstance -CimClass $collectionRuleQueryClass -ClientOnly -Property @{
                        RuleName = 'Query';
                        QueryExpression = $queryRule;
                        QueryID = 1;
                        }
                    New-CMNLogEntry -entry 'Removing existing rules' -type 1 @NewLogEntry
                    Invoke-CimMethod -inputobject $collection -MethodName 'DeleteMembershipRules' -Arguments @{collectionRules = $collection.CollectionRules} | Out-Null
                    New-CMNLogEntry -entry 'Adding rule' -type 1 @NewLogEntry
                    Invoke-CimMethod -inputobject $collection -MethodName 'AddMembershipRule' -Arguments @{collectionRule = $queryMemberRule} | Out-Null
                    $results = "Computer $computerName was added to collection $($collection.Name)"
                    remove-variable queryRule
                    remove-variable queryMemberRule
                    remove-variable collection
                }

                catch {
                    New-CMNLogEntry -entry 'Failed to update rule' -type 3 @NewLogEntry
                    $result = "Failed to update rule"
                }
            }
        }
        else{
            try{
                New-CMNLogEntry -entry 'Creating rule' -type 1 @NewLogEntry
                $queryRule = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.NetbiosName in ('$computerName')"
                New-CMNLogEntry -entry "Query = $queryRule" -type 1 @NewLogEntry
                New-CMNLogEntry -entry 'Getting class' -type 1 @NewLogEntry
                $collectionRuleQueryClass = Get-CimClass -ClassName SMS_CollectionRuleQuery -CimSession $cimSession -Namespace $Namespace
                New-CMNLogEntry -entry 'Creating new ciminstance' -type 1 @NewLogEntry
                $queryMemberRule = new-CimInstance -CimClass $collectionRuleQueryClass -ClientOnly -Property @{
                    RuleName = 'Query';
                    QueryExpression = $queryRule;
                    QueryID = 1;
                    }
                New-CMNLogEntry -entry 'Adding rule' -type 1 @NewLogEntry
                Invoke-CimMethod -inputobject $collection -MethodName 'AddMembershipRule' -Arguments @{collectionRule = $queryMemberRule} | Out-Null
                $results = "Computer $computerName was added to collection $($collection.Name)"
                remove-variable queryRule
                remove-variable queryMemberRule
                remove-variable collection
            }

            catch {
                New-CMNLogEntry -entry 'Failed to update rule' -type 3 @NewLogEntry
                $result = "Failed to update rule"
            }
        }   
    }

    End {
        New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        New-CMNLogEntry -entry $results -type 1 @NewLogEntry
        Return $results
    }
} #End Add-ServerToMaintenanceWindow

# Remove a server from a Maintenance Window
Function Remove-ServerFromMaintenanceWindow {
    <#
    .SYNOPSIS
        Removes a computer from a maintenance window collection.

    .DESCRIPTION
        Removes a computer from a maintenance window collection. You provide the computerName and collectionID.

    .PARAMETER cimSession
        This is a variable with an existing CimSession opened to the site server
    
    .PARAMETER computerName
        Name of computer to retrieve the maintenance windows for

    .PARAMETER collectionID
        CollectionID of the collection to remove the computer from

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
        Date:	    2019-04-02
        Updated:    
        PSVer:	    3.0
        Version:    1.0.0		
	#>

    [CmdletBinding(ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'CimSession for queries')]
        [PSObject]$cimSession,

        [Parameter(Mandatory = $true, HelpMessage = 'Computer to search for Maintenance Window Collecitons')]
        [String]$computerName,

        [Parameter(Mandatory = $true, HelpMessage = 'CollectionID to remove computer from')]
        [String]$collectionID,

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
            Component     = 'Remove-ServerFromMaintenanceWindow';
            logEntries    = $logEntries;
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        #Get Site Code
        $siteCode = (Get-CimInstance -CimSession $cimSession -Namespace root/sms -ClassName SMS_ProviderLocation).SiteCode

        #Set Cim parameters
        $Namespace = "root/sms/Site_$siteCode"

        # Create a hashtable with your output info
        $returnHashTable = @{}

        New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        New-CMNLogEntry -entry "cimSession.ComputerName = $($cimSession.ComputerName)" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "computerName = $computerName" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "collectionID = $collectionID" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
    }

    process {
        New-CMNLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry
        $collection = get-CimInstance -cimSession $cimSession -Namespace $Namespace -query "Select * from SMS_Collection where CollectionID = '$collectionID'" | get-CimInstance
        $queryRule = $collection.CollectionRules.QueryExpression
        if($queryRule){
            if($queryRule.Contains($computerName)){
                try{
                    New-CMNLogEntry -entry 'Parsing rule' -type 1 @NewLogEntry
                    $computerList = $queryRule.Substring($queryRule.IndexOf('(') + 1, $queryRule.Length - $queryRule.IndexOf('(') -2)
                    $computerList = $computerList -replace "'",''
                    $computers = $computerList.Split(',') | Sort-Object
                    $queryRule = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.NetbiosName in ("
                    foreach($computer in $computers){
                        if($computer -ne $computerName ){$queryRule = "$queryRule'$computer',"}
                    }
                    $queryRule = "$($queryRule.SubString(0,$queryRule.Length - 1)))"
                    New-CMNLogEntry -entry "Query = $queryRule" -type 1 @NewLogEntry
                    New-CMNLogEntry -entry 'Getting class' -type 1 @NewLogEntry
                    $collectionRuleQueryClass = Get-CimClass -ClassName SMS_CollectionRuleQuery -CimSession $cimSession -Namespace $Namespace
                    New-CMNLogEntry -entry 'Creating new ciminstance' -type 1 @NewLogEntry
                    $queryMemberRule = new-CimInstance -CimClass $collectionRuleQueryClass -ClientOnly -Property @{
                        RuleName = 'Query';
                        QueryExpression = $queryRule;
                        QueryID = 1;
                        }
                    New-CMNLogEntry -entry 'Removing existing rules' -type 1 @NewLogEntry
                    Invoke-CimMethod -inputobject $collection -MethodName 'DeleteMembershipRules' -Arguments @{collectionRules = $collection.CollectionRules} | Out-Null
                    New-CMNLogEntry -entry 'Adding rule' -type 1 @NewLogEntry
                    Invoke-CimMethod -inputobject $collection -MethodName 'AddMembershipRule' -Arguments @{collectionRule = $queryMemberRule} | Out-Null
                    $results = "Computer $computerName was removed from collection $($collection.Name)"
                    remove-variable queryRule
                    remove-variable queryMemberRule
                    remove-variable collection
                }

                catch {
                    New-CMNLogEntry -entry 'Failed to update rule' -type 3 @NewLogEntry
                    $result = "Failed to update rule"
                }
            }
        }
        else{
            New-CMNLogEntry "Collection $($collection.Name) does not contain $computerName" -type 2 @NewLogEntry
            $results = "Collection $($collection.Name) does not contain $computerName"
        }
    }

    End {
        New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        New-CMNLogEntry -entry $results -type 1 @NewLogEntry
        Return $results
    }
} #End Remove-ServerFromMaintenanceWindow

##Test lines below
$cimSession = New-CimSession -ComputerName LOUAPPWTS1140
$logFile = 'C:\Temp\SNOW.log'
$computerName = 'LOUAPPWTS1140'
$collectionID = 'MT100886'

Write-Output 'Running Show-MaintenanceWindows'
Show-MaintenanceWindows -cimSession $cimSession -logFile $logFile -logEntries
Write-Output 'Running Get-MaintenanceWindows'
Get-MaintenanceWindows -cimSession $cimSession -computerName $computerName -logfile $logfile -logEntries
Write-Output "Removing $computerName from $collectionID"
Remove-ServerFromMaintenanceWindow -cimSession $cimSession -computerName $computerName -CollectionID $collectionID -logFile $logFile -logEntries
Write-Output "Removing $computerName from $collectionID (should fail)"
Remove-ServerFromMaintenanceWindow -cimSession $cimSession -computerName $computerName -CollectionID $collectionID -logFile $logFile -logEntries
Write-Output "Adding $computerName to $collectionID"
Add-ServerToMaintenanceWindow -cimSession $cimSession -computerName $computerName -CollectionID $collectionID -logFile $logFile -logEntries
Write-Output "Adding $computerName to $collectionID (should fail)"
Add-ServerToMaintenanceWindow -cimSession $cimSession -computerName $computerName -CollectionID $collectionID -logFile $logFile -logEntries