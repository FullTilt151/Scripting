<#
https://blogs.technet.microsoft.com/configurationmgr/2016/01/26/the-complete-guide-to-microsoft-wsus-and-configuration-manager-sup-maintenance/

WSUS.Title = SMS_SoftwareUpdate.LocalizedDisplayName

Steps to maintenance
    Verify Parameters
    Check to see if we are on a site server or doing maintenance on a stand alone WSUS
    Try UpdateServicesModule?
    Connect to upstream WSUS and index database
    If firstrun, call procedure directly to delete obsolete updates
    Confirm action parameter was given (FirstRun, Decline Superseded, DeclineByTitle, RunCleanupWizard, CleanSUGs, combine Sugs, UpdateADRDeploymentPackages, CleanSources, and MaxUpdateRunTime)
    Prevent ConfigMGR actions on StandAlone
    Build list of updates to decline. We want to end up with a hashtable that has updates to be declined. Start by checking for updates to decline, afterwards, cycle through and remove anything that we want to keep. Then decline the list.
        Connect to WSUS and get list of current updates (all)
        Cycle through and decline (if option is selected):
            Superseded updates
            Last Level Only
            Date released (aged)
            Name matches
            Run decline modules
        Cycle through declined updates and "unapprove":
            Currently deployed updates
            Exception Bulletins
            Exception Articles
        We now should have comprehensive list of updates to decline, and a list of any to approve (to correct whatever was decliend by mistake)
        Cycle through WSUS updates and:
            Decline any matches to Decline hashtable
            Approve any matches to Approve Hashtable.
    Run cleanup
    index WSUS database
    Resync Updates
    Clean SUGs
    Combine SUGs
    CleanSource Packages
    CleanADRPackages
    SMS_SUPSyncStats - LastSyncState 6704 = Syncing??

    [String[]]$exceptionBulletinIDs = ('08-052', '09-062', '10-036', '10-087', '11-022', '11-023', '11-025', '11-036', '11-045', '11-053', '11-072', '11-073', '11-090', '12-013', '12-016', '12-020', '12-036', '12-039', '12-043', '12-045', '12-046', '12-057', '12-059', '12-060', '12-066', '12-074', '13-002', '13-004', '13-009', '13-022', '13-023', '13-025', '13-027', '13-035', '13-041', '13-044', '13-052', '13-054', '13-068', '13-074', '13-082', '13-085', '13-087', '13-090', '13-094', '13-095', '13-097', '13-098', '13-099', '13-104', '13-105', '13-106', '14-001', '14-007', '14-009', '14-010', '14-011', '14-012', '14-014', '14-018', '14-021', '14-023', '14-024', '14-025', '14-026', '14-031', '14-036', '14-037', '14-044', '14-046', '14-051', '14-052', '14-053', '14-056', '14-065', '14-072', '14-075', '14-080', '14-081', '14-083', '15-004', '15-009', '15-011', '15-012', '15-013', '15-022', '15-028', '15-032', '15-033', '15-034', '15-041', '15-044', '15-045', '15-046', '15-048', '15-056', '15-065', '15-067', '15-069', '15-076', '15-079', '15-080', '15-081', '15-093', '15-094', '15-098', '15-106', '15-109', '15-112', '15-116', '15-118', '15-124', '15-128', '15-129', '16-001', '16-004', '16-006', '16-017', '16-029', '16-035', '16-039', '16-041', '16-051', '16-054', '16-061', '16-063', '16-065', '16-070', '16-075', '16-079', '16-084', '16-087', '16-090', '16-095', '16-104', '16-106', '16-107', '16-109', '16-118', '16-120', '16-132', '16-133', '16-136', '16-139', '16-142', '16-144', '16-146', '16-154', '16-155', '17-001', '17-003', '17-004', '17-005', '17-006', '17-013', '17-014', '17-023'),

    [Parameter(Mandatory = $false, HelpMessage = 'Exception article ID''s, these will always be set to not approved.')]
    [String[]]$exceptionArticleIDs = ('371021', '948108', '948109', '948111', '948113', '971089', '971089', '971090', '971091', '971092', '973544', '973544', '973551', '973551', '973552', '973552', '973830', '982158', '982312', '2264072', '2264107', '2289158', '2460011', '2464594', '2465373', '2465373', '2467173', '2503665', '2509488', '2523021', '2532531', '2535818', '2538218', '2538241', '2538242', '2538243', '2542054', '2548826', '2553070', '2553428', '2565057', '2565063', '2570947', '2579115', '2584063', '2584066', '2584146', '2597974', '2598243', '2598244', '2618451', '2619339', '2621440', '2633873', '2654428', '2667402', '2685939', '2687417', '2687423', '2687499', '2687505', '2687510', '2698023', '2698365', '2721691', '2726929', '2742597', '2750841', '2760406', '2760600', '2794707', '2807986', '2810048', '2810062', '2810068', '2810073', '2814124', '2817330', '2817478', '2825644', '2832414', '2833946', '2837597', '2837599', '2837610', '2837618', '2847559', '2862152', '2862966', '2862973', '2863240', '2868626', '2871997', '2878230', '2878284', '2890788', '2892074', '2893294', '2898850', '2898857', '2898868', '2900986', '2901125', '2905616', '2909210', '2909210', '2912390', '2928120', '2931358', '2931366', '2932677', '2937610', '2949927', '2956073', '2956078', '2957189', '2960358', '2961858', '2963983', '2965161', '2965242', '2965310', '2973112', '2975808', '2977326', '2978128', '2986475', '2999412', '3000483', '3005607', '3023224', '3032655', '3033929', '3037581', '3042553', '3048070', '3054834', '3054848', '3054978', '3054984', '3056819', '3063858', '3067505', '3067904', '3070738', '3072633', '3076949', '3080333', '3080446', '3097996', '3098781', '3099862', '3101520', '3101526', '3101544', '3106614', '3114402', '3114511', '3114518', '3114862', '3114883', '3115467', '3115487', '3118304', '3118378', '3123479', '3124280', '3126036', '3126446', '3127894', '3127945', '3135983', '3135988', '3135996', '3136000', '3139940', '3141537', '3142033', '3142042', '3143693', '3146706', '3149090', '3151058', '3151097', '3153704', '3154070', '3160005', '3161561', '3163245', '3163251', '3164025', '3164033', '3164035', '3168965', '3170106', '3170455', '3172531', '3174644', '3175443', '3178687', '3178688', '3178702', '3178729', '3182373', '3185319', '3185330', '3185911', '3188730', '3188740', '3191828', '3191837', '3191843', '3191844', '3191847', '3191848', '3191858', '3191863', '3191865', '3191881', '3191882', '3191907', '3191932', '3191937', '3191938', '3191939', '3191943', '3191944', '3191945', '3193713', '3194716', '3194725', '3197868', '3203382', '3203383', '3203386', '3203392', '3203393', '3203436', '3203438', '3203460', '3203461', '3203464', '3203467', '3203474', '3203477', '3205383', '3205402', '3206632', '3207752', '3209498', '3212646', '3213537', '3213545', '3213555', '3213624', '3213630', '3213640', '3213647', '3213648', '3213986', '3214628', '4010250', '4011038', '4011040', '4011050', '4011052', '4011055', '4011061', '4011062', '4011063', '4011064', '4011078', '4011089', '4011090', '4011091', '4011095', '4011103', '4011107', '4011108', '4011110', '4011159', '4011162', '4011178', '4011179', '4011196', '4011197', '4011199', '4011201', '4011205', '4011213', '4011220', '4011222', '4011232', '4011233', '4011234', '4011242', '4011250', '4011264', '4011265', '4011266', '4011270', '4011273', '4011277', '4011575', '4011575', '4011590', '4011602', '4011604', '4011605', '4011607', '4011608', '4011611', '4011614', '4011618', '4011626', '4011627', '4011627', '4011632', '4011636', '4011637', '4011639', '4011643', '4011651', '4011657', '4011659', '4011660', '4011665', '4011674', '4011675', '4011682', '4011686', '4011690', '4011695', '4011697', '4011707', '4011711', '4011714', '4011720', '4011721', '4011727', '4011730', '4012204', '4012215', '4012216', '4013429', '4013867', '4014329', '4014661', '4014981', '4015217', '4015549', '4016871', '4017094', '4018271', '4018291', '4018381', '4018483', '4018588', '4019088', '4019089', '4019090', '4019092', '4019093', '4019112', '4019115', '4019263', '4019264', '4019472', '4019473', '4019474', '4020821', '4021558', '4022715', '4022719', '4022730', '4025252', '4025339', '4025341', '4025376', '4034658', '4034662', '4034664', '4034674', '4034733', '4036586', '4036996', '4038777', '4038782', '4038783', '4038788', '4038792', '4038806', '4040685', '4041083', '4041676', '4041681', '4041689', '4041691', '4041693', '4047206', '4048951', '4048952', '4048953', '4048954', '4048957', '4048958', '4049179', '4052725', '4052978', '4053440', '4053577', '4053578', '4053579', '4053580', '4054517', '4054518', '4054519', '4055266', '4055532', '4056568', '4056887', '4056888', '4056890', '4056891', '4056892', '4056893', '4056894', '4056895', '4073537', '4074588', '4074590', '4074591', '4074592', '4074594', '4074595', '4074598', '4074736', '4078130', '4088776', '4088779', '4088782', '4088785', '4088787', '4088875', '4089187', '4096040', '4284833', '4284860')
