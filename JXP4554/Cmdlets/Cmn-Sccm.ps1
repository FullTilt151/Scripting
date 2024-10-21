#Requires -Version 3

# Non-SCCM functions

Function New-CmnLogEntry {
    <#
    .SYNOPSIS
        Writes log entry that can be read by CMTrace.exe

    .DESCRIPTION
        If you set 'logEntries' to $true, it writes log entries to a file. If the file is larger then MaxFileSize, it will rename it to *yyyymmdd-HHmmss.log and start a new file. You can specify if it's an (1) informational, (2) warning, or (3) error message as well. It will also add time zone information, so if you have machines in multiple time zones, you can convert to UTC and make sure you know exactly when things happened.
        
        Will always write the entry verbose for troubleshooting

    .PARAMETER entry
        This is the text that is the log entry.

    .PARAMETER type
        Defines the type of message, 1 = Informational (default), 2 = Warning, and 3 = Error.

    .PARAMETER component
        Specifies the Component information. This could be the name of the function or thread, or whatever you like, to further help identify what is being logged.

    .PARAMETER logFile
        File for writing logs to (default is c:\temp\eror.log).

    .PARAMETER logEntries
        Set to $true to write to the log file. Otherwise, it will just be write-verbose (default is $false).

    .PARAMETER maxLogSize
        Max size for the log (default is 5MB).

    .PARAMETER maxLogHistory
        Specifies the number of history log files to keep (default is 5).

    .EXAMPLE
        New-CmnLogEntry -entry "Machine $computerName needs a restart." -type 2 -component 'Installer' -logFile $logFile -logEntries -MaxLogSize 10485760

        This will add a warning entry, after expanding $computerName from the compontent Installer to the logfile and roll it over if it exceeds 10MB

    .LINK
        http://configman-notes.com

    .NOTES
        Author:     James Parris
        Contact:    jim@ConfigMan-Notes.com
        Created:    2016-03-22
        Updated:    2017-03-01  Added log rollover
                    2018-10-23  Added Write-Verbose
                                Added adjustment in TimeZond for Daylight Savings Time
                                Corrected time format for renaming logs because I'm an idiot and put 3 digits in the minute field.
        PSVer:	    3.0
        Version:    2.0
    #>
    
    [CmdletBinding(ConfirmImpact = 'Low')]
    Param
    (
        [Parameter(Mandatory = $true, HelpMessage = 'This is the text that is the log entry.')]
        [String]$entry,

        [Parameter(Mandatory = $true, HelpMessage = 'Defines the type of message, 1 = Informational (default), 2 = Warning, and 3 = Error.')]
        [ValidateSet(1, 2, 3)]
        [INT32]$type,

        [Parameter(Mandatory = $true, HelpMessage = 'Specifies the Component information. This could be the name of the function or thread, or whatever you like, to further help identify what is being logged.')]
        [String]$component,

        [Parameter(Mandatory = $false, HelpMessage = 'File for writing logs to (default is c:\temp\eror.log).')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Set to $true to write to the log file. Otherwise, it will just be write-verbose (default is $false).')]
        [Boolean]$logEntries = $false,

        [Parameter(Mandatory = $false, HelpMessage = 'Max size for the log (default is 5MB).')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Specifies the number of history log files to keep (default is 5).')]
        [Int]$maxLogHistory = 5
    )

    # Get Timezone info
    $now = Get-Date
    $tzInfo = [System.TimeZoneInfo]::Local
    
    # Get Timezone Offset
    $tzOffset = $tzInfo.BaseUTcOffset.Negate().TotalMinutes
    
    # If it's daylight savings time, we need to adjust
    if ($tzInfo.IsDaylightSavingTime($now)) {
        $tzAdjust = ((($tzInfo.GetAdjustmentRules()).DaylightDelta).TotalMinutes)[0]
        $tzOffset -= $tzAdjust
    }

    # Now, to figure out the format. if the timezone adjustment is posative, we need to represent it as +###
    if ($tzOffset -ge 0) {
        $tzOffset = "$(Get-Date -Format "HH:mm:ss.fff")+$($tzOffset)"
    }
    # Otherwise, we need to represent it as -###
    else {
        $tzOffset = "$(Get-Date -Format "HH:mm:ss.fff")$tzOffset"
    }

    # Create entry line, properly formatted
    $cmEntry = "<![LOG[{0}]LOG]!><time=""{2}"" date=""{1}"" component=""{5}"" context="""" type=""{4}"" thread=""{3}"">" -f $entry, (Get-Date -Format "MM-dd-yyyy"), $tzOffset, $pid, $type, $component

    if ($PSBoundParameters['logEntries']) {
        # Now, see if we need to roll the log
        if (Test-Path $logFile) {
            # File exists, now to check the size
            if ((Get-Item -Path $logFile).Length -gt $MaxLogSize) {
                # Rename file
                $backupLog = ($logFile -replace '\.log$', '') + "-$(Get-Date -Format "yyyymmdd-HHmmss").log"
                Rename-Item -Path $logFile -NewName $backupLog -Force
                # Get filter information
                # First, we do a regex search, and just get the text before the .log and after the \
                $logFile -match '(\w*).log' | Out-Null
                # Now, we add a trailing * for the filter
                $logFileName = "$($Matches[1])*"
                # Get the path for the log so we know where to search
                $logPath = Split-Path -Path $logFile
                # And we remove any extra rollover logs.
                Get-ChildItem -Path $logPath -filter $logFileName | Where-Object { $_.Name -notin (Get-ChildItem -Path $logPath -Filter $logFileName | Sort-Object -Property LastWriteTime -Descending | Select-Object -First $maxLogHistory).name } | Remove-Item
            }
        }
        # Finally, we write the entry
        $cmEntry | Out-File $logFile -Append -Encoding ascii
    }
    # Also, we write verbose, just incase that's turned on.
    Write-Verbose $entry
} # End New-CmnLogEntry

Function Get-CMNPatchTuesday {
    <#
	.SYNOPSIS
		Calculates Patch Tuesday for the month provided (defaults to current month).

	.DESCRIPTION
        Calculates Patch Tuesday for the month provided (defaults to current month). Returns a date time
        
    .PARAMETER date
        Date for the month you want to determine patch Tuesday for (default is current month).

	.EXAMPLE
        $PatchTuesday = Get-CMNPatchTuesday
        
    .LINK
        http://configman-notes.com

    .NOTES
        Author:     James Parris
        Contact:    jim@ConfigMan-Notes.com
        Created:    2019-05-13
        Updated:    
        PSVer:	    3.0
        Version:    1.0.0
	#>
    [CmdletBinding(ConfirmImpact = 'Low')]

    PARAM
    (
        [Parameter(Mandatory = $false, HelpMessage = 'Date for the month you want to determine patch Tuesday for (default is current month).')]
        [DateTime]$date = $(Get-Date)
    )

    # Start by getting current day of week and finding the first Tuesday of the month
    [DateTime]$StrtDate = Get-date("$((Get-Date $date).Month)/1/$((Get-Date $date).Year)")
    While ($StrtDate.DayOfWeek -ne 'Tuesday') { $StrtDate = $StrtDate.AddDays(1) }
    # Now that we know when the first Tuesday is, let's get the second.
    $StrtDate = $StrtDate.AddDays(7)
    Return Get-Date $StrtDate -Format d
} # End Get-CMNPatchTuesday

# SCCM Functions 

Function Get-CmnSccmConnectionInfo {
    <#
    .SYNOPSIS
        Builds SccmConnectionInfo object for use in functions

    .DESCRIPTION
        Builds SccmConnectionInfo object for use in functions. Returns a PSObject with four properties:
            CimSession      CimSession to be used when calling functions
            NameSpace       NameSpace, also to be used when calling functions
            SCCMDBServer    SCCM Database Server Name
            SCCMDB          SCCM Database Name

    .PARAMETER SiteServer
        This is a variable containing name of the site server to connect to.
        
    .PARAMETER logFile
        File for writing logs to (default is c:\temp\eror.log).

    .PARAMETER logEntries
        Set to $true to write to the log file. Otherwise, it will just be write-verbose (default is $false).

    .PARAMETER maxLogSize
        Max size for the log (default is 5MB).

    .PARAMETER maxLogHistory
        Specifies the number of history log files to keep (default is 5).

    .EXAMPLE
        Get-CmnSccmConnectionInfo -siteServer Server1

        Returns
            SccmDbServer : server1.domain.com
            CimSession   : CimSession: server1
            NameSpace    : Root/SMS/Site_S01
            SccmDb       : CM_S01

    .LINK
        http://configman-notes.com

    .NOTES
        Author:	    Jim Parris
        Email:	    Jim@ConfigMan-Notes.com
        Date:	    2019-05-02
        Updated:    
        PSVer:	    3.0
        Version:    1.0.0		
	#>

    [CmdletBinding(ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'This is a variable containing name of the site server to connect to.')]
        [PSObject]$siteServer,

        [Parameter(Mandatory = $false, HelpMessage = 'File for writing logs to (default is c:\temp\eror.log).')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Set to $true to write to the log file. Otherwise, it will just be write-verbose (default is $false).')]
        [Boolean]$logEntries = $false,

        [Parameter(Mandatory = $false, HelpMessage = 'Max size for the log (default is 5MB).')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Specifies the number of history log files to keep (default is 5).')]
        [Int]$maxLogHistory = 5
    )

    begin {
        # Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'Get-CmnSccmConnectionInfo';
            logEntries    = $logEntries;
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        # Create a hashtable with your output info
        $returnHashTable = @{ }

        New-CmnLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        New-CmnLogEntry -entry "siteServer = $siteServer" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "siteCode = $siteCode" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
    }

    process {
        New-CmnLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry
        try {
            # Establish new CimSession to the site server.
            $cimSession = New-CimSession -ComputerName $siteServer

            # Now, to get the siteCode. We do this in the try/catch area to handle any errors.
            $siteCode = (Get-CimInstance -CimSession $cimSession -ClassName SMS_ProviderLocation -Namespace root\SMS).SiteCode
        }
        catch {
            # We hope this never runs, but if it does, time to write out some logs.
            New-CmnLogEntry -entry "Failed to complete: $error" -type 3 @NewLogEntry
            throw "Failed to complete: $error"
        }

        # Now that we are connected, let's get the database information. First pull from the site what we need
        $DataSourceWMI = $(Get-CimInstance -Class 'SMS_SiteSystemSummarizer' -Namespace "root/sms/site_$siteCode" -CimSession $cimSession -Filter "Role = 'SMS SQL SERVER' and SiteCode = '$siteCode' and ObjectType = 1").SiteObject

        # Now, to clean it up and just get the server name
        $SccmDbServer = $DataSourceWMI -replace '.*\\\\([A-Z0-9_.]+)\\.*', '$+'

        # Finally, the database name.
        $SccmDb = $DataSourceWMI -replace ".*\\([A-Z_0-9]*?)\\$", '$+'

        # Build the returnHashTable.
        $returnHashTable.Add('CimSession', $cimSession)
        $returnHashTable.Add('NameSpace', "Root/SMS/Site_$siteCode")
        $returnHashTable.Add('SccmDbServer', $SccmDbServer)
        $returnHashTable.Add('SccmDb', $SccmDb)
    }

    End {
        New-CmnLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.SccmConnectionInfo')
        Return $obj	
    }
} # End Get-CmnSccmConnectionInfo

Function Show-CMNLogs {
    <#
	    .SYNOPSIS
		    Opens logfiles using CMTrace for particular activity

	    .DESCRIPTION
		    You specify what activity you want to view logs for, this will open CMtrace showing those log files.
            This script assumes you have CMTrace in the directory you are in or in your path

	    .PARAMETER computerName
            Name of computer you want to view the logs for, defaults to localhost

        .PARAMETER activity
            Activity you are interested in, default is Default. Available values are:
                Default
                ClientDeployment
                ClientInventory
                Updates

	    .EXAMPLE
            Show-CMNLogs -computerName Computer1 -logs ClientDeployment
	    .LINK
		    http://configman-notes.com

	    .NOTES
		    Author:	Jim Parris
		    Email:	Jim@ConfigMan-Notes
		    Date:	2/1/2017
		    PSVer:	2.0/3.0
    #>

    [cmdletbinding()]
    PARAM
    (
        [Parameter(Mandatory = $false, HelpMessage = 'Computer name')]
        [ValidateScript( { Test-Connection -ComputerName $_ -Count 1 -Quiet })]
        [String]$computerName = 'localHost',

        [Parameter(Mandatory = $false, HelpMessage = 'Logs to look at')]
        [ValidateSet('Default', 'Application', 'ClientDeployment', 'ClientInventory', 'Updates', 'DCM', 'Schedule')]
        [String]$activity = 'Default'
    )
    #Hash table for log lists
    $sccmLogs = @{
        Default          = ('CAS.log', 'NomadBranch.log', 'PolicyAgent.log', 'ccmexec.log', 'execmgr.log');
        Application      = ('AppDiscovery.log', 'AppEnforce.log', 'CAS.log', 'NomadBranch.log', 'PolicyAgent.log', 'ccmexec.log', 'execmgr.log');
        ClientDeployment = ('ContentTransferManager.log', 'DataTransferService.log', 'LocationServices.log', 'ClientLocation.log', 'NomadBranch.log', 'ClientIDManagerStartup.log', 'PolicyAgent.log', 'CCMExec.log', 'ExecMgr.log');
        ClientInventory  = ('InventoryProvider.log', 'InventoryAgent.log', 'NomadBranch.log', 'PolicyAgent.log', 'CCMExec.log', 'ExecMgr.log');
        Updates          = ('CIDownloader.log', 'DataTransferService.log', 'ContentTransferManager.log', 'CAS.log', 'Scheduler.log', 'ServiceWindowManager.log', 'WUAhandler.log', 'UpdatesDeployment.log', 'ScanAgent.log', 'PolicyAgent.log', 'CCMExec.log', 'ExecMgr.log');
        DCM              = ('CIAgent.log', 'DCMWMIProvider.log', 'DCMAgent.log', 'DCMReporting.log', 'PolicyAgent.log', 'CCMExec.log', 'ExecMgr.log');
        Schedule         = ('ServiceWindowManager.log', 'Scheduler.log', 'CAS.log', 'NomadBranch.log', 'PolicyAgent.log', 'CCMexec.log', 'execmgr.log');
    }

    $nonSCCMLogs = @{
        ClientDeployment = ('\\ComputerName\C$\Windows\CCMSetup\Logs\CCMSetup.log', '\\ComputerName\C$\temp\Software_Install_Logs\System Center Configuration Manager (SCCM) Client_PSAppDeployToolkit_Install.log', '\\ComputerName\C$\temp\Software_Install_Logs\System Center Configuration Manager (SCCM) Client_PSAppDeployToolkit_Uninstall.log');
        Updates          = ('\\ComputerName\C$\Windows\WindowsUpdate.log');
    }

    #Make sure we have a good computername
    if ($computerName -eq 'localhost') { $computerName = $env:COMPUTERNAME }

    #get log base directory from registry
    $key = 'SOFTWARE\\Microsoft\\CCM\\Logging\\@Global'
    $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computerName)
    $RegKey = $Reg.OpenSubKey($key)
    $ccmLogDir = $RegKey.GetValue("LogDirectory")
    #"(?<pre>.*)st",'${pre}ar'
    $ccmLogDir -match '(.):\\(.*)' | Out-Null
    $ccmLogDir = "\\$computerName\$($Matches[1])$\$($Matches[2])"

    #Time to build the command
    $command = 'CMTrace'

    #Add the Non-SCCM logs first
    foreach ($log in $nonSCCMLogs[$activity]) {
        $line = $log -replace 'ComputerName', $computerName
        $command = "$command ""$line"""
    }

    foreach ($log in $sccmLogs[$activity]) {
        $command = "$command ""$ccmLogDir\$log"""
    }

    Invoke-Expression -Command $command
} # End Show-CMNLogs

# Collection functions

Function New-CMNCollection {
    <#
    .SYNOPSIS
        Creates a new, empty collection.

    .DESCRIPTION
        Creates a new, empty collection. Returns a collection object.

    .PARAMETER sccmConnectionInfo
        This is a variable containing the cim session to the site server, the site code, SCCM Database Server, and SCCM Database Name. It is a result of Get-CMNSccmConnectionInfo.

    .PARAMETER collectionName
        This is the name of the collection to be created.

    .PARAMETER description
        This is for the Comment section of the collection (optional).

    .PARAMETER limitToCollectionID
        CollectionID of the limiting collection this collection will be using.

    .PARAMETER collectionType
        Collection Type (1 = User, 2 = Device). Default = 2.
        
    .PARAMETER logFile
        File for writing logs to (default is c:\temp\eror.log).

    .PARAMETER logEntries
        Set to $true to write to the log file. Otherwise, it will just be write-verbose (default is $false).

    .PARAMETER maxLogSize
        Max size for the log (default is 5MB).

    .PARAMETER maxLogHistory
        Specifies the number of history log files to keep (default is 5).

    .EXAMPLE
        $collection = New-CMNCollection -sccmConnectionInfo $sccmCon -collectionName 'Test' -description 'Description goes here' -limitToCollectionID 'S0100001' -logFile 'C:\Temp\TestScript.log' -logEntries

        This will create a new collection named 'Test' with a comment of 'Description goes here' limited to the All Systems collection. It will also log to C:\Temp\TestScript.log

    .LINK
        http://configman-notes.com

    .NOTES
        Author:	    Jim Parris
        Email:	    Jim@ConfigMan-Notes.com
        Date:	    2019-05-02
        Updated:    
        PSVer:	    3.0
        Version:    1.0.0		
	#>

    [CmdletBinding(ConfirmImpact = 'Low')]
    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'This is a variable containing the cim session to the site server, the site code, SCCM Database Server, and SCCM Database Name. It is a result of Get-CMNSccmConnectionInfo.')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'This is the name of the collection to be created.')]
        [String]$collectionName,

        [Parameter(Mandatory = $false, HelpMessage = 'This is for the Comment section of the collection (optional).')]
        [String]$description,

        [Parameter(Mandatory = $true, HelpMessage = 'CollectionID of the limiting collection this collection will be using.')]
        [ValidatePattern('.{8}')]
        [String]$limitToCollectionID,

        [Parameter(Mandatory = $false, HelpMessage = 'Collection Type (1 = User, 2 = Device). Default = 2.')]
        [Int32]$collectionType = 2,

        [Parameter(Mandatory = $false, HelpMessage = 'File for writing logs to (default is c:\temp\eror.log).')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Set to $true to write to the log file. Otherwise, it will just be write-verbose (default is $false).')]
        [Boolean]$logEntries = $false,

        [Parameter(Mandatory = $false, HelpMessage = 'Max size for the log (default is 5MB).')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Specifies the number of history log files to keep (default is 5).')]
        [Int]$maxLogHistory = 5
    )

    begin {
        # Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'New-CMNCollection';
            logEntries    = $logEntries;
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        New-CmnLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        New-CmnLogEntry -entry "sccmConnectionInfo = $sccmConnectionInfo" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "collectionName = $collectionName" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "description = $description" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "limitToCollectionID = $limitToCollectionID" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "collectionType = $collectionType" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry    
        New-CmnLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
    }

    process {
        New-CmnLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry
        try {
            # Create the instance. That's all there is to it!
            $collection = New-CimInstance -CimSession ($sccmConnectionInfo.CimSession) -Namespace ($sccmConnectionInfo.NameSpace) -ClassName SMS_Collection -Property @{
                Name                = $collectionName;
                Comment             = $description;
                LimitToCollectionID = $limitToCollectionID;
                CollectionType      = $collectionType;
            }
        }
        catch {
            # Unless we have an error!
            New-CmnLogEntry -entry $Error -type 3 @NewLogEntry
            throw "Failed: $Error"
        }
    }

    End {
        New-CmnLogEntry -entry 'Completing Function' -type 1 @NewLogEntry
        New-CmnLogEntry -entry "Returning $($collection.CollectionID) - $($collection.Name)" -type 1 @NewLogEntry
        Return $collection	
    }
} # End New-CMNCollection

