<#

    $fileDir = 'D:\MoveIssue'
    $startDate = '1/10/2017 07:00 PM'
    $endDate = '1/11/2017 02:00 PM'
    $siteServer = 'LOUAPPWPS1658'2952664
    3184143

    WindowsUpdate.log - Time is in the first 24 charcters of the line. Looks to be tab seperated

    RCA.dbo.Logs
    LOG - Lots of characters
    DateTime
    Component
    Context
    type
    Thread
    File
    Source

    Table Creation Script
    IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_Entries_PK]') AND type = 'D')
    BEGIN
    ALTER TABLE [dbo].[Entries] DROP CONSTRAINT [DF_Entries_PK]
    END

    GO

    /****** Object:  Table [dbo].[Entries]    Script Date: 01/19/2017 15:34:54 ******/
    IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Entries]') AND type in (N'U'))
    DROP TABLE [dbo].[Entries]
    GO

    /****** Object:  Table [dbo].[Entries]    Script Date: 01/19/2017 15:34:54 ******/
    SET ANSI_NULLS ON
    GO

    SET QUOTED_IDENTIFIER ON
    GO

    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Entries]') AND type in (N'U'))
    BEGIN
    CREATE TABLE [dbo].[Entries](
	    [PK] [uniqueidentifier] NOT NULL,
	    [WKID] [nvarchar](25) NOT NULL,
	    [Entry] [nvarchar](3000) NULL,
	    [UTCDateTime] [datetime] NULL,
	    [Component] [nvarchar](50) NULL,
	    [Context] [nvarchar](50) NULL,
	    [Type] [int] NULL,
	    [Source] [nvarchar](50) NULL,
     CONSTRAINT [PK_Entries] PRIMARY KEY CLUSTERED 
    (
	    [PK] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
    ) ON [PRIMARY]
    END
    GO

    IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_Entries_PK]') AND type = 'D')
    BEGIN
    ALTER TABLE [dbo].[Entries] ADD  CONSTRAINT [DF_Entries_PK]  DEFAULT (newid()) FOR [PK]
    END

    GO

#>

[CmdletBinding(SupportsShouldProcess = $true)]
PARAM
(
    [Parameter(Mandatory = $true,
        HelpMessage = 'SiteServer')]
    [String]$siteServer,

    [Parameter(Mandatory = $true,
        HelpMessage = 'Database Server')]
    [String]$databaseServer,

    [Parameter(Mandatory = $true,
        HelpMessage = 'Database')]
    [String]$database,

    [Parameter(Mandatory = $true,
        HelpMessage = 'CollectionID')]
    [String]$collectionID,

    [Parameter(Mandatory = $true,
        HelpMessage = 'Start Date/Time')]
    [DateTime]$startDate,

    [Parameter(Mandatory = $true,
        HelpMessage = 'End Date/Time')]
    [DateTime]$endDate
)

$scriptStart = Get-Date
Write-Output "Starting - $scriptStart"
$sccmCon = Get-CMNSCCMConnectionInfo -SiteServer $siteServer
$sccmCS = Get-CMNConnectionString -DatabaseServer $sccmCon.SCCMDBServer -Database $sccmCon.SCCMDB
$dbCS = Get-CMNConnectionString -DatabaseServer $databaseServer -Database $database

$query = "SELECT SYS.netbios_name0
    FROM   v_r_system SYS
            JOIN v_fullcollectionmembership FCS
                ON SYS.resourceid = FCS.resourceid
                AND FCS.collectionid = '$collectionID'
    ORDER  BY SYS.netbios_name0"

