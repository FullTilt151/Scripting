Function New-CMNSoftwareUpdateGroup {
    <# 
    .SYNOPSIS
        This function creates a new Software Update Group.

    .DESCRIPTION
        This function creates a new Software Update Group.

    .PARAMETER SCCMConnectionInfo
        This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
        Get-CMNSCCMConnectionInfo in a variable and passing that variable.

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
        Email:	    Jim@ConfigMan-Notes
        Date:	    4/25/2018
        PSVer:	    3.0
        Updated: 
        Version:    1.0.0		
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info')]
        [PSObject]$SCCMConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'Authorization List Name')]
        [String]$authListName,
        
        [Parameter(Mandatory = $false, HelpMessage = 'Authorization List Description')]
        [String]$authListDescription,

        [Parameter(Mandatory = $false, HelpMessage = 'Authorization List Locale')]
        [Int]$authListLocale = 1033,

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
        # Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'New-CMNSoftwareUpdateGroup';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        # Build splats for WMIQueries
        $WMIQueryParameters = $SCCMConnectionInfo.WMIQueryParameters

        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "SCCMConnectionInfo = $SCCMConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
        }
    }

    process {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry}

        if ($PSCmdlet.ShouldProcess($authListName)) {
            $SMS_CI_LocalizedProperties = ([WMIClass] "\\$($SCCMConnectionInfo.ComputerName)\$($SCCMConnectionInfo.NameSpace):SMS_CI_LocalizedProperties").CreateInstance()
            $SMS_CI_LocalizedProperties.DisplayName = $authListName
            $SMS_CI_LocalizedProperties.Description = $authListDescription
            $SMS_CI_LocalizedProperties.LocaleID = $authListLocale
            $authList = ([WMIClass] "\\$($SCCMConnectionInfo.ComputerName)\$($SCCMConnectionInfo.NameSpace):SMS_AuthorizationList").CreateInstance()
            $authList.CIType_ID = 9
            $authList.LocalizedInformation = $SMS_CI_LocalizedProperties
            $authList.Put() | Out-Null
        }
    }

    End {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
        Return $authList
    }
} # End New-CMNSoftwareUpdateGroup
Function Copy-CMNSoftwareUpdateGroup {
    <# 
    .SYNOPSIS
        Copies the software update group, specified as an AuthlistID from the source site to the destination site

    .DESCRIPTION
        Copies the software update group, specified as an AuthlistID from the source site to the destination site

    .PARAMETER SrcConnectionInfo
        This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
        Get-CMNSCCMConnectionInfo in a variable and passing that variable.

    .PARAMETER DstConnectionInfo
        This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
        Get-CMNSCCMConnectionInfo in a variable and passing that variable.

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
        FileName:    Copy-CMNSoftwareUpdateGroup.ps1
        Author:      James Parris
        Contact:     Jim@ConfigMan-Notes.com
        Created:     2018-04-06
        Updated:     
        Version:     1.0.0
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Source Connection Info')]
        [PSObject]$SrcConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Destination Connection Info')]
        [PSObject]$DstConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'CI_ID for AuthList')]
        [String]$AuthListCI_ID,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int32]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int32]$maxLogHistory = 5
    )

    Begin {
        # Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'Copy-CMNSoftwareUpdateGroup';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }
        # Build splats for WMIQueries
        $WMISrcQueryParameters = $SrcConnectionInfo.WMIQueryParameters
        $WMIDstQueryParameters = $DstConnectionInfo.WMIQueryParameters
        
        # Assign a value to logEntries
        if ($PSBoundParameters['logEntries']) {$logEntries = $true}
        else {$logEntries = $false}

        # Create a hashtable with your output info
        $returnHashTable = @{}

        # Define hashtable for passing updates
        $updates = @{}

        # Do some logging
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "SrcConnectionInfo = $SrcConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "DstConnectionInfo = $DstConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "AuthListCI_ID = $AuthListCI_ID" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "Verifying Authorization List exists" -type 1 @NewLogEntry
        }

        #  Get the source authorization list
        $srcAuthList = Get-WmiObject -Query "Select * from SMS_AuthorizationList Where CI_ID='$AuthListCI_ID'" @WMISrcQueryParameters -ErrorAction SilentlyContinue

        if (-not($srcAuthList)) {
            #  If it does not exist, error out.
            if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Authorization list $AuthListCI_ID does not exist." -type 3 @NewLogEntry}
            throw "Authorization list $AuthListCI_ID does not exist."
        }
        else {
            #  Make array of updates in list
            if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Building array of updates' -type 1 @NewLogEntry}
            $srcAuthList.Get()
            if ($srcAuthList.Updates.Count -ne 0 -and $srcAuthList.Updates.Count -ne $null) {
                foreach ($update in $srcAuthList.Updates) {
                    if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Getting update CI_ID $update" -type 1 @NewLogEntry}
                    $updateDetail = Get-WmiObject -Query "SELECT * FROM SMS_SoftwareUpdate WHERE CI_ID='$update'" @WMISrcQueryParameters
                    $updateObject = New-Object PSObject -Property @{
                        ArticleID                      = $updateDetail.ArticleID;
                        BulletinID                     = $updateDetail.BulletinID;
                        LocalizedCategoryInstanceNames = $updateDetail.LocalizedCategoryInstanceNames;
                        LocalizedDescription           = $updateDetail.LocalizedDescription;
                        LocalizedDisplayName           = $updateDetail.LocalizedDisplayName;
                    }
                    $updates.Add($updateDetail.CI_UniqueID, $updateObject)
                }
            }
        }
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Finished building update list, end Begin loop' -type 1 @NewLogEntry}
    }

    Process {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry}
        
        # Find out if the Authorization List already exists
        if ($PSCmdlet.ShouldProcess($AuthListCI_ID)) {
            $authList = Get-WmiObject -Query "Select * from SMS_AuthorizationList Where LocalizedDisplayName ='$($srcAuthList.LocalizedDisplayName)'" @WMIDstQueryParameters
            if ($authList) {
                if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "$($authList.LocalizedDisplayName) already exists" -type 2 @NewLogEntry}
                $authList.Get()
            }
            else {
                if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "$($srcAuthList.LocalizedDisplayName) doesn't exist, creating" -type 1 @NewLogEntry}
                $authList = New-CMNSoftwareUpdateGroup -SCCMConnectionInfo $DstConnectionInfo -authListName $srcAuthList.LocalizedDisplayName -AuthListDescription $srcAuthList.LocalizedDescription -authListLocale $srcAuthList.LocalizedPropertyLocaleID -logFile $logFile -logEntries:$logEntries -maxLogHistory $maxLogHistory -maxLogSize $maxLogSize
            }
            
            # Now, we need to build an array of UInt32 of each update CI_ID.
            $updateCI_ID = New-Object System.Collections.ArrayList
            foreach ($updateItem in $updates.GetEnumerator()) {
                $update = Get-CimInstance -Query "SELECT * FROM SMS_SoftwareUpdate WHERE CI_UniqueID = '$($updateItem.Key)'" @WMIDstQueryParameters
                if ($update) {
                    if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Adding update $($updateItem.Value.BulletinID) - $($updateItem.Value.ArticleID) - $($updateItem.Value.LocalizedDisplayName)." -type 1 @NewLogEntry}
                    $return = New-Object -TypeName psobject -Property $update.Value
                    $return.PSObject.TypeNames.Insert(0, 'Success')
                    $returnHashTable.add($updateItem.key, $return)
                    $updateCI_ID.Add($update.CI_ID) | Out-Null
                }
                else {
                    if ($PSBoundParameters['logEntries']) {                        New-CMNLogEntry -entry "Update $($updateItem.Value.BulletinID) - $($updateItem.Value.ArticleID) - $($updateItem.Value.LocalizedDisplayName) does not exist on site $($DstConnectionInfo.Site)" -type 3 @NewLogEntry}
                    $return = New-Object -TypeName psobject -Property $update.Value
                    $return.PSObject.TypeNames.Insert(0, 'Fail')
                    $returnHashTable.add($updateItem.key, $return)
                }
            }
        }
        $authList.Updates = $updateCI_ID
        $authList.Put() | Out-Null
    }
    
    End {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.CopyCMNSoftwareUpdateGroup')
        Return $obj	
    }
} # End Copy-CMNSoftwareUpdateGroup