Function New-CmnCollectionRuleQuery {
    <#
    .SYNOPSIS
        Adds a query rule to a collection.

    .DESCRIPTION
        Adds a query rule to a collection. You provide the sccmConnectionInfo, collection object, colQuery, and ruleName. The query will be added to the collection.

    .PARAMETER sccmConnectionInfo
        This is a variable containing the cim session to the site server, the site code, SCCM Database Server, and SCCM Database Name. It is a result of Get-CMNSccmConnectionInfo.

    .PARAMETER collectionObj
        This is a SMS_Collection object of the collection to be updated.

    .PARAMETER sms_CollectionRuleQueryObj
        This is a SMS_CollectionRuleQuery object to add rules.

    .PARAMETER colQuery
        This is a WQL Query to be added as a rule to the collection.

    .PARAMETER ruleName
        This is the name to be given for the query rule, (default is "Query").
        
    .PARAMETER logFile
        File for writing logs to (default is c:\temp\eror.log).

    .PARAMETER logEntries
        Set to $true to write to the log file. Otherwise, it will just be write-verbose (default is $false).

    .PARAMETER maxLogSize
        Max size for the log (default is 5MB).

    .PARAMETER maxLogHistory
        Specifies the number of history log files to keep (default is 5).

    .EXAMPLE
        $query = 'select * from  SMS_R_System where SMS_R_System.NetbiosName in ("Server01","Server02","Server03")'
        New-CmnCollectionRuleQuery -sccmConnectionInfo $sccmCon -collection $collection -colQuery $query -ruleName 'RuleName' -Verbose | Out-Null

        This would add a query based rule to the collection that is held by the $collection variable.

    .LINK
        http://configman-notes.com

    .NOTES
        Author:	    Jim Parris
        Email:	    Jim@ConfigMan-Notes.com
        Date:	    2019-05-02
        Updated:    
        PSVer:	    3.0
        Version:    1.0.0		
	#>

    [CmdletBinding(ConfirmImpact = 'Low')]
    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'This is a variable containing the cim session to the site server, the site code, SCCM Database Server, and SCCM Database Name. It is a result of Get-CMNSccmConnectionInfo.')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'This is a SMS_Collection object of the collection to be updated.')]
        [PSObject]$collectionObj,

        [Parameter(Mandatory = $true, HelpMessage = 'This is a SMS_CollectionRuleQuery object to add rules.')]
        [PSObject]$sms_CollectionRuleQueryObj,

        [Parameter(Mandatory = $true, HelpMessage = 'This is a WQL Query to be added as a rule to the collection.')]
        [String]$colQuery,

        [Parameter(Mandatory = $false, HelpMessage = 'This is the name to be given for the query rule, default is "Query."')]
        [String]$ruleName = 'Query',

        [Parameter(Mandatory = $false, HelpMessage = 'File for writing logs to (default is c:\temp\eror.log).')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Set to $true to write to the log file. Otherwise, it will just be write-verbose (default is $false).')]
        [Boolean]$logEntries = $false,

        [Parameter(Mandatory = $false, HelpMessage = 'Max size for the log (default is 5MB).')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Specifies the number of history log files to keep (default is 5).')]
        [Int]$maxLogHistory = 5
    )

    begin {
        #Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'New-CmnCollectionRuleQuery';
            logEntries    = $logEntries;
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        New-CmnLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        New-CmnLogEntry -entry "sccmConnectionInfo = $sccmConnectionInfo" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "collectionObj = $collectionObj" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "sms_CollectionRuleQueryObj = $sms_CollectionRuleQueryObj" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "colQuery = $colQuery" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "ruleName = $ruleName" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
    }

    process {
        New-CmnLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry
        try {
            # Create a temporary one in memory (because of the -ClientOnly switch) for the rule.
            $queryMemberRule = New-CimInstance -ClientOnly -CimClass $sms_CollectionRuleQueryObj -Property @{
                QueryExpression = $colQuery;
                RuleName        = $ruleName;
            }

            # Finally, wwe add that rule to the colleciton
            $collection | Invoke-CimMethod -MethodName AddMembershipRule -Arguments @{CollectionRule = $queryMemberRule } | Out-Null
        }
        catch {
            # No!! We hope this never runs!
            New-CmnLogEntry -entry "Failed: $error" -type 3 @NewLogEntry
            throw "Failed: $error"
        }
    }

    End {
        New-CmnLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        Return $collection
    }
} #End New-CmnCollectionRuleQuery

