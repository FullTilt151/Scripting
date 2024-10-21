Function Get-CMNDatabaseData {
    <#
    .Synopsis
        This function will query the database specified in the connectionString using the query. If it's a SQL server, isSQLServer should be set to true.

    .DESCRIPTION
        This function will query the database specified in the connectionString using the query. If it's a SQL server, isSQLServer should be set to true.
		This script was taken straight out of Learn PowerShell ToolMaking in a Month of Lunches, it's a great book that I used to develop this module.
		Can be found at http://www.manning.com

    .PARAMETER connectionString
        This is the connectionstring to connect to the SQL server

    .PARAMETER query
        query to be executed to retrieve the data

    .PARAMETER isSQLServer
        Lets us know if it's a SQL server

    .EXAMPLE
		Get-CMNSQLQuery 'Data source=SQLServer1;Integrated Security=SSPI;Initial Catalog=Shopping' 'Select * from v_Employees'

    .LINK
        http://configman-notes.com

    .NOTES

    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$connectionString,
        [Parameter(Mandatory = $true)]
        [string]$query,
        [Parameter(Mandatory = $true)]
        [switch]$isSQLServer,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int]$maxLogHistory = 5
    )
    # Assign a value to logEntries
    if ($PSBoundParameters['logEntries']) {$logEntries = $true}
    else {$logEntries = $false}

    #Build splat for log entries
    $NewLogEntry = @{
        logFile       = $logFile;
        logEntries    = $logEntries;
        Component     = 'Get-CMNDatabaseData';
        maxLogSize    = $maxLogSize;
        maxLogHistory = $maxLogHistory;
    }

    if ($isSQLServer) {
        New-CmnLogEntry -entry 'in SQL Server mode' -type 1 @NewLogentry
        $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
    }
    else {
        New-CmnLogEntry -entry 'in OleDB mode' -type 1 @NewLogEntry
        $connection = New-Object -TypeName System.Data.OleDb.OleDbConnection
    }
    $connection.ConnectionString = $connectionString
    $command = $connection.CreateCommand()
    $command.CommandTimeout = 600
    $command.CommandText = $query
    if ($isSQLServer) {
        $adapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter $command
    }
    else {
        $adapter = New-Object -TypeName System.Data.OleDb.OleDbDataAdapter $command
    }
    $dataset = New-Object -TypeName System.Data.DataSet
    New-CMNLogEntry -entry "Running $query" -type 1 @NewLogEntry
    $adapter.Fill($dataset) | Out-Null
    $connection.close()
    return $dataset.Tables[0]
} #End Get-CMNDatabaseData

Function Invoke-CMNDatabaseQuery {
    <#
    .Synopsis
        This function will query the database $Database on $DatabaseServer using the $SQLCommand

    .DESCRIPTION
        This function will query the database $Database on $DatabaseServer using the $SQLCommand. It uses windows authentication

    .PARAMETER connectionString
        This is the database server that the query will be run on

    .PARAMETER query
        This is the query to be run

    .PARAMETER isSQLServer
        This is the query to be run

    .EXAMPLE
		Get-CMNSQLQuery 'DB1' 'DBServer' 'Select * from v_Employees'

    .LINK
        http://configman-notes.com

    .NOTES

    #>

    [CmdletBinding(SupportsShouldProcess = $True,
        ConfirmImpact = 'Low')]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$connectionString,
        [Parameter(Mandatory = $true)]
        [string]$query,
        [Parameter(Mandatory = $true)]
        [switch]$isSQLServer,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int]$maxLogHistory = 5
    )
    # Assign a value to logEntries
    if ($PSBoundParameters['logEntries']) {$logEntries = $true}
    else {$logEntries = $false}

    #Build splat for log entries
    $NewLogEntry = @{
        logFile       = $logFile;
        logEntries    = $logEntries;
        Component     = 'Invoke-CMNDatabaseQuery';
        maxLogSize    = $maxLogSize;
        maxLogHistory = $maxLogHistory;
    }

    if ($isSQLServer) {
        New-CmnLogEntry -entry 'in SQL Server mode' -type 1 @NewLogentry
        $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
    }
    else {
        New-CmnLogEntry -entry 'in OleDB mode' -type 1 @NewLogentry
        $connection = New-Object -TypeName System.Data.OleDb.OleDbConnection
    }
    $connection.ConnectionString = $connectionString
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    if ($pscmdlet.shouldprocess($query)) {
        New-CMNLogEntry -entry "Running $query" -type 1 @NewLogEntry
        $connection.Open()
        $command.ExecuteNonQuery() | Out-Null
        $connection.close()
    }
} #End Invoke-CMNDatabaseQuery

