Function Create-CMNProductCollections
{
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

	.PARAMETER maxLogSize
		Max size for the log. Defaults to 5MB.

	.PARAMETER maxHistory
			Specifies the number of history log files to keep, default is 5

 	.EXAMPLE

	.LINK
		http://configman-notes.com

	.NOTES
		FileName:    Create-CMNProductCollections.ps1
		Author:      James Parris
		Contact:     Jim@ConfigMan-Notes.com
		Created:     2016-03-22
		Updated:     2016-03-22
		Version:     1.0.0
	#>

	[CmdletBinding(SupportsShouldProcess = $true,
		ConfirmImpact = 'Low')]

	PARAM
	(
		[Parameter(Mandatory = $true,
			HelpMessage = 'SCCM Connection Info')]
		[PSObject]$SCCMConnectionInfo,

		[Parameter(Mandatory = $true,
			HelpMessage = 'Product (Use % as wildcard)')]
		[String]$Product,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Limit to Colleciton ID')]
        [String]$LimitToCollectionID,

 		[Parameter(Mandatory = $false,
			HelpMessage = 'LogFile Name')]
		[String]$logFile = 'C:\Temp\Error.log',

		[Parameter(Mandatory = $false,
			HelpMessage = 'Log entries')]
		[Switch]$logEntries,

		[Parameter(Mandatory = $false,
			HelpMessage = 'Max Log size')]
		[Int32]$maxLogSize = 5242880,

		[Parameter(Mandatory = $false,
            HelpMessage = 'Max number of history logs')]
        [Int32]$maxHistory = 5
	)

	Begin
	{
		# Disable Fast parameter usage check for Lazy properties
		$CMPSSuppressFastNotUsedCheck = $true
		#Build splat for log entries
		$NewLogEntry = @{
			LogFile = $logFile;
			Component = 'Create-CMNProductCollections';
			maxLogSize = $maxLogSize;
			maxHistory = $maxHistory;
		}
		#Build splats for WMIQueries
        $WMIQueryParameters = $SCCMConnectionInfo.WMIQueryParameters
		$DBConnectionString = Get-CMNConnectionString -DatabaseServer $SCCMConnectionInfo.SCCMDBServer -Database $SCCMConnectionInfo.SCCMDB
		if($PSBoundParameters['logEntries'])
		{
			New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
			New-CMNLogEntry -entry "SCCMConnectionInfo = $SCCMConnectionInfo" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "DBConnectionString = $DBConnectionString" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "Product = $Product" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "LimitToCollectionID - $LimitToCollectionID" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "maxHistory = $maxHistory" -type 1 @NewLogEntry
		}
	}

	Process
	{
		if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry}
		# Main code part goes here
		$Query = "SELECT DISTINCT productname0,
                productversion0
FROM   v_gs_installed_software
WHERE  productname0 LIKE '$Product'
ORDER  BY productname0,
          productversion0"
		$Results = Get-CMNDatabaseData -connectionString $DBConnectionString -query $Query -isSQLServer
		foreach($Result in $Results)
		{
			$Query = "SELECT *
FROM   sms_r_system
       INNER JOIN sms_g_system_installed_software
               ON sms_g_system_installed_software.resourceid =
                  sms_r_system.resourceid
WHERE  sms_g_system_installed_software.productname LIKE '$($Result.productname0)'
       AND sms_g_system_installed_software.productversion = '$($Result.productversion0)'"
            $CollectionName = "$($Result.productname0) - $($Result.ProductVersion0)"
            $Collection = Get-WmiObject -query "Select * from SMS_Collection where Name = '$CollectionName'" @WMIQueryParameters
            if($Collection)
            {
                if($PSBoundParameters['LogEntries']){New-CMNLogEntry -entry "$CollectionName already exists, skipping" -type 1 @NewLogEntry}
            }
            else
            {
                if($PSBoundParameters['LogEntries']){New-CMNLogEntry -entry "Creating collection $CollectionName" -type 1 @NewLogEntry}
                $Collection = New-CMNDeviceCollection -SCCMConnectionInfo $SCCMConnectionInfo -comment "Created by script" -limitToCollectionID $LimitToCollectionID -name $CollectionName
                if($PSBoundParameters['LogEntries']){New-CMNLogEntry -entry "Adding rule" -type 1 @NewLogEntry}
                $rule = New-CMNDeviceCollectionQueryMemberRule -SCCMConnectionInfo $SCCMConnectionInfo -CollectionID $Collection.CollectionID -query $Query -ruleName $CollectionName -logFile $logfile
            }
		}
	}

	End
	{
		if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
	}
} #End Create-CMNProductCollections

$SCCMConnectionInfo = Get-CMNSCCMConnectionInfo -siteServer LOUAPPWTS1140
$Product = 'Microsoft SQL Server%'
$LimitToCollectionID = 'SMSDM003'
Create-CMNProductCollections -SCCMConnectionInfo $SCCMConnectionInfo -Product $Product -LimitToCollectionID $LimitToCollectionID -logFile 'C:\Temp\Create-CMNProductCollections.log' -logEntries

<#
SELECT DISTINCT productname0
FROM   v_gs_installed_software
WHERE  productname0 LIKE 'Microsoft SQL Server%'
ORDER  BY productname0

SELECT DISTINCT productname0,
                productversion0,
                Count(*) [Count]
FROM   v_gs_installed_software
WHERE  productname0 LIKE 'Microsoft SQL Server%Database Engine%'
GROUP  BY productname0,
          productversion0
HAVING Count(*) > 5
ORDER  BY productname0,
          productversion0
#>