#>

[CmdletBinding(ConfirmImpact = 'Low')]
Param(
    [Parameter(Mandatory = $false)]
    [String[]]$siteServers,

    [Parameter(Mandatory = $false)]
    [string] $updateServer = $env:COMPUTERNAME,
	
    [Parameter(Mandatory = $false)]
    [Switch] $useSSL,
	
    [Parameter(Mandatory = $false)]
    [Int]$port = 8530,

    [Parameter(Mandatory = $false)]
    [switch] $SkipDecline,
	
    [Parameter(Mandatory = $false)]
    [switch] $DeclineLastLevelOnly,

    [Parameter(Mandatory = $false, HelpMessage = 'Delete Declined Updates')]
    [Switch]$deleteDeclined,
	
    [Parameter(Mandatory = $False)]
    [int] $ExclusionPeriod = 60,
    
    [Parameter(Mandatory = $false, HelpMessage = 'Exception bulletin ID''s, these will always be set to not approved.')]
    [String[]]$exceptionBulletinIDs = @('17-023','16-065','15-124','10-087','15-011','16-107','13-094','13-085','15-058','09-062','16-026'),

    [Parameter(Mandatory = $false, HelpMessage = 'Exception article ID''s, these will always be set to not approved.')]
    [String[]]$exceptionArticleIDs = @('4284860'),

    [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
    [String]$logFile = 'C:\Temp\Approve-WSUS.log',

    [Parameter(Mandatory = $false, HelpMessage = 'Log Entries')]
    [Switch]$logEntries,

    [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
    [Int]$maxLogSize = 5242880,

    [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
    [Int]$maxLogHistory = 5
)

Function Get-CMNCurrentlyDeployedUpdates {
    <#
    .SYNOPSIS
        Returns a hashtable with the ID and name of all updates that are currently deployed from the site servers provided
    .DESCRIPTION
        This function will connect to each site server, use the SMS_SoftwareUpdate WMI class to retrieve all updates that have isDeployed = $true. It will return an array with the LocaliedDescription

    .PARAMETER SiteServers
		List of Site Servers to pull from

    .PARAMETER logFile
        File for writing logs to, default is c:\temp\eror.log

    .PARAMETER logEntries
        Switch for logging entries, default is $false

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
        Date:	    2018-10-01
        Updated:    
        PSVer:	    3.0
        Version:    1.0.0	
        
        SELECT * FROM SMS_AuthorizationList - Get's lists, updates contains UINT32 array of CI_ID's found in SMS_SoftwareUpdate.CI_ID 
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'List of SiteServers to get currently deployed updates from')]
        [String[]]$siteServers,

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
            Component     = 'Get-CMNCurrentlyDeployedUpdates';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        # Create a array with your output info
        $returnArray = [System.Collections.ArrayList]@()

        if ($logEntries) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "siteServers = $siteServers" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
        }
    }

    process {
        if ($logEntries) {New-CMNLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry}

        if ($PSCmdlet.ShouldProcess($siteServers)) {
            #Cycle through list of site servers
            foreach ($siteServer in $siteServers) {
                #Test connection to site server
                if ($logEntries) {New-CMNLogEntry -entry "Processing $siteServer" -type 1 @NewLogEntry}
                if (Test-Connection -ComputerName $siteServer -Quiet) {
                    $sccmConnectionInfo = Get-CMNSCCMConnectionInfo -siteServer $siteServer
                    if ($sccmConnectionInfo.SiteCode) {
                        #Get list of currently deployed updates
                        $query = 'SELECT DISTINCT UCI.CI_UniqueID
                        FROM vSMS_CIRelation CR
                        JOIN v_UpdateCIs UCI ON CR.ToCIID = UCI.CI_ID
                        JOIN v_AuthListInfo AL ON AL.CI_ID = CR.FromCIID
                        ORDER BY UCI.CI_UniqueID'
                        $dbCon = Get-CMNConnectionString -DatabaseServer $sccmConnectionInfo.SCCMDBServer -Database $sccmConnectionInfo.SCCMDB
                        $deployedUpdates = (Get-CMNDatabaseData -connectionString $dbCon -query $query -isSQLServer).CI_UniqueID
                        foreach ($deployedUpdate in $deployedUpdates) {
                            if ($returnArray.Contains($deployedUpdate)) {
                                if ($logentries) {New-CMNLogEntry -entry "$deployedUpdate already in results" -type 1 @NewLogEntry}
                            }
                            else {
                                if ($logentries) {New-CMNLogEntry -entry "Adding $deployedUpdate" -type 1 @NewLogEntry}
                                $returnArray.add($deployedUpdate)
                            }
                        }
                    }
                    else {
                        if ($logEntries) {New-CMNLogEntry -entry "$siteServer doesn't appear to be a Site server or we don't have rights" -type 3 @NewLogEntry}
                    }
                } 
                else {
                    if ($logEntries) {New-CMNLogEntry -entry "Unable to connect to $siteServer" -type 3 @NewLogEntry}
                }
            }
        }
    }

    End {
        if ($logEntries) {New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
        Return $returnArray
    }
} #End Get-CMNCurrentlyDeployedUpdates