Function ConvertTo-CmnIpAddress {
    <#
    .SYNOPSIS 
        Converts binary IP address to dotted decimal notation

    .DESCRIPTION
        Converts binary IP address to dotted decimal notation
        
    .PARAMETER ipInBinary
        IP Address in binary

    .EXAMPLE
        ConvertTo-CmnIpAddress -ipInBinary '10000100101000101110011111111100'
        Returns:
        132.162.231.252

    .LINK
        http://configman-notes.com

    .NOTES
        Author:	    Jim Parris
        Email:	    Jim@ConfigMan-Notes
        Date:	    2018-12-26
        PSVer:	    2.0/3.0
        Updated: 
        Version:    1.0.0		
	#>
 
    [CmdletBinding(ConfirmImpact = 'Low')]

    Param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'IP Address (in Binary) to convert')]
        [string]$ipInBinary,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int]$maxLogHistory = 5
    )
    # Assign a value to logEntries
    if ($PSBoundParameters['logEntries']) {$logEntries = $true}
    else {$logEntries = $false}

    #Build splat for log entries
    $NewLogEntry = @{
        logFile       = $logFile;
        logEntries    = $logEntries;
        Component     = 'ConvertTo-CmnIpAddress';
        maxLogSize    = $maxLogSize;
        maxLogHistory = $maxLogHistory;
    }

    $IP = @() 
    For ($x = 1 ; $x -le 4 ; $x++) { 
        #Work out start character position 
        $StartCharNumber = ($x - 1) * 8 
        #Get octet in binary 
        $IPOctetInBinary = $ipInBinary.Substring($StartCharNumber, 8) 
        #Convert octet into decimal 
        $IPOctetInDecimal = [convert]::ToInt32($IPOctetInBinary, 2) 
        #Add octet to IP  
        $IP += $IPOctetInDecimal 
    } 
    #Separate by . 
    $IP = $IP -join "."
    Return $IP
} #End ConvertTo-CmnIpAddress

