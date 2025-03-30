#Requires -Version 5
#Requires -Module SqlServer
Function Reset-CmnWsusContentDir {
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

    begin {
        # Assign a value to logEntries
        if ($PSBoundParameters['logEntries']) {$logEntries = $true}
        else {$logEntries = $false}

        #Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'Reset-CmnWsusContentDir';
            logEntries    = $logEntries;
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
    }

    process {
        New-CMNLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry

        New-CMNLogEntry -entry 'Getting content path' -type 1 @NewLogEntry
        $contentDir = "$((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Update Services\Server\Setup').ContentDir)\WsusContent\"
        if (Test-Path -Path $contentDir) {
            try {
                New-CMNLogEntry -entry 'Stopping WsusService' -type 1 @NewLogEntry
                Stop-Service -Name WsusService
                New-CMNLogEntry -entry "Deleting $contentDir" -type 1 @NewLogEntry
                Remove-Item -Path $contentDir -Filter '*.*' -Recurse -Force
                New-CMNLogEntry -entry 'Starting WsusService' -type 1 @NewLogEntry
                Start-Service -Name WsusService
            }
            catch {
                New-CMNLogEntry -entry "Content reset failed" -type 3 @NewLogEntry
            }
        }
        if (!(Test-Path -Path $contentDir)) {
            New-CMNLogEntry -entry "Recreating $contentDir" -type 1 @NewLogEntry
            New-Item -Path $contentDir -ItemType Directory
        }
    }

    End {
        New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
    }
} #End Reset-CmnWsusContentDir

Function Reset-CmnWsus {
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

    begin {
        # Assign a value to logEntries
        if ($PSBoundParameters['logEntries']) {$logEntries = $true}
        else {$logEntries = $false}

        #Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'Reset-CmnWsus';
            logEntries    = $logEntries;
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }
        
        New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
    }

    process {
        New-CMNLogEntry -entry 'Performing reset on WSUS server' -type 1 @NewLogEntry
        $cmd = "$((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Update Services\Server\Setup').TargetDir)Tools\WsusUtil.exe"
        $params = [Array]"reset"
        New-CMNLogEntry -entry "Executing $cmd $params" -type 1 @NewLogEntry
        & $cmd $params
    }

    end {
        New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
    }
} #End Reset-CmnWsus

Function Optimize-CmnWsusIndex {
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

    begin {
        # Assign a value to logEntries
        if ($PSBoundParameters['logEntries']) {$logEntries = $true}
        else {$logEntries = $false}

        #Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'Optimize-CmnWsusIndex';
            logEntries    = $logEntries;
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }
        
        New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
    }

    process {
        New-CMNLogEntry -entry 'Determining database type' -type 1 @NewLogEntry
        $database = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Update Services\Server\Setup').SQLServerName
        if ($database -match '#WID') {
            New-CMNLogEntry -entry "Starting defrag on WID Database" -type 1 @NewLogEntry
            Invoke-Sqlcmd -ServerInstance "np:\\.\pipe\MICROSOFT##WID\tsql\query" -InputFile '.\WSUS Database Defragmentation.sql'
        }
        else {
            New-CMNLogEntry -entry "Starting defrag on SQL Database" -type 1 @NewLogEntry
            Invoke-Sqlcmd -ServerInstance $database -InputFile '.\WSUS Database Defragmentation.sql'
        }
    }
    end {
        New-CMNLogEntry -entry 'Finished' -type 1 @NewLogEntry
    }
} #End Optimize-CmnWsusIndex 

Function Optimize-CmnWSUSCleanup {
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

    begin {
        # Assign a value to logEntries
        if ($PSBoundParameters['logEntries']) {$logEntries = $true}
        else {$logEntries = $false}

        #Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'Optimize-CmnWSUSCleanup';
            logEntries    = $logEntries;
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }
        
        New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
    }

    process {
        $isOptomized = $false
        $retries = 0
        if ((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Update Services\Server\Setup' -Name UsingSSL).UsingSSL -eq 1) {$useSSL = $true}
        else {$useSSL = $false}
        $port = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Update Services\Server\Setup' -Name PortNumber).PortNumber
        $myFQDN = (Get-WmiObject win32_computersystem).DNSHostName + "." + (Get-WmiObject win32_computersystem).Domain
        New-CMNLogEntry -entry "Starting WSUS Cleanup section" -type 1 -logFile $logFile -component 'Optimize-WSUS/Cleanup'
        [reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | out-null 
        New-CMNLogEntry -entry "Loaded assembly, connecting to $($myFQDN):$port - SSL $useSSL" -type 1 -logFile $logFile -component 'Optimize-WSUS/Cleanup'
        $wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer($myFQDN, $useSSL, $port); 
        New-CMNLogEntry -entry "Connected to WSUS" -type 1 -logFile $logFile -component 'Optimze-WSUS/Cleanup'
        $cleanupScope = new-object Microsoft.UpdateServices.Administration.CleanupScope; 
        New-CMNLogEntry -entry "Setting scope options" -type 1 -logFile $logFile -component 'Optimize-WSUS/Cleanup'
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
    end {
        New-CMNLogEntry -entry 'Finished' -type 1 @NewLogEntry
    }
} #End Optimize-CmnWSUSCleanup

if ($PSBoundParameters['doDeleteDeclined']) {
    $database = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Update Services\Server\Setup').SQLServerName
    if ($database -match '#WID') {
        New-CMNLogEntry -entry "Starting delete decliend updates on WID Database" -type 1 @NewLogEntry
        & .\SQLCMD.EXE -S "np:\\.\pipe\MICROSOFT##WID\tsql\query" -E -i "Delete-DeclinedUpdates.sql" -o $sqlLog
    }
    else {
        New-CMNLogEntry -entry "Starting delete decliend updates on SQL Database" -type 1 @NewLogEntry
        & .\SQLCMD.EXE -S $database -E -i "Delete-DeclinedUpdates.sql" -o $sqlLog
    }
    New-CMNLogEntry -entry 'Finished' -type 1 @NewLogEntry
}

If ($PSBoundParameters['doIndex'] -and $PSBoundParameters['doWsusCleanup']) {
    $database = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Update Services\Server\Setup').SQLServerName
    if ($database -match '#WID') {
        New-CMNLogEntry -entry "Starting second defrag on WID Database" -type 1 @NewLogEntry
        & .\SQLCMD.EXE -S "np:\\.\pipe\MICROSOFT##WID\tsql\query" -E -i "WSUS Database Defragmentation.sql" -o $sqlLog
    }
    else {
        New-CMNLogEntry -entry "Starting second defrag on SQL Database" -type 1 @NewLogEntry
        & .\SQLCMD.EXE -S $database -E -i "WSUS Database Defragmentation.sql" -o $sqlLog
    }
    New-CMNLogEntry -entry 'Finished' -type 1 @NewLogEntry
}
New-CMNLogEntry -entry "Finished script" -type 1 -logFile $logFile -component 'Optimize-WSUS'