Function Set-CMNWsusUpdateApprovals {
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
        Switch for logging entries, default is $false

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
        [Parameter(Mandatory = $false)]
        [string] $updateServer = $env:COMPUTERNAME,
	
        [Parameter(Mandatory = $false)]
        [Switch] $useSSL,
	
        [Parameter(Mandatory = $false)]
        [Int]$port = 8530,

        [Parameter(Mandatory = $false)]
        [switch] $SkipDecline,
	
        [Parameter(Mandatory = $false)]
        [switch] $DeclineLastLevelOnly,

        [Parameter(Mandatory = $false, HelpMessage = 'Delete Declined Updates')]
        [Switch]$deleteDeclined,
	
        [Parameter(Mandatory = $False)]
        [int] $ExclusionPeriod = 60,
    
        [Parameter(Mandatory = $false, HelpMessage = 'Exception bulletin ID''s, these will always be set to not approved.')]
        [String[]]$exceptionBulletinIDs,

        [Parameter(Mandatory = $false, HelpMessage = 'Exception article ID''s, these will always be set to not approved.')]
        [String[]]$exceptionArticleIDs,

        [Parameter(Mandatory = $false, HelpMessage = 'List of update GUIDS to keep')]
        [String[]]$exceptionGUIDs,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Approve-WSUS.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log Entries')]
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
            Component     = 'Set-CMNWsusUpdateApprovals';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        $declineGuids = New-Object System.Collections.ArrayList

        if ($logEntries) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "updateServer = $updateServer" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "useSSL = $useSSL" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "port = $port" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "skipDecline = $skipDecline" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "declineLastLevelOnly = $declineLastLevelOnly" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "deleteDeclined = $deleteDeclined" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "exclusionPeriod = $exclusionPeriod" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "exceptionBulletinIDs = $exceptionBulletinIDs" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "exceptionArticleIDs  = $exceptionArticleIDs" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "exceptionGUIDs = $exceptionGUIDs" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
        }
        Write-Verbose 'Starting Function'
        Write-Verbose "updateServer = $updateServer"
        Write-Verbose "useSSL = $useSSL"
        Write-Verbose "port = $port"
        Write-Verbose "skipDecline = $skipDecline"
        Write-Verbose "declineLastLevelOnly = $declineLastLevelOnly"
        Write-Verbose "deleteDeclined = $deleteDeclined"
        Write-Verbose "exclusionPeriod = $exclusionPeriod"
        Write-Verbose "exceptionBulletinIDs = $exceptionBulletinIDs"
        Write-Verbose "exceptionArticleIDs  = $exceptionArticleIDs"
        Write-Verbose "exceptionGUIDs = $exceptionGUIDs"
        Write-Verbose "logFile = $logFile"
        Write-Verbose "logEntries = $logEntries"
        Write-Verbose "maxLogSize = $maxLogSize"
        Write-Verbose "maxLogHistory = $maxLogHistory"
    }

    process {
        $message = 'Beginning process loop'
        if ($logEntries) {New-CMNLogEntry -entry $message -type 1 @NewLogEntry}
        Write-Verbose $message
        if ($PSCmdlet.ShouldProcess($updateServer)) {
            #Now we connect to WSUS and decline all updates that meet the criterea
            try {
                if ($useSSL) {
                    $message = "Connecting to WSUS server $updateServer on Port $Port using SSL... "
                    if ($logEntries) {New-CMNLogEntry -entry $message -type 1 @NewLogEntry}
                    Write-Verbose $message
                    $useSSL = $true
                }
                Else {
                    $message = "Connecting to WSUS server $updateServer on Port $Port... "
                    if ($logEntries) {New-CMNLogEntry -entry $message -type 1 @NewLogEntry}
                    Write-Verbose $message
                    $useSSL = $false
                }
                [reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | out-null
                $wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer($updateServer, $useSSL, $Port);
            }
            catch [System.Exception] {
                $message = "Failed to connect.`r`nError: $($_.Exception.Message)`r`nPlease make sure that WSUS Admin Console is installed on this machine"
                if ($logEntries) {
                    New-CMNLogEntry -entry $message -type 3 @NewLogEntry
                    Write-Verbose $message
                    throw $message
                }
            }
            $message = "Connected to WSUS server $updateServer, getting list of updates"
            if ($logentries) {New-CMNLogEntry -entry $message -type 1 @NewLogEntry}
            Write-Verbose $message

            try {
                $allUpdates = $wsus.GetUpdates()
                $allGroups = $wsus.GetComputerTargetGroups()
                $approval = [Microsoft.UpdateServices.Administration.UpdateApprovalAction]::NotApproved
            }

            catch [System.Exception] {
                $message = "Failed to get updates.`r`nError: $($_.Exception.Message)`r`nIf this operation timed out, please decline the superseded updates from the WSUS Console manually."
                if ($logEntries) {New-CMNLogEntry -entry $message -type 3 @NewLogEntry}
                Write-Verbose $message
                throw $message
            }
            $message = 'Done, now going to parse the list and gather current numbers.'
            if ($logEntries) {New-CMNLogEntry -entry $message -type 1 @NewLogEntry}
            Write-Verbose $message

            #Setup #'s to record
            $countAllUpdates = 0
            $countSupersededAll = 0
            $countSupersededLastLevel = 0
            $countSupersededExclusionPeriod = 0
            $countSupersededLastLevelExclusionPeriod = 0
            $countDeclined = 0

            foreach ($update in $allUpdates) {
                $countAllUpdates++
                if ($update.IsDeclined) {
                    $countDeclined++
                }
                if (!$update.IsDeclined -and $update.IsSuperseded) {
                    $countSupersededAll++
                    if (!$update.HasSupersededUpdates) {
                        $countSupersededLastLevel++
                    }
                    if ($update.CreationDate -lt (get-date).AddDays(-$ExclusionPeriod)) {
                        $countSupersededExclusionPeriod++
                        if (!$update.HasSupersededUpdates) {
                            $countSupersededLastLevelExclusionPeriod++
                        }
                    }		
                }
            }
            $anyExceptDeclined = ($countAllUpdates - $countDeclined)

            if ($logEntries) {
                New-CMNLogEntry -entry 'Done.' -type 1 @NewLogEntry
                New-CMNLogEntry -entry "List of superseded updates: $outSupersededList" -type 1 @NewLogEntry
                New-CMNLogEntry -entry '--------' -type 1 @NewLogEntry
                New-CMNLogEntry -entry 'Summary:' -type 1 @NewLogEntry
                New-CMNLogEntry -entry "========" -type 1 @NewLogEntry
                New-CMNLogEntry -entry "All Updates = $countAllUpdates" -type 1 @NewLogEntry
                New-CMNLogEntry -entry "Any except Declined = $anyExceptDeclined" -type 1 @NewLogEntry
                New-CMNLogEntry -entry "All Superseded Updates = $countSupersededAll" -type 1 @NewLogEntry
                New-CMNLogEntry -entry "`tSuperseded Updates (Intermediate) = $($countSupersededAll - $countSupersededLastLevel)" -type 1 @NewLogEntry
                New-CMNLogEntry -entry "`tSuperseded Updates (Last Level) = $countSupersededLastLevel" -type 1 @NewLogEntry
                New-CMNLogEntry -entry "`tSuperseded Updates (Older than $ExclusionPeriod days) = $countSupersededExclusionPeriod" -type 1 @NewLogEntry
                New-CMNLogEntry -entry "`tSuperseded Updates (Last Level Older than $ExclusionPeriod days) = $countSupersededLastLevelExclusionPeriod" -type 1 @NewLogEntry
                New-CMNLogEntry -entry "`tDeclined updates = $countDeclined" -type 1 @NewLogEntry
                New-CMNLogEntry -entry '--------' -type 1 @NewLogEntry
            }
            Write-Verbose 'Done.'
            Write-Verbose "List of superseded updates: $outSupersededList"
            Write-Verbose '--------'
            Write-Verbose 'Summary:'
            Write-Verbose '========'
            Write-Verbose "All Updates = $countAllUpdates"
            Write-Verbose "Any except Declined = $anyExceptDeclined"
            Write-Verbose "All Superseded Updates = $countSupersededAll"
            Write-Verbose "`tSuperseded Updates (Intermediate)= $($countSupersededAll - $countSupersededLastLevel)"
            Write-Verbose "`tSuperseded Updates (Last Level) = $countSupersededLastLevel"
            Write-Verbose "`tSuperseded Updates (Older than $ExclusionPeriod days) = $countSupersededExclusionPeriod"
            Write-Verbose "`tSuperseded Updates (Last Level Older than $ExclusionPeriod days) = $countSupersededLastLevelExclusionPeriod"
            Write-Verbose "`tDeclined updates = $countDeclined"
            Write-Verbose '--------'

            #now it's time to start declining updates!!
            
            if (!$SkipDecline) {
                $message = "SkipDecline flag is set to $SkipDecline. Continuing with declining updates"
                if ($logEntries) {New-CMNLogEntry -entry $message -type 1 @NewLogEntry}
                Write-Verbose $message
                if ($DeclineLastLevelOnly) {
                    $message = 'DeclineLastLevel is set to True. Only declining last level superseded updates.'
                    if ($logEntries) {New-CMNLogEntry -entry $message -type 1 @NewLogEntry}
                    Write-Verbose $message
                }
                else {
                    $message = 'DeclineLastLevel is set to False. Declining all superseded updates.'
                    if ($logEntries) {New-CMNLogEntry -entry $message -type 1 @NewLogEntry}
                    Write-Verbose $message
                }
                $updatesDeclined = 0
                $updatesApproved = 0
                foreach ($update in $allUpdates) {
                    $doApprove = $false
                    if ($update.Title -match 'itanium') {$doDecline = $true}
                    else {
                        $doDecline = $false
                        #let's verify the delcined aren't on the keep list
                        if ($update.IsDeclined) {
                            foreach ($updateArticleID in $update.KnowledgebaseArticles) {
                                if ($exceptionArticleIDs.Contains($updateArticleID)) {
                                    Write-Verbose "$($update.Title) is declined, but on the Article Exception List"    
                                    $doApprove = $true
                                }
                            }
                            #is it an exception BulletinID?
                            foreach ($updateBulletinID in $update.SecurityBulletins) {
                                if ($exceptionBulletinIDs.Contains($update.BulletinID)) {
                                    Write-Verbose "$($update.Title) is declined, but on the Bulletin Exception List"
                                    $doApprove = $true
                                }
                            }
                            if ($exceptionGUIDs.Contains($update.Id.UpdateID)) {
                                Write-Verbose "$($update.Title) is declined, but on the GUID Exception List"
                                $doApprove = $true
                            }
                        }
                        elseif ((($update.IsSuperseded -and !$update.HasSupersededUpdates -and $DeclineLastLevelOnly) -or ($update.IsSuperseded -and !$DeclineLastLevelOnly)) -and $update.CreationDate -lt (get-date).AddDays(-$ExclusionPeriod)) {
                            Write-Verbose "Checking $($update.Title) created $($update.CreationDate) - superseded = $($update.IsSuperseded) - hasSuperSeded = $($update.HasSupersededUpdates)"
                            $doDecline = $true
                            foreach ($updateArticleID in $update.KnowledgebaseArticles) {
                                #is it an exception ArticleID?
                                if ($exceptionArticleIDs.Contains($updateArticleID)) {
                                    Write-Verbose "$($update.Title) is approved and on the Article Exception List, skipping"
                                    $doDecline = $false
                                }
                            }
                            #is it an exception BulletinID?
                            foreach ($updateBulletinID in $update.SecurityBulletins) {
                                if ($exceptionBulletinIDs.Contains($update.BulletinID)) {
                                    Write-Verbose "$($update.Title) is approved and on the Bulletin Exception List, skipping"
                                    $doDecline = $false
                                }
                            }
                            #is it an exception Guid?
                            if ($exceptionGUIDs.Contains($update.Id.UpdateID)) {
                                Write-Verbose "$($update.Title) is approved and on the GUID Exception List, skipping"
                                $doDecline = $false
                            }
                        
                        }
                    }
                    if ($update.IsDeclined) {
                        if ($doApprove) {
                            $message = "$($update.Title) is declined, but on an exception list, setting to not approved"
                            if ($logEntries) {New-CMNLogEntry -entry $message -type 2 @NewLogEntry}
                            Write-Verbose $message
                            $updatesApproved++
                            $update.Approve($approval, $allGroups[0]) | Out-Null
                            $update.Refresh()
                        }
                        elseif ($PSBoundParameters['deleteDeclined']){
                            $message = "$($update.Title) is declined and will be deleted"
                            if ($logEntries) {New-CMNLogEntry -entry $message -type 2 @NewLogEntry}
                            Write-Verbose $message
                            $declineGuids.Add($update.Id.UpdateID)
                        }
                    }
                    elseif (!$update.IsDeclined -and $doDecline) {
                        $message = "Declining $($update.Title)"
                        if ($logEntries) {New-CMNLogEntry -entry $message -type 1 @NewLogEntry}
                        Write-Verbose $message
                        $updatesDeclined ++
                        $update.Decline() | Out-Null
                        $update.Refresh()
                    }
                }
                $message = "Declined $updatesDeclined updates; Approved $updatesApproved updates."
                if ($logEntries) {New-CMNLogEntry -entry $message -type 1 @NewLogEntry}
                Write-Verbose $message
                if($PSBoundParameters['deleteDeclined'] -and $declineGuids.Count -gt 0){
                    delete-cmnDeclinedUpdates -
                }
            }
            else {
                $message = "SkipDecline flag is set to $SkipDecline. Skipped declining updates"
                if ($logEntries) {New-CMNLogEntry -entry $message -type 1 @NewLogEntry}
                Write-Verbose $message
            }
        }
    }

    End {
        $message = 'Completing Function'
        if ($logEntries) {New-CMNLogEntry -entry $message -Type 1 @NewLogEntry}
        Write-Verbose $message
    }
} #End Set-CMNWsusUpdateApprovals