Function Get-CmnIpRange {
    <#
    .SYNOPSIS 

    .DESCRIPTION
        
    .PARAMETER 

    .EXAMPLE

    .LINK
        http://configman-notes.com

    .NOTES
        Author:	    Jim Parris
        Email:	    Jim@ConfigMan-Notes
        Date:	
        PSVer:	    2.0/3.0
        Updated: 
        Version:    1.0.0		
	#>
 
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]

    Param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'IP Subnet (using CIDR) to get range of')]
        [String]$subnet,

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
            logFile       = $logFile;
            logentries    = $logEntries;
            Component     = 'Get-CmnIpRange';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        # Create a hashtable with your output info
        $returnHashTable = @{}

        # Create a hashtable with your output info
        $returnHashTable = @{}

        New-CmnLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        New-CmnLogEntry -entry "subnet = $subnet" -type 1 @NewLogEntry
    }

    process {
        New-CmnLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry
        
        if ($PSCmdlet.ShouldProcess($subnet)) {
            
            #Split IP and subnet 
            $IP = ($Subnet -split "\/")[0] 
            $SubnetBits = ($Subnet -split "\/")[1] 
            #Convert IP into binary 
            #Split IP into different octects and for each one, figure out the binary with leading zeros and add to the total 
            $Octets = $IP -split "\." 
            $IPInBinary = @() 
            foreach ($Octet in $Octets) { 
                #convert to binary 
                $OctetInBinary = [convert]::ToString($Octet, 2) 
                #get length of binary string add leading zeros to make octet 
                $OctetInBinary = ("0" * (8 - ($OctetInBinary).Length) + $OctetInBinary) 
                $IPInBinary = $IPInBinary + $OctetInBinary 
            } 
            $IPInBinary = $IPInBinary -join "" 
            #Get network ID by subtracting subnet mask 
            $HostBits = 32 - $SubnetBits 
            $NetworkIDInBinary = $IPInBinary.Substring(0, $SubnetBits) 
            #Get host ID and get the first host ID by converting all 1s into 0s 
            $HostIDInBinary = $IPInBinary.Substring($SubnetBits, $HostBits)         
            $HostIDInBinary = $HostIDInBinary -replace "1", "0" 
            #Work out all the host IDs in that subnet by cycling through $i from 1 up to max $HostIDInBinary (i.e. 1s stringed up to $HostBits) 
            #Work out max $HostIDInBinary 
            $iSubnet = [convert]::ToInt32($HostIDInBinary, 2)
            $iSubnetHostBinary = [convert]::toString($iSubnet, 2)
            $iSubnetInBinary = "$NetworkIDInBinary$("0" * ($HostIDInBinary.Length - $iSubnetHostBinary.Length) + $iSubnetHostBinary)"
            $imin = [convert]::ToInt32($HostIDInBinary, 2) + 1
            $iMinHostBinary = [convert]::ToString($imin, 2)
            $iMinInBinary = "$NetworkIDInBinary$("0" * ($HostIDInBinary.Length - $iMinHostBinary.Length) + $iMinHostBinary)"
            $imax = [convert]::ToInt32(("1" * $HostBits), 2) - 1 
            $iMaxHostBinary = [Convert]::ToString($imax, 2)
            $iMaxInBinary = "$NetworkIDInBinary$("0" * ($HostIDInBinary.Length - $iMaxHostBinary.Length) + $iMaxHostBinary)"
            $iBroadcast = [convert]::ToInt32(("1" * $HostBits), 2)
            $iBroadcastHostBinary = [Convert]::ToString($iBroadcast, 2)
            $iBroadcastInBinary = "$NetworkIDInBinary$("0" * ($HostIDInBinary.Length - $iBroadcastHostBinary.Length) + $iBroadcastHostBinary)"
            $returnHashTable.Add('Subnet', (ConvertTo-CmnIpAddress -ipInBinary $iSubnetInBinary))
            $returnHashTable.Add('Min', (ConvertTo-CmnIpAddress -ipInBinary $iMinInBinary))
            $returnHashTable.Add('Max', (ConvertTo-CmnIpAddress -ipInBinary $iMaxInBinary))
            $returnHashTable.Add('Broadcast', (ConvertTo-CmnIpAddress -ipInBinary $iBroadcastInBinary))
        }
    }

    End {
        New-CmnLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.IpRange')
        Return $obj
    }
} #End Get-CmnIpRange