$wkids = Get-CMNDatabaseData -connectionString $sccmCS -query $query -isSQLServer
for($p=0;$p -lt $wkids.Count;$p++)
{
    Write-Progress -Id 1 -Activity "Working $($wkids[$p].Netbios_Name0)" -Status "Working machine $($p + 1) of $($wkids.Count)" -PercentComplete ($p / $wkids.Count * 100)
    if(Test-Connection -ComputerName $wkids[$p].Netbios_Name0)
    {
        $logFiles = Get-ChildItem -Path "\\$($wkids[$p].Netbios_Name0)\c$\windows\ccm\logs\*" -Recurse
        $curLogFile = 1
        foreach($logfile in $logFiles)
        {
            if($logfile -match 'CAS' -or $logfile -match 'CcmExec' -or $logfile -match 'CIAgent' -or $logfile -match 'CIDownloader' -or $logfile -match 'CIStateStore' -or $logfile -match 'CIStore' -or $logfile -match 'ContentTransferManager' -or $logfile -match 'DataTransferService' -or $logfile -match 'execmgr' -or $logfile -match 'MaintenanceCoordinator' -or $logfile -match 'MtrMgr' -or $logfile -match 'RebootCoordinator' -or $logfile -match 'ScanAgent' -or $logfile -match 'Scheduler' -or $logfile -match 'ServiceWindowManager' -or $logfile -match 'SrcUpdateMgr' -or $logfile -match 'UpdatesDeployment' -or $logfile -match 'UpdatesHandler' -or $logfile -match 'UpdatesStore' -or $logfile -match 'UpdateTrustedSites' -or $logfile -match 'WUAHandler')
            {
                $x = 0
                $source = $logfile.Name
                Write-Progress -Id 2 -Activity "Working $source" -Status "Working log $curLogFile of $($logFiles.Count)" -PercentComplete ($curLogFile / $logFiles.count * 100) -ParentId 1
                #Write-Output $logfile.Name
                $curLogFile++
                $log = Get-Content -Path $logfile.FullName
                do
                {
                    Write-Progress -Activity "Reading Log" -Status "Working line $($x + 1) of $($log.Count)" -PercentComplete (($x + 1) / $log.Count * 100) -ParentId 2
                    #get complete line in $logLine
                    $logLine = ''
                    if($log[$x] -notmatch '^<!\[LOG\[.*\]LOG\]!>') #Not a complete line.
                    {
                        $y = $x #record $x to make sure we don't add too many lines
                        do
                        {
                            $logLine = "$logLine$($log[$x])"
                            $x++
                        }while($log[$x - 1] -notmatch '\]LOG\]!>.*date="([\d-]*).*' -and $x -lt $log.Count)
                    }
                    else
                    {
                        $logLine = $log[$x]
                        $x++
                    }
                    $entry = ($logLine -replace '^<!\[LOG\[(.*)\]LOG\]!>.*','$1')
                    if($entry.Length -gt 0){$entry = ConvertTo-CMNSingleQuotedString -Text $entry}
                    #$entry = $entry -replace '"','\"'
                    $date = ($logline -replace '^<!\[LOG\[.*\]LOG\]!>.*date="([\d-]*).*','$1') + ' ' + ($logline -replace '^<!\[LOG\[.*\]LOG\]!>.*time="([\d:]*).*','$1')
                    $offset = $logline -replace '^<!\[LOG\[.*\]LOG\]!>.*time="[\d\.:]*([+-]\d*).*','$1'
                    if($offset.Length -eq 4){$utcDate = (Get-Date $date).AddMinutes($offset)}
                    else{$utcDate = $date}
                    $component = ($logLine -replace '^<!\[LOG\[.*\]LOG\]!>.*component="(\w*)".*','$1')
                    $context = $logLine -replace '^<!\[LOG\[.*\]LOG\]!>.*context="(\w*)".*','$1'
                    $type = $logLine -replace '^<!\[LOG\[.*\]LOG\]!>.*type="(\d)".*','$1'
                    $query = "insert Entries (WKID, Entry, UTCDateTime, Component, Context, Type, Source)
                    values (N'$($wkids[$p].Netbios_Name0)',N'$entry', '$utcDate', N'$component',N'$context','$type',N'$source')"
                    if($utcDate -ge $startDate -and $utcDate -le $endDate)
                    {
                        Try
                        {
                            Invoke-CMNDatabaseQuery -query $query -connectionString $dbCS -isSQLServer
                        }
                        catch
                        {
                            Write-Output $query
                        }
                    }
                } while($x -lt $log.Count)
                Write-Progress -Activity "Reading Log" -Completed
            }
            else
            {
                $curLogFile++
            }
        }
        Write-Progress -Activity "LOG - $source" -Completed
    }
}
Write-Progress -Activity "Gathering Logs between $startDate and $endDate" -Completed
$scriptEnd = Get-Date
Write-Output "Started $scriptStart, ended $scriptEnd"