$src = Get-CMNSCCMConnectionInfo -siteServer LOUAPPWPS1825
$logFile = 'c:\temp\Copy-CMNSoftwareUpdateGroup.log'
$WMIQueryParameters = $src.WMIQueryParameters
$SMS_DeploymentInfo = Get-CimClass -ClassName SMS_DeploymentInfo -Namespace $src.NameSpace -ComputerName $src.ComputerName
#$SUGIDs = (Get-CimInstance -ClassName SMS_UpdateGroupAssignment -Namespace $src.NameSpace -ComputerName $src.ComputerName -Filter "TargetCollectionID = 'SP10030E' and AssignmentType = 5").AssignedUpdateGroup | Sort-Object -Unique
$SUGIDs = (Get-CimInstance -ClassName SMS_UpdateGroupAssignment -Namespace $src.NameSpace -ComputerName $src.ComputerName -Filter "AssignmentType = 5").AssignedUpdateGroup | Sort-Object -Unique
$siteServers = ('LOUAPPWQS1150')
#$sugs = Get-WmiObject -Query "Select * from SMS_AuthorizationList where LocalizedDisplayName = 'NWS - Baseline Windows 2012R2 - SP1'" @WMIQueryParameters

$results = @{}
foreach ($sugid in $sugids) {
    foreach ($siteServer in $siteServers) {
        $dst = Get-CMNSCCMConnectionInfo -siteServer $siteServer
        Copy-CMNSoftwareUpdateGroup -SrcConnectionInfo $src -DstConnectionInfo $dst -AuthListCI_ID $sugid -logFile $logFile -logEntries
    }
}
$results