Function ConvertTo-CmnCidr {
    <#
    .SYNOPSIS 
        Converts IP address and subnet mask to a CIDR address

    .DESCRIPTION
        Converts IP address and subnet amsk in put to a CIDR address

    .PARAMETER ipAddress
        IP Address in dotted decimal notation

    .PARAMETER subnetMask
        Subnet mask in dotted decimal notation

    .PARAMETER logFile
        File for writing logs to, default is c:\temp\eror.log

    .PARAMETER logEntries
         Switch to say if we write to the log file. Otherwise, it will just be write-verbose

    .PARAMETER maxLogSize
        Max size for the log. Defaults to 5MB.

    .PARAMETER maxLogHistory
        Specifies the number of history log files to keep, default is 5
    
    .EXAMPLE
        ConvertTo-CmnCidr -ipAddress 192.168.0.1 -subnetMask 255.255.240.0
        will return 192.168.0.1/20

    .LINK
        http://configman-notes.com

    .NOTES
        Author:	    Jim Parris
        Email:	    Jim@ConfigMan-Notes
        Date:	
        PSVer:	    2.0/3.0
        Updated:    2018-12-26
        Version:    1.0.0		
	#>
 
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]

    Param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'IP Address')]
        [string]$ipAddress,
        
        [Parameter(Mandatory = $true, HelpMessage = 'Subnet Mask')]
        [String]$subnetMask,

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
            logFile       = $logFile;
            logEntries    = $logEntries;
            Component     = 'ConvertTo-CmnCidr';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        #Write to the log if we're supposed to!
        New-CmnLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        New-CmnLogEntry -entry "ipAddress = $ipAddress" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "subnetMask = $subnetMask" -type 1 @NewLogEntry
    }

    process {
        New-CmnLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry
        
        if ($PSCmdlet.ShouldProcess($ipAddress)) {
            $octets = $subnetMask -split "\." 
            $subnetInBinary = @() 
            foreach ($octet in $octets) { 
                #convert to binary 
                $octetInBinary = [convert]::ToString($octet, 2) 
                #get length of binary string add leading zeros to make octet 
                $octetInBinary = ("0" * (8 - ($octetInBinary).Length) + $octetInBinary) 
                $subnetInBinary = $subnetInBinary + $octetInBinary 
            } 
            $subnetInBinary = $subnetInBinary -join "" 
            New-CmnLogEntry -entry "Subnet = $subnetInBinary" -type 1 @NewLogEntry
            $x = 0
            while ($subnetInBinary.Substring($x, 1) -eq '1') {
                $x++
            }
            $networkBits = $x
            $isValid = $true
            do {
                if ($subnetInBinary.Substring($x, 1) -ne '0') {
                    $isValid = $false
                } 
                $x++ 
            } while ($x -lt 32)
        }
    }

    End {
        New-CmnLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        if (!$isValid) {
            New-CmnLogEntry "Invalid Mask" -type 3 @NewLogEntry
            throw "Invalid Mask"
        }
        Return "$ipAddress/$networkBits"
    }
} #End ConvertTo-CmnCidr

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
                                      Added adjustment in TimeZond for Daylight Savings Time
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
    #otherwise, we need to represent it as -###
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

Function Get-CMNADSites {
    <#
    .SYNOPSIS
        Gets sites from current domain

    .DESCRIPTION
        Gets sites from current domain

    .EXAMPLE

    .LINK
        http://configman-notes.com

    .NOTES
        Author:	    Jim Parris
        Email:	    Jim@ConfigMan-Notes.com
        Date:	    2018-12-26
        Updated:    
        PSVer:	    3.0
        Version:    1.0.0
        http://powershellblogger.com/2015/10/export-subnets-from-active-directory-sites-and-services/	
	#>

    [CmdletBinding(ConfirmImpact = 'Low')]
    PARAM(
        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int]$maxLogHistory = 5
    )
    # Assign a value to logEntries
    if ($PSBoundParameters['logEntries']) {$logEntries = $true}
    else {$logEntries = $false}

    #Build splat for log entries
    $NewLogEntry = @{
        logFile       = $logFile;
        logEntries    = $logEntries;
        Component     = 'Get-CMNADSites';
        maxLogSize    = $maxLogSize;
        maxLogHistory = $maxLogHistory;
    }

    New-CmnLogEntry -entry 'Starting AD Sites' -type 1 @NewLogEntry
    $sites = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Sites

    $sitesubnets = @()

    New-CmnLogEntry -entry 'Retrieved sites, cycling through' -type 1 @NewLogEntry
    foreach ($site in $sites) {
        foreach ($subnet in $site.subnets) {
            $temp = New-Object PSCustomObject -Property @{
                'Site'   = $site.Name;
                'Subnet' = $subnet.Name; 
            }
            $sitesubnets += $temp
        }
    }
    Return $sitesubnets
} #End Get-CMNADSites

