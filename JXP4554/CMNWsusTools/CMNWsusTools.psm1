Function Optimize-CMNWsus {
    [CmdletBinding(ConfirmImpact = 'Low')]
    PARAM(
        [Parameter(Mandatory = $false, HelpMessage = 'Do Index?')]
        [Switch]$doIndex,

        [Parameter(Mandatory = $false, HelpMessage = 'Do WSUSCleanup?')]
        [Switch]$doWsusCleanup,

        [Parameter(Mandatory = $false, HelpMessage = 'Run the WsusUtil reset after?')]
        [Switch]$doReset,

        [Parameter(Mandatory = $false, HelpMessage = 'Clean Content Dir? This will stop the WSUSServer service, delete the contents of WSUS\WsusContent and restart the service')]
        [Switch]$doContentReset,

        [Parameter(Mandatory = $false, HelpMessage = 'Delete declined updates - This can take a while')]
        [Switch]$doDeleteDeclined,

        [Parameter(Mandatory = $false, HelpMessage = 'Max retryies on WSUS Optimizaiton, default is 10')]
        [int]$maxRetries = 10,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int]$maxLogHistory = 5
    )

    New-CMNLogEntry -entry "Starting script" -type 1 -logFile $logFile -component 'Optimize-WSUS'

    if ($PSBoundParameters['doContentReset']) {
        New-CMNLogEntry -entry 'Getting content path' -type 1 -logFile $logFile -component 'Optimize-WSUS/Reset Content'
        $contentDir = "$((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Update Services\Server\Setup').ContentDir)\WsusContent\"
        if (Test-Path -Path $contentDir) {
            try {
                New-CMNLogEntry -entry 'Stopping WsusService' -type 1 -logFile $logFile -component 'Optimize-WSUS/Reset Content'
                Stop-Service -Name WsusService
                New-CMNLogEntry -entry "Deleting $contentDir" -type 1 -logFile $logFile -component 'Optimize-WSUS/Reset Content'
                Get-ChildItem -Path $contentDir -Recurse | Remove-Item -Force
                New-CMNLogEntry -entry 'Starting WsusService' -type 1 -logFile $logFile -component 'Optimize-WSUS/Reset Content'
                Start-Service -Name WsusService
            }
            catch {
                New-CMNLogEntry -entry "Content reset failed" -type 3 -logFile $logFile -component 'Optimize-WSUS/Reset Content'
            }
        }
        if (!(Test-Path -Path $contentDir)) {
            New-CMNLogEntry -entry "Recreating $contentDir" -type 1 -logFile $logFile -component 'Optimize-WSUS/Reset Content'
            New-Item -Path $contentDir -ItemType Directory
        }
    }

    if ($PSBoundParameters['doReset']) {
        New-CMNLogEntry -entry 'Performing reset on WSUS server' -type 1 -logFile $logFile -component 'Optimize-WSUS/Reset'
        $cmd = "$((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Update Services\Server\Setup').TargetDir)Tools\WsusUtil.exe"
        $params = [Array]"reset"
        & $cmd $params
    }

    If ($PSBoundParameters['doIndex']) {
        $database = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Update Services\Server\Setup').SQLServerName
        if ($database -match '#WID') {
            New-CMNLogEntry -entry "Starting defrag on WID Database" -type 1 -logFile $logFile -component 'Optimze-WSUS/Index'
            & .\SQLCMD.EXE -S "np:\\.\pipe\MICROSOFT##WID\tsql\query" -E -i "WSUS Database Defragmentation.sql" -o $sqlLog
        }
        else {
            New-CMNLogEntry -entry "Starting defrag on SQL Database" -type 1 -logFile $logFile -component 'Optimze-WSUS/Index'
            & .\SQLCMD.EXE -S $database -E -i "WSUS Database Defragmentation.sql" -o $sqlLog
        }
        New-CMNLogEntry -entry 'Finished' -type 1 -logFile $logFile -component 'Optimze-WSUS/Index'
    }

    if ($PSBoundParameters['doWsusCleanup']) {
        $isOptomized = $false
        $retries = 0
        if ((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Update Services\Server\Setup' -Name UsingSSL).UsingSSL -eq 1) {$useSSL = $true}
        else {$useSSL = $false}
        $port = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Update Services\Server\Setup' -Name PortNumber).PortNumber
        $myFQDN = (Get-WmiObject win32_computersystem).DNSHostName + "." + (Get-WmiObject win32_computersystem).Domain
        New-CMNLogEntry -entry "Starting WSUS Cleanup section" -type 1 -logFile $logFile -component 'Optimze-WSUS/Cleanup'
        [reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | out-null 
        New-CMNLogEntry -entry "Loaded assembly, connecting to $($myFQDN):$port - SSL $useSSL" -type 1 -logFile $logFile -component 'Optimze-WSUS/Cleanup'
        $wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer($myFQDN, $useSSL, $port); 
        New-CMNLogEntry -entry "Connected to WSUS" -type 1 -logFile $logFile -component 'Optimze-WSUS/Cleanup'
        $cleanupScope = new-object Microsoft.UpdateServices.Administration.CleanupScope; 
        New-CMNLogEntry -entry "Setting scope options" -type 1 -logFile $logFile -component 'Optimze-WSUS/Cleanup'
        $cleanupScope.DeclineSupersededUpdates = $true
        $cleanupScope.DeclineExpiredUpdates = $true
        $cleanupScope.CleanupObsoleteUpdates = $true
        $cleanupScope.CompressUpdates = $true
        $cleanupScope.CleanupObsoleteComputers = $true
        $cleanupScope.CleanupUnneededContentFiles = $true
        do {
            try {
                New-CMNLogEntry -entry "Starting WSUS Cleanup" -type 1 -logFile $logFile -component 'Optimze-WSUS/Cleanup'
                $cleanupManager = $wsus.GetCleanupManager()
                $results = $cleanupManager.PerformCleanup($cleanupScope)
                New-CMNLogEntry -entry "DiskSpaceFreed=$($results.DiskSpaceFreed)" -type 1 -logFile $logFile -component 'Optimze-WSUS/Cleanup'
                New-CMNLogEntry -entry "ExpiredUpdatesDeclined=$($results.ExpiredUpdatesDeclined)" -type 1 -logFile $logFile -component 'Optimze-WSUS/Cleanup'
                New-CMNLogEntry -entry "ObsoleteComputersDeleted=$($results.ObsoleteComputersDeleted)" -type 1 -logFile $logFile -component 'Optimze-WSUS/Cleanup'
                New-CMNLogEntry -entry "ObsoleteUpdatesDeleted=$($results.ObsoleteUpdatesDeleted)" -type 1 -logFile $logFile -component 'Optimze-WSUS/Cleanup'
                New-CMNLogEntry -entry "SupersededUpdatesDeclined=$($results.SuperSededUpdatesDeclined)" -type 1 -logFile $logFile -component 'Optimze-WSUS/Cleanup'
                New-CMNLogEntry -entry "UpdatesCompressed=$($results.UpdatesCompressed)" -type 1 -logFile $logFile -component 'Optimze-WSUS/Cleanup'
                $isOptomized = $true
            }
            catch {
                New-CMNLogEntry -entry "Optimization failed, retrying" -type 1 -logFile $logFile -component 'Optimze-WSUS/Cleanup'
                $isOptomized = $false
                $retries++
            }
        } until ($isOptomized -or $retries -ge $maxRetries)
        if ($retries -ge $maxRetries) {New-CMNLogEntry -entry "Optimization Failed" -type 3 -logFile $logFile -component 'Optimze-WSUS/Cleanup'}
        else {New-CMNLogEntry -entry "Optimization Complete" -type 1 -logFile $logFile -component 'Optimze-WSUS/Cleanup'}
    }

    if ($PSBoundParameters['doDeleteDeclined']) {
        $database = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Update Services\Server\Setup').SQLServerName
        if ($database -match '#WID') {
            New-CMNLogEntry -entry "Starting delete decliend updates on WID Database" -type 1 -logFile $logFile -component 'Optimze-WSUS/Index'
            & .\SQLCMD.EXE -S "np:\\.\pipe\MICROSOFT##WID\tsql\query" -E -i "Delete-DeclinedUpdates.sql" -o $sqlLog
        }
        else {
            New-CMNLogEntry -entry "Starting delete decliend updates on SQL Database" -type 1 -logFile $logFile -component 'Optimze-WSUS/Index'
            & .\SQLCMD.EXE -S $database -E -i "Delete-DeclinedUpdates.sql" -o $sqlLog
        }
        New-CMNLogEntry -entry 'Finished' -type 1 -logFile $logFile -component 'Optimze-WSUS/Index'
    }

    If ($PSBoundParameters['doIndex'] -and $PSBoundParameters['doWsusCleanup']) {
        $database = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Update Services\Server\Setup').SQLServerName
        if ($database -match '#WID') {
            New-CMNLogEntry -entry "Starting second defrag on WID Database" -type 1 -logFile $logFile -component 'Optimze-WSUS/Index'
            & .\SQLCMD.EXE -S "np:\\.\pipe\MICROSOFT##WID\tsql\query" -E -i "WSUS Database Defragmentation.sql" -o $sqlLog
        }
        else {
            New-CMNLogEntry -entry "Starting second defrag on SQL Database" -type 1 -logFile $logFile -component 'Optimze-WSUS/Index'
            & .\SQLCMD.EXE -S $database -E -i "WSUS Database Defragmentation.sql" -o $sqlLog
        }
        New-CMNLogEntry -entry 'Finished' -type 1 -logFile $logFile -component 'Optimze-WSUS/Index'
    }
    New-CMNLogEntry -entry "Finished script" -type 1 -logFile $logFile -component 'Optimize-WSUS'
    <# 
Info to delete declined updates. In progress
$connectionString ="Provider={ODBC Driver 13 for SQL Server};server=np:\\.\pipe\MICROSOFT##WID\tsql\query;Description=WID;trusted_connection=Yes;"

$query = "DECLARE @var1 nvarchar(255) 
DECLARE @msg NVARCHAR(100) 

select UpdateId
into #results
from PUBLIC_VIEWS.vUpdate
where IsDeclined = 1

DECLARE wc CURSOR FOR 
  SELECT UpdateId 
  FROM   #results 

OPEN wc 

FETCH next FROM wc INTO @var1 

WHILE ( @@FETCH_STATUS > -1 ) 
  BEGIN 
      SET @msg = 'Deleting ' + CONVERT(VARCHAR(100), @var1) 

      RAISERROR(@msg,0,1) WITH nowait 

      EXEC spDeleteUpdateByUpdateID
        @UpdateID=@var1 

      FETCH next FROM wc INTO @var1 
  END 

CLOSE wc 

DEALLOCATE wc 

DROP TABLE #results   

select UpdateId
from PUBLIC_VIEWS.vUpdate
where IsDeclined = 1"
 #>
}