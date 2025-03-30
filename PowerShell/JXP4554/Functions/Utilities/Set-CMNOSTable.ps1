Function Set-CMNOSTable {
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
            Component     = 'FunctionName';
            logEntries    = $logEntries;
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        $SQLConn = Get-CMNConnectionString -DatabaseServer $SCCMConnectionInfo.SCCMDBServer -Database $SCCMConnectionInfo.SCCMDB
    }

    process {
        $query = "IF EXISTS (SELECT *
           FROM   sys.objects
           WHERE  object_id = Object_id(N'[dbo].[Humana_OS_Caption_DisplayName]'
                              )
                  AND type IN ( N'U' ))
  DROP TABLE [dbo].[humana_os_caption_displayname]" 

        Invoke-CMNDatabaseQuery -connectionString $SQLConn -query $query -isSQLServer

        $query = "IF NOT EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id =
                      Object_id(N'[dbo].[Humana_OS_Caption_DisplayName]')
                      AND type IN ( N'U' ))
  BEGIN
      CREATE TABLE [dbo].[Humana_OS_Caption_DisplayName]
        (
           [Caption]     [NVARCHAR](100) NOT NULL,
           [DisplayName] [NVARCHAR](500) NOT NULL,
           PRIMARY KEY CLUSTERED ( [caption] ASC )WITH (pad_index = OFF,
           statistics_norecompute = OFF, ignore_dup_key = OFF, allow_row_locks =
           on,
           allow_page_locks = on, FILLFACTOR = 90) ON [PRIMARY]
        )
      ON [PRIMARY]
  END"

        Invoke-CMNDatabaseQuery -connectionString $SQLConn -query $query -isSQLServer

        $query = 'SELECT DISTINCT SYS.operating_system_name_and0 [Caption],
                OS.caption0                    [DisplayName]
FROM   v_r_system SYS
       JOIN v_gs_operating_system OS
         ON SYS.resourceid = OS.resourceid
WHERE  SYS.operating_system_name_and0 IS NOT NULL
       AND SYS.operating_system_name_and0 != ''
       AND OS.caption0 IS NOT NULL
       AND OS.caption0 != ''
ORDER  BY caption'
        $results = Get-CMNDatabaseData -connectionString $SQLConn -query $query -isSQLServer
        if ($results.Count -gt 0) {
            for ($x = 0; $x -lt $results.Count; $x++) {
                if ($results[$x].DisplayName.GetType().Name -ne 'DBNull' -and $results[$x].DisplayName -ne '') {
                    $Caption = $results[$x].Caption
                    $DisplayName = $results[$x].DisplayName
                    while ($results[$x].Caption -eq $results[$x + 1].Caption -and $x -lt ($results.Count - 1) -and $results[$x + 1].DisplayName -ne '') {
                        $x++
                        if ($results[$x].DisplayName.GetType().Name -ne 'DBNull' -and $results[$x].DisplayName -ne '') {$DisplayName += "/$($results[$x].DisplayName)"}
                    }
                    $query = "INSERT humana_os_caption_displayname
                VALUES('$Caption', 
               '$DisplayName') "
                    Invoke-CMNDatabaseQuery -connectionString $SQLConn -query $query -isSQLServer
                }
            }
        }
        Else {
            $query = "INSERT humana_os_caption_displayname
    VALUES('$($results.Caption)',
           '$($results.DisplayName)')"
            Invoke-CMNDatabaseQuery -connectionString $SQLConn -query $query -isSQLServer
        }
    }

    end {}
} # End Set-CMNOSTable