Function New-CmnPatchTuesdayMaintenanceWindow {
    <#
    .SYNOPSIS
        Creates maintenance windows based of patch Tuesday for each month

    .DESCRIPTION
        Description goes here

    .PARAMETER sccmConnectionInfo
        This is a variable containing the cim session to the site server and the site code. It is a result of Get-CMNSccmConnectionInfo.

    .PARAMETER collectionObj
        This is the collection object that is to be updated

    .PARAMETER startDay
        Start Day. This is an integer of the number of days past PatchTuesday the maintenance window will start.

    .PARAMETER startTime
        Start Time. This is date/time object with just the time of day the maintenance window will start.

    .PARAMETER duration
        Duration: This is an integer with the number of minutes for the maintenance window.

    .PARAMETER numberOfMaintenanceWindows
        Number of Maintenance Windows to create (Default is 12)
        
    .PARAMETER logFile
        File for writing logs to (default is c:\temp\eror.log).

    .PARAMETER logEntries
        Set to $true to write to the log file. Otherwise, it will just be write-verbose (default is $false).

    .PARAMETER maxLogSize
        Max size for the log (default is 5MB).

    .PARAMETER maxLogHistory
        Specifies the number of history log files to keep (default is 5).

    .EXAMPLE

    .LINK
        http://configman-notes.com

    .NOTES
        Author:	    Jim Parris
        Email:	    Jim@ConfigMan-Notes.com
        Date:	    2019-05-14
        Updated:    
        PSVer:	    3.0
        Version:    1.0.0		
	#>

    [CmdletBinding(ConfirmImpact = 'Low')]
    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'This is a variable containing the cim session to the site server and the site code. It is a result of Get-CMNSccmConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'This is the collection object that is to be updated')]
        [PSObject]$collectionObj,

        [Parameter(Mandatory = $true, HelpMessage = 'This is a SMS_CollectionSettings Class object created by Get-CimClass')]
        [PSObject]$sms_CollectionSettings,
        
        [Parameter(Mandatory = $true, HelpMessage = 'This is a SMS_ST_NonRecurring Class object created by Get-CimClass')]
        [PSObject]$sms_ST_NonRecurring,
        
        [Parameter(Mandatory = $true, HelpMessage = 'This is a SMS_ServiceWindow Class object created by Get-CimClass')]
        [PSObject]$sms_ServiceWindow,
        
        [Parameter(Mandatory = $true, HelpMessage = 'Start Day. This is an integer of the number of days past PatchTuesday the maintenance window will start.')]
        [Int32]$startDay,

        [Parameter(Mandatory = $true, HelpMessage = 'Start Time. This is date/time object with just the time of day the maintenance window will start.')]
        [DateTime]$startTime,

        [Parameter(Mandatory = $true, HelpMessage = 'Duration: This is an integer with the number of minutes for the maintenance window.')]
        [Int32]$duration,

        [Parameter(Mandatory = $false, HelpMessage = 'Number of Maintenance Windows to create (Default is 12)')]
        [Int32]$numberOfMaintenanceWindows = 12,

        [Parameter(Mandatory = $false, HelpMessage = 'File for writing logs to (default is c:\temp\eror.log).')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Set to $true to write to the log file. Otherwise, it will just be write-verbose (default is $false).')]
        [Boolean]$logEntries = $false,

        [Parameter(Mandatory = $false, HelpMessage = 'Max size for the log (default is 5MB).')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Specifies the number of history log files to keep (default is 5).')]
        [Int]$maxLogHistory = 5
    )

    begin {
        # Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'New-CmnPatchTuesdayMaintenanceWindow';
            logEntries    = $logEntries;
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        New-CmnLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        New-CmnLogEntry -entry "sccmConnectionInfo = $sccmConnectionInfo" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "collectionOBJ = $collectionObj" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "startDay = $startDay" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "startTime = $startTime" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "duration = $duration" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "numberOfMaintenanceWindows = $numberOfMaintenanceWindows" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
    }

    process {
        New-CmnLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry
        if ($duration -ge 60) {
            [Int]$hourDuration = [Math]::Floor($duration / 60)
            [Int]$minuteDuration = $duration % 60
        }
        else {
            [Int]$hourDuration = 0
            [Int]$minuteDuration = $duration
        }
        try {
            # Create the instance. That's all there is to it!
            $CollectionSettings = Get-CimInstance -CimSession ($sccmConnectionInfo.CimSession) -Namespace ($sccmConnectionInfo.NameSpace) -ClassName SMS_CollectionSettings -Filter "CollectionID = '$($collectionObj.CollectionID)'"
            if (!($CollectionSettings)) {
                $CollectionSettings = New-CimInstance -CimSession ($sccmConnectionInfo.CimSession) -Namespace ($sccmConnectionInfo.NameSpace) -ClassName SMS_CollectionSettings -Property @{
                    CollectionID = ($collectionObj.CollectionID);
                }
            }
            for ($x = 0; $x -lt $numberOfMaintenanceWindows; $x++) {
                $StartTime = "$(Get-Date -date (Get-Date -Date (Get-CMNPatchTuesday -date (Get-Date).AddMonths($x))).AddDays($startDay - 1) -Format d) $(Get-Date $startTime -Format t)"
                $ServiceWindow = New-CimInstance -ClientOnly -CimClass $sms_ServiceWindowObj -Property @{
                    Name              = "Month - $x";
                    Description       = "Month - $x";
                    IsEnabled         = $true;
                    RecurrenceType    = 1;
                    ServiceWindowType = 1;
                    StartTime         = $startTime;
                }
                $CMSchedule = New-CimInstance -ClientOnly -CimClass $sms_ST_NonRecurringObj -Property @{
                    DayDuration    = 0;
                    HourDuration   = $hourDuration;
                    MinuteDuration = $minuteDuration;
                    IsGMT          = $false;
                    StartTime      = $startTime;
                }
                $ServiceWindow.ServiceWindowSchedules = (Invoke-CimMethod -Name WriteToString -ClassName SMS_ScheduleMethods -Namespace ($sccmConnectionInfo.NameSpace) -CimSession ($sccmConnectionInfo.CimSession) -Arguments @{
                        TokenData = $CMSchedule;
                    }).StringData;
                    
                $CollectionSettings.ServiceWindows += $ServiceWindow.PSObject.BaseObject
                if ($logEntries) { New-CmnLogEntry -entry "Setting $($targetCollection.Key) - Maintenance Window. Starts at $StartTime and goes for $hourDuration hours and $minuteDuration minutes." -type 1 @NewLogEntry }

                #Final step, it's just like we're hitting the "OK" button!
                $CollectionSettings.put() | Out-Null
            }
        }
        catch {
            # Unless we have an error!
            New-CmnLogEntry -entry $Error -type 3 @NewLogEntry
            throw "Failed: $Error"
        }
    }

    End {
        New-CmnLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
    }
} # End New-CmnPatchTuesdayMaintenanceWindow

#region
# Variables

$FeatureTypes = @("Unknown", "Application", "Program", "Invalid", "Invalid", "Software Update", "Invalid", "Task Sequence")

$OfferTypes = @("Required", "Not Used", "Available")

$FastDPOptions = @('RunProgramFromDistributionPoint', 'DownloadContentFromDistributionPointAndRunLocally')

$ObjectIDtoObjectType = @{
    2    = 'SMS_Package';
    3    = 'SMS_Advertisement';
    7    = 'SMS_Query';
    8    = 'SMS_Report';
    9    = 'SMS_MeteredProductRule';
    11   = 'SMS_ConfigurationItem';
    14   = 'SMS_OperatingSystemInstallPackage';
    17   = 'SMS_StateMigration';
    18   = 'SMS_ImagePackage';
    19   = 'SMS_BootImagePackage';
    20   = 'SMS_TaskSequencePackage';
    21   = 'SMS_DeviceSettingPackage';
    23   = 'SMS_DriverPackage';
    25   = 'SMS_Driver';
    1011 = 'SMS_SoftwareUpdate';
    2011 = 'SMS_ConfigurationBaselineInfo';
    5000 = 'SMS_Collection_Device';
    5001 = 'SMS_Collection_User';
    6000 = 'SMS_ApplicationLatest';
    6001 = 'SMS_ConfigurationItemLatest';
}

$ObjectTypetoObjectID = @{
    'SMS_Package'                       = 2;
    'SMS_Advertisement'                 = 3;
    'SMS_Query'                         = 7;
    'SMS_Report'                        = 8;
    'SMS_MeteredProductRule'            = 9;
    'SMS_ConfigurationItem'             = 11;
    'SMS_OperatingSystemInstallPackage' = 14;
    'SMS_StateMigration'                = 17;
    'SMS_ImagePackage'                  = 18;
    'SMS_BootImagePackage'              = 19;
    'SMS_TaskSequencePackage'           = 20;
    'SMS_DeviceSettingPackage'          = 21;
    'SMS_DriverPackage'                 = 23;
    'SMS_Driver'                        = 25;
    'SMS_SoftwareUpdate'                = 1011;
    'SMS_ConfigurationBaselineInfo'     = 2011;
    'SMS_Collection_Device'             = 5000;
    'SMS_Collection_User'               = 5001;
    'SMS_ApplicationLatest'             = 6000;
    'SMS_ConfigurationItemLatest'       = 6001;
}

$RerunBehaviors = @{
    RERUN_ALWAYS       = 'AlwaysRerunProgram';
    RERUN_NEVER        = 'NeverRerunDeployedProgra';
    RERUN_IF_FAILED    = 'RerunIfFailedPreviousAttempt';
    RERUN_IF_SUCCEEDED = 'RerunIfSucceededOnpreviousAttempt';
}

$SlowDPOptions = @('DoNotRunProgram', 'DownloadContentFromDistributionPointAndLocally', 'RunProgramFromDistributionPoint')

$SMS_Advertisement_AdvertFlags = @{
    IMMEDIATE                         = "0x00000020";
    ONSYSTEMSTARTUP                   = "0x00000100";
    ONUSERLOGON                       = "0x00000200";
    ONUSERLOGOFF                      = "0x00000400";
    WINDOWS_CE                        = "0x00008000";
    ENABLE_PEER_CACHING               = "0x00010000";
    DONOT_FALLBACK                    = "0x00020000";
    ENABLE_TS_FROM_CD_AND_PXE         = "0x00040000";
    OVERRIDE_SERVICE_WINDOWS          = "0x00100000";
    REBOOT_OUTSIDE_OF_SERVICE_WINDOWS = "0x00200000";
    WAKE_ON_LAN_ENABLED               = "0x00400000";
    SHOW_PROGRESS                     = "0x00800000";
    NO_DISPLAY                        = "0x02000000";
    ONSLOWNET                         = "0x04000000";
}

$SMS_Advertisement_DeviceFlags = @{
    AlwaysAssignProgramToTheClient = "0x01000000";
    OnlyIfDeviceHighBandwidth      = "0x02000000";
    AssignIfDocked                 = "0x04000000";
}

$SMS_Advertisement_ProgramFlags = @{
    DYNAMIC_INSTALL            = "0x00000001";
    TS_SHOW_PROGRESS           = "0x00000002";
    DEFAULT_PROGRAM            = "0x0000001";
    DISABLE_MOM_ALERTS         = "0x00000020";
    GENERATE_MOM_ALERT_IF_FAIL = "0x00000040";
    ADVANCED_CLIENT            = "0x00000080";
    DEVICE_PROGRAM             = "0x00000100";
    RUN_DEPENDENT              = "0x00000200";
    NO_COUNTDOWN_DIALOG        = "0x00000400";
    RESTART_ADR                = "0x00000800";
    PROGRAM_DISABLED           = "0x00001000";
    NO_USER_INTERACTION        = "0x00002000";
    RUN_IN_USER_CONTEXT        = "0x00004000";
    RUN_AS_ADMINISTRATOR       = "0x00008000";
    RUN_FOR_EVERY_USER         = "0x00010000";
    NO_USER_LOGGED_ON          = "0x00020000";
    EXIT_FOR_RESTART           = "0x00080000";
    USE_UNC_PATH               = "0x00100000";
    PERSIST_CONNECTION         = "0x00200000";
    RUN_MINIMIZED              = "0x00400000";
    RUN_MAXIMIZED              = "0x00800000";
    RUN_HIDDEN                 = "0x01000000";
    LOGOFF_WHEN_COMPLETE       = "0x02000000"
    ADMIN_ACCOUNT_DEFINED      = "0x04000000";
    OVERRIDE_PLATFORM_CHECK    = "0x08000000";
    UNINSTALL_WHEN_EXPIRED     = "0x20000000";
    PLATFORM_NOT_SUPPORTED     = "0x40000000"
    DISPLAY_IN_ADR             = "0x80000000";
}

$SMS_Advertisement_RemoteClientFlags = @{
    BATTERY_POWER                     = "0x00000001";
    RUN_FROM_CD                       = "0x00000002";
    DOWNLOAD_FROM_CD                  = "0x00000004";
    RUN_FROM_LOCAL_DISPPOINT          = "0x00000008";
    DOWNLOAD_FROM_LOCAL_DISPPOINT     = "0x00000010";
    DONT_RUN_NO_LOCAL_DISPPOINT       = "0x00000020";
    DOWNLOAD_FROM_REMOTE_DISPPOINT    = "0x00000040";
    RUN_FROM_REMOTE_DISPPOINT         = "0x00000080";
    DOWNLOAD_ON_DEMAND_FROM_LOCAL_DP  = "0x00000100";
    DOWNLOAD_ON_DEMAND_FROM_REMOTE_DP = "0x00000200";
    BALLOON_REMINDERS_REQUIRED        = "0x00000400";
    RERUN_ALWAYS                      = "0x00000800";
    RERUN_NEVER                       = "0x00001000";
    RERUN_IF_FAILED                   = "0x00002000";
    RERUN_IF_SUCCEEDED                = "0x00004000";
    PERSIST_ON_WRITE_FILTER_DEVICES   = "0x00008000";
    DONT_FALLBACK                     = "0x00020000";
    DP_ALLOW_METERED_NETWORK          = "0x00040000";
}

$SMS_Advertisement_TimeFlags = @{
    ENABLE_PRESENT     = '0x00000001';
    ENABLE_EXPIRATION  = '0x00000002';
    ENABLE_AVAILABLE   = '0x00000004';
    ENABLE_UNAVAILABLE = '0x00000008';
    ENABLE_MANDATORY   = '0x00000010';
    GMT_PRESENT        = '0x00000020';
    GMT_EXPIRATION     = '0x00000040';
    GMT_AVAILABLE      = '0x00000080';
    GMT_UNAVAILABLE    = '0x00000100';
    GMT_MANDATORY      = '0x00000200';
}

$SMS_Package_PkgFlags = @{
    COPY_CONTENT         = '0x00000080';
    DO_NOT_DOWNLOAD      = '0x01000000';
    PERSIST_IN_CACHE     = '0x02000000';
    USE_BINARY_DELTA_REP = '0x04000000';
    NO_PACKAGE           = '0x10000000';
    USE_SPECIAL_MIF      = '0x20000000';
    DISTRIBUTE_ON_DEMAND = '0x40000000';
}

$SMS_Program_ProgramFlags = @{
    AUTHORIZED_DYNAMIC_INSTALL = '0x00000001';
    USECUSTOMPROGRESSMSG       = '0x00000002';
    DEFAULT_PROGRAM            = '0x00000010';
    DISABLEMOMALERTONRUNNING   = '0x00000020';
    MOMALERTONFAIL             = '0x00000040';
    RUN_DEPENDANT_ALWAYS       = '0x00000080';
    WINDOWS_CE                 = '0x00000100';
    COUNTDOWN                  = '0x00000400';
    FORCERERUN                 = '0x00000800';
    DISABLED                   = '0x00001000';
    UNATTENDED                 = '0x00002000';
    USERCONTEXT                = '0x00004000';
    ADMINRIGHTS                = '0x00008000';
    EVERYUSER                  = '0x00010000';
    NOUSERLOGGEDIN             = '0x00020000';
    OKTOQUIT                   = '0x00040000';
    OKTOREBOOT                 = '0x00080000';
    USEUNCPATH                 = '0x00100000';
    PERSISTCONNECTION          = '0x00200000';
    RUNMINIMIZED               = '0x00400000';
    RUNMAXIMIZED               = '0x00800000';
    HIDEWINDOW                 = '0x01000000';
    OKTOLOGOFF                 = '0x02000000';
    RUNACCOUNT                 = '0x04000000';
    ANY_PLATFORM               = '0x08000000';
    SUPPORT_UNINSTALL          = '0x20000000';
}
#endregion
<# 
$sccmCon = Get-CmnSccmConnectionInfo -siteServer LOUAPPWTS1140 -Verbose
$sms_CollectionRuleQueryObj = Get-CimClass -CimSession ($sccmCon.CimSession) -Namespace ($sccmCon.NameSpace) -ClassName SMS_CollectionRuleQuery
$sms_CollectionSettingsObj = Get-CimClass -CimSession ($sccmCon.CimSession) -Namespace ($sccmCon.NameSpace) -ClassName SMS_CollectionSettings
$sms_ST_NonRecurringObj = Get-CimClass -CimSession ($sccmCon.CimSession) -Namespace ($sccmCon.NameSpace) -ClassName SMS_ST_NonRecurring
$sms_ServiceWindowObj = Get-CimClass -CimSession ($sccmCon.CimSession) -Namespace ($sccmCon.NameSpace) -ClassName SMS_ServiceWindow
$sms_ScheduleMethodsObj = Get-CimClass -CimSession ($sccmCon.CimSession) -Namespace ($sccmCon.NameSpace) -ClassName SMS_ScheduleMethods
$collection = New-CMNCollection -sccmConnectionInfo $sccmCon -collectionName 'Test' -description 'Description goes here' -limitToCollectionID 'SMS00001' -Verbose
$query = 'select * from  SMS_R_System where SMS_R_System.NetbiosName in ("LOUAPPWTS1140")'
$collection2 = New-CmnCollectionRuleQuery -sccmConnectionInfo $sccmCon -collection $collection -sms_CollectionRuleQueryObj $sms_CollectionRuleQueryObj -colQuery $query -ruleName 'RuleName' -Verbose 
$collection | gm
Write-Output '-----------------------------------------------'
$collection2 | gm
New-CmnPatchTuesdayMaintenanceWindow -sccmConnectionInfo $sccmCon -collectionObj $collection -sms_CollectionSettings $sms_CollectionSettingsObj -sms_ST_NonRecurring $sms_ST_NonRecurringObj -sms_ServiceWindow $sms_ServiceWindowObj -startDay 5 -startTime "8:00:00 pm" -duration 120 -Verbose
 #>