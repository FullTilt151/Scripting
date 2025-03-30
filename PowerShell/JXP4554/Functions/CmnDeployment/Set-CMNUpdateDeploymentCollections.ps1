Function Set-CMNUpdateDeploymentCollections {
    <#
	.SYNOPSIS
		This script is to create the Reboot/NoReboot deployment collections for patching. It will look in the \Assets and Compliance\Overview\Device Collections\NWS Patch Management\Deploy to Collections folder for the collections and create the deployment collections in the Reboot/NoReboot folder below

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

	.PARAMETER maxLogHistory
			Specifies the number of history log files to keep, default is 5

 	.EXAMPLE

	.LINK
		http://configman-notes.com

	.NOTES
		FileName:    Set-CMNUpdateDeploymentCollections.ps1
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
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Deployment Collection Folder')]
        [String]$deploymentFolder = 'NWS Patch Management\Deploy to Collections',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Maintenance window folder')]
        [String]$maintenanceWindowFolder = 'Maintenance Windows',

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
        [Int32]$maxLogHistory = 5
    )

    begin {
        #Build splat for log entries
        $NewLogEntry = @{
            LogFile = $logFile;
            Component = 'Set-CMNUpdateDeploymentCollections';
            maxLogSize = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }
        #Build splats for WMIQueries
        $WMIQueryParameters = @{
            ComputerName = $sccmConnectionInfo.ComputerName;
            NameSpace = $sccmConnectionInfo.NameSpace;
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "SCCMConnectionInfo = $sccmConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "DeploymentFolder = $deploymentFolder" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "MaintenanceWindowFolder = $maintenanceWindowFolder" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
        }
    }

    process {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry}

        # Get Maintenance Window FolderID
        if ($PSBoundParameters['logEntries']) {$maintenanceFolderID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $sccmConnectionInfo -Name $maintenanceWindowFolder -ObjectType SMS_Collection_Device -logFile $logFile -logEntries}
        else {$maintenanceFolderID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $sccmConnectionInfo -Name $maintenanceWindowFolder -ObjectType SMS_Collection_Device}

        # Get Deployment Folder ID
        if ($PSBoundParameters['logEntries']) {$deploymentFolderID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $sccmConnectionInfo -Name $deploymentFolder -ObjectType SMS_Collection_Device -logFile $logFile -logEntries}
        else {$deploymentFolderID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $sccmConnectionInfo -Name $deploymentFolder -ObjectType SMS_Collection_Device}

        # Get Deployment Reboot Folder ID
        if ($PSBoundParameters['logEntries']) {$deploymentRebootFolderID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $sccmConnectionInfo -Name "$deploymentFolder\Reboot" -ObjectType SMS_Collection_Device -logFile $logFile -logEntries}
        else {$deploymentRebootFolderID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $sccmConnectionInfo -Name $"$deploymentFolder\Reboot" -ObjectType SMS_Collection_Device}

        # Get Deployment NoReboot Folder ID
        if ($PSBoundParameters['logEntries']) {$deploymentNoRebootFolderID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $sccmConnectionInfo -Name "$deploymentFolder\NoReboot" -ObjectType SMS_Collection_Device -logFile $logFile -logEntries}
        else {$deploymentNoRebootFolderID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $sccmConnectionInfo -Name "$deploymentFolder\NoReboot" -ObjectType SMS_Collection_Device}

        # Get collectionID's under the deployment folder
        if ($PSBoundParameters['logEntries']) {$deployToCollectionIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $sccmConnectionInfo -parentContainerNodeID $deploymentFolderID -ObjectType SMS_Collection_Device -logFile $logFile -logEntries}
        else {$deployToCollectionIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $sccmConnectionInfo -parentContainerNodeID $deploymentFolderID -ObjectType SMS_Collection_Device}

        # Get collectionID's under the reboot folder
        if ($PSBoundParameters['logEntries']) {$rebootCollectionIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $sccmConnectionInfo -parentContainerNodeID $deploymentRebootFolderID -ObjectType SMS_Collection_Device -Recurse -logFile $logFile -logEntries}
        else {$rebootCollectionIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $sccmConnectionInfo -parentContainerNodeID $deploymentRebootFolderID -ObjectType SMS_Collection_Device -Recurse}

        # Get collectionID's under the noReboot folder
        if ($PSBoundParameters['logEntries']) {$noRebootCollectionIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $sccmConnectionInfo -parentContainerNodeID $deploymentNoRebootFolderID -ObjectType SMS_Collection_Device -Recurse -logFile $logFile -logEntries}
        else {$noRebootCollectionIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $sccmConnectionInfo -parentContainerNodeID $deploymentNoRebootFolderID -ObjectType SMS_Collection_Device -Recurse}

        # Now that we have the reboot/noreboot collectionIDs, let's get collectionID's under folder (no recursion)
        if ($PSBoundParameters['logEntries']) {$mwCollectionIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $sccmConnectionInfo -parentContainerNodeID $maintenanceFolderID -ObjectType SMS_Collection_Device -logFile $logFile -logEntries | Where-Object {$_ -ne ''}}
        else {$mwCollectionIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $sccmConnectionInfo -parentContainerNodeID $maintenanceFolderID -ObjectType SMS_Collection_Device | Where-Object {$_ -ne ''}}

        # Cycle through the ID's and build the Reboot/NoReboot Collection Objects
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Building include rules for later' -type 1 @NewLogEntry}
        $noRebootColRules = New-Object System.Collections.ArrayList
        $rebootColRules = New-Object System.Collections.ArrayList
        foreach ($mwCollectionID in $mwCollectionIDs) {
            $query = "select * from sms_collection where collectionID = '$mwCollectionID'"
            $collection = Get-WmiObject -Query $query @WMIQueryParameters
            $includeRule = ([WMIClass]"//$($sccmConnectionInfo.ComputerName)/$($sccmConnectionInfo.NameSpace):SMS_CollectionRuleIncludeCollection").CreateInstance()
            $includeRule.IncludeCollectionID = $mwCollectionID
            $includeRule.RuleName = $collection.Name
            if ($collection.Name -match 'NoReboot' -or $collection.Name -match 'No Reboot') {
                if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Adding $($collection.Name) to noReboot rules" -type 1 @NewLogEntry}
                $noRebootColRules.Add($includeRule) | Out-Null
            }
            elseif ($collection.name -notmatch 'Do Not Patch') {
                if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Adding $($collection.Name) to reboot rules" -type 1 @NewLogEntry}
                $rebootColRules.Add($includeRule) | Out-Null
            }
        }

        # Cycle throgh and verify/create reboot/noreboot collections
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Updating Deploy to collections with new include rules' -type 1 @NewLogEntry}
        foreach ($deployToCollectionID in $deployToCollectionIDs) {
            $query = "Select * from SMS_Collection where CollectionID = '$deployToCollectionID'"
            $collection = Get-WmiObject -Query $query @WMIQueryParameters
            if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Processing $($collection.Name)" -type 1 @NewLogEntry}

            # if we don't get a collection, we've got a problem
            if ($collection) {
                $rebootCollectionName = "$($collection.Name) - Reboot"
                $noRebootCollectionName = "$($collection.Name) - NoReboot"
                # See if Reboot Collection Exists
                $query = "Select * from SMS_Collection where Name = '$rebootCollectionName'"
                $rebootCollection = Get-WmiObject -Query $query @WMIQueryParameters
                if (-not($rebootCollection)) {
                    if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "$rebootCollectionName doesn't exist, creating." -type 1 @NewLogEntry}
                    $rebootCollection = New-CMNDeviceCollection -SCCMConnectionInfo $sccmConnectionInfo -limitToCollectionID $collection.CollectionID -name $rebootCollectionName -comment 'Created by script'
                    Move-CMNObject -SCCMConnectionInfo $sccmConnectionInfo -objectID $rebootCollection.CollectionID -destinationContainerID $deploymentRebootFolderID -objectType SMS_Collection_Device
                }

                # See if NoReboot Collection Exists
                $query = "Select * from SMS_Collection where name = '$noRebootCollectionName'"
                $noRebootCollection = Get-WmiObject -Query $query @WMIQueryParameters
                if (-not($noRebootCollection)) {
                    if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "$noRebootCollectionName doesn't exist, creating." -type 1 @NewLogEntry}
                    $noRebootCollection = New-CMNDeviceCollection -SCCMConnectionInfo $sccmConnectionInfo -limitToCollectionID $collection.CollectionID -name $noRebootCollectionName -comment 'Created by script'
                    Move-CMNObject -SCCMConnectionInfo $sccmConnectionInfo -objectID $noRebootCollection.CollectionID -destinationContainerID $deploymentNoRebootFolderID -objectType SMS_Collection_Device
                }

                # Get rid of the existing rules
                if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Removing rules from $rebootCollectionName" -type 1 @NewLogEntry}
                $rebootCollection.get()
                $rebootCollection.DeleteMembershipRules($rebootCollection.CollectionRules)
                if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Adding rules to $rebootCollectionName" -type 1 @NewLogEntry}
                $rebootCollection.get()
                $rebootCollection.AddMemberShipRules($rebootColRules) | Out-Null

                if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Removing rules from $noRebootCollectionName" -type 1 @NewLogEntry}
                $noRebootCollection.get()
                $noRebootCollection.DeleteMembershipRules($noRebootCollection.CollectionRules)
                if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Adding rules to $noRebootCollectionName" -type 1 @NewLogEntry}
                $noRebootCollection.get()
                $noRebootCollection.AddMemberShipRules($noRebootColRules) | Out-Null
            }
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
    }
} #End Set-CMNUpdateDeploymentCollections