if ($PSBoundParameters['logEntries']) {$logEntries = $true}
else {$logEntries = $false}

if ($PSBoundParameters['useSSL']) {$useSSL = $true}
else {$useSSL = $false}

#Build splat for log entries
$NewLogEntry = @{
    LogFile       = $logFile;
    Component     = 'Optimize-CMNWSUSServer';
    maxLogSize    = $maxLogSize;
    maxLogHistory = $maxLogHistory;
}

if ($logEntries) {
    New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
    New-CMNLogEntry -entry "siteServers = $siteServers" -type 1 @NewLogEntry
    New-CMNLogEntry -entry "updateServer = $updateServer" -type 1 @NewLogEntry
    New-CMNLogEntry -entry "useSSL = $useSSL" -type 1 @NewLogEntry
    New-CMNLogEntry -entry "port = $port" -type 1 @NewLogEntry
    New-CMNLogEntry -entry "exceptionBulletinIDs = $exceptionBulletinIDs" -type 1 @NewLogEntry
    New-CMNLogEntry -entry "exceptionArticleIDs = $exceptionArticleIDs" -type 1 @NewLogEntry
    New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
    New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
    New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
    New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
}

#We start by gathering information for updates we do not want to decline. This list will contain all the updates that need to be set to not approved

$deployedUpdates = Get-CMNCurrentlyDeployedUpdates -siteServers $siteServers -logFile $logFile -logEntries:$logEntries
Set-CMNWsusUpdateApprovals -updateServer $updateServer -useSSL:$useSSL -port $port -SkipDecline:$SkipDecline -DeclineLastLevelOnly:$DeclineLastLevelOnly -deleteDeclined:($deleteDeclined.IsPresent) -ExclusionPeriod $ExclusionPeriod -exceptionBulletinIDs $exceptionBulletinIDs -exceptionArticleIDs $exceptionArticleIDs -exceptionGUIDs $deployedUpdates -logFile $logFile -logEntries:$logEntries -maxLogSize $maxLogSize -maxLogHistory $maxLogHistory -Verbose