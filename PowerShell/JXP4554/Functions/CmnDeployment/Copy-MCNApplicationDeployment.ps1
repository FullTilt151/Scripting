Function Copy-CMNApplicationDeployment {
    <#
	.SYNOPSIS
		Copies applications between sites

	.DESCRIPTION
		Copies applications between sites

	.PARAMETER SCCMSourceConnectionInfo
		This is a connection object for the source site. The best way to get this is storing the results of
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.

	.PARAMETER SCCMDestinationConnectionInfo
		This is a connection object for the destination site. The best way to get this is storing the results of
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.

	.PARAMETER logFile
		File for writing logs to

	.PARAMETER logEntries
		Switch to say whether or not to create a log file

	.EXAMPLE

	.LINK
		http://configman-notes.com

	.NOTES
		FileName:    Copy-CMNApplicationDeployment.ps1
		Author:      James Parris
		Contact:     jim@ConfigMan-Notes.com
		Created:     2016-03-22
		Updated:     2016-03-22
		Version:     1.0.0
		SMS_ApplicationLatest <- SMS_DeploymentType <- SMS_ObjectContentExtraInfo
		https://www.scconfigmgr.com/2014/01/09/create-an-application-in-configmgr-2012-with-powershell/
	#>

    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Low')]

    PARAM
    (
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info')]
        [PSObject]$SCCMSourceConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info')]
        [PSObject]$SCCMDestinationConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'Application Model Name')]
        [String]$applicationModelName,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries
    )

    begin {
        $NewLogEntry = @{
            LogFile = $logFile;
            Component = 'Copy-CMNApplicationDeployment'
        }
        $WMISRCQueryParameters = @{
            ComputerName = $SCCMSourceConnectionInfo.ComputerName;
            NameSpace = $SCCMSourceConnectionInfo.NameSpace;
        }
        $WMIDSTQueryParameters = @{
            ComputerName = $SCCMDestinationConnectionInfo.ComputerName;
            NameSpace = $SCCMDestinationConnectionInfo.NameSpace;
        }
        if ($PSBoundParameters['clearLog']) {if (Test-Path -Path $logFile) {Remove-Item -Path $logFile}}
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry}
    }

    process {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry}
        if ($PSCmdlet.ShouldProcess($applicationModelName)) {
            $ReturnHashTable = @{}
            $query = "SELECT * FROM SMS_ApplicationLatest WHERE ModelName='$applicationModelName'"
            $srcApplication = Get-WmiObject -Query $query @WMISRCQueryParameters

            #Verify Applcation exists
            if ($srcApplication) {
                #Check to see if it already exists on destination
                $dstApplication = Get-WmiObject -Query $query @WMIDSTQueryParameters
                if ($dstApplication) {
                    Write-Output "App Exists in Destination"
                }
                else {
                    #Create Application on destination
                    $dstApplication = ([WMIClass] "\\$($SCCMDestinationConnectionInfo.ComputerName)\$($SCCMDestinationConnectionInfo.NameSpace):SMS_Application").CreateInstance()
                    $dstApplication.get()
                    $dstApplication.ApplicabilityCondition = $srcApplication.ApplicabilityCondition
                    $dstApplication.CategoryInstance_UniqueIDs = $srcApplication.CategoryInstance_UniqueIDs
                    $dstApplication.CI_ID = $srcApplication.CI_ID
                    $dstApplication.CI_UniqueID = $srcApplication.CI_UniqueID
                    #$dstApplication.CIType_ID = $srcApplication.CIType_ID
                    #$dstApplication.CIVersion = $srcApplication.CIVersion
                    $dstApplication.ConfigurationFlags = $srcApplication.ConfigurationFlags
                    #$dstApplication.CreatedBy = $srcApplication.CreatedBy
                    #$dstApplication.DateCreated = $srcApplication.DateCreated
                    #$dstApplication.DateLastModified = $srcApplication.DateLastModified
                    #$dstApplication.EffectiveDate = $srcApplication.EffectiveDate
                    #$dstApplication.EULAAccepted = $srcApplication.EULAAccepted
                    #$dstApplication.EULAExists = $srcApplication.EULAExists
                    #$dstApplication.EULASignoffDate = $srcApplication.EULASignoffDate
                    #$dstApplication.EULASignoffUser = $srcApplication.EULASignoffUser
                    #$dstApplication.ExecutionContext = $srcApplication.ExecutionContext
                    #$dstApplication.Featured = $srcApplication.Featured
                    #$dstApplication.HasContent = $srcApplication.HasContent
                    $dstApplication.IsBundle = $srcApplication.IsBundle
                    #$dstApplication.IsDeployable = $srcApplication.IsDeployable
                    #$dstApplication.IsDeployed = $srcApplication.IsDeployed
                    #$dstApplication.IsDigest = $srcApplication.IsDigest
                    $dstApplication.IsEnabled = $srcApplication.IsEnabled
                    $dstApplication.IsExpired = $srcApplication.IsExpired
                    $dstApplication.IsHidden = $srcApplication.IsHidden
                    #$dstApplication.IsLatest = $srcApplication.IsLatest
                    #$dstApplication.IsQuarantined = $srcApplication.IsQuarantined
                    #$dstApplication.IsSuperseded = $srcApplication.IsSuperseded
                    #$dstApplication.IsSuperseding = $srcApplication.IsSuperseding
                    $dstApplication.IsUserDefined = $srcApplication.IsUserDefined
                    $dstApplication.IsVersionCompatible = $srcApplication.IsVersionCompatible
                    #$dstApplication.LastModifiedBy = $srcApplication.LastModifiedBy
                    #$dstApplication.LocalizedCategoryInstanceNames = $srcApplication.LocalizedCategoryInstanceNames
                    #$dstApplication.LocalizedDescription = $srcApplication.LocalizedDescription
                    #$dstApplication.LocalizedDisplayName = $srcApplication.LocalizedDisplayName
                    #$dstApplication.LocalizedInformativeURL = $srcApplication.LocalizedInformativeURL
                    #$dstApplication.LocalizedPropertyLocaleID = $srcApplication.LocalizedPropertyLocaleID
                    #$dstApplication.LogonRequirement = $srcApplication.LogonRequirement
                    #$dstApplication.Manufacturer = $srcApplication.Manufacturer
                    $dstApplication.ModelID = $srcApplication.ModelID
                    $dstApplication.ModelName = $srcApplication.ModelName
                    #$dstApplication.NumberOfDependentDTs = $srcApplication.NumberOfDependentDTs
                    #$dstApplication.NumberOfDependentTS = $srcApplication.NumberOfDependentTS
                    #$dstApplication.NumberOfDeployments = $srcApplication.NumberOfDeployments
                    #$dstApplication.NumberOfDeploymentTypes = $srcApplication.NumberOfDeploymentTypes
                    #$dstApplication.NumberOfDevicesWithApp = $srcApplication.NumberOfDevicesWithApp
                    #$dstApplication.NumberOfDevicesWithFailure = $srcApplication.NumberOfDevicesWithFailure
                    #$dstApplication.NumberOfSettings = $srcApplication.NumberOfSettings
                    #$dstApplication.NumberOfUsersWithApp = $srcApplication.NumberOfUsersWithApp
                    #$dstApplication.NumberOfUsersWithFailure = $srcApplication.NumberOfUsersWithFailure
                    #$dstApplication.NumberOfUsersWithRequest = $srcApplication.NumberOfUsersWithRequest
                    #$dstApplication.NumberOfVirtualEnvironments = $srcApplication.NumberOfVirtualEnvironments
                    $dstApplication.PackageID = $srcApplication.PackageID
                    $dstApplication.PermittedUses = $srcApplication.PermittedUses
                    $dstApplication.PlatformCategoryInstance_UniqueIDs = $srcApplication.PlatformCategoryInstance_UniqueIDs
                    #$dstApplication.PlatformType = $srcApplication.PlatformType
                    $dstApplication.SDMPackageLocalizedData = $srcApplication.SDMPackageLocalizedData
                    $dstApplication.SDMPackageVersion = $srcApplication.SDMPackageVersion
                    $dstApplication.SDMPackageXML = $srcApplication.SDMPackageXML
                    #$dstApplication.SecuredScopeNames = $srcApplication.SecuredScopeNames
                    #$dstApplication.SedoObjectVersion = $srcApplication.SedoObjectVersion
                    #$dstApplication.SoftwareVersion = $srcApplication.SoftwareVersion
                    #$dstApplication.SourceCIVersion = $srcApplication.SourceCIVersion
                    #$dstApplication.SourceModelName = $srcApplication.SourceModelName
                    $dstApplication.SourceSite = $srcApplication.SourceSite
                    #$dstApplication.SummarizationTime = $srcApplication.SummarizationTime
                    #$dstApplication.PSComputerName = $srcApplication.PSComputerName
                    $dstApplication.Put()

                    $query = "SELECT * FROM SMS_DeploymentType WHERE AppModelName = '$applicationModelName'"

                    #Get deploymenttypes from source and replicate to destination
                    $deploymentTypes = Get-WmiObject -Query $query @WMISRCQueryParameters
                    Write-Output "deploymentTypes"
                    $deploymentTypes

                    #ContentPackage
                    foreach ($deploymentType in $deploymentTypes) {
                        $query = "SELECT * FROM SMS_ObjectContentExtraInfo where ObjectID = '$($deployment.AppModelName)'"
                        $objectContentExtraInfo = Get-WmiObject -Query $query @WMISRCQueryParameters
                        Write-Output "ObjectContentExtraInfo"
                        $objectContentExtraInfo

                        $query = "SELECT * FROM SMS_ContentPackage WHERE SecurityKey = '$($deploymentType.AppModelName)'"
                        $contentPackage = Get-WmiObject -Query $query @WMISRCQueryParameters
                        Write-Output "ContentPackage"
                        $contentPackage

                        $query = "SELECT * FROM SMS_Package WHERE PackageID = '$($contentPackage.PackageID)'"
                        $package = Get-WmiObject -Query $query @WMISRCQueryParameters
                        Write-Output "Package"
                        $package

                        $query = "SELECT * FROM SMS_PackageToContent WHERE PackageID = '$($contentPackage.PackageID)'"
                        $packageToContent = Get-WmiObject -Query $query @WMISRCQueryParameters
                        Write-Output "packageToContent"
                        $packageToContent

                        $query = "SELECT * FROM SMS_Content WHERE ContentID = '$($packageToContent.ContentID)'"
                        $content = Get-WmiObject -Query $query @WMISRCQueryParameters
                        Write-Output "content"
                        $content

                        $query = "SELECT * FROM SMS_ContentPackage WHERE PackageID = '$($contentPackage.PackageID)'"
                        $contentToPackage = Get-WmiObject -Query $query @WMISRCQueryParameters
                        Write-Output "contentToPackage"
                        $contentToPackage
                    }

                    $ReturnHashTable.Add($applicationModelName, $App.ModelName)
                    Return $ReturnHashTable
                }
            }
            else {
                Write-Output "No App"
            }
        }
    }

    end {
        if ($PSBoundParameters['ShowProgress']) {Write-Progress -Activity 'Copy-CMNApplicationDeployment' -Completed}
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
    }
} #End Copy-CMNApplicationDeployment