Function Optimize-CMNBoundaries {
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
        
        SMS_Boundary.BoundaryFlags 0 = FAST, 1 = SLOW
        SMS_Boundary.BoundaryType 0 = IPSUBNET, 1 = ADSITE, 2 = IPV6PREFIX, 3 = IPRANGE
	#>

    [CmdletBinding(ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'Database connection string')]
        [String]$databaseConnectionString,

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
            logFile       = $logFile;
            logEntries    = $logEntries;
            Component     = 'Optimize-CMNBoundaries';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        New-CmnLogEntry -entry 'Starting gathering information' -type 1 @NewLogEntry

        #Build splat for WMIQueries
        $WMIQueryParameters = $sccmConnectionInfo.WMIQueryParameters

        $dbConString = Get-CMNConnectionString -DatabaseServer $sccmConnectionInfo.SCCMDBServer -Database $sccmConnectionInfo.SCCMDB

        # Create a hashtable with your output info
        $returnHashTable = @{}

        New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        New-CMNLogEntry -entry "sccmConnectionInfo = $sccmConnectionInfo" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
        $query = "SELECT DISTINCT STM.Domain0,
        NAC.IPAddress0,
        NAC.IPSubnet0
    FROM v_GS_System STM
    JOIN v_GS_NETWORK_ADAPTER_CONFIGURATION NAC ON STM.ResourceID = NAC.ResourceID
    WHERE IPAddress0 IS NOT NULL
    ORDER BY IPAddress0,
        IPSubnet0"
        New-CmnLogEntry -entry 'Getting Subnets' -type 1 @NewLogEntry
        $subnets = Get-CMNDatabaseData -connectionString $dbConString -query $query -isSQLServer -logFile $logFile -logEntries:$logEntries -maxLogSize $maxLogSize -maxLogHistory $maxLogHistory
        New-CmnLogEntry -entry 'Getting AD Sites' -type 1 @NewLogEntry
        $adSites = Get-CMNADSites -logFile $logFile -logEntries:$logEntries -maxLogSize $maxLogSize -maxLogHistory $maxLogHistory
        New-CmnLogEntry -entry 'Getting CM Boundaries' -type 1 @NewLogEntry
        $boundaries = Get-CimInstance -ClassName SMS_Boundary @WMIQueryParameters
    }

    process {
        New-CMNLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry
        #$boundaries.Value = $adSites.SiteName
        #$boundaries.BoundaryType 1 = AD Site
        foreach ($adSite in $adSites) {
            $ipRange = Get-CmnIpRange -subnet $adsite.Subnet -logFile $logFile -logEntries:$logEntries -maxLogSize $maxLogSize -maxLogHistory $maxLogHistory #account for nulls
            $query = "INSERT INTO ADSites (
                    Site,
                    Subnet,
                    SubnetID,
                    BroadcastID
                    )
                VALUES (
                    '$($adSite.Site)',
                    '$($adSite.Subnet)',
                    '$($ipRange.Subnet)',
                    '$($ipRange.Broadcast)'
                    )"
            Invoke-CMNDatabaseQuery -connectionString $databaseConnectionString -query $query -isSQLServer
            $ipRange = Get-CMNIpRange -subnet $adSite.Subnet -logFile $logFile -logEntries:$logEntries -maxLogSize $maxLogSize -maxLogHistory $maxLogHistory #account for null
            $query = "IF NOT (
                    EXISTS (
                        SELECT *
                        FROM Boundaries
                        WHERE Subnet = '$($adSite.Subnet)'
                        )
                    )
                INSERT INTO Boundaries (
                    Subnet,
                    MinIP,
                    MaxIP,
                    SubnetID,
                    BroadcastID
                    )
                VALUES (
                    '$($adSite.Subnet)',
                    '$($ipRange.Min)',
                    '$($ipRange.Max)',
                    '$($ipRange.Subnet)',
                    '$($ipRange.Broadcast)'
                    )"
            Invoke-CMNDatabaseQuery -connectionString $databaseConnectionString -query $query -isSQLServer -logFile $logFile -logEntries:$logEntries -maxLogSize $maxLogSize -maxLogHistory $maxLogHistory
        }
        foreach ($boundary in $boundaries) {
            #BoundaryType 0 = IPSubnet, 1 = ADSite, 2 = IPV6Prefix, 3 = IPRANGE
            if ($boundary.BoudaryType -eq 3) {
                $ipRange = @{
                    Min       = 'NA';
                    Max       = 'NA';
                    Subnet    = 'NA';
                    Broadcast = 'NA';
                }
            }
            else {
                $boundaryRange = $boundary.Value.Split('-')
                $ipRange = @{
                    Min       = 'NA';
                    Max       = 'NA';
                    Subnet    = $boundaryRange[0];
                    Broadcast = $boundaryRange[1];
                }
            }            
            $query = "INSERT INTO CM_Boundaries (
                    BoundaryID,
                    BoundaryType,
                    DisplayName,
                    Value,
                    SubnetID,
                    BroadcastID
                    )
                VALUES (
                    '$($boundary.BoundaryID)',
                    '$($boundary.BoundaryType)',
                    '$($boundary.DisplayName)',
                    '$($boundary.Value)',
                    '$($ipRange.Subnet)',
                    '$($ipRange.Brodcast)'
                    )"
            Invoke-CMNDatabaseQuery -connectionString $databaseConnectionString -query $query -isSQLServer -logFile $logFile -logEntries:$logEntries -maxLogSize $maxLogSize -maxLogHistory $maxLogHistory
        }
        foreach ($subnet in $subnets) {
            $ipSubnet = ConvertTo-CMNCidr -ipAddress $subnet.IPaddress0 -subnetMask $subnet.IPSubnet0 -logFile $logFile -logEntries:$logEntries -maxLogSize $maxLogSize -maxLogHistory $maxLogHistory
            $query = "INSERT INTO CM_Subnets (
                    Domain,
                    Subnet
                    )
                VALUES (
                    '$($subnet.Domain0)',
                    '$ipSubnet'
                    )"
            Invoke-CMNDatabaseQuery -connectionString $databaseConnectionString -query $query -isSQLServer -logFile $logFile -logEntries:$logEntries -maxLogSize $maxLogSize -maxLogHistory $maxLogHistory
            $ipRange = Get-CMNIpRange -subnet $ipSubnet -logFile $logFile -logEntries:$logEntries -maxLogSize $maxLogSize -maxLogHistory $maxLogHistory
            $query = "IF NOT (
                    EXISTS (
                        SELECT *
                        FROM Boundaries
                        WHERE Subnet = '$ipSubnet'
                        )
                    )
                    INSERT INTO Boundaries (
                        Subnet,
                        MinIP,
                        MaxIP
                        )
                    VALUES (
                        '$ipSubnet',
                        '$($ipRange.Min)',
                        '$($ipRange.Max)'
                        )"
            Invoke-CMNDatabaseQuery -connectionString $databaseConnectionString -query $query -isSQLServer -logFile $logFile -logEntries:$logEntries -maxLogSize $maxLogSize -maxLogHistory $maxLogHistory
        }
    }

    End {
        New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.ObjectType')
        Return $obj	
    }
} #End Optimize-CMNBoundaries

$logFile = 'c:\temp\Optimize-CMNBoundaries.log'
New-CmnLogEntry -entry 'Beginning it all!' -type 1 -logFile $logFile -logEntries -component 'Optimize-CMNBoundaries'
$SCM = Get-CMNSCCMConnectionInfo -siteServer LOUAPPWTS1140
$dbCon = Get-CMNConnectionString -DatabaseServer 'lousqlwts553.rsc.humad.com' -Database 'OptimizeBoundaries'
Optimize-CMNBoundaries -sccmConnectionInfo $SCM -databaseConnectionString $dbCon -logFile $logFile -logEntries