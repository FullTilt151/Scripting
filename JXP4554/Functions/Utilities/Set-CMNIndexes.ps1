Function Set-CMNIndexes
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
		FileName:    Set-CMNIndexes.ps1
		Author:      James Parris
		Contact:     Jim@ConfigMan-Notes.com
		Created:     2016-12-21
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
            HelpMessage = 'Script File Name')]
        [String]$ScriptFile,

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
			Component = 'Set-CMNIndexes';
			maxLogSize = $maxLogSize;
			maxHistory = $maxHistory;
		}
		#Build splats for WMIQueries
        $WMIQueryParameters = $($SCCMConnectionInfo.WMIQueryParameters)
		$SCCMDBConStr = Get-CMNConnectionString -DatabaseServer $SCCMConnectionInfo.SCCMDBServer -Database $SCCMConnectionInfo.SCCMDB
		if($PSBoundParameters['logEntries'])
		{
			New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "ScriptFile = $ScriptFile" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "SCCMConnectionInfo = $SCCMConnectionInfo" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "WMIQueryParameters = $WMIQueryParameters" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "SCCMDBConStr = $SCCMDBConStr" -type 1 @NewLogEntry
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
		$Query = "DECLARE @runtime DATETIME
DECLARE @cpu_time_start     BIGINT,
        @cpu_time           BIGINT,
        @elapsed_time_start BIGINT,
        @rowcount           BIGINT
DECLARE @queryduration            INT,
        @qrydurationwarnthreshold INT
DECLARE @querystarttime DATETIME

SET @runtime = Getdate()
SET @qrydurationwarnthreshold = 5000

SELECT CONVERT (VARCHAR(30), @runtime, 126)                                                                               AS runtime,
       mig.index_group_handle,
       mid.index_handle,
       CONVERT (DECIMAL (28, 1), migs.avg_total_user_cost * migs.avg_user_impact * ( migs.user_seeks + migs.user_scans )) AS improvement_measure,
       'CREATE INDEX CMN_missing_index_'
       + CONVERT (VARCHAR, mig.index_group_handle)
       + '_' + CONVERT (VARCHAR, mid.index_handle)
       + ' ON ' + mid.statement + ' ('
       + Isnull (mid.equality_columns, '') + CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE
       '' END
       + Isnull (mid.inequality_columns, '') + ')'
       + Isnull (' INCLUDE (' + mid.included_columns + ')', '')                                                           AS
       create_index_statement,
       mid.statement                                                                                                      [Index Name 1],
       Isnull (mid.equality_columns, '')                                                                                  [Index Name 2],
       CASE
         WHEN mid.equality_columns IS NOT NULL
              AND mid.inequality_columns IS NOT NULL THEN ','
         ELSE ''
       END                                                                                                                [Index Name 3],
       IsNull (mid.included_columns, '')                                                                                  [Index Name 4],
       mid.statement                                                                                                      [On 1],
       Isnull (mid.equality_columns, '')                                                                                  [On 2],
       CASE
         WHEN mid.equality_columns IS NOT NULL
              AND mid.inequality_columns IS NOT NULL THEN ','
         ELSE ''
       END                                                                                                                [On 3],
       Isnull (mid.inequality_columns, '')                                                                                [On 4],
       Isnull (' INCLUDE (' + mid.included_columns + ')', '')                                                             [On 5],
       migs.*,
       mid.database_id,
       mid.[object_id]
FROM   sys.dm_db_missing_index_groups mig
       INNER JOIN sys.dm_db_missing_index_group_stats migs
               ON migs.group_handle = mig.index_group_handle
       INNER JOIN sys.dm_db_missing_index_details mid
               ON mig.index_handle = mid.index_handle
WHERE  CONVERT (DECIMAL (28, 1), migs.avg_total_user_cost * migs.avg_user_impact * ( migs.user_seeks + migs.user_scans )) > 10
ORDER  BY migs.avg_total_user_cost * migs.avg_user_impact * ( migs.user_seeks + migs.user_scans ) DESC"
		$Results = (Get-CMNDatabaseData -connectionString $SCCMDBConStr -query $Query -isSQLServer)
		for($x = 0 ; $x -lt $Results.Count; $x++)
        {
            if($PSBoundParameters['LogEntries'])
            {
                #New-CMNLogEntry -entry ($Results[$x] | ConvertTo-Csv) -type 1 @NewLogEntry
                New-CMNLogEntry -entry "Adding $($Results[$x].create_index_statement) to $ScriptFile" -type 1 @NewLogEntry
            }
            $Results[$x].create_index_statement | Out-File -FilePath $ScriptFile -Encoding ascii -Append
        }
	}

	End
	{
		if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
	}
} #End Set-CMNIndexes

$SCCMConnectionInfo = Get-CMNSCCMConnectionInfo -siteServer LOUAPPWQS1151
$ScriptFile = "e:\CreateIndexes_$($SCCMConnectionInfo.SiteCode).sql"
Set-CMNIndexes -SCCMConnectionInfo $SCCMConnectionInfo -logFile 'C:\Temp\Set-CMNIndexes.log' -logEntries -ScriptFile $ScriptFile