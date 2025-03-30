Function Copy-CMNPackage {
    <#
		.SYNOPSIS
			Copies packages from one site to another

		.DESCRIPTION
			This function will copy the packages from the source site to the desitnation site

		.PARAMETER sourceConnectionInfo
			This is a PSObject that is the result of Get-CMNSCCMConnectionInfo pointing to the source site server

		.PARAMETER destinationConnectionInfo
			This is a PSObject that is the result of Get-CMNSCCMConnectionInfo pointing to the destination site server

		.PARAMETER packageIDs
			Array of PackageIDs to be copied from the source to the destination site

		.PARAMETER copyScopes
			Copy scopes to new package?

		.PARAMETER copyFolder
			Copy folder structure?

		.PARAMTER overWriteExisting
			Over write existing package if the same name?

		.PARAMETER logFile
			File for writing logs to

		.PARAMETER logEntries
			Switch to say whether or not to create a log file

		.EXAMPLE
			Copy-CMNPackage -sourceConnectionInfo $SP1ConnectionInfo -destinationConnectionInfo $SP2ConnectionInfo -packageIDs 'SP1003AC','SP1003AA' -logFile 'C:\CopyPackages.log'

		.LINK
			http://configman-notes.com

		.NOTES
			Author:	Jim Parris
			Email:	Jim@ConfigMan-Notes
			Date:	8/12/2016
			PSVer:	2.0/3.0

			To update NomadBranch settings, put the following string in AlternateContentProviders
			'<AlternateDownloadSettings SchemaVersion="1.0"><Provider Name="NomadBranch"><Data><ProviderSettings /><mc /><pc>1</pc></Data></Provider></AlternateDownloadSettings>'
	#>

    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Low')]
    param
    (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Source SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo',
            Position = 1)]
        [PSObject]$sourceConnectionInfo,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Destination SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo',
            Position = 2)]
        [PSObject]$destinationConnectionInfo,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'PackageID(s) you want to copy',
            Position = 3)]
        [string[]]$packageIDs,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Copy scopes',
            Position = 4)]
        [Switch]$copyScopes,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Copy folder structure',
            Position = 5)]
        [Switch]$copyFolders,

        [Parameter(Mandatory = $false,
            HelpMessage = 'OverWrite Existing Package',
            Position = 6)]
        [Switch]$overWriteExisting,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'LogFile',
            Position = 7)]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries',
            Position = 6)]
        [Switch]$logEntries = $false
    )

    begin {
        $NewLogEntry = @{
            LogFile = $logFile;
            Component = 'Copy-CMNPackage'
        }
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Starting Function' -Type 1 @NewLogEntry}
    }

    process {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Beginning process loop' -Type 1 @NewLogEntry}

        foreach ($packageID in $packageIDs) {
            $sourcePackage = Get-WmiObject -Class SMS_Package -Filter "PackageID = '$packageID'" -Namespace $SourceConnectionInfo.NameSpace -ComputerName $SourceConnectionInfo.ComputerName
            $sourcePackage.Get()
            if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Processing $($sourcePackage.Name)" -Type 1 @NewLogEntry}

            if ($PSCmdlet.ShouldProcess($sourcePackage.Name)) {
                #Check to see if package exists already
                if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Checking if $packageID exists on destination site" -Type 1 @NewLogEntry}
                $query = "SELECT * FROM SMS_PACKAGE WHERE PackageID = '$packageID'"
                $destinationPackage = Get-WmiObject -Query $query -Namespace $destinationConnectionInfo.NameSpace -ComputerName $destinationConnectionInfo.ComputerName
                if (-not $destinationPackage) {
                    #Create package in destination site
                    if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Creating package $($sourcePackage.Name)" -Type 1 @NewLogEntry}
                    $destinationPackage = ([WMIClass]"\\$($destinationConnectionInfo.ComputerName)\$($destinationConnectionInfo.NameSpace):SMS_Package").CreateInstance()
                    $newPackage = $true
                }
                else {
                    if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Package $($destinationPackage.Name) already exists" -Type 1 @NewLogEntry}
                    $newPackage = $false
                }
                if ($newPackage -or $overWriteExisting) {
                    #Copy properties
                    if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Copying properties for package $($destinationPackage.Name)" -Type 1 @NewLogEntry}
                    if ($newPackage) {
                        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Copying Property PackageID = $($sourcePackage.PackageID)" -Type 1 @NewLogEntry}
                        $destinationPackage.PackageID = $sourcePackage.PackageID
                    }
                    else {
                        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Skipping PackageID since it''s an existing package' -Type 1 @NewLogEntry}
                    }
                    $destinationPackage.ActionInProgress = $sourcePackage.ActionInProgress
                    $destinationPackage.AlternateContentProviders = '<AlternateDownloadSettings SchemaVersion="1.0"><Provider Name="NomadBranch"><Data><ProviderSettings /><pc>1</pc></Data></Provider></AlternateDownloadSettings>'
                    $destinationPackage.DefaultImageFlags = $sourcePackage.DefaultImageFlags
                    $destinationPackage.Description = $sourcePackage.Description
                    $destinationPackage.ExtendedData = $sourcePackage.ExtendedData
                    $destinationPackage.ExtendedDataSize = $sourcePackage.ExtendedDataSize
                    $destinationPackage.ForcedDisconnectDelay = $sourcePackage.ForcedDisconnectDelay
                    $destinationPackage.ForcedDisconnectEnabled = $sourcePackage.ForcedDisconnectEnabled
                    $destinationPackage.ForcedDisconnectNumRetries = $sourcePackage.ForcedDisconnectNumRetries
                    $destinationPackage.Icon = $sourcePackage.Icon
                    $destinationPackage.IconSize = $sourcePackage.IconSize
                    $destinationPackage.IgnoreAddressSchedule = $sourcePackage.IgnoreAddressSchedule
                    $destinationPackage.IsPredefinedPackage = $sourcePackage.IsPredefinedPackage
                    $destinationPackage.ISVData = $sourcePackage.ISVData
                    $destinationPackage.ISVDataSize = $sourcePackage.ISVDataSize
                    $destinationPackage.Language = $sourcePackage.Language
                    #$destinationPackage.LastRefreshTime = $sourcePackage.LastRefreshTime
                    $destinationPackage.LocalizedCategoryInstanceNames = $sourcePackage.LocalizedCategeroyInstanceNames
                    $destinationPackage.Manufacturer = $sourcePackage.Manufacturer
                    $destinationPackage.MIFFileName = $sourcePackage.MIFFileName
                    $destinationPackage.MIFName = $sourcePackage.MIFName
                    $destinationPackage.MIFPublisher = $sourcePackage.MIFPublisher
                    $destinationPackage.MIFVersion = $sourcePackage.MIFVersion
                    $destinationPackage.Name = $sourcePackage.Name
                    #$destinationPackage.NumOfPrograms = $sourcePackage.NumOfPrograms
                    #$destinationPackage.PackageSize = $sourcePackage.PackageSize
                    $destinationPackage.PkgFlags = $sourcePackage.PkgFlags
                    $destinationPackage.PkgSourceFlag = $sourcePackage.PkgSourceFlag
                    $destinationPackage.PkgSourcePath = $sourcePackage.PkgSourcePath
                    $destinationPackage.PreferredAddressType = $sourcePackage.PreferredAddressType
                    $destinationPackage.Priority = $sourcePackage.Priority
                    $destinationPackage.RefreshSchedule = $sourcePackage.RefreshSchedule
                    #$destinationPackage.SedoObjectVersion = $sourcePackage.SedoObjectVersion
                    $destinationPackage.ShareName = $sourcePackage.ShareName
                    $destinationPackage.ShareType = $sourcePackage.ShareType
                    #$destinationPackage.SourceDate = $sourcePackage.SourceDate
                    #$destinationPackage.SourceSite = $sourcePackage.SourceSite
                    $destinationPackage.SourceVersion = $sourcePackage.SourceVersion
                    $destinationPackage.StoredPkgPath = $sourcePackage.StoredPkgPath
                    $destinationPackage.StoredPkgVersion = $sourcePackage.StoredPkgVersion
                    #$destinationPackage.TransformAnalysisDate = $sourcePackage.TransformAnalysisDate
                    #$destinationPackage.TransformReadiness = $sourcePackage.TrasnformReadiness
                    $destinationPackage.Version = $sourcePackage.Version
                    #Save package
                    $destinationPackage.Put() | Out-Null

                    #Copy Programs for package

                    $programs = Get-WmiObject -Class SMS_Program -Filter "PackageID = '$($sourcePackage.PackageID)'" -Namespace $sourceConnectionInfo.NameSpace -ComputerName $sourceConnectionInfo.ComputerName
                    foreach ($program in $programs) {
                        $program.Get()
                        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Creating Program $($program.ProgramName)" -Type 1 @NewLogEntry}
                        #Create Program in destination site
                        $destinationProgram = ([WMIClass]"\\$($destinationConnectionInfo.ComputerName)\$($destinationConnectionInfo.NameSpace):SMS_Program").CreateInstance()
                        #Copy Properties
                        foreach ($property in ($destinationProgram.Properties.Name)) {
                            $destinationProgram.$property = $program.$property
                        }
                        #Save Program
                        $destinationProgram.Put() | Out-Null
                    }
                    if ($copyScopes) {
                        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Starting to copy scopes' -Type 1 @NewLogEntry}
                        $query = "SELECT * FROM SMS_SecuredCategory"
                        $scopes = (Get-WmiObject -Query $query -ComputerName $destinationConnectionInfo.ComputerName -Namespace $destinationConnectionInfo.NameSpace).CategoryName
                        foreach ($scope in $sourcePackage.SecuredScopeNames) {
                            switch ($scope) {
                                #Certificaiton Scope
                                {$_ -eq 'ATS Scope'} {
                                    if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Adding Certification role on $($destinationPackage.Name)" -Type 1 @NewLogEntry}
                                    Add-CMNRoleOnObject -SCCMConnectionInfo $destinationConnectionInfo -objectID $destinationPackage.PackageID -objectType SMS_Package -roleName 'Certification' -logFile $logFile
                                }
                                {$_ -eq 'DOC CERT Scope' -or $_ -eq 'CIT Scope' -or $_ -eq 'Default' -or $_ -eq 'Local DSI' -or $_ -eq 'Package Read Only' -or $_ -eq 'Server Scope' -or $_ -eq 'Workstations'} {
                                    if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Adding Production role on $($destinationPackage.Name)" -Type 1 @NewLogEntry}
                                    Add-CMNRoleOnObject -SCCMConnectionInfo $destinationConnectionInfo -objectID $destinationPackage.PackageID -objectType SMS_Package -roleName 'Production' -logFile $logFile
                                }
                                Default {
                                    if ($scope -in $scopes) {
                                        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Adding $scope to $($destinationPackage.Name)" -Type 1 @NewLogEntry}
                                        Add-CMNRoleOnObject -SCCMConnectionInfo $destinationConnectionInfo -objectID $destinationPackage.PackageID -objectType SMS_Package -roleName $scope -logFile $logFile
                                    }
                                    else {
                                        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Unable to add $scope to $($destinationPackage.Name)" -Type 3 @NewLogEntry}
                                    }
                                }
                            }
                        }
                    }
                    if ($copyFolders) {
                        $option = [System.StringSplitOptions]::RemoveEmptyEntries
                        $folders = Get-CMNObjectFolderPath -SCCMConnectionInfo $sourceConnectionInfo -ObjectID $packageID -ObjectType SMS_Package -logFile $logFile
                        if ($folders -ne '\') {
                            $x = 0
                            $parentContainerNodeID = 0
                            $folder = $folders.Split('\', $option)
                            while ($x -lt $folder.count) {
                                $query = "select * from SMS_ObjectContainerNode where Name = '$($folder[$x])' and ParentContainerNodeID = $parentContainerNodeID and ObjectType = $($ObjectTypetoObjectID['SMS_Package'])"
                                $container = Get-WmiObject -Query $query -Namespace $destinationConnectionInfo.NameSPace -ComputerName $destinationConnectionInfo.ComputerName
                                if ($container) {
                                    if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Container $($folder[$x]) exists" -type 1 @NewLogEntry}
                                    $parentContainerNodeID = $container.ContainerNodeID
                                    $x++
                                }
                                else {
                                    if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Container $($folder[$x]) does not exist" -type 1 @NewLogEntry}
                                    $newContainer = ([WMIClass]"\\$($destinationConnectionInfo.ComputerName)\$($destinationConnectionInfo.NameSpace):SMS_ObjectContainerNode").CreateInstance()
                                    $newContainer.Name = $folder[$x]
                                    $newContainer.ObjectType = $ObjectTypetoObjectID['SMS_Package']
                                    $newContainer.ParentContainerNodeID = $parentContainerNodeID
                                    $newContainer.Put() | Out-Null
                                    $newContainer.Get()
                                    $parentContainerNodeID = $newContainer.ContainerNodeID
                                    $x++
                                }
                            }
                            if ($parentContainerNodeID -ne 0 -and $parentContainerNodeID -ne $null) {
                                [Array]$instanceID = $destinationPackage.PackageID
                                #Invoke-WmiMethod -Name MoveMembers -Class SMS_ObjectContainerItem -ArgumentList $instanceID, $currentContainerNodeID, $parentContainerNodeID, $ObjectTypetoObjectID['SMS_Package'] -Namespace $destinationConnectionInfo.NameSpace -ComputerName $destinationConnectionInfo.ComputerName | Out-Null
                                $WMIConnection = [WMIClass]"\\$($destinationConnectionInfo.ComputerName)\$($destinationConnectionInfo.NameSpace):SMS_objectContainerItem"
                                $MoveItem = $WMIConnection.psbase.GetMethodParameters("MoveMembers")
                                $MoveItem.ContainerNodeID = (Get-CMNObjectContainerNodeID -SCCMConnectionInfo $destinationConnectionInfo -ObjectID $destinationPackage.PackageID -ObjectType SMS_Package -logFile $logFile)
                                $MoveItem.InstanceKeys = $destinationPackage.PackageID
                                $MoveItem.ObjectType = $ObjectTypetoObjectID['SMS_Package']
                                $MoveItem.TargetContainerNodeID = $parentContainerNodeID
                                $WMIConnection.psbase.InvokeMethod("MoveMembers", $MoveItem, $null) | Out-Null
                            }
                        }
                        else {
                            if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Package $($destinationPackage.Name) already exists in the root" -type 1 @NewLogEntry}
                        }
                    }
                }
                else {
                    if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Package $($destinationPackage.Name) already exists in the destination site and OverWriteExisting was not selected" -Type 3 @NewLogEntry}
                    Write-Error "Package $($destinationPackage.Name) already exists in the destination site and OverWriteExisting was not selected"
                }
                Write-Output $destinationPackage
            }
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'End Function' -Type 1 @NewLogEntry}
    }
} #End Copy-CMNPackage
