Function Add-CMNRoleOnObject {
    <#
	.SYNOPSIS
		This Function will add a role to an object

	.DESCRIPTION
		You provide the ObjectType to add the scope to, the Type of object, and the RoleName. If you add a role that already exists,
		the function will behave the same as if the role wasn't there. In either case, the role will be there afterwards.

	.PARAMETER SCCMConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.

	.PARAMETER objectID
		This is the ID of the object to add the role to (PackageID, DriverID, etc.)

	.PARAMETER objectType
		ObjectType for the object you are working with. Valid values are:
			SMS_Package
			SMS_Advertisement
			SMS_Query
			SMS_Report
			SMS_MeteredProductRule
			SMS_ConfigurationItem
			SMS_OperatingSystemInstallPackage
			SMS_StateMigration
			SMS_ImagePackage
			SMS_BootImagePackage
			SMS_TaskSequencePackage
			SMS_DeviceSettingPackage
			SMS_DriverPackage
			SMS_Driver
			SMS_SoftwareUpdate
			SMS_ConfigurationBaselineInfo
			SMS_Collection_Device
			SMS_Collection_User
			SMS_ApplicationLatest
			SMS_ConfigurationItemLatest

	.PARAMETER roleName
		The Role to add to the Object

    .PARAMETER logFile
        File for writing logs to, default is c:\temp\eror.log

    .PARAMETER logEntries
        Switch for logging entries, default is $false

    .PARAMETER maxLogSize
        Max size for the log. Defaults to 5MB.

    .PARAMETER maxHistory
            Specifies the number of history log files to keep, default is 5

    .EXAMPLE
        Add-CMNRoleOnObject -objectID 'S0101234' -objectType 'SMS_Package' -roleName 'Certification'
        This will add the Certification role to the Package with the ID S0101234

	.EXAMPLE
		Add-CMNRoleOnObject 'S0101234' 'SMS_Package' 'Certification'
        This will also add the Certification role to the Package with the ID S0101234

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	  Jim Parris
		Email:	  Jim@ConfigMan-Notes
		Date:	  2016-02-05
        Updated:  2016-11-08
        PSVer:	  3.0
        Version:  1.0.1
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info from Get-CMNSccmConnctionInfo')]
        [Alias('computerName', 'hostName')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'ObjectID to Add Scope to')]
        [String]$objectID,

        [Parameter(Mandatory = $true, HelpMessage = 'Object Type')]
        [ValidateSet('SMS_Package', 'SMS_Advertisement', 'SMS_Query', 'SMS_Report', 'SMS_MeteredProductRule', 'SMS_ConfigurationItem', 'SMS_OperatingSystemInstallPackage', 'SMS_StateMigration', 'SMS_ImagePackage', 'SMS_BootImagePackage', 'SMS_TaskSequencePackage', 'SMS_DeviceSettingPackage', 'SMS_DriverPackage', 'SMS_Driver', 'SMS_SoftwareUpdate', 'SMS_ConfigurationBaselineInfo', 'SMS_Collection_Device', 'SMS_Collection_User', 'SMS_ApplicationLatest', 'SMS_ConfigurationItemLatest')]
        [String]$objectType,

        [Parameter(Mandatory = $true, HelpMessage = 'Role to add')]
        [String]$roleName,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries = $false,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int]$maxLogHistory = 5
    )

    begin {
        #Check for valid SCCMConnectionInfo

        #Verify it has the correct properties
        #Verify you can connect to the site Server

        #Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'Add-CMNRoleOnObject';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        #Build splat for WMIQueries
        $WMIQueryParameters = $sccmConnectionInfo.WMIQueryParameters

        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "SCCMConnectionInfo = $sccmConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "objectID = $objectID" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "objectType = $objectType" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "roleName = $roleName" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry  "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
        }
    }

    process {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Beginning processing loop' -Type 1 @NewLogEntry
            New-CMNLogEntry -entry "SecurityScopeCategoryID is $securityScopeCategoryID" -Type 1 @NewLogEntry
            New-CMNLogEntry -entry 'Translate the Role name into a ID' -type 1 @NewLogEntry
        }

        [ARRAY]$securityScopeCategoryID = (Get-WmiObject -Class SMS_SecuredCategory -Filter "CategoryName = '$roleName'" @WMIQueryParameters).CategoryID
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry "securityScopeCategoryID = $securityScopeCategoryID" -type 1 @NewLogEntry
            New-CMNLogEntry -entry 'Now, we loop through each object to add the role.' -type 1 @NewLogEntry
        }
        try {
            if ($PSCmdlet.ShouldProcess($objectID)) {
                if ($PSBoundParameters['logEntries']) {
                    New-CMNLogEntry -entry "Setting Role on $objectID" -type 1 @NewLogEntry
                }
                Invoke-WmiMethod -Name AddMemberShips -Class SMS_SecuredCategoryMemberShip -ArgumentList $securityScopeCategoryID, $objectID, $objectTypetoObjectID[$objectType] @WMIQueryParameters | Out-Null
            }
        }

        catch {
            if ($PSBoundParameters['logEntries']) {
                New-CMNLogEntry -entry "Failed to add $roleName to $objID" -Type 3 @NewLogEntry
            }
            Throw "Failed to add $roleName to $objID"
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        }
    }
} #End Add-CMNRoleOnObject

Function Add-CMNScopeOnObject {
    <#
	.SYNOPSIS
		This Function will add a scope to an object

	.DESCRIPTION
		You provide the ObjectType (Package, Advertisment, etc) and ObjectID (PackageID, AdvertID, etc.) and the scopeName.
		If you add a scope that is already assigned to the object, the function will behave the same as it wasn't.
		In either case, the scope will be there afterwards.

	.PARAMETER SCCMConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.

	.PARAMETER objectID
		This is the ID of the object to add the role to (PackageID, DriverID, etc.)

	.PARAMETER objectType
		ObjectType for the object you are working with. Valid values are:
			SMS_Package
			SMS_Advertisement
			SMS_Query
			SMS_Report
			SMS_MeteredProductRule
			SMS_ConfigurationItem
			SMS_OperatingSystemInstallPackage
			SMS_StateMigration
			SMS_ImagePackage
			SMS_BootImagePackage
			SMS_TaskSequencePackage
			SMS_DeviceSettingPackage
			SMS_DriverPackage
			SMS_Driver
			SMS_SoftwareUpdate
			SMS_ConfigurationBaselineInfo
			SMS_Collection_Device
			SMS_Collection_User
			SMS_ApplicationLatest
			SMS_ConfigurationItemLatest

	.PARAMETER scopeName
		Alias - roleName
		The scope to add to the Object

	.PARAMETER logFile
		File for writing logs to

    .PARAMETER logEntries
        Switch to say whether or not to create a log file

	.PARAMETER maxLogSize
		Max size for the log. Defaults to 5MB.

	.PARAMETER maxLogHistory
				Specifies the number of history log files to keep, default is 5
	.EXAMPLE
		$Site = Get-CMNSCCMConnectionI
		Add-CMNScopeOnObject -SCCMConnectionInfo $Site -ObjectID 'S01003F2' -objectType 'SMS_Package' -scopeName 'Workstations' -logFile 'c:\Temp\AddObjects.log' -logEntries

		This will add the Workstations Role to PackageID S01003F2

	.EXAMPLE
		'S01003F2' | Add-CMNScopeOnObject -objectType 'SMS_Package' -roleName 'Workstations'

		This will add the Workstations role to PacakgeID S01003F2

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:	2/25/2016
		PSVer:	2.0/3.0
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'ObjectID to Add Scope to', ValueFromPipeLine = $true)]
        [String[]]$objectID,

        [Parameter(Mandatory = $true, HelpMessage = 'Object Type')]
        [ValidateSet('SMS_Package', 'SMS_Advertisement', 'SMS_Query', 'SMS_Report', 'SMS_MeteredProductRule', 'SMS_ConfigurationItem', 'SMS_OperatingSystemInstallPackage', 'SMS_StateMigration', 'SMS_ImagePackage', 'SMS_BootImagePackage', 'SMS_TaskSequencePackage', 'SMS_DeviceSettingPackage', 'SMS_DriverPackage', 'SMS_Driver', 'SMS_SoftwareUpdate', 'SMS_ConfigurationBaselineInfo', 'SMS_Collection_Device', 'SMS_Collection_User', 'SMS_ApplicationLatest', 'SMS_ConfigurationItemLatest')]
        [String]$objectType,

        [Parameter(Mandatory = $true, HelpMessage = 'Scope to add')]
        [Alias('roleName')]
        [String]$scopeName,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int32]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int32]$maxLogHistory = 5
    )

    begin {
        #Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'Add-CMNScopeOnObject';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        #Build splat for WMIQueries
        $WMIQueryParameters = @{
            ComputerName = $sccmConnectionInfo.ComputerName;
            NameSpace    = $sccmConnectionInfo.NameSpace;
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "SCCMConnectionInfo = $sccmConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "objectID = $objectID" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "objectType = $objectType" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "scopeName = $scopeName" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
        }
        #Translate the Role name into a ID
        [ARRAY]$securityScopeCategoryID = (Get-WmiObject -Class SMS_SecuredCategory -Filter "CategoryName = '$scopeName'" @WMIQueryParameters).CategoryID
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry "SecurityScopeCategoryID is $securityScopeCategoryID" -Type 1 @NewLogEntry
        }
    }

    process {
        if ($pscmdlet.ShouldProcess($scopeName)) {
            if ($PSBoundParameters['logEntries']) {
                New-CMNLogEntry -entry 'Beginning processing loop' -Type 1 @NewLogEntry
            }
            foreach ($objID in $objectID) {
                try {
                    Invoke-WmiMethod -Name AddMemberShips -Class SMS_SecuredCategoryMemberShip -ArgumentList $securityScopeCategoryID, $objID, $objectTypetoObjectID[$objectType] @WMIQueryParameters | Out-Null
                }

                catch {
                    if ($PSBoundParameters['logEntries']) {
                        New-CMNLogEntry -entry "Failed to add $scopeName to $objID" -Type 3 @NewLogEntry
                    }
                    Write-Error "Failed to add $scopeName to $objID"
                }
            }
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Completed Function' -Type 1 @NewLogEntry
        }
    }
} #End Add-CMNScopeOnObject

Function ConvertTo-CMNDomainUserSID {
    <#
	.SYNOPSIS
		Returns the SID for a domain user

	.DESCRIPTION
		Returns the SID for a domain user

	.PARAMETER domain
		Domain for the login

	.PARAMETER userID
		Login you want the SID for

	.EXAMPLE
		ConvertTo-CMNDomainUserSID -domain Contoso -user jparris

		Returns sid for user jparris

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:	4/14/2017
		PSVer:	2.0/3.0
		Updated:
	#>
    PARAM
    (
        [Parameter(Mandatory = $true, HelpMessage = 'Domain for the login', Position = 1)]
        [String]$domain,

        [Parameter(Mandatory = $true, HelpMessage = 'Login you want SID for', Position = 2)]
        [String]$userID
    )
    $objUser = New-Object System.Security.Principal.NTAccount($Domain, $UserID)
    $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
    Return $strSID.Value
} # End ConvertTo-CMNDomainUserSID

Function ConvertTo-CMNLocalUserSID {
    <#
	.SYNOPSIS
		Returns the SID for a Local user

	.DESCRIPTION
		Returns the SID for a Local user

	.PARAMETER userID
		Login you want the SID for

	.EXAMPLE
		ConvertTo-CMNLocalUserSID -user jparris

		Returns sid for user jparris

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:	4/14/2017
		PSVer:	2.0/3.0
		Updated:
	#>

    PARAM
    (
        [Parameter(Mandatory = $true, HelpMessage = 'LoginID to translate')]
        [String]$userID
    )

    $objUser = New-Object System.Security.Principal.NTAccount($userID)
    $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
    Return $strSID.Value
} # End ConvertTo-CMNLocalUserSID

Function ConvertTo-CMNSingleQuotedString {
    <#
	.SYNOPSIS
		This will replace a ' with ''

	.DESCRIPTION
		This will replace a ' with '' to make the text compatable for SQL queries or any query that uses the ' as an escape/delimiter

	.PARAMETER Text
		Text to be fixed

	.EXAMPLE
		Get-CMNQuotedVersion -Text "Windows 7 Workstation's"

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:	2/25/2016
		PSVer:	2.0/3.0
		Updated:
	#>

    [CmdletBinding(ConfirmImpact = 'Low')]
    Param
    (
        [Parameter(Mandatory = $true)]
        [String]$text
    )
    return ([regex]::Replace($text, '(?<SingleQuote>'')', '${SingleQuote}'''))
} #End ConvertTo-CMNSingleQuotedString

Function ConvertTo-CMNWMISingleQuotedString {
    <#
	.SYNOPSIS
		This will replace a ' with \'

	.DESCRIPTION
		This will replace a ' with \' to make the text compatable for WQL queries or any query that uses the ' as an escape/delimiter

	.PARAMETER Text
		Text to be fixed

	.EXAMPLE
		Get-CMNQuotedVersion -Text "Windows 7 Workstation's"

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:	8/12/2016
		PSVer:	2.0/3.0
	#>

    [CmdletBinding(ConfirmImpact = 'Low')]
    Param
    (
        [Parameter(Mandatory = $true)]
        [String]$text
    )
    return ([regex]::Replace($text, '(?<SingleQuote>'')', '\${SingleQuote}'))
} #End ConvertTo-CMNWMISingleQuotedString

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
            LogFile   = $logFile;
            Component = 'Copy-CMNApplicationDeployment'
        }
        $WMISRCQueryParameters = @{
            ComputerName = $SCCMSourceConnectionInfo.ComputerName;
            NameSpace    = $SCCMSourceConnectionInfo.NameSpace;
        }
        $WMIDSTQueryParameters = @{
            ComputerName = $SCCMDestinationConnectionInfo.ComputerName;
            NameSpace    = $SCCMDestinationConnectionInfo.NameSpace;
        }
        if ($PSBoundParameters['clearLog']) {
            if (Test-Path -Path $logFile) {
                Remove-Item -Path $logFile
            }
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        }
    }

    process {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry
        }
        if ($PSCmdlet.ShouldProcess($applicationModelName)) {
            $ReturnHashTable = @{ }
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
        if ($PSBoundParameters['ShowProgress']) {
            Write-Progress -Activity 'Copy-CMNApplicationDeployment' -Completed
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        }
    }
} #End Copy-CMNApplicationDeployment

Function Copy-CMNClientSettings {
    <#
	.SYNOPSIS
		Copies Client Settings from one SCCM site to another

	.DESCRIPTION
		Copies Client Settings from one SCCM site to another

	.PARAMETER sourceConnection
		This is a connection object for the source site. The best way to get this is storing the results of
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.

	.PARAMETER destinationConnection
		This is a connection object to the destination site.

	.PARAMETER logFile
		File for writing logs to

	.PARAMETER logEntries
		Switch to say whether or not to create a log file

	.PARAMETER clearLog
		If this is set, we will clear (delete) any existing log file.

	.PARAMETER maxLogSize
		Max size for the log. Defaults to 5MB.

	.EXAMPLE
		$SrcCon = Get-CMNSCCMConnectionInfo -SiteServer Server01
		$DstCon = Get-CMNSCCMConnectionInfo -SiteServer Server02
		Copy-CMNClientSettings -sourceConnection $SrcCon -destinationConnection $DstCon -logFile $logfile -logEntries

	.LINK
		http://configman-notes.com

	.NOTES
		FileName:    Copy-CMNClientSettings.ps1
		Author:      James Parris
		Contact:     jim@ConfigMan-Notes.com
		Created:     2016-03-22
		Updated:     2017-03-2
		Version:     1.0.1
	#>

    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Low')]

    PARAM
    (
        [Parameter(Mandatory = $true,
            HelpMessage = 'SCCM Connection Info',
            Position = 1)]
        [PSObject]$sourceConnection,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Destination SCCM Connection',
            Position = 2)]
        [PSObject]$destinationConnection,

        [Parameter(Mandatory = $false,
            HelpMessage = 'LogFile Name',
            Position = 3)]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries',
            Position = 4)]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Clear Log File',
            Position = 5)]
        [Switch]$clearLog,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Max Log size',
            Position = 6)]
        [Int32]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Max number of history logs',
            Position = 7)]
        [Int32]$maxLogHistory = 5
    )
    begin {
        #Build splat for log entries
        $NewLogEntry = @{
            logFile       = $logFile;
            component     = 'Copy-CMNClientSettings';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }
        #Build splats for WMIQueries
        $WMISourceQueryParameters = @{
            ComputerName = $sourceConnection.ComputerName;
            NameSpace    = $sourceConnection.NameSpace;
        }
        $WMIDestinationQueryParameters = @{
            ComputerName = $destinationConnection.ComputerName;
            NameSpace    = $destinationConnection.NameSpace;
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "sourceConnection = $sourceConnection" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "destinationConnection = $destinationConnection" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
        }
    }

    process {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry
        }
        if ($PSCmdlet.ShouldProcess($sourceConnection)) {
            #Let's get the settings from the source site.
            $query = 'SELECT * FROM SMS_ClientSettings order by priority'
            $clientSettings = Get-WmiObject -Query $query @WMISourceQueryParameters
            #Now to cycle through them and copy!
            foreach ($clientSetting in $clientSettings) {
                #Get the individual setting
                $query = "select * from SMS_ClientSettings where Name = '$($clientSetting.Name)'"
                #Let's see if it already exists
                $testDestSettings = Get-WmiObject -Query $query @WMIDestinationQueryParameters
                if ($testDestSettings) {
                    Write-Output 'Already Exists'
                }
                else {
                    #Eureka! Let's create it! First, get those lazy parameters....
                    $clientSetting.Get()
                    #And we start anew!
                    $destClientSettings = ([WMIClass]"//$($destinationConnection.ComputerName)/$($destinationConnection.NameSpace):SMS_ClientSettings").CreateInstance()
                    #Now for those pesky details...
                    $destClientSettings.AgentConfigurations = $clientSetting.AgentConfigurations
                    $destClientSettings.Description = $clientSetting.Description
                    $destClientSettings.Enabled = $clientSetting.Enabled
                    $destClientSettings.FeatureType = $clientSetting.FeatureType
                    $destClientSettings.Flags = $clientSetting.Flags
                    $destClientSettings.Name = $clientSetting.Name
                    $destClientSettings.Priority = $clientSetting.Priority
                    $destClientSettings.Type = $clientSetting.Type
                    #And save it!
                    $destClientSettings.Put()
                }
            }
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        }
    }
} #End Copy-CMNClientSettings

Function Copy-CMNCollection {
    <#
	.SYNOPSIS
		Copies collection from one site to another

	.DESCRIPTION
		This function will copy the collections from the source site to the desitnation site

	.PARAMETER sourceConnection
		This is a PSObject that is the result of Get-CMNSCCMConnectionInfo pointing to the source site server

	.PARAMETER destinationConnection
		This is a PSObject that is the result of Get-CMNSCCMConnectionInfo pointing to the destination site server

	.PARAMETER collectionIDs
		Array of Collection IDs to be copied from the source to the destination site

	.PARAMETER MatchByName
		If set, collections will be matched by names, not collection ID's.

	.PARAMETER overWriteExisting
		Switch to signal if we should overwrite the collection in the destination site if it exists

	.PARAMETER logFile
		File for writing logs to

	.PARAMETER logEntries
		Switch to say whether or not to create a log file

	.PARAMETER maxLogSize
		Max size for the log. Defaults to 5MB.

	.PARAMETER maxLogHistory
			Specifies the number of history log files to keep, default is 5

	.EXAMPLE
		Copy-CMNCollection -sourceConnectionInfo $SP1ConnectionInfo -destinationConnectionInfo $SP2Connection Info -collectionIDs 'SP100334', 'SP100335' -overWriteExisting

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	    Jim Parris
		Email:	    Jim@ConfigMan-Notes
		Date:	    8/12/2016
		PSVer:	    2.0/3.0
        Version:    1.0.0
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'Source SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sourceConnection,

        [Parameter(Mandatory = $true, HelpMessage = 'Destination SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$destinationConnection,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'CollectionID(s) you want to copy')]
        [string[]]$collectionIDs,

        [Parameter(Mandatory = $false, HelpMessage = 'If set, collections are matched by name, otherwise by CollectionID')]
        [Switch]$matchByName,

        [Parameter(Mandatory = $false, HelpMessage = 'Overwrite Existing Collection')]
        [Switch]$overWriteExisting,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries = $false,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int32]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int32]$maxLogHistory = 5
    )

    begin {
        #Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'FunctionName';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }
        #Build splats for WMIQueries
        $WMISourceQueryParameters = @{
            ComputerName = $sourceConnection.ComputerName;
            NameSpace    = $sourceConnection.NameSpace;
        }
        $WMIDestinationQueryParameters = @{
            ComputerName = $destinationConnection.ComputerName;
            NameSpace    = $destinationConnection.NameSpace;
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "sourceConnection = $sourceConnection" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "destinationConnection = $destinationConnection" -type 1 @NewLogEntry
            foreach ($collectionID in $collectionIDs) {
                New-CMNLogEntry -entry "collectionID = $collectionID" -type 1 @NewLogEntry
            }
            New-CMNLogEntry -entry "matchByName = $matchByName" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
        }
    }

    process {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Beginning process loop' -Type 1 @NewLogEntry
        }

        foreach ($collectionID in $collectionIDs) {
            $sourceCollection = Get-WmiObject -Class SMS_Collection -Filter "CollectionID = '$collectionID'" @WMISourceQueryParameters
            $sourceCollection.get()
            if ($PSBoundParameters['logEntries']) {
                New-CMNLogEntry -entry "Processing $($sourceCollection.Name)" -Type 1 @NewLogEntry
            }

            if ($PSCmdlet.ShouldProcess($sourceCollection.Name)) {
                #note if collection already exists
                if ($matchByName) {
                    $query = "select * from SMS_Collection where Name = '$($sourceCollection.Name)'"
                }
                else {
                    $query = "select * from SMS_Collection where CollectionID = '$collectionID'"
                }
                $destinationCollection = Get-WmiObject -Query $query @WMIDestinationQueryParameters
                if ($destinationCollection) {
                    $isCollectionExist = $true
                }
                else {
                    $isCollectionExist = $false
                }
                if ($isCollectionExist -and -not($overWriteExisting)) {
                    if ($PSBoundParameters['logEntries']) {
                        New-CMNLogEntry -entry "Collection $($destinationCollection.Name) already exists" -type 3 @NewLogEntry
                    }
                    Write-Error "Collection $($destinationCollection.Name) already exists"
                }
                else {
                    #Get limiting colleciton info
                    $query = "Select * from SMS_Collection where CollectionID = '$($sourceCollection.LimitToCollectionID)'"
                    $sourceLimitingCollection = Get-WmiObject -Query $query @WMISourceQueryParameters
                    $sourceLimitingCollection.get()
                    $filterName = [regex]::Replace($sourceLimitingCollection.Name, '(?<SingleQuote>'')', '\${SingleQuote}')
                    $query = "Select * from SMS_Collection where Name  = '$filterName'"
                    $destinationLimitingCollection = Get-WmiObject -Query $query @WMIDestinationQueryParameters
                    $destinationLimitingCollection.get()

                    if (-not($destinationLimitingCollection)) {
                        if ($PSBoundParameters['logEntries']) {
                            New-CMNLogEntry -entry 'No matching limiting collection' -type 3 @NewLogEntry
                        }
                        Write-Error 'No matching limiting collection'
                    }

                    if ($destinationLimitingCollection.count -gt 1) {
                        if ($PSBoundParameters['logEntries']) {
                            New-CMNLogEntry -entry 'Ambiguious limiting collection' -type 3 @NewLogEntry
                        }
                        Write-Error 'Ambiguious limiting collection'
                    }

                    #Create collection in destination site
                    if (-not ($isCollectionExist)) {
                        $destinationCollection = ([WMIClass]"\\$($destinationConnection.ComputerName)\Root\sms\site_$($destinationConnection.SiteCode):SMS_Collection").CreateInstance()
                        $destinationCollection.CollectionID = $sourceCollection.CollectionID
                    }
                    #Copy properties
                    $destinationCollection.CollectionType = $sourceCollection.CollectionType
                    $destinationCollection.Comment = $sourceCollection.Comment
                    $destinationCollection.LimitToCollectionID = $destinationLimitingCollection.CollectionID
                    $destinationCollection.LimitToCollectionName = $destinationLimitingCollection.Name
                    $destinationCollection.MonitoringFlags = $sourceCollection.MonitoringFlags
                    $destinationCollection.Name = $sourceCollection.Name
                    if ($sourceCollection.RefreshType -ne 1) {
                        $destinationCollection.RefreshSchedule = $sourceCollection.RefreshSchedule
                    }
                    $destinationCollection.RefreshType = $sourceCollection.RefreshType

                    $destinationCollection.Put() | Out-Null

                    #Copy Collection Rules
                    foreach ($collectionRule in $sourceCollection.CollectionRules) {
                        if ($collectionRule.QueryID -gt 0) {
                            #We have a query rule, time to create
                            New-CMNDeviceCollectionQueryMemberRule -SCCMConnectionInfo $destinationConnection -CollectionID ($destinationCollection.CollectionID) -query ($collectionRule.QueryExpression) -ruleName ($collectionRule.RuleName) -logFile $logFile -logEntries:$logEntries -maxLogSize $maxLogSize -maxLogHistory $maxLogHistory
                        }
                        elseif ($collectionRule.IncludeCollectionID -gt 0) {
                            #We have a include rule, time to create
                            New-CMNDeviceCollectionIncludeRule -SCCMConnectionInfo $destinationConnection -CollectionID ($destinationCollection.CollectionID) -includeCollectionID ($collectionRule.IncludeCollectionID) -ruleName ($collectionRule.RuleName) -logFile $logFile -logEntries $logEntries -maxLogSize $maxLogSize -maxLogHistory $maxLogHistory
                        }
                        elseif ($collectionRule.ExcludeCollectionID -gt 0) {
                            New-CMNDeviceCollectionExcludeRule -SCCMConnectionInfo $destinationConnection -CollectionID ($destinationCollection.CollectionID) -excludeCollectionID ($collectionRule.ExcludeCollectionID) -ruleName ($collectionRule.RuleName) -logFile $logFile -logEntries $logEntries -maxLogSize $maxLogSize -maxLogHistory $maxLogHistory
                        }
                        else {
                            New-CMNDeviceCollectionDirectMemberRule -SCCMConnectionInfo $destinationConnection -CollectionID $destinationCollection.CollectionID -NetbiosNames $collectionRule.RuleName -logFile $logFile -logEntries $logEntries -maxLogSize $maxLogSize -maxLogHistory $maxLogHistory
                        }
                    }
                }
            }
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Finish Function' -type 1 @NewLogEntry
        }
    }
} #End Copy-CMNCollection

Function Copy-CMNDeployment {
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

	.EXAMPLE

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:
		PSVer:	2.0/3.0
		Updated:
	#>

    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Low')]
    param
    (
        [Parameter(Mandatory = $true,
            HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'What computer name would you like to target?')]
        [Alias('host')]
        [ValidateLength(3, 30)]
        [string[]]$computername,

        [Parameter(Mandatory = $true,
            HelpMessage = 'LogFile name')]
        [string]$logfile,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries')]
        [Switch]$logEntries = $false
    )

    begin {
        $NewLogEntry = @{
            LogFile   = $logFile;
            Component = 'Copy-CMNDeployment'
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        }
    }

    process {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry
        }

        foreach ($computer in $computername) {
            # create a hashtable with your output info
            $returnHashTable = @{
                'info1' = $value1;
                'info2' = $value2;
                'info3' = $value3;
                'info4' = $value4
            }
            $LimitingCollection = Get-WmiObject -Class SMS_Collection -Filter "CollectionID = '$LimitToCollectionID'" -Namespace root/sms/site_$($sccmConnectionInfo.SiteCode) -ComputerName $sccmConnectionInfo.ComputerName
            Write-Verbose "Processing $computer"
            # use $computer to target a single computer

            if ($PSCmdlet.ShouldProcess($CIID)) {
                Write-Output (New-Object �TypenamePSObject �Prop $returnHashTable)
                $obj = New-Object -TypeName PSObject -Property $returnHashTable
                $obj.PSObject.TypeNames.Insert(0, 'CMN.ObjectType')
            }
        }
    }

    end {
        Return $obj
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Completing Function' -type 1 @NewLogEntry
        }
    }
} #End Copy-CMNDeployment

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
            LogFile   = $logFile;
            Component = 'Copy-CMNPackage'
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -Type 1 @NewLogEntry
        }
    }

    process {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Beginning process loop' -Type 1 @NewLogEntry
        }

        foreach ($packageID in $packageIDs) {
            $sourcePackage = Get-WmiObject -Class SMS_Package -Filter "PackageID = '$packageID'" -Namespace $SourceConnectionInfo.NameSpace -ComputerName $SourceConnectionInfo.ComputerName
            $sourcePackage.Get()
            if ($PSBoundParameters['logEntries']) {
                New-CMNLogEntry -entry "Processing $($sourcePackage.Name)" -Type 1 @NewLogEntry
            }

            if ($PSCmdlet.ShouldProcess($sourcePackage.Name)) {
                #Check to see if package exists already
                if ($PSBoundParameters['logEntries']) {
                    New-CMNLogEntry -entry "Checking if $packageID exists on destination site" -Type 1 @NewLogEntry
                }
                $query = "SELECT * FROM SMS_PACKAGE WHERE PackageID = '$packageID'"
                $destinationPackage = Get-WmiObject -Query $query -Namespace $destinationConnectionInfo.NameSpace -ComputerName $destinationConnectionInfo.ComputerName
                if (-not $destinationPackage) {
                    #Create package in destination site
                    if ($PSBoundParameters['logEntries']) {
                        New-CMNLogEntry -entry "Creating package $($sourcePackage.Name)" -Type 1 @NewLogEntry
                    }
                    $destinationPackage = ([WMIClass]"\\$($destinationConnectionInfo.ComputerName)\$($destinationConnectionInfo.NameSpace):SMS_Package").CreateInstance()
                    $newPackage = $true
                }
                else {
                    if ($PSBoundParameters['logEntries']) {
                        New-CMNLogEntry -entry "Package $($destinationPackage.Name) already exists" -Type 1 @NewLogEntry
                    }
                    $newPackage = $false
                }
                if ($newPackage -or $overWriteExisting) {
                    #Copy properties
                    if ($PSBoundParameters['logEntries']) {
                        New-CMNLogEntry -entry "Copying properties for package $($destinationPackage.Name)" -Type 1 @NewLogEntry
                    }
                    if ($newPackage) {
                        if ($PSBoundParameters['logEntries']) {
                            New-CMNLogEntry -entry "Copying Property PackageID = $($sourcePackage.PackageID)" -Type 1 @NewLogEntry
                        }
                        $destinationPackage.PackageID = $sourcePackage.PackageID
                    }
                    else {
                        if ($PSBoundParameters['logEntries']) {
                            New-CMNLogEntry -entry 'Skipping PackageID since it''s an existing package' -Type 1 @NewLogEntry
                        }
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
                        if ($PSBoundParameters['logEntries']) {
                            New-CMNLogEntry -entry "Creating Program $($program.ProgramName)" -Type 1 @NewLogEntry
                        }
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
                        if ($PSBoundParameters['logEntries']) {
                            New-CMNLogEntry -entry 'Starting to copy scopes' -Type 1 @NewLogEntry
                        }
                        $query = "SELECT * FROM SMS_SecuredCategory"
                        $scopes = (Get-WmiObject -Query $query -ComputerName $destinationConnectionInfo.ComputerName -Namespace $destinationConnectionInfo.NameSpace).CategoryName
                        foreach ($scope in $sourcePackage.SecuredScopeNames) {
                            switch ($scope) {
                                #Certificaiton Scope
                                { $_ -eq 'ATS Scope' } {
                                    if ($PSBoundParameters['logEntries']) {
                                        New-CMNLogEntry -entry "Adding Certification role on $($destinationPackage.Name)" -Type 1 @NewLogEntry
                                    }
                                    Add-CMNRoleOnObject -SCCMConnectionInfo $destinationConnectionInfo -objectID $destinationPackage.PackageID -objectType SMS_Package -roleName 'Certification' -logFile $logFile
                                }
                                { $_ -eq 'DOC CERT Scope' -or $_ -eq 'CIT Scope' -or $_ -eq 'Default' -or $_ -eq 'Local DSI' -or $_ -eq 'Package Read Only' -or $_ -eq 'Server Scope' -or $_ -eq 'Workstations' } {
                                    if ($PSBoundParameters['logEntries']) {
                                        New-CMNLogEntry -entry "Adding Production role on $($destinationPackage.Name)" -Type 1 @NewLogEntry
                                    }
                                    Add-CMNRoleOnObject -SCCMConnectionInfo $destinationConnectionInfo -objectID $destinationPackage.PackageID -objectType SMS_Package -roleName 'Production' -logFile $logFile
                                }
                                Default {
                                    if ($scope -in $scopes) {
                                        if ($PSBoundParameters['logEntries']) {
                                            New-CMNLogEntry -entry "Adding $scope to $($destinationPackage.Name)" -Type 1 @NewLogEntry
                                        }
                                        Add-CMNRoleOnObject -SCCMConnectionInfo $destinationConnectionInfo -objectID $destinationPackage.PackageID -objectType SMS_Package -roleName $scope -logFile $logFile
                                    }
                                    else {
                                        if ($PSBoundParameters['logEntries']) {
                                            New-CMNLogEntry -entry "Unable to add $scope to $($destinationPackage.Name)" -Type 3 @NewLogEntry
                                        }
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
                                    if ($PSBoundParameters['logEntries']) {
                                        New-CMNLogEntry -entry "Container $($folder[$x]) exists" -type 1 @NewLogEntry
                                    }
                                    $parentContainerNodeID = $container.ContainerNodeID
                                    $x++
                                }
                                else {
                                    if ($PSBoundParameters['logEntries']) {
                                        New-CMNLogEntry -entry "Container $($folder[$x]) does not exist" -type 1 @NewLogEntry
                                    }
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
                            if ($PSBoundParameters['logEntries']) {
                                New-CMNLogEntry -entry "Package $($destinationPackage.Name) already exists in the root" -type 1 @NewLogEntry
                            }
                        }
                    }
                }
                else {
                    if ($PSBoundParameters['logEntries']) {
                        New-CMNLogEntry -entry "Package $($destinationPackage.Name) already exists in the destination site and OverWriteExisting was not selected" -Type 3 @NewLogEntry
                    }
                    Write-Error "Package $($destinationPackage.Name) already exists in the destination site and OverWriteExisting was not selected"
                }
                Write-Output $destinationPackage
            }
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'End Function' -Type 1 @NewLogEntry
        }
    }
} #End Copy-CMNPackage

Function Copy-CMNPackageDeployment {
    <#
		.SYNOPSIS
            Copies a deployment from one site to another

		.DESCRIPTION
            Copies a deployment from one site to another. You provide the source connection, packageID, program name, also the
            destination connection, packageID, and collection ID. This will copy the deployment to that collection ID.

		.PARAMETER SCCMSourceConnectionInfo
			This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
			Get-CMNSCCMConnectionInfo in a variable and passing that variable.

		.PARAMETER SCCMDestinationConnectionInfo
			This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
			Get-CMNSCCMConnectionInfo in a variable and passing that variable.

        .PARAMETER srcPackageID
            Package ID in source site

        .PARAMETER programName
            Program name to be used in the deployment

        .PARAMETER dstPackageID
            Destination package ID

        .PARAMETER dstCollectionID
            Destination collection ID

		.PARAMETER logFile
			File for writing logs to

		.PARAMETER logEntries
			Switch to say whether or not to create a log file

		.PARAMETER clearlog
			Switch to clear the log file

		.PARAMETER maxLogSize
			Max size for the log. Defaults to 5MB.

		.PARAMETER maxLogHistory
				Specifies the number of history log files to keep, default is 5

		.EXAMPLE

		.LINK
			http://configman-notes.com

		.NOTES
			FileName:    Copy-CMNPackageDeployment.ps1
			Author:      James Parris
			Contact:     jim@ConfigMan-Notes.com
			Created:     2016-03-22
			Updated:     2016-03-22
			Version:     1.0.0

            SMS_Advertisement
            SMS_Package
            SMS_Program
	#>

    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Low')]

    PARAM
    (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Source SCCM Connection Info',
            Position = 1)]
        [PSObject]$SCCMSourceConnectionInfo,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Destination SCCM Connection Info',
            Position = 2)]
        [PSObject]$SCCMDestinationConnectionInfo,

        [Parameter(Mandatory = $true,
            HelpMessage = 'PackageId(s)',
            Position = 3)]
        [String]$srcPackageID,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Program Name',
            Position = 4)]
        [String]$programName,

        [Parameter(Mandatory = $true,
            HelpMessage = 'PackageId(s)',
            Position = 5)]
        [String]$dstPackageID,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Destination Collection ID',
            Position = 6)]
        [String]$dstCollectionID,

        [Parameter(Mandatory = $false,
            HelpMessage = 'LogFile Name',
            Position = 7)]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries',
            Position = 8)]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Clear Log File',
            Position = 9)]
        [Switch]$clearLog,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Max Log size',
            Position = 10)]
        [Int32]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Max number of history logs',
            Position = 11)]
        [Int32]$maxLogHistory = 5
    )

    begin {
        $NewLogEntry = @{
            logFile       = $logFile;
            component     = 'Copy-CMNPackageDeployment';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }
        $WMISourceQueryParameters = @{
            ComputerName = $SCCMSourceConnectionInfo.ComputerName;
            NameSpace    = $SCCMSourceConnectionInfo.NameSpace;
        }
        $WMIDestinationQueryParameters = @{
            ComputerName = $SCCMDestinationConnectionInfo.ComputerName;
            NameSpace    = $SCCMDestinationConnectionInfo.NameSpace;
        }
        if ($PSBoundParameters['clearLog']) {
            if (Test-Path -Path $logFile) {
                Remove-Item -Path $logFile
            }
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        }
    }

    process {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry
        }
        if ($PSCmdlet.ShouldProcess($packageID)) {
            #Verify Source Pacakge
            if ($PSBoundParameters['logEntries']) {
                New-CMNLogEntry -entry 'Verifying source package' -type 1 @NewLogEntry
            }
            $query = "Select * from SMS_Package where PackageID = '$srcPackageID'"
            $srcPackage = Get-WmiObject -Query $query @WMISourceQueryParameters
            if ($srcPackage) {
                if ($PSBoundParameters['logEntries']) {
                    New-CMNLogEntry -entry 'Source package exists, checking that program exists' -type 1 @NewLogEntry
                }
                $query = "SELECT * from SMS_Program where PackageID = '$srcPackageID' and ProgramName = '$programName'"
                $srcProgram = Get-WmiObject -Query $query @WMISourceQueryParameters
                if ($srcProgram) {
                    #Verify Destination Package
                    if ($PSBoundParameters['logEntries']) {
                        New-CMNLogEntry -entry 'Program exists, verifying destination package' -type 1 @NewLogEntry
                    }
                    $query = "Select * from SMS_Package where PackageID = '$dstPackageID'"
                    $dstPackage = Get-WmiObject -Query $query @WMISourceQueryParameters
                    if ($dstPackage) {
                        if ($PSBoundParameters['logEntries']) {
                            New-CMNLogEntry -entry 'Destination package exists, creating deployment' -type 1 @NewLogEntry
                        }
                        $query = "Select * from SMS_Advertisement where PackageID = '$dstPackageID' and ProgramName = '$programName'"
                        $dstDeployment = Get-WmiObject -Query $query @WMIDestinationQueryParameters
                        if (-not ($dstDeployment)) {
                            #Copy deployments to destination
                            $dstDeployment = ([WMIClass]"\\$($SCCMDestinationConnectionInfo.ComputerName)\$($SCCMDestinationConnectionInfo.NameSpace):SMS_Advertisement").CreateInstance()
                            $dstDeployment.ActionInProgress = $srcDeployment.ActionInProgress
                            $dstDeployment.AdvertFlags = $srcDeployment.AdvertFlags
                            $dstDeployment.AdvertisementName = $srcDeployment.AdvertisementName
                            $dstDeployment.AssignedScheduleEnabled = $srcDeployment.AssignedScheduleEnabled
                            $dstDeployment.AssignedScheduleIsGMT = $srcDeployment.AssignedScheduleIsGMT
                            $dstDeployment.CollectionID = $dstCollectionID
                            $dstDeployment.Comment = $srcDeployment.Comment
                            $dstDeployment.ExpirationTime = $srcDeployment.ExpirationTime
                            $dstDeployment.MandatoryCountdown = $srcDeployment.MandatoryCountdown
                            $dstDeployment.PackageID = $dstPackageID
                            $dstDeployment.PresentTime = $srcDeployment.PresentTime
                            $dstDeployment.PresentTimeEnabled = $srcDeployment.PresentTimeEnabled
                            $dstDeployment.PresentTimeIsGMT = $srcDeployment.PresentTimeIsGMT
                            $dstDeployment.Priority = $srcDeployment.Priority
                            $dstDeployment.ProgramName = $programName
                            $dstDeployment.RemoteClientFlags = $srcDeployment.RemoteClientFlags
                            $dstDeployment.TimeFlags = $srcDeployment.TimeFlags
                            $dstDeployment.Put() | Out-Null
                        }
                        else {
                            if ($PSBoundParameters['logEntries']) {
                                New-CMNLogEntry -entry "Deployment already exists on collection $dstCollectionID" -type 2 @NewLogEntry
                            }
                            Throw 'Already exists'
                        }
                    }
                    else {
                        if ($PSBoundParameters['logEntries']) {
                            New-CMNLogEntry -entry 'Destination package does not exist' -type 3 @NewLogEntry
                        }
                        Throw 'Destination Package does not exist'
                    }
                }
                else {
                    if ($PSBoundParameters['logEntries']) {
                        New-CMNLogEntry -entry 'Program does not exist on source package' -type 3 @NewLogEntry
                    }
                    Throw 'Program does not exist on source'
                }
            }
            else {
                if ($PSBoundParameters['logEntries']) {
                    New-CMNLogEntry -entry "Package $srcPackageID does not exist on source" -type 3 @NewLogEntry
                }
                Throw 'Source Package does not exist'
            }
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        }
    }
} #End Copy-CMNPackageDeployment

Function Copy-CMNUpdateSettings {
    <#
	.SYNOPSIS

	.DESCRIPTION

	.PARAMETER SCCMConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.

     .PARAMETER logFile
        File for writing logs to, default is c:\temp\eror.log

    .PARAMETER logEntries
        Switch for logging entries, default is $false

    .PARAMETER maxLogSize
        Max size for the log. Defaults to 5MB.

    .PARAMETER maxHistory
            Specifies the number of history log files to keep, default is 5

 	.EXAMPLE

	.LINK
		http://configman-notes.com

	.NOTES
        Author:	    Jim Parris
        Email:	    Jim@ConfigMan-Notes
        Date:	    2018-05-09
        Updated:
        PSVer:	    3.0
        Version:    1.0.0
	#>

    [CmdletBinding(ConfirmImpact = 'Low')]

    PARAM
    (
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Source Connection Info')]
        [PSObject]$SourceConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Destination Connection Info')]
        [PSObject]$DestinationConnectionInfo,

        [Parameter(Mandatory = $false, HelpMessage = 'Set anything selected in the source site in the destination site')]
        [Switch]$doSet,

        [Parameter(Mandatory = $false, HelpMessage = 'Clear anything not selected in the source site from the destination site')]
        [Switch]$doClear,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int]$maxLogHistory = 5
    )

    Begin {
        if ($PSBoundParameters['logEntries']) {
            $logEntries = $true
        }
        else {
            $logEntries = $false
        }

        #Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'Copy-CMNUpdateSettings';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }
        #Build splats for WMIQueries
        $WMISourceQueryParameters = $SourceConnectionInfo.WMIQueryParameters
        $WMIDestinationQueryParameters = $DestinationConnectionInfo.WMIQueryParameters
        if ($logEntries) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "SourceConnectionInfo = $SourceConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "DestinationConnectionInfo = $DestinationConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "doSet = $doSet" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "doClear = $doClear" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
        }

        #Make sure we have at least one "do" parameter set
        if (!$doClear -and !$doSet) {
            $message = 'You must select doClear and/or doSet'
            if ($logEntries) {
                New-CMNLogEntry -entry $message -type 3 @NewLogEntry
            }
            throw $message
        }
    }

    Process {
        if ($logEntries) {
            New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry
        }
        # Main code part goes here
        $sourceSettings = Get-WmiObject -Class SMS_UpdateCategoryInstance @WMISourceQueryParameters
        $destinationSettings = Get-WmiObject -Class SMS_UpdateCategoryInstance @WMIDestinationQueryParameters
        foreach ($sourceSetting in $sourceSettings) {
            $foundMatch = $false
            if ($logEntries) {
                New-CMNLogEntry -entry "Checking $($sourceSetting.LocalizedCategoryInstanceName)" -type 1 @NewLogEntry
            }
            #Loop through destination settings
            foreach ($destinationSetting in $destinationSettings) {
                if ($sourceSetting.LocalizedCategoryInstanceName -eq $destinationSetting.LocalizedCategoryInstanceName) {
                    $foundMatch = $true
                    if ($sourceSetting.IsSubscribed -ne $destinationSetting.IsSubscribed) {
                        if ($sourceSetting.IsSubscribed -and $doSet) {
                            if ($logEntries) {
                                New-CMNLogEntry -entry "  Setting $($sourceSetting.LocalizedCategoryInstanceName) is being set to $($sourceSetting.IsSubscribed)" -type 1 @NewLogEntry
                            }
                            $destinationSetting.IsSubscribed = $sourceSetting.IsSubscribed
                            $destinationSetting.Put() | Out-Null
                        }
                        else {
                            if (!$sourceSetting.IsSubscribed -and $doClear) {
                                if ($logEntries) {
                                    New-CMNLogEntry -entry "  Setting $($sourceSetting.LocalizedCategoryInstanceName) is being set to $($sourceSetting.IsSubscribed)" -type 1 @NewLogEntry
                                }
                                $destinationSetting.IsSubscribed = $sourceSetting.IsSubscribed
                                $destinationSetting.Put() | Out-Null
                            }
                        }
                    }
                }
            }
            if (-not($foundMatch)) {
                if ($logEntries) {
                    New-CMNLogEntry -entry "  Setting $($sourceSetting.LocalizedCategoryInstanceName) does not appear to be on the destination site." -type 1 @NewLogEntry
                }
                if ($sourceSetting.IsSubscribed -and $logEntries) {
                    New-CMNLogEntry -entry "  It needs to be subscribed to" -type 2 @NewLogEntry
                }
                elseif ($logEntries) {
                    New-CMNLogEntry -entry "  It was not subscribed to." -type 1 @NewLogEntry
                }
            }
        }
    }

    End {
        if ($logEntries) {
            New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        }
    }
} #End Copy-CMNUpdateSettings

Function Get-CMNBitFlagSet {
    <#
		.SYNOPSIS
			This will return the CI_ID of an application

		.DESCRIPTION
			This will return the CI_ID of an application that can be used for other functions

		.EXAMPLE
			Get-CMNApplicationCI_ID -ApplicaitonName 'Orca'

		.PARAMETER SCCMConnectionInfo
			This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
			Get-CMNSCCMConnectionInfo in a variable and passing that variable.

		.PARAMETER FlagsProp
			The value of the bitflag to decode

		.PARAMETER BitFlagHashTable
			This contains the list of the bitflags,

		.EXAMPLE
			Get-CMNBitFlagSet $($SMSAdvert.AdvertFlags) $SMS_Advertisment_AdvertFlags

		.NOTES
			Author:	Jim Parris
			Email:	Jim@ConfigMan-Notes
			Date:	2/25/2016
			PSVer:	2.0/3.0
			Updated:

		.LINK
			http://configman-notes.com
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM(
        [Parameter(Mandatory = $true,
            HelpMessage = 'Hash table of bit flags')]
        [HashTable]$BitFlagHashTable,

        [Parameter(Mandatory = $True,
            HelpMessage = 'CurrentValue to Check')]
        [String]$CurrentValue,

        [Parameter(Mandatory = $false,
            HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries')]
        [Switch]$logEntries = $false,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Max Log size')]
        [Int32]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Max number of history logs')]
        [Int32]$maxLogHistory = 5
    )

    begin {
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'Add-CMNRoleOnObject';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "BitFlagHashTable = $BitFlagHashTable" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "CurrentValue = $CurrentValue" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
        }
    }

    process {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting process loop' -type 1 @NewLogEntry
        }
        $ReturnHashTable = @{ }
        foreach ($keyName in $bitFlagHashTable.GetEnumerator()) {
            if ($PSCmdlet.ShouldProcess($keyName.Key)) {
                if ($CurrentValue -band $keyName.Value) {
                    $ReturnHashTable.Add($keyName.key, $true)
                }
                else {
                    $ReturnHashTable.Add($keyName.key, $false)
                }
            }
        }
    }

    end {
        $obj = New-Object -TypeName PSObject -Property $ReturnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.CMNBitFlagSet')
        Return $obj
    }
} #End Get-CMNBitFlagSet

Function Get-CMNApplicationModelName {
    <#
		.SYNOPSIS
			Returns the ModelName for an application name. If the application doesn't exist, it will return $null

		.DESCRIPTION
			Returns the ModelName for an application name. If the application doesn't exist, it will return $null

		.PARAMETER SCCMConnectionInfo
				This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
				Get-CMNSCCMConnectionInfo in a variable and passing that variable.

		.PARAMETER ApplicationName
			Name of application to get the ModelName for

		.PARAMETER logFile
			File for writing logs to

		.PARAMETER logEntries
			Switch to say whether or not to create a log file

		.PARAMETER ShowProgress
			Show a progressbar displaying the current operation.

		.EXAMPLE

		.LINK
			http://configman-notes.com

		.NOTES
			FileName:    Get-CMNApplicationModelName.ps1
			Author:      James Parris
			Contact:     jim@ConfigMan-Notes.com
			Created:     2017-03-01
			Updated:     2017-03-01
			Version:     1.0.0
	#>

    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Low')]

    PARAM
    (
        [Parameter(Mandatory = $true,
            HelpMessage = 'SCCM Connection Info',
            Position = 1)]
        [Alias('computerName')]
        [Alias('hostName')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(
            Mandatory = $True,
            HelpMessage = 'Application Name',
            ValueFromPipeLine = $true,
            Position = 2)]
        [String]$applicationName,

        [Parameter(Mandatory = $false,
            HelpMessage = 'LogFile Name',
            Position = 3)]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries',
            Position = 4)]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Clear Log File',
            Position = 5)]
        [Switch]$clearLog,

        [parameter(Mandatory = $false,
            HelpMessage = "Show a progressbar displaying the current operation.",
            Position = 6)]
        [Switch]$showProgress
    )
    begin {
        $NewLogEntry = @{
            LogFile   = $logFile;
            Component = 'Get-CMNApplicationModelName'
        }
        $WMIQueryParameters = @{
            ComputerName = $sccmConnectionInfo.ComputerName;
            NameSpace    = $sccmConnectionInfo.NameSpace;
        }
        if ($PSBoundParameters['clearLog']) {
            if (Test-Path -Path $logFile) {
                Remove-Item -Path $logFile
            }
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        }
    }

    process {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry
        }
        if ($PSBoundParameters['showProgress']) {
            $ProgressCount = 0
        }
        if ($PSCmdlet.ShouldProcess($applicationName)) {
            $ReturnHashTable = @{ }
            $App = Get-WmiObject -Class SMS_ApplicationLatest -Filter "LocalizedDisplayName = '$applicationName'" @WMIQueryParameters
            $ReturnHashTable.Add($applicationName, $App.ModelName)
            Return $ReturnHashTable
        }
    }

    end {
        if ($PSBoundParameters['ShowProgress']) {
            Write-Progress -Activity 'Get-CMNApplicationModelName' -Completed
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        }
    }
} #End Get-CMNApplicationModelName

Function Get-CMNAuthorizationListCI_ID {
    <#
		.SYNOPSIS
			This will return the CI_ID of an Authorization List (Software Update Group)

		.DESCRIPTION
			This will return the CI_ID of an Authorization List (Software Update Group) that can be used for other commands

		.PARAMETER SCCMConnectionInfo
			This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
			Get-CMNSCCMConnectionInfo in a variable and passing that variable.

		.PARAMETER AuthorizationList

		.EXAMPLE
			Get-CMNAuthorizationListCI_ID -AuthorizationList 'Windows 7 - 2015 Updates'

		.NOTES
			Author:	Jim Parris
			Email:	Jim@ConfigMan-Notes
			Date:	2/25/2016
			PSVer:	2.0/3.0
			Updated:

		.LINK
			http://configman-notes.com
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM
    (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'SCCM Connection Info')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $True, HelpMessage = 'Application Name')]
        [String[]]$AuthorizationList
    )
    begin {
    }
    process {
        Write-Verbose 'Starting Get-CMNAuthorizationListCI_ID'
        foreach ($AuthList in $AuthorizationList) {
            if ($PSCmdlet.ShouldProcess($AuthList)) {
                $App = Get-WmiObject -Class SMS_AuthorizationList  -Filter "LocalizedDisplayName = '$AuthList'" -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
                Return ($App.CI_ID)
            }
        }
    }
    end {
    }
} #End Get-CMNAuthorizationListCI_ID

Function Get-CMNBitFlagsSet {
    <#
	.SYNOPSIS
		This will take the BitFlagHastTable and return the state of the flags in FlagProp

	.DESCRIPTION
		This will take the BitFlag value you pass and using the BitFlagHashTable, tell you the value of each key
		We have defined the following BitFlagHashTables:
			$SMS_Advertisement_AdvertFlags
			$SMS_Advertisement_DeviceFlags
			$SMS_Advertisement_RemoteClientFlags
			$SMS_Advertisement_TimeFlags
			$SMS_Package_PkgFlags
			$SMS_Program_ProgramFlags

	.EXAMPLE

	.PARAMETER FlagsProp
		The value of the bitflag to decode

	.PARAMETER BitFlagHashTable
		This contains the list of the bitflags,

	.EXAMPLE
		Get-CMNBitFlagSet $($SMSAdvert.AdvertFlags) $SMS_Advertisment_AdvertFlags

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:	2/25/2016
		PSVer:	2.0/3.0
		Updated:

	.LINK
		http://configman-notes.com
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM
    (
        [Parameter(Mandatory = $true)]
        [String]$FlagsProp,

        [Parameter(Mandatory = $true)]
        [HashTable]$BitFlagHashTable
    )
    #New-LogEntry 'Starting Function' 1 Get-CMNBitFlagsSet
    $ReturnHashTable = @{ }
    $BitFlagHashTable.Keys | ForEach-Object { if (($FlagsProp -band $BitFlagHashTable.Item($_)) -ne 0 ) {
            $ReturnHashTable.Add($($_), $true)
        }
        else {
            $ReturnHashTable.Add($($_), $false)
        } }
    #New-LogEntry "Returning $ReturnHashTable" 1 Get-CMNBitFlagsSet
    $obj = New-Object -TypeName PSObject -Property $ReturnHashTable
    $obj.PSObject.TypeNames.Insert(0, 'CMN.BitFlagSet')
    Return $obj
}#End Get-CMNBitFlagsSet

Function Get-CMNClientServiceWindow {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM
    (
        [Parameter(Mandatory = $false)]
        [String]$ComputerName = $env:COMPUTERNAME
    )
    $ReturnObject = New-Object System.Collections.ArrayList
    $ServiceWindows = Get-WmiObject -ComputerName $ComputerName -Class CCM_ServiceWindow -Namespace root\ccm\ClientSDK
    foreach ($ServiceWindow in $ServiceWindows) {
        $Duration = ($ServiceWindow.Duration / 60)
        $StartTime = [System.Management.ManagementDateTimeConverter]::ToDateTime($ServiceWindow.StartTime)
        $EndTime = [System.Management.ManagementDateTimeConverter]::ToDateTime($ServiceWindow.EndTime)
        switch ($ServiceWindow.Type) {
            1 {
                $Type = 'All Programs Service Window'
            }
            2 {
                $Type = 'Program Service Window'
            }
            3 {
                $Type = 'Reboot Required Service Window'
            }
            4 {
                $Type = 'Software Update Service Window'
            }
            5 {
                $Type = 'OSD Service Window'
            }
            6 {
                $Type = 'Non-working hours (Set in Software Center)'
            }
        }
        $ReturnHashTable = @{
            ID        = $ServiceWindow.ID
            Duration  = $Duration;
            StartTime = $StartTime;
            EndTime   = $EndTime;
            Type      = $Type;
        }
        $ReturnObject.Add($ReturnHashTable) | Out-Null
    }
    #$obj = New-Object -TypeName PSObject -Property $ReturnObject
    #$obj.PSObject.TypeNames.Insert(0,'CMN.ClientServiceWindow')
    Return $ReturnObject
}#End Get-CMNClientServiceWindow

Function Get-CMNClientSite {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM
    (
        [Parameter(Mandatory = $true)]
        [String]$MachineName
    )
    $query = "Select * from SMS_R_System where NetBiosName = '$MachineName' and Client =  1 and Obsolete = 0"
    $deviceSP1 = Get-WmiObject -Query $query @WMIQueryParametersSP1
    $deviceSQ1 = Get-WmiObject -Query $query @WMIQueryParametersSQ1
    $deviceWP1 = Get-WmiObject -Query $query @WMIQueryParametersWP1
    $deviceWQ1 = Get-WmiObject -Query $query @WMIQueryParametersWQ1
    $deviceMT1 = Get-WmiObject -Query $query @WMIQueryParametersMT1
    if ($deviceSP1 -or $deviceSQ1 -or $deviceWP1 -or $deviceWQ1 -or $deviceMT1) {
        if ($deviceSP1) {
            $Message = 'SP1'
        }
        elseif ($deviceSQ1) {
            $Message = 'SQ1'
        }
        elseif ($deviceWP1) {
            $Message = 'WP1'
        }
        elseif ($deviceWQ1) {
            $Message = 'WQ1'
        }
        elseif ($deviceMT1) {
            $Message = 'MT1'
        }
        else {
            $Message = 'Error'
        }
    }
    else {
        $Message = 'No Client'
    }
    return $Message
}#End Get-CMNClientSite

Function Get-CMNComputersInCollection {
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

	.PARAMETER maxLogHistory
			Specifies the number of history log files to keep, default is 5

 	.EXAMPLE

	.LINK
		http://configman-notes.com

	.NOTES
		FileName:    Get-CMNComputersInCollection.ps1
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

        [Parameter(Mandatory = $true,
            HelpMessage = 'CollectionID to get list of computers from')]
        [String]$CollectionID,

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
            LogFile       = $logFile;
            Component     = 'Get-CMNComputersInCollection';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }
        #Build splats for WMIQueries
        $WMIQueryParameters = $sccmConnectionInfo.WMIQueryParameters
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "SCCMConnectionInfo = $sccmConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
        }
    }

    process {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry
        }
        if ($PSBoundParameters['showProgress']) {
            $ProgressCount = 0
        }
        # Main code part goes here
        $Query = "select ResourceID from SMS_FullCollectionMembership where CollectionID = '$CollectionID'"
        $ResourceIDs = (Get-WmiObject -Query $Query @WMIQueryParameters).ResourceID
        if ($ResourceIDs.Count -gt 0) {
            $Query = "Select * from SMS_R_SYSTEM where ResourceID in ("
            foreach ($ResourceID in $ResourceIDs) {
                $Query = "$Query'$ResourceID',"
            }
            $Query = "$($Query.Substring(0,$Query.Length - 1)))"
            $Computers = (Get-WmiObject -Query $Query @WMIQueryParameters).Name
        }
        else {
            $Computers = $null
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        }
        Return $Computers
    }
} #End Get-CMNComputersInCollection

Function Get-CMNConnectionString {
    <#
    .Synopsis
        This function will return the connection string

    .DESCRIPTION
        This function will query the database $Database on $DatabaseServer using the $SQLCommand. It uses windows authentication

    .PARAMETER DatabaseServer
        This is the database server that the query will be run on

    .PARAMETER Database
        This is the database on the server to be queried

    .EXAMPLE
		Get-CMNSQLQuery 'DB1' 'DBServer' 'Select * from v_Employees'

    .LINK
        http://configman-notes.com

    .NOTES

    #>
    Param
    (
        [Parameter(Mandatory = $true)]
        [String]$DatabaseServer,
        [Parameter(Mandatory = $true)]
        [String]$Database
    )
    Return "Data Source=$DataBaseServer;Integrated Security=SSPI;Initial Catalog=$Database"
} #End Get-CMNConnectionString

Function Get-CMNDatabaseData {
    <#
    .Synopsis
        This function will query the database specified in the connectionString using the query. If it's a SQL server, isSQLServer should be set to true.

    .DESCRIPTION
        This function will query the database specified in the connectionString using the query. If it's a SQL server, isSQLServer should be set to true.
		This script was taken straight out of Learn PowerShell ToolMaking in a Month of Lunches, it's a great book that I used to develop this module.
		Can be found at http://www.manning.com

    .PARAMETER connectionString
        This is the connectionstring to connect to the SQL server

    .PARAMETER query
        query to be executed to retrieve the data

    .PARAMETER isSQLServer
        Lets us know if it's a SQL server

    .EXAMPLE
		Get-CMNSQLQuery 'Data source=SQLServer1;Integrated Security=SSPI;Initial Catalog=Shopping' 'Select * from v_Employees'

    .LINK
        http://configman-notes.com

    .NOTES

    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$connectionString,
        [Parameter(Mandatory = $true)]
        [string]$query,
        [Parameter(Mandatory = $true)]
        [switch]$isSQLServer
    )
    if ($isSQLServer) {
        Write-Verbose 'in SQL Server mode'
        $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
    }
    else {
        Write-Verbose 'in OleDB mode'
        $connection = New-Object -TypeName System.Data.OleDb.OleDbConnection
    }
    $connection.ConnectionString = $connectionString
    $command = $connection.CreateCommand()
    $command.CommandTimeout = 600
    $command.CommandText = $query
    if ($isSQLServer) {
        $adapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter $command
    }
    else {
        $adapter = New-Object -TypeName System.Data.OleDb.OleDbDataAdapter $command
    }
    $dataset = New-Object -TypeName System.Data.DataSet
    $adapter.Fill($dataset) | Out-Null
    $connection.close()
    return $dataset.Tables[0]
} #End Get-CMNDatabaseData

Function Get-CMNObjectID {
    <#
	.SYNOPSIS
        Gets Member ID for an object

	.DESCRIPTION
		This function will return the Member ID for an object, this can be used in the other functions dealing with containers

	.PARAMETER SCCMConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.

	.PARAMETER ObjectID
		This is the Package/Advertisement/... ID of object to locate

	.PARAMETER ObjectType
		ObjectTypeID for the object you are working with. Valid values are:
			SMS_Package
			SMS_Advertisement
			SMS_Query
			SMS_Report
			SMS_MeteredProductRule
			SMS_ConfigurationItem
			SMS_OperatingSystemInstallPackage
			SMS_StateMigration
			SMS_ImagePackage
			SMS_BootImagePackage
			SMS_TaskSequencePackage
			SMS_DeviceSettingPackage
			SMS_DriverPackage
			SMS_Driver
			SMS_SoftwareUpdate
			SMS_ConfigurationBaselineInfo
			SMS_Collection_Device
			SMS_Collection_User
			SMS_ApplicationLatest
			SMS_ConfigurationItemLatest

	.PARAMETER logFile
		File for writing logs to

    .PARAMETER logEntries
        Switch to say whether or not to create a log file

	.EXAMPLE

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:	2/25/2016
		PSVer:	2.0/3.0
		Updated:
	#>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM
    (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'Package/Advertisement/... ID of object to locate')]
        [string]$ObjectID,

        [Parameter(Mandatory = $true, HelpMessage = 'Object Type')]
        [ValidateSet('SMS_Package', 'SMS_Advertisement', 'SMS_Query', 'SMS_Report', 'SMS_MeteredProductRule', 'SMS_ConfigurationItem', 'SMS_OperatingSystemInstallPackage', 'SMS_StateMigration', 'SMS_ImagePackage', 'SMS_BootImagePackage', 'SMS_TaskSequencePackage', 'SMS_DeviceSettingPackage', 'SMS_DriverPackage', 'SMS_Driver', 'SMS_SoftwareUpdate', 'SMS_ConfigurationBaselineInfo', 'SMS_Collection_Device', 'SMS_Collection_User', 'SMS_ApplicationLatest', 'SMS_ConfigurationItemLatest')]
        [String]$ObjectType,

        [Parameter(Mandatory = $false)]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries')]
        [Switch]$logEntries = $false
    )

    begin {
        $NewLogEntry = @{
            LogFile   = $logFile;
            Component = 'Get-CMNObjectID';
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "ObjectID = $ObjectID" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "ObjectType = $ObjectType" -type 1 @NewLogEntry
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess($ObjectID)) {
            $query = "Select MemberID from SMS_ObjectContainerItem where InstanceKey = '$ObjectID' and ObjectType = '$($ObjectTypetoObjectID[$ObjectType])'"
            $ObjID = (Get-WmiObject -Query $query -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName).MemberID
            if ($ObjID -eq $null -or $ObjID -eq '') {
                $ObjID = 0
            }
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Completing function' -type 1 @NewLogEntry
        }
        Return $ObjID
    }
} #End Get-Get-CMNObjectID

Function Get-CMNObjectContainerNodeID {
    <#
	.SYNOPSIS
        Gets container node ID for an object

	.DESCRIPTION
		This function will return the Node ID for an object, this can be used in the other functions dealing with containers

	.PARAMETER SCCMConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.

	.PARAMETER ObjectID
		This is the Package/Advertisement/... ID of object to locate

	.PARAMETER ObjectType
		ObjectTypeID for the object you are working with. Valid values are:
			SMS_Package
			SMS_Advertisement
			SMS_Query
			SMS_Report
			SMS_MeteredProductRule
			SMS_ConfigurationItem
			SMS_OperatingSystemInstallPackage
			SMS_StateMigration
			SMS_ImagePackage
			SMS_BootImagePackage
			SMS_TaskSequencePackage
			SMS_DeviceSettingPackage
			SMS_DriverPackage
			SMS_Driver
			SMS_SoftwareUpdate
			SMS_ConfigurationBaselineInfo
			SMS_Collection_Device
			SMS_Collection_User
			SMS_ApplicationLatest
			SMS_ConfigurationItemLatest

	.PARAMETER logFile
		File for writing logs to

    .PARAMETER logEntries
        Switch to say whether or not to create a log file

	.EXAMPLE

	.NOTES

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:	2/25/2016
		PSVer:	2.0/3.0
		Updated:
	#>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM
    (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'Package/Advertisement/... ID of object to locate')]
        [string]$ObjectID,

        [Parameter(Mandatory = $true, HelpMessage = 'Object Type')]
        [ValidateSet('SMS_Package', 'SMS_Advertisement', 'SMS_Query', 'SMS_Report', 'SMS_MeteredProductRule', 'SMS_ConfigurationItem', 'SMS_OperatingSystemInstallPackage', 'SMS_StateMigration', 'SMS_ImagePackage', 'SMS_BootImagePackage', 'SMS_TaskSequencePackage', 'SMS_DeviceSettingPackage', 'SMS_DriverPackage', 'SMS_Driver', 'SMS_SoftwareUpdate', 'SMS_ConfigurationBaselineInfo', 'SMS_Collection_Device', 'SMS_Collection_User', 'SMS_ApplicationLatest', 'SMS_ConfigurationItemLatest')]
        [String]$ObjectType,

        [Parameter(Mandatory = $false)]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries')]
        [Switch]$logEntries = $false
    )

    begin {
        $NewLogEntry = @{
            LogFile   = $logFile;
            Component = 'Get-CMNObjectContainerNodeID'
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting function' -type 1 @NewLogEntry
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess($ObjectID)) {
            $query = "Select ContainerNodeID from SMS_ObjectContainerItem where InstanceKey = '$ObjectID' and ObjectType = $($ObjectTypetoObjectID[$ObjectType])"
            if ($PSBoundParameters['logEntries']) {
                New-CMNLogEntry -entry "Query = $query" -type 1 @NewLogEntry
            }
            $ObjID = (Get-WmiObject -Query $query -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName).ContainerNodeID
            if ($PSBoundParameters['logEntries']) {
                New-CMNLogEntry -entry "ObjID = $ObjID" -type 1 @NewLogEntry
            }
            if ($ObjID -eq $null -or $ObjID -eq '') {
                $ObjID = 0
            }
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Completing function' -type 1 @NewLogEntry
        }
        Return $ObjID
    }
} #End Get-CMNObjectContainerNodeID

Function Get-CMNObjectIDsBelowFolder {
    <#
	.SYNOPSIS
		This will return all the ObjectID's of type ObjectType from the branch starting at ContainerID

	.DESCRIPTION

		This function expects the variable $WMIQueryParameters to be used, if you have your site server, you can use the info below
		to get your necessary information:

		$SiteServer = '<InsertServerName>'
		$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

		$WMIQueryParameters = @{
			ComputerName = $SiteServer
			Namespace = "root\sms\site_$SiteCode"

	.PARAMETER SCCMConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.

	.PARAMETER ObjectType
		Type of object you are working with. Valid values are:
			SMS_Package
			SMS_Advertisement
			SMS_Query
			SMS_Report
			SMS_MeteredProductRule
			SMS_ConfigurationItem
			SMS_OperatingSystemInstallPackage
			SMS_StateMigration
			SMS_ImagePackage
			SMS_BootImagePackage
			SMS_TaskSequencePackage
			SMS_DeviceSettingPackage
			SMS_DriverPackage
			SMS_Driver
			SMS_SoftwareUpdate
			SMS_ConfigurationBaselineInfo
			SMS_Collection_Device
			SMS_Collection_User
			SMS_ApplicationLatest
			SMS_ConfigurationItemLatest

	.PARAMETER logFile
		File for writing logs to

    .PARAMETER logEntries
        Switch to say whether or not to create a log file

	.EXAMPLE

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:	2/25/2016
		PSVer:	2.0/3.0
		Updated:
	#>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM
    (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'Parent Container Node ID')]
        [string]$parentContainerNodeID,

        [Parameter(Mandatory = $true)]
        [ValidateSet('SMS_Package', 'SMS_Advertisement', 'SMS_Query', 'SMS_Report', 'SMS_MeteredProductRule', 'SMS_ConfigurationItem', 'SMS_OperatingSystemInstallPackage', 'SMS_StateMigration', 'SMS_ImagePackage', 'SMS_BootImagePackage', 'SMS_TaskSequencePackage', 'SMS_DeviceSettingPackage', 'SMS_DriverPackage', 'SMS_Driver', 'SMS_SoftwareUpdate', 'SMS_ConfigurationBaselineInfo', 'SMS_Collection_Device', 'SMS_Collection_User', 'SMS_ApplicationLatest', 'SMS_ConfigurationItemLatest')]
        [String]$ObjectType,

        [Parameter(Mandatory = $false)]
        [Switch]$Recurse,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'LogFile',
            Position = 6)]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries')]
        [Switch]$logEntries = $false

    )

    begin {
        $NewLogEntry = @{
            LogFile   = $logFile;
            Component = 'Get-CMNObjectFolderPath'
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting function' -type 1 @NewLogEntry
        }
        #Initialize $ObjectIDs
        $ObjectIDs = @()
        #First, get list of items that have this object as a parent and recurse
        $ChildItemIDs = (Get-WmiObject -Class SMS_ObjectContainerNode -Filter "ParentContainerNodeID = '$parentContainerNodeID' and ObjectType = '$($ObjectTypetoObjectID[$ObjectType])'" -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName).ContainerNodeID
    }

    process {
        if ($PSBoundParameters["Recurse"]) {
            foreach ($ChildItemID in $ChildItemIDs) {
                #$ObjectIDs = $ObjectIDs + (Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $sccmConnectionInfo -ObjectID $ChildItemID -ObjectType $ObjectType)
                if ($logEntries.IsPresent) {
                    $ObjectIDs = $ObjectIDs + (Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $sccmConnectionInfo -parentContainerNodeID $ChildItemID -ObjectType $objectType -logFile $logFile -logEntries)
                }
                else {
                    $ObjectIDs = $ObjectIDs + (Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $sccmConnectionInfo -parentContainerNodeID $ChildItemID -ObjectType $objectType -logFile $logFile)
                }
            }
        }

        #Now, get a list of Items in the folder and build array
        $ObjectIDs = $ObjectIDs + (Get-WmiObject -Class SMS_ObjectContainerItem -Filter "ContainerNodeID = '$parentContainerNodeID' and ObjectType = '$($ObjectTypetoObjectID[$ObjectType])'" -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName).InstanceKey
    }

    end {
        #Return Results
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Completing function' -type 1 @NewLogEntry
        }
        Return $ObjectIDs
    }
} #End Get-CMNObjectIDsBelowFolder

Function Get-CMNObjectContainerNodeIDbyName {
    <#
	.SYNOPSIS
        Gets container node ID for an object

	.DESCRIPTION
		This function will return the Node ID for an object, this can be used in the other functions dealing with containers

	.PARAMETER SCCMConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.

	.PARAMETER Name
		This is the name of the object whos container node id you want

	.PARAMETER ObjectType
		ObjectTypeID for the object you are working with. Valid values are:
			SMS_Package
			SMS_Advertisement
			SMS_Query
			SMS_Report
			SMS_MeteredProductRule
			SMS_ConfigurationItem
			SMS_OperatingSystemInstallPackage
			SMS_StateMigration
			SMS_ImagePackage
			SMS_BootImagePackage
			SMS_TaskSequencePackage
			SMS_DeviceSettingPackage
			SMS_DriverPackage
			SMS_Driver
			SMS_SoftwareUpdate
			SMS_ConfigurationBaselineInfo
			SMS_Collection_Device
			SMS_Collection_User
			SMS_ApplicationLatest
			SMS_ConfigurationItemLatest

	.PARAMETER logFile
		File for writing logs to

    .PARAMETER logEntries
        Switch to say whether or not to create a log file

	.EXAMPLE

	.NOTES

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:	2/25/2016
		PSVer:	2.0/3.0
		Updated:
	#>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM
    (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'Name of container to locate in the format folder\folder')]
        [string]$Name,

        [Parameter(Mandatory = $true, HelpMessage = 'Object Type')]
        [ValidateSet('SMS_Package', 'SMS_Advertisement', 'SMS_Query', 'SMS_Report', 'SMS_MeteredProductRule', 'SMS_ConfigurationItem', 'SMS_OperatingSystemInstallPackage', 'SMS_StateMigration', 'SMS_ImagePackage', 'SMS_BootImagePackage', 'SMS_TaskSequencePackage', 'SMS_DeviceSettingPackage', 'SMS_DriverPackage', 'SMS_Driver', 'SMS_SoftwareUpdate', 'SMS_ConfigurationBaselineInfo', 'SMS_Collection_Device', 'SMS_Collection_User', 'SMS_ApplicationLatest', 'SMS_ConfigurationItemLatest')]
        [String]$ObjectType,

        [Parameter(Mandatory = $false)]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries')]
        [Switch]$logEntries = $false
    )

    begin {
        $NewLogEntry = @{
            LogFile   = $logFile;
            Component = 'Get-CMNObjectContainerNodeIDbyName'
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting function' -type 1 @NewLogEntry
        }
    }
    process {
        if ($PSCmdlet.ShouldProcess($Name)) {
            try {
                #Remove any leading '\'
                $containerPath = $Name -replace '^\\(.*)', '$1'
                $containerPath = $containerPath -split '\\'
                $parentContainerID = 0
                foreach ($container in $containerPath) {
                    $cntnr = ConvertTo-CMNWMISingleQuotedString -text $container
                    $query = "SELECT ContainerNodeID from SMS_ObjectContainerNode where Name = '$cntnr' and ObjectType = '$($ObjectTypetoObjectID[$ObjectType])' and ParentContainerNodeID = '$parentContainerID'"
                    $FolderID = Get-WmiObject -Query $query -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
                    if ($FolderID -eq $null) {
                        throw 'Unknown Object'
                    }
                    $parentContainerID = $($FolderID.ContainerNodeID)
                }
            }
            catch {
                Write-Error 'Error resolving folder ID'
                Write-Error "Query = $query"
                #Write-Verbose $Error[0]
            }
        }
        Return $($FolderID.ContainerNodeID)
    }

    end {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Completing function' -type 1 @NewLogEntry
        }
    }
} #End Get-CMNObjectContainerNodeIDbyName

Function Get-CMNObjectFolderPath {
    <#
	.SYNOPSIS

	.DESCRIPTION

		This function expects the variable $WMIQueryParameters to be used, if you have your site server, you can use the info below
		to get your necessary information:

		$SiteServer = '<InsertServerName>'
		$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

	.PARAMETER SCCMConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.

	.Parameter ObjectID
		ID of bottom level container.

	.PARAMETER ObjectType
		ObjectTypeID for the object you are working with. Valid values are:
			SMS_Package
			SMS_Advertisement
			SMS_Query
			SMS_Report
			SMS_MeteredProductRule
			SMS_ConfigurationItem
			SMS_OperatingSystemInstallPackage
			SMS_StateMigration
			SMS_ImagePackage
			SMS_BootImagePackage
			SMS_TaskSequencePackage
			SMS_DeviceSettingPackage
			SMS_DriverPackage
			SMS_Driver
			SMS_SoftwareUpdate
			SMS_ConfigurationBaselineInfo
			SMS_Collection_Device
			SMS_Collection_User
			SMS_ApplicationLatest
			SMS_ConfigurationItemLatest

	.PARAMETER logFile
		File for writing logs to

    .PARAMETER logEntries
        Switch to say whether or not to create a log file

	.EXAMPLE

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:	2/25/2016
		PSVer:	2.0/3.0
		Updated:
		SMS_ObjectContainerNode - Maps Folder name to ConatainerNodeID
		SMS_ObjectContainerItem - Maps ContainerNodeID to CollectionID
	#>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM
    (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'Package/Advertisement/... ID of object to locate')]
        [string]$ObjectID,

        [Parameter(Mandatory = $true, HelpMessage = 'Object Type')]
        [ValidateSet('SMS_Package', 'SMS_Advertisement', 'SMS_Query', 'SMS_Report', 'SMS_MeteredProductRule', 'SMS_ConfigurationItem', 'SMS_OperatingSystemInstallPackage', 'SMS_StateMigration', 'SMS_ImagePackage', 'SMS_BootImagePackage', 'SMS_TaskSequencePackage', 'SMS_DeviceSettingPackage', 'SMS_DriverPackage', 'SMS_Driver', 'SMS_SoftwareUpdate', 'SMS_ConfigurationBaselineInfo', 'SMS_Collection_Device', 'SMS_Collection_User', 'SMS_ApplicationLatest', 'SMS_ConfigurationItemLatest')]
        [String]$ObjectType,

        [Parameter(Mandatory = $false)]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries')]
        [Switch]$logEntries = $false
    )
    begin {
        $NewLogEntry = @{
            LogFile   = $logFile;
            Component = 'Get-CMNObjectFolderPath';
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting function' -type 1 @NewLogEntry
        }
    }

    process {
        $FolderID = Get-WmiObject -Class SMS_ObjectContainerItem -Filter "InstanceKey = '$ObjectID' and ObjectType = '$($ObjectTypetoObjectID[$ObjectType])'" -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
        if ($FolderID) {
            $Folder = Get-WmiObject -Class SMS_ObjectContainerNode -Filter "ContainerNodeID = '$($FolderID.ContainerNodeID)'" -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
            $Path = "$($Folder.Name)\$Path"
            do {
                $Folder = Get-WmiObject -Class SMS_ObjectContainerNode -Filter "ContainerNodeID = '$($Folder.ParentContainerNodeID)'" -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
                $Path = "$($Folder.Name)\$Path"
            } until ($($Folder.ParentContainerNodeID) -eq 0)
        }
        else {
            $Path = '\'
        }
        if (!($Path -match '\^') -and ($Path.Length -ne 1)) {
            $Path = "\$Path"
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Completing function' -type 1 @NewLogEntry
        }
        Return $Path
    }
} #End Get-CMNObjectFolderPath

Function Get-CMNPackageForSoftwareUpdate {
    <#
	.SYNOPSIS

	.DESCRIPTION

		This function expects the variable $WMIQueryParameters to be used, if you have your site server, you can use the info below
		to get your necessary information:

		$SiteServer = '<InsertServerName>'
		$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

		$WMIQueryParameters = @{
			ComputerName = $SiteServer
			Namespace = "root\sms\site_$SiteCode"

	.EXAMPLE

	.PARAMETER RoleName

	.NOTES

	.LINK
		http://configman-notes.com
	#>

    PARAM
    (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $True)]
        [String]$ModelNumber
    )

    $Query = "Select SMS_PackageToContent.PackageID`
	from SMS_SoftwareUpdate`
    JOIN SMS_CIToContent on SMS_SoftwareUpdate.CI_ID = SMS_CIToContent.CI_ID JOIN
	SMS_PackageToContent on SMS_PackageToContent.ContentID = SMS_CIToContent.ContentID`
	WHERE SMS_SoftwareUpdate.ModelName = '$ModelNumber'"

    return (Get-WmiObject -Query $Query @WMIQueryParameters).PackageID
} #End Get-CMNPackageForSoftwareUpdate

Function Get-CMNPatchTuesday {
    <#
	.SYNOPSIS
		Calculates Patch Tuesday for the current month

	.DESCRIPTION
		See Synopsis

	.EXAMPLE
		$PatchTuesday = Get-CMNPatchTuesday
	#>
    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Low')]

    PARAM
    (
        [Parameter(Mandatory = $false,
            HelpMessage = 'Date for the month you want to deterimine patch Tuesday')]
        [DateTime]$date = $(Get-Date)
    )
    #Calculate Patch Tuesday Date
    [DateTime]$StrtDate = Get-Date("$((Get-Date $date).Month)/1/$((Get-Date $date).Year)")
    While ($StrtDate.DayOfWeek -ne 'Tuesday') {
        $StrtDate = $StrtDate.AddDays(1)
    }
    #Now that we know when the first Tuesday is, let's get the second.
    $StrtDate = $StrtDate.AddDays(7)
    Return Get-Date $StrtDate -Format g
} #End Get-CMNPatchTuesday

Function Get-CMNRoleOnApplication {
    <#
	.SYNOPSIS
		This Function will get all the roles on an Application

	.DESCRIPTION
		You provide the applicaoitn CI_ID and it will return the scopes.

	.PARAMETER CI_ID
		The CI_ID of the application you are retreiving the scopes for

	.EXAMPLE
		Get-CMNRoleOnApplicaiton -CI_ID 15342

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:	2/25/2016
		PSVer:	2.0/3.0
		Updated:
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM
    (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Application CI_ID',
            ValueFromPipeLine = $true)]
        [String[]]$CI_ID
    )

    begin {
    }

    process {
        Write-Verbose 'Starting Get-CMNRoleOnApplication'
        foreach ($CIID in $CI_ID) {
            if ($PSCmdlet.ShouldProcess($CIID)) {
                Return (Get-WmiObject -Class SMS_ApplicationLatest -Filter "CI_ID = '$CIID'" @WMIQueryParameters).SecuredScopeNames
            }
        }
    }

    end {
    }
} #End Get-CMNRoleOnApplication

Function Get-CMNRoleOnPackage {
    <#
	.SYNOPSIS
		This Function will get all the roles on a Package

	.DESCRIPTION
		You provide the ObjectID to add the scope to, the Type of object, and the RoleName. If you add a role that already exists,
		the function will behave the same as if the role wasn't there. In either case, the role will be there afterwards.

		This function expects the variable $WMIQueryParameters to be used, if you have your site server, you can use the info below
		to get your necessary information:

		$SiteServer = '<InsertServerName>'
		$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

		$WMIQueryParameters = @{
			ComputerName = $SiteServer
			Namespace = "root\sms\site_$SiteCode"
		}

	.PARAMETER ObjectID
		This is the ID of the object to add the role to (PackageID, DriverID, etc.)

	.PARAMETER ObjectTypeID
		ObjectTypeID for the object you are working with. Valid values are:
			2 - SMS_Package
			3 - SMS_Advertisement
			7 - SMS_Query
			8 - SMS_Report
			9 - SMS_MeteredProductRule
			11 - SMS_ConfigurationItem
			14 - SMS_OperatingSystemInstallPackage
			17 - SMS_StateMigration
			18 - SMS_ImagePackage
			19 - SMS_BootImagePackage
			20 - SMS_TaskSequencePackage
			21 - SMS_DeviceSettingPackage
			23 - SMS_DriverPackage
			25 - SMS_Driver
			1011 - SMS_SoftwareUpdate
			2011 - SMS_ConfigurationBaselineInfo
			5000 - SMS_Collection_Device
			5001 - SMS_Collection_User
			6000 - SMS_ApplicationLatest
			6001 - SMS_ConfigurationItemLatest

	.PARAMETER RoleName
		The Role to add to the Object

	.EXAMPLE
		Add-CMNRoleOnObject 'CAS003F2' 2 'Workstations'

		This will add the Workstations Role to PackageID CAS003F2

	.EXAMPLE
		'CAS003F2' | Add-CMNRoleOnObject -ObjectTypeID 2 -RoleName 'Workstations'

		This will add the Workstations role to PacakgeID CAS003F2

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:	2/25/2016
		PSVer:	2.0/3.0
		Updated:
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM
    (
        [Parameter(Mandatory = $true,
            HelpMessage = 'PackageID to get roles on',
            ValueFromPipeLine = $true)]
        [String[]]$PackageID
    )

    begin {
    }

    process {
        Write-Verbose 'Starting Get-CMNRoleOnPackage'
        foreach ($PkgID in $PackageID) {
            if ($PSCmdlet.ShouldProcess($PkgID)) {
                Return (Get-WmiObject -Class SMS_Package -Filter "PackageID = '$PkgID'" @WMIQueryParameters).SecuredScopeNames
            }
        }
    }

    end {
    }
} #End Get-CMNRoleOnPackage

Function Get-CMNSCCMConnectionInfo {
    <#
	.SYNOPSIS
		Returns a hashtable to containing the SCCMDBServer (Site Database Server), SCCMDB (Site Database),
		ComputerName (Site Server), SiteCode (Site Code), and NameSpace (WMI NameSpace)

	.DESCRIPTION
		This function creates a hashtable with the necessary information used by a variety of my functions.
		Whenever a function has to talk to an SCCM site, it expects to be passed this hastable so it knows the
		connection information

	.PARAMETER SiteServer
		This is the siteserver for the site you want to connect to.

	.PARAMETER logFile
		File for writing logs to.

    .PARAMETER logEntries
        Switch to say whether or not to create a log file

    .PARAMETER maxLogSize
		Specifies, in bytes, how large the file should be before rolling log over.

	.EXAMPLE
		Get-CMNSccmConnctionInfo -SiteServer Server01

	.LINK
		http://configman-notes.com

	.NOTES
		Author:      James Parris
		Contact:     jim@ConfigMan-Notes.com
		Created:     2016-11-07
		Updated:
		Version:     1.0.0
	#>

    param
    (
        [Parameter(Mandatory = $true,
            HelpMessage = "Site server where the SMS Provider is installed.",
            Position = 1)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Connection -ComputerName $_ -Count 1 -Quiet })]
        [string]$siteServer,

        [Parameter(Mandatory = $false,
            HelpMessage = 'LogFile Name',
            Position = 2)]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries',
            Position = 3)]
        [Switch]$logEntries = $false,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Max Log size',
            Position = 4)]
        [Int32]$MaxLogSize = 5242880
    )

    begin {
        #Build splat for log entries
        $NewLogEntry = @{
            LogFile    = $logFile;
            Component  = 'Get-CMNSCCMConnectionInfo';
            MaxLogSize = $MaxLogSize;
        }
        #Write to the log if we're supposed to!
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        }
    }

    process {
        #Get the site code from the site server
        $siteCode = $(Get-WmiObject -ComputerName $siteServer -Namespace 'root/SMS' -Class SMS_ProviderLocation -ErrorAction SilentlyContinue).SiteCode | Select-Object -Unique
        #if we don't get a result, we have a problem.
        if (-not($SiteCode)) {
            if ($PSBoundParameters['logEntries']) {
                New-CMNLogEntry -entry "Unable to connect to Site Server $SiteServer" -type 3 @NewLogEntry
            }
            throw "Unable to connect to Site Server $siteServer"
            break
        }
        #Now, to determine the SQL Server and database being used for the site.
        $DataSourceWMI = $(Get-WmiObject -Class SMS_SiteSystemSummarizer -Namespace root/sms/site_$siteCode -ComputerName $siteServer -Filter "Role = 'SMS SQL SERVER' and SiteCode = '$siteCode' and ObjectType = 1").SiteObject | Select-Object -Unique
        $SCCMDBServer = $DataSourceWMI -replace '.*\\\\([A-Z0-9_.]+)\\.*', '$+'
        $SCCMDB = $DataSourceWMI -replace ".*\\([A-Z_0-9]*?)\\$", '$+'
        #Now, we've got our data, time to return some results!
        $ReturnHashTable = @{
            SCCMDBServer       = $SCCMDBServer;
            SCCMDB             = $SCCMDB;
            SiteCode           = $SiteCode;
            ComputerName       = $SiteServer;
            NameSpace          = "Root/SMS/Site_$siteCode";
            WMIQueryParameters = @{
                Namespace    = "Root/SMS/Site_$siteCode";
                ComputerName = $SiteServer;
            }
        }
        #Let's put our TypeName on the results
        $obj = New-Object -TypeName PSObject -Property $ReturnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.SCCMConnectionInfo')
        #Log if if we're supposed to!
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry "SCCMDBServer = $SCCMDBServer" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "SCCMDB = $SCCMDB" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "SiteCode = $siteCode" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "ComputerName = $siteServer" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "NameSpace = Root/SMS/Site_$siteCode" -type 1 @NewLogEntry
        }
    }

    end {
        #Done! Log it!
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        }
        Return $obj
    }
} #End Get-CMNSCCMConnectionInfo

Function Get-CMNServerNameFromRole {
    <#
	https://blogs.technet.microsoft.com/heyscriptingguy/2014/03/21/use-dynamic-parameters-to-populate-list-of-printer-names/
	#>
    PARAM
    (
        #[Parameter(Mandatory=$true)]
        #[ValidateSet()]
    )
}#End Get-CMNServerNameFromRole

Function Get-CMNSiteSystems {
    <#
	.SYNOPSIS
		This will return all the site systems of the role you request

	.DESCRIPTION
		This will return all the site systems of the role you request

	.PARAMETER SCCMConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.

	.PARAMETER role
		Specifies the role you are searching for, valid values are:
		'SMS Application Web Service','SMS Component Server','SMS Distribution Point',
		'SMS Dmp Connector','SMS Fallback Status Point','SMS Management Point',
		'SMS Portal Web Site','SMS Site Server','SMS Software Update Point',
		'SMS SQL Server','SMS SRS Reporting Point'

    .PARAMETER logFile
        File for writing logs to, default is c:\temp\eror.log

    .PARAMETER logEntries
        Switch for logging entries, default is $false

    .PARAMETER maxLogSize
        Max size for the log. Defaults to 5MB.

    .PARAMETER maxHistory
            Specifies the number of history log files to keep, default is 5

 	.EXAMPLE

	.LINK
		http://configman-notes.com

	.NOTES
        Author:	    Jim Parris
        Email:	    Jim@ConfigMan-Notes
		Date:     	2018-04-25
		Updated:
        PSVer:	    3.0
		Version:    1.0.0
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]

    PARAM	(
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'Role you are looking for')]
        [ValidateSet('SMS Application Web Service', 'SMS Component Server', 'SMS Distribution Point', 'SMS Dmp Connector', 'SMS Fallback Status Point', 'SMS Management Point', 'SMS Portal Web Site', 'SMS Site Server', 'SMS Software Update Point', 'SMS SQL Server', 'SMS SRS Reporting Point')]
        [String]$role,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int32]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int32]$maxHistory = 5
    )

    begin {
        #Build splat for log entries
        $NewLogEntry = @{
            LogFile    = $logFile;
            Component  = 'Get-CMNSiteSystems';
            maxLogSize = $maxLogSize;
            maxHistory = $maxHistory;
        }
        #Build splat for WMIQueries
        $WMIQueryParameters = $sccmConnectionInfo.WMIQueryParameters

        # Create a hashtable with your output info
        $returnHashTable = @{ }

        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "SCCMConnectionInfo = $sccmConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxHistory = $maxHistory" -type 1 @NewLogEntry
        }
    }

    process {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry
        }
        if ($PSCmdlet.shouldprocess($role)) {
            $query = "Select * from SMS_SiteSystemSummarizer where Role = '$role'"
            $SiteSystems = (Get-WmiObject -Query $query @WMIQueryParameters).SiteSystem -replace '.*\\(.*)\\.*', '$1' | Sort-Object -Unique
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry "Returning:" -type 1 @NewLogEntry
            New-CMNLogEntry -entry $SiteSystems -type 1 @NewLogEntry
            New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        }
        Return $SiteSystems
    }
} #End Get-CMNSiteSystems

Function Get-CMNMWStartTime {
    <#
	.SYNOPSIS
		This function will calculate the Maintenance Window Start Time

	.DESCRIPTION
		Using the collection name, it will start the Maintenance

	.PARAMETER Collection
		Collection name to figure out the maintenance window for.

	.PARAMETER MaintenanceWindowDuration
		This is how long, in hours, your maintenance window is. This can be from 1 to 6 hours, default is 4. The validation check is done in the initial set of parameters,
		I did not do it here also.
	.PARAMETER PatchTuesday
		The date for Patch Tuesday

	.EXAMPLE
		$StartDateTime = Get-CMNMWStartTime 'Patch Day 03 - Reboot 03:00' 4 $PatchTuesday

		This will get the startdate for a collection Named Patch Day 03 - Reboot 03:00. It will have a four hour duration and end at 3:00AM

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:	2/25/2016
		PSVer:	2.0/3.0
		Updated:
	#>

    PARAM
    (
        [Parameter(Mandatory = $True)]
        [String]$Collection,
        [Parameter(Mandatory = $True)]
        [Int32]$MaintenanceWindowDuration,
        [Parameter(Mandatory = $True)]
        [DateTime]$PatchTuesday
    )

    $Collection -match '\d{1,2}:\d{1,2}.?([AP]M)' | Out-Null
    $Meridian = $Matches[1]

    $Collection -match 'Patch Day ([0-9]*).*' | Out-Null
    [int32]$Day = $Matches[1]

    $Collection -match '(\d{1,2}):(\d{1,2})' | Out-Null
    [Single]$Mn = $Matches[2]
    [Single]$Hr = $Matches[1]
    if (($Hr -lt 12) -and ($Meridian -eq 'PM')) {
        $Hr += 12
        if ($Hr -ge 24) {
            $Hr -= 24
        }
    }
    $DecTime = $Hr + ($Mn / 60)
    $StartDateTIme = $PatchTuesday.AddDays($Day)
    $StartDateTIme = $StartDateTIme.AddHours($Hr - $MaintenanceWindowDuration)
    $StartDateTIme = $StartDateTIme.AddMinutes($Mn)
    if ($DecTime -gt $MaintenanceWindowDuration) {
        $StartDateTIme = $StartDateTIme.AddDays(-1)
    }
    Return $StartDateTIme
} #End Get-CMNMWStartTime

Function Get-CMNUpdates {
    Param
    (
        [Parameter(Mandatory = $true)]
        [String]$SUG,

        [Parameter(Mandatory = $true)]
        [String]$PackageSourcePath,

        [Parameter(Mandatory = $true)]
        [String]$DPGroupName,

        [Parameter(Mandatory = $true)]
        [String[]]$UpdateList
    )

    begin {
        #Test for PackageSourcePath
        if (-not (Test-Path $PackageSourcePath)) {
            Throw "Unknown Path - $PackageSourcePath"
        }

        #Test for DP Group
        $DPGroup = Get-WmiObject -Class SMS_DistributionPointGroup -Filter "name = '$DPGroupName'" @WMIQueryParameters
        if (-not $DPGroup) {
            Throw "Unknown Distribution Point Group - $DPGroup"
        }
    }

    process {
        #       Function Set-CMNUpdateDeploymentPackage{
        # This function creates and distributes the Deployment Package
        $PKGPath = "$PackageSourcePath$SUG"
        $DeployPackage = ([WMIClass]"\\$($SccmConnectInfo.ComputerName)\$($SccmConnectInfo.NameSpace):SMS_SoftwareUpdatesPackage").CreateInstance()
        $DeployPackage.Name = $SUG
        $DeployPackage.SourceSite = $SccmConnectInfo.SiteCode
        $DeployPackage.PkgSourcePath = $PKGPath
        $DeployPackage.Description = "$SUG"
        $DeployPackage.PkgSourceFlag = [int32]2 #Value of 2 -->Stores Software Updates

        $DeployPackage.put()

        $DeployPackage.get()
        $contentsourcepath = Get-ChildItem  -path $PKGPath | Select-Object -ExpandProperty Fullname
        $allContentIDs = $contentsourcepath | ForEach-Object { Split-Path  -Path $_ -Leaf }
        $DeployPackage.AddUpdateContent($allContentIDs, $contentsourcepath, $true)
        $DPGroup = Get-WmiObject -Class SMS_DistributionPointGroup -Filter "name = '$DPGroupName'" @WMIQueryParameters
        $DPGroup.AddPackages($DeployPackage.PackageID)
        #    } #End Set-CMNUpdateDeploymentPackage

        #Create a new PSDrive where the Patches will be downloaded
        if (-not $PackageSourcePath -match '\\$') {
            $PackageSourcePath = "$PackageSourcePath\"
        }
        New-PSDrive -Name M -PSProvider FileSystem -Root "$PackageSourcePath" | Out-Null
        $DownloadPath = "M:\$SUG"
        if (-not (Test-Path M:\$SUG)) {
            New-Item -Path "M:\$SUG" -ItemType directory
        }

        $DownloadInfo = foreach ($CI_ID in $UpdateList) {
            $contentID = Get-WmiObject -Query "Select ContentID,ContentUniqueID,ContentLocales from SMS_CITOContent Where CI_ID='$CI_ID'"  @WMIQueryParameters
            #Filter out the English Local and ContentID's not targeted to a particular Language
            $contentID = $contentID | Where-Object { ($_.ContentLocales -eq "Locale:9") -or ($_.ContentLocales -eq "Locale:0") }

            foreach ($id in $contentID) {
                $contentFile = Get-WmiObject -Query "Select FileName,SourceURL from SMS_CIContentfiles WHERE ContentID='$($ID.ContentID)'" @WMIQueryParameters
                [pscustomobject]@{Source = $contentFile.SourceURL ;
                    Destination          = "$DownloadPath\$($id.ContentID)\$($contentFile.FileName)";
                }
            }
        }

        $DownloadInfo.destination |
        ForEach-Object -process {
            If (! (Test-Path -Path "filesystem::$(Split-Path -Path $_)")) {
                New-Item -ItemType directory -Path "$(Split-Path -Path $_)"
            }
        }
        $DownloadInfo | Start-BitsTransfer

        Set-CMNUpdateDeploymentPackage $SUG $UpdateList
        $DownloadInfo.destination |`
            ForEach-Object -Process `
        {
            if (Test-Path (Split-Path -path $_)) {
                Remove-Item -Path (Split-Path -path $_) -Recurse -verbose
            }
        }
    }

    end {
    }
} #End Get-CMNUpdates

Function Invoke-CMNDatabaseQuery {
    <#
    .Synopsis
        This function will query the database $Database on $DatabaseServer using the $SQLCommand

    .DESCRIPTION
        This function will query the database $Database on $DatabaseServer using the $SQLCommand. It uses windows authentication

    .PARAMETER connectionString
        This is the database server that the query will be run on

    .PARAMETER query
        This is the query to be run

    .PARAMETER isSQLServer
        This is the query to be run

    .EXAMPLE
		Get-CMNSQLQuery 'DB1' 'DBServer' 'Select * from v_Employees'

    .LINK
        http://configman-notes.com

    .NOTES

    #>

    [CmdletBinding(SupportsShouldProcess = $True,
        ConfirmImpact = 'Low')]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$connectionString,
        [Parameter(Mandatory = $true)]
        [string]$query,
        [Parameter(Mandatory = $true)]
        [switch]$isSQLServer
    )
    if ($isSQLServer) {
        Write-Verbose 'in SQL Server mode'
        $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
    }
    else {
        Write-Verbose 'in OleDB mode'
        $connection = New-Object -TypeName System.Data.OleDb.OleDbConnection
    }
    $connection.ConnectionString = $connectionString
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    if ($pscmdlet.shouldprocess($query)) {
        $connection.Open()
        $command.ExecuteNonQuery() | Out-Null
        $connection.close()
    }
} #End Invoke-CMNDatabaseQuery

Function Move-CMNApplication {
    <#
	.SYNOPSIS

	.DESCRIPTION

	.EXAMPLE

	.PARAMETER Text

	.NOTES
		Not currently working
	.LINK
		http://configman-notes.com
	#>
    Param
    (
        [Parameter(Mandatory = $true)]
        [PSObject]$MoveDeployment
    )
    #New-LogEntry 'Starting Function' 1 'Move-CMNApplication'
    #DeploymentType 1 = install, 2=uninstall
    $objApplication = Get-CMApplication -Id $MoveDeployment.CI_ID
    $objDeployment = Get-WmiObject @WMIQueryParameters -class SMS_DeploymentInfo -Filter "DeploymentID = '$($MoveDeployment.DeploymentID)'"
    $objDeployment.Get()
    if ($MoveApplications -and ($objDeployment.DeploymentIntent -eq 2 -or ($objDeployment.DeploymentIntent -eq 3 -and $MoveRequired))) {
        if ($CopyDeployment) {
            try {
                $NewDeployment = ([WMICLASS]"\\$($SiteServer)\root\sms\site_$($SiteCode):SMS_DeploymentInfo").CreateInstance()
                $NewDeployment.CollectionID = $ToCollectionID;
                $NewDeployment.CollectionName = $MoveDeployment.CollectionName;
                $NewDeployment.DeploymentIntent = $objDeployment.DeploymentIntent;
                $NewDeployment.DeploymentType = $objDeployment.DeploymentType;
                $NewDeployment.TargetID = $objDeployment.TargetID;
                $NewDeployment.TargetName = $objDeployment.TargetName
                $NewDeployment.TargetSecurityTypeID = $objDeployment.TargetSecurityTypeID;
                $NewDeployment.TargetSubName = $objDeployment.TargetSubName;
                $NewDeployment.Put() | Out-Null
            }
            catch [system.exception] {
                Write-Error "Had an error - Not copying deployment $($objAdvertisment.PackageID) - $($objAdvertisment.AdvertisementID)."
            }
        }
        else {
            try {
                $objDeployment.CollectionID = $ToCollectionID
                $objDeployment.put() | Out-Null
            }
            catch [system.exception] {
                Write-Error "Had an error - Not moving deployment $($objDeployment.DeploymentID) - $($objAdvertisment.AdvertisementID)."
            }
        }
    }
} # End Move-CMNApplication

Function Move-CMNObject {
    <#
	.SYNOPSIS
        Moves an object to the container

	.DESCRIPTION
		This function will return the Node ID for an object, this can be used in the other functions dealing with containers

	.PARAMETER SCCMConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.

	.PARAMETER Name
		This is the name of the object whos container node id you want

	.PARAMETER ObjectType
		ObjectTypeID for the object you are working with. Valid values are:
			SMS_Package
			SMS_Advertisement
			SMS_Query
			SMS_Report
			SMS_MeteredProductRule
			SMS_ConfigurationItem
			SMS_OperatingSystemInstallPackage
			SMS_StateMigration
			SMS_ImagePackage
			SMS_BootImagePackage
			SMS_TaskSequencePackage
			SMS_DeviceSettingPackage
			SMS_DriverPackage
			SMS_Driver
			SMS_SoftwareUpdate
			SMS_ConfigurationBaselineInfo
			SMS_Collection_Device
			SMS_Collection_User
			SMS_ApplicationLatest
			SMS_ConfigurationItemLatest

	.EXAMPLE

	.NOTES

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:	2/25/2016
		PSVer:	2.0/3.0
		Updated:
	#>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM
    (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'PackageID of object to move')]
        [string]$objectID,

        [Parameter(Mandatory = $true, HelpMessage = 'ObjectID of destination container')]
        [Int32]$destinationContainerID,

        [Parameter(Mandatory = $true, HelpMessage = 'Object Type')]
        [ValidateSet('SMS_Package', 'SMS_Advertisement', 'SMS_Query', 'SMS_Report', 'SMS_MeteredProductRule', 'SMS_ConfigurationItem', 'SMS_OperatingSystemInstallPackage', 'SMS_StateMigration', 'SMS_ImagePackage', 'SMS_BootImagePackage', 'SMS_TaskSequencePackage', 'SMS_DeviceSettingPackage', 'SMS_DriverPackage', 'SMS_Driver', 'SMS_SoftwareUpdate', 'SMS_ConfigurationBaselineInfo', 'SMS_Collection_Device', 'SMS_Collection_User', 'SMS_ApplicationLatest', 'SMS_ConfigurationItemLatest')]
        [String]$objectType
    )

    begin {
    }

    process {
        if ($PSCmdlet.ShouldProcess($objectID)) {
            $sourceContainerID = (Get-WmiObject -Class SMS_ObjectContainerItem -Filter "InstanceKey = '$objectID' and ObjectType = '$($ObjectTypetoObjectID[$objectType])'" -Namespace $sccmConnectionInfo.NameSpace -ComputerName ($sccmConnectionInfo.ComputerName)).ContainerNodeID
            if ($sourceContainerID -eq $null -or $sourceContainerID -eq '') {
                $sourceContainerID = 0
            }
            Invoke-WmiMethod -Class SMS_ObjectContainerItem -Name MoveMembers -ArgumentList $sourceContainerID, $objectID, $ObjectTypetoObjectID[$objectType], $destinationContainerID -Namespace $sccmConnectionInfo.NameSpace -ComputerName ($sccmConnectionInfo.ComputerName)
        }
    }

    end {
    }
} # End Move-CMNObject

Function Move-CMNProgram {
    <#
	.SYNOPSIS

	.DESCRIPTION

	.EXAMPLE

	.PARAMETER Text

	.NOTES
		Not currently working
	.LINK
		http://configman-notes.com
	#>
    Param
    (
        [Parameter(Mandatory = $true)]
        [PSObject]$MoveDeployment,

        [Parameter(Mandatory = $false)]
        [Switch]$CopyDeployment = $false
    )
    $Error.Clear()
    $objAdvertisment = Get-WmiObject @WMIQueryParameters -class SMS_Advertisement -Filter "AdvertisementID = '$($MoveDeployment.DeploymentID)'"
    $objAdvertisment.Get()
    if ($CopyDeployment) {
        try {
            $NewDeployment = ([WMICLASS]"\\$($SiteServer)\root\sms\site_$($SiteCode):SMS_Advertisement").CreateInstance()
            $NewDeployment.ActionInProgress = $objAdvertisment.ActionInProgress
            $NewDeployment.AdvertFlags = $objAdvertisment.AdvertFlags;
            $NewDeployment.AdvertisementName = $objAdvertisment.AdvertisementName;
            $NewDeployment.AssignedSchedule = $objAdvertisment.AssignedSchedule;
            $NewDeployment.AssignedScheduleEnabled = $objAdvertisment.AssignedScheduleEnabled;
            $NewDeployment.AssignedScheduleIsGMT = $objAdvertisment.AssignedScheduleIsGMT;
            $NewDeployment.CollectionID = $ToCollectionID;
            $NewDeployment.Comment = $objAdvertisment.Comment;
            $NewDeployment.DeviceFlags = $objAdvertisment.DeviceFlags;
            $NewDeployment.ExpirationTime = $objAdvertisment.ExpirationTime;
            $NewDeployment.ExpirationTimeEnabled = $objAdvertisment.ExpirationTimeEnabled;
            $NewDeployment.HierarchyPath = $objAdvertisment.HierarchyPath
            $NewDeployment.IncludeSubCollection = $objAdvertisment.IncludeSubCollection;
            $NewDeployment.ISVData = $objAdvertisment.ISVData;
            $NewDeployment.ISVDataSize = $objAdvertisment.ISVDataSize;
            $NewDeployment.IsVersionCompatible = $objAdvertisment.IsVersionCompatible;
            $NewDeployment.MandatoryCountdown = $objAdvertisment.MandatoryCountdown;
            $NewDeployment.OfferType = $objAdvertisment.OfferType;
            $NewDeployment.PackageID = $objAdvertisment.PackageID;
            $NewDeployment.PresentTime = $objAdvertisment.PresentTime;
            $NewDeployment.PresentTimeEnabled = $objAdvertisment.PresentTimeEnabled;
            $NewDeployment.PresentTimeIsGMT = $objAdvertisment.PresentTimeIsGMT;
            $NewDeployment.Priority = $objAdvertisment.Priority;
            $NewDeployment.ProgramName = $objAdvertisment.ProgramName;
            $NewDeployment.RemoteClientFlags = $objAdvertisment.RemoteClientFlags;
            $NewDeployment.SourceSite = $objAdvertisment.SourceSite;
            $NewDeployment.TimeFlags = $objAdvertisment.TimeFlags
            $NewDeployment.Put() | Out-Null
        }
        catch [system.exception] {
            Throw "Had an error - Not copying deployment $($objAdvertisment.PackageID) - $($objAdvertisment.AdvertisementID). Error $Error"
        }
    }
    else {
        try {
            $objAdvertisment.CollectionID = $ToCollectionID
            $objAdvertisment.put() | Out-Null
        }
        catch [system.exception] {
            Throw "Had an error - Not moving deployment $($objAdvertisment.PackageID) - $($objAdvertisment.AdvertisementID). Error $Error"
        }
    }
} # End Move-CMNProgram

Function New-CMNDailySchedule {
    <#
		.SYNOPSIS
			Returns a SMS_ST_RecurInterval object for a non-repeating schedule.

		.DESCRIPTION

		.PARAMETER Text

		.PARAMETER logFile
			File for writing logs to

		.PARAMETER logEntries
			Switch to say whether or not to create a log file

		.EXAMPLE

		.NOTES

		.LINK
			http://configman-notes.com
	#>
    Param
    (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'Collection ID')]
        [String]$collectionID,

        [Parameter(Mandatory = $false, HelpMessage = 'Start time')]
        [DateTime]$startTime
    )

    $collection = Get-WmiObject -Class SMS_Collection -Filter "CollectionID = '$collectionID'" -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
    if ($collection) {
        $ScheduleTime = ([WMIClass] "\\$($sccmConnectionInfo.ComputerName)\$($sccmConnectionInfo.NameSpace):SMS_ST_RecurInterval").CreateInstance()

        $ScheduleTime.DayDuration = 0
        $ScheduleTime.DaySpan = 1
        $ScheduleTime.HourDuration = 0
        $ScheduleTime.HourSpan = 0
        $ScheduleTime.MinuteDuration = 0
        $ScheduleTime.MinuteSpan = 0
        $ScheduleTime.IsGMT = $false
        $ScheduleTime.StartTime = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime((Get-Date $startTime -Format "MM/dd/yyy hh:mm:ss"))
        $collection.Get()
        $collection.RefreshType = 2
        $collection.RefreshSchedule = $ScheduleTime
        $collection.Put()
        $collection.RequestRefresh()
    }
    else {
        Write-Verbose "Collection $collectionID does not exist"
    }
} #End New-CMNDailySchedule

Function New-CMNDeviceCollection {
    <#
	.SYNOPSIS

	.DESCRIPTION

	.PARAMETER SCCMConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.

	.EXAMPLE

	.NOTES

	.LINK
		http://configman-notes.com
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM
    (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true)]
        [String]$comment,

        [Parameter(Mandatory = $true)]
        [String]$limitToCollectionID,

        [Parameter(Mandatory = $true)]
        [String]$name
    )

    begin {
    }

    process {
        if ($PSCmdlet.ShouldProcess($Name)) {
            $LimitingCollection = Get-WmiObject -Class SMS_Collection -Filter "CollectionID = '$LimitToCollectionID'" -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
            $SCCMCollection = ([WMIClass]"\\$($sccmConnectionInfo.ComputerName)\root\SMS\Site_$($sccmConnectionInfo.SiteCode):SMS_Collection").CreateInstance()
            $SCCMCollection.CollectionType = 2
            $SCCMCollection.Comment = $Comment
            $SCCMCollection.Name = $Name
            $SCCMCollection.LimitToCollectionID = ($LimitingCollection.CollectionID)
            $SCCMCollection.LimitToCollectionName = ($LimitingCollection.Name)
            $SCCMCollection.RefreshType = 1 #Manual
            $SCCMCollection.Put()
            $SCCMCollection.Get()
            #$SCCMCollection.PSObject.TypeNames.Insert(0,'CMN.BitFlagSet')
        }
    }

    end {
        return $SCCMCollection
    }
} #End New-CMDeviceCollection

Function New-CMNDeviceCollectionDirectMemberRule {
    <#
		.SYNOPSIS

		.DESCRIPTION

		.PARAMETER Text

		.PARAMETER logFile
			File for writing logs to

		.PARAMETER logEntries
			Switch to say whether or not to create a log file

		.EXAMPLE

		.NOTES

		.LINK
			http://configman-notes.com
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM
    (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true)]
        [String]$collectionID,

        [Parameter(Mandatory = $true)]
        [String[]]$netbiosNames,

        [Parameter(Mandatory = $false)]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries')]
        [Switch]$logEntries = $false
    )
    begin {
        $NewLogEntry = @{
            LogFile   = $logFile;
            Component = 'New-CMNDeviceCollectionDirectMemberRule'
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -Type 1 @NewLogEntry
        }
        $query = "Select * from SMS_Collection where CollectionID = '$collectionID'"
        $collection = Get-WmiObject -Query $query -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
    }

    process {
        foreach ($netbiosName in $netbiosNames) {
            if ($PSCmdlet.ShouldProcess($netbiosName)) {
                if ($PSBoundParameters['logEntries']) {
                    New-CMNLogEntry -entry "Adding $netbiosName" -type 1 @NewLogEntry
                }
                $query = "Select ResourceID from SMS_R_System where NetbiosName = '$netbiosName' and Active = 1 and Client = 1 and Obsolete = 0"
                $system = Get-WmiObject -Query $query -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
                if ($system) {
                    try {
                        $directMemberRule = ([WMIClass]"//$($sccmConnectionInfo.ComputerName)/$($sccmConnectionInfo.NameSpace):SMS_CollectionRuleDirect").CreateInstance()
                        $directMemberRule.ResourceClassName = 'SMS_R_System'
                        $directMemberRule.ResourceID = ($System.ResourceID)
                        $directMemberRule.RuleName = $NetbiosName
                        $addRules += [Array]$directMemberRule
                    }
                    catch {
                        if ($PSBoundParameters['logEntries']) {
                            New-CMNLogEntry -entry "Unable to add $($System.ResourceID) - $NetbiosName" -Type 3 @NewLogEntry
                        }
                        Write-Error "Unable to add $($System.ResourceID) - $NetbiosName"
                    }
                }
                else {
                    if ($PSBoundParameters['logEntries']) {
                        New-CMNLogEntry -entry "Unable to add $NetbiosName to $($Collection.Name)" -type 3 @NewLogEntry
                    }
                }
            }
        }
    }

    end {
        if ($addRules) {
            if ($PSBoundParameters['logEntries']) {
                New-CMNLogEntry -entry "Adding Rules to $($collection.Name)" -Type 1 @NewLogEntry
            }
            $collection.AddMemberShipRules($addRules)
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Finished Function' -Type 1 @NewLogEntry
        }
    }
} #End New-CMNDeviceCollectionDirectMemberRule

Function New-CMNDeviceCollectionExcludeRule {
    <#
		.SYNOPSIS

		.DESCRIPTION

		.PARAMETER Text

		.PARAMETER logFile
			File for writing logs to

		.PARAMETER logEntries
			Switch to say whether or not to create a log file

		.EXAMPLE

		.NOTES

		.LINK
			http://configman-notes.com
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM
    (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true)]
        [String]$CollectionID,

        [Parameter(Mandatory = $true)]
        [String]$excludeCollectionID,

        [Parameter(Mandatory = $true)]
        [String]$ruleName,

        [Parameter(Mandatory = $false)]
        [String]$logFile,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries')]
        [Switch]$logEntries = $false
    )
    begin {
        $NewLogEntry = @{
            LogFile   = $logFile;
            Component = 'New-CMNDeviceCollectionExcludeRule'
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess($query)) {
            $colQuery = "Select * from SMS_Collection where CollectionID = '$CollectionID'"
            $collection = Get-WmiObject -Query $colQuery -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
            if ($collection) {
                $excludeRule = ([WMIClass]"//$($sccmConnectionInfo.ComputerName)/$($sccmConnectionInfo.NameSpace):SMS_CollectionRuleExcludeCollection").CreateInstance()
                $excludeRule.ExcludeCollectionID = $excludeCollectionID
                $excludeRule.RuleName = $ruleName
                $collection.AddMembershipRule($excludeRule)
            }
            else {
                if ($PSBoundParameters['logEntries']) {
                    New-CMNLogEntry -entry "Unable to add $ruleName to $CollectionID" -Type 1 @NewLogEntry
                }
            }
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Completing function' -type 1 @NewLogEntry
        }
    }
} #End New-CMNDeviceCollectionExcludeRule

Function New-CMNDeviceCollectionIncludeRule {
    <#
		.SYNOPSIS

		.DESCRIPTION

		.PARAMETER Text

		.PARAMETER logFile
			File for writing logs to

		.PARAMETER logEntries
			Switch to say whether or not to create a log file

		.EXAMPLE

		.NOTES

		.LINK
			http://configman-notes.com
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM
    (
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true)]
        [String]$CollectionID,

        [Parameter(Mandatory = $true)]
        [String]$includeCollectionID,

        [Parameter(Mandatory = $true)]
        [String]$ruleName,

        [Parameter(Mandatory = $false)]
        [String]$logFile,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries')]
        [Switch]$logEntries = $false
    )
    begin {
        $NewLogEntry = @{
            LogFile   = $logFile;
            Component = 'New-CMNDeviceCollectionIncludeRule'
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -Type 1 @NewLogEntry
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess($ruleName)) {
            if ($PSBoundParameters['logEntries']) {
                New-CMNLogEntry -entry "Processing $ruleName" -Type 1 @NewLogEntry
            }
            $colQuery = "Select * from SMS_Collection where CollectionID = '$CollectionID'"
            $collection = Get-WmiObject -Query $colQuery -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
            if ($collection) {
                $includeRule = ([WMIClass]"//$($sccmConnectionInfo.ComputerName)/$($sccmConnectionInfo.NameSpace):SMS_CollectionRuleIncludeCollection").CreateInstance()
                $includeRule.IncludeCollectionID = $includeCollectionID
                $includeRule.RuleName = $ruleName
                $collection.AddMembershipRule($includeRule)
            }
            else {
                if ($PSBoundParameters['logEntries']) {
                    New-CMNLogEntry -entry "Unable to add $ruleName to $CollectionID" -Type 3 @NewLogEntry
                }
            }
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Finished Function' -Type 1 @NewLogEntry
        }
    }
} #End New-CMNDeviceCollectionIncludeRule

Function New-CMNDeviceCollectionQueryMemberRule {
    <#
		.SYNOPSIS

		.DESCRIPTION

		.PARAMETER Text

		.PARAMETER logFile
			File for writing logs to

		.PARAMETER logEntries
			Switch to say whether or not to create a log file

		.EXAMPLE

		.NOTES

		.LINK
			http://configman-notes.com
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM
    (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true)]
        [String]$CollectionID,

        [Parameter(Mandatory = $true)]
        [String]$query,

        [Parameter(Mandatory = $true)]
        [String]$ruleName,

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
        $NewLogEntry = @{
            LogFile   = $logFile;
            Component = 'New-CMNDeviceCollectionQueryMemberRule'
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -Type 1 @NewLogEntry
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess($query)) {
            if ($PSBoundParameters['logEntries']) {
                New-CMNLogEntry -entry "Processing $query" -Type 1 @NewLogEntry
            }
            $colQuery = "Select * from SMS_Collection where CollectionID = '$CollectionID'"
            $collection = Get-WmiObject -Query $colQuery -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
            if ($collection) {
                $queryMemberRule = ([WMIClass]"\\$($sccmConnectionInfo.ComputerName)\$($sccmConnectionInfo.NameSpace):SMS_CollectionRuleQuery").CreateInstance()
                $queryMemberRule.QueryExpression = $query
                $queryMemberRule.RuleName = $ruleName
                $collection.AddMembershipRule($queryMemberRule)
            }
            else {
                if ($PSBoundParameters['logEntries']) {
                    New-CMNLogEntry -entry "Unable to add $NetbiosName to $($Collection.Name)" -Type 3 @NewLogEntry
                }
            }
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        }
    }
} #End New-CMNDeviceCollectionQueryMemberRule

Function New-CMNLogEntry {
    <#
		.SYNOPSIS
			Writes log entry that can be read by CMTrace.exe

		.DESCRIPTION
			Writes log entries to a file. If the file is larger then MaxFileSize, it will rename it to *.lo_ and start a new file.
			You can specify if it's an informational, warning, or error message as well. It will also add time zone information, so if you
			have machines in multiple time zones, you can convert to UTC and make sure you know exactly when things happened.

		.PARAMETER entry
			This is the text that is the log entry.

		.PARAMETER type
			Defines the type of message, 1 = Informational (default), 2 = Warning, and 3 = Error.

		.PARAMETER component
			Specifies the Component information. This could be the name of the function, or thread, or whatever you like,
			to further help identify what is being logged.

		.PARAMETER logFile
			File for writing logs to.

		.PARAMETER maxLogSize
			Specifies, in bytes, how large the file should be before rolling log over.

		.PARAMETER maxLogHistory
			Specifies the number of history log files to keep, default is 5

		.EXAMPLE
			New-CMNLogEntry -entry "Machine $computerName needs a restart." -type 2 -component 'Installer' -logFile $logFile -MaxLogSize 10485760
			This will add a warning entry, after expanding $computerName from the compontent Installer to the logfile and roll it over if it exceeds 10MB

		.LINK
			http://configman-notes.com

		.NOTES
			FileName:    Copy-CMNApplicationDeployment.ps1
			Author:      James Parris
			Contact:     jim@ConfigMan-Notes.com
			Created:     2016-03-22
			Updated:     2017-03-01
			Version:     1.0.2
	#>
    [CmdletBinding(ConfirmImpact = 'Low')]

    # Writes to the log file
    Param
    (
        [Parameter(Mandatory = $true, HelpMessage = 'Entry for the log')]
        [String]$entry,

        [Parameter(Mandatory = $true, HelpMessage = 'Type of message, 1 = Informational, 2 = Warning, 3 = Error')]
        [ValidateSet(1, 2, 3)]
        [INT32]$type,

        [Parameter(Mandatory = $true, HelpMessage = 'Component')]
        [String]$component,

        [Parameter(Mandatory = $true, HelpMessage = 'Log File')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int32]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int32]$maxLogHistory = 5,

        [Parameter(Mandatory = $false, HelpMessage = 'Clear existing log?')]
        [Switch]$clearLog
    )
    #Check for an empty entry, if so, change it to 'N/A'
    if ($entry.Length -eq 0) {
        $entry = 'N/A'
    }
    #Get Timezone info
    $tzOffset = ([TimeZoneInfo]::Local).BaseUTcOffset.TotalMinutes
    #Now, to figure out the format. if the timezone is negative, we need to represent it as +###
    if ($tzOffset -lt 0) {
        $tzOffset = "$(Get-Date -Format "HH:mm:ss.fff")+$(-$tzOffset)"
    }
    #otherwise, we need to represent it as -###
    else {
        $tzOffset = "$(Get-Date -Format "HH:mm:ss.fff")-$tzOffset"
    }
    #Create entry line, properly formatted
    $entry = "<![LOG[{0}]LOG]!><time=""{2}"" date=""{1}"" component=""{5}"" context="""" type=""{4}"" thread=""{3}"">" -f $entry, (Get-Date -Format "MM-dd-yyyy"), $tzOffset, $pid, $type, $component

    #Now, see if we need to roll the log
    if (Test-Path $logFile) {
        #File exists, now to check the size
        if ((Get-Item -Path $logFile).Length -gt $MaxLogSize) {
            #rename file
            $backupLog = ($logFile -replace '\.log$', '') + "-$(Get-Date -Format "yyyymmdd-HHmmmss").log"
            Rename-Item -Path $logFile -NewName $backupLog -Force
            #get filter information
            $logFile -match '(\w*).log' | Out-Null
            $logName = $Matches[0]
            $logFileName = $Matches[1]
            $logFileName = "$logFileName*"
            $logPath = $logFile -replace "(.*)$logName", '$1'
            #remove any extra rollover logs.
            Get-ChildItem -Path $logPath -filter $logFileName | Where-Object { $_.Name -notin (Get-ChildItem -Path $logPath -Filter $logFileName | Sort-Object -Property LastWriteTime -Descending | Select-Object -First $maxLogHistory).name } | Remove-Item
        }
    }
    #write the entry
    $entry | Out-File $logFile -Append -Encoding ascii
}#End New-CMNLogEntry

Function New-CMNNonRepeatingSchedule {
    $Program = Get-WmiObject -ComputerName $SiteServer -Namespace "root\SMS\Site_$SiteCode" -Query "Select * from SMS_Program WHERE PackageID = '$packageID'"

    # Get the available time
    $FormatAvailable = Get-Date -Day 25 -Hour 10 -Minute 0 -Second 0
    $DateAvailable = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime($(Get-Date -Day $Day -Hour $Hour -Minute $Minute -Second $Second))

    # Get the required time
    $FormatRequired = Get-Date -format yyyyMMddHHmmss -Day 25 -Hour 22 -Minute 0 -Second 0
    $DateRequired = $FormatRequired + ".000000+***"

    # Create Assigment Time
    $ScheduleTime = ([WMIClass] "\\$($sccmConnectionInfo.ComputerName)\$($sccmConnectionInfo.NameSpace):SMS_ST_NonRecurring").CreateInstance()

    $ScheduleTime.DayDuration = 0
    $ScheduleTime.HourDuration = 0
    $ScheduleTime.MinuteDuration = 0
    $ScheduleTime.IsGMT = "false"
    $ScheduleTime.StartTime = $DateRequired

    # Create Advertisment
    $Advertisement = ([WMIClass] "\\$($sccmConnectionInfo.ComputerName)\$($sccmConnectionInfo.NameSpace):SMS_Advertisement").CreateInstance()

    $Advertisement.AdvertFlags = "36700160";
    #$Advertisement.AdvertisementName = $AppName;
    $Advertisement.CollectionID = $CollectionID;
    $Advertisement.PackageID = $PackageID;
    $Advertisement.AssignedSchedule = $ScheduleTime;
    $Advertisement.DeviceFlags = 0x00000000;
    $Advertisement.ProgramName = $Program.ProgramName;
    $Advertisement.RemoteClientFlags = "34896";
    $Advertisement.PresentTime = $DateAvailable;
    $Advertisement.SourceSite = $SiteCode;
    $Advertisement.TimeFlags = "8209"

    # Apply Advertisement
    $Advertisement.put()
} #End New-CMNNonRepeatingSchedule

Function New-CMNDailySchedule {
    <#
		.SYNOPSIS
			Returns a SMS_ST_RecurInterval object for a non-repeating schedule.

		.DESCRIPTION

		.PARAMETER Text

		.PARAMETER logFile
			File for writing logs to

		.PARAMETER logEntries
			Switch to say whether or not to create a log file

		.EXAMPLE

		.NOTES

		.LINK
			http://configman-notes.com
	#>
    Param
    (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'Collection ID')]
        [String]$collectionID,

        [Parameter(Mandatory = $false, HelpMessage = 'Start time')]
        [DateTime]$startTime
    )

    $collection = Get-WmiObject -Class SMS_Collection -Filter "CollectionID = '$collectionID'" -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
    if ($collection) {
        $ScheduleTime = ([WMIClass] "\\$($sccmConnectionInfo.ComputerName)\$($sccmConnectionInfo.NameSpace):SMS_ST_RecurInterval").CreateInstance()

        $ScheduleTime.DayDuration = 0
        $ScheduleTime.DaySpan = 1
        $ScheduleTime.HourDuration = 0
        $ScheduleTime.HourSpan = 0
        $ScheduleTime.MinuteDuration = 0
        $ScheduleTime.MinuteSpan = 0
        $ScheduleTime.IsGMT = $false
        $ScheduleTime.StartTime = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime((Get-Date $startTime -Format "MM/dd/yyy hh:mm:ss"))
        $collection.Get()
        $collection.RefreshType = 2
        $collection.RefreshSchedule = $ScheduleTime
        $collection.Put()
        $collection.RequestRefresh()
    }
    else {
        Write-Verbose "Collection $collectionID does not exist"
    }
} #End New-CMNDailySchedule

Function New-CMNObjectContainer {
    $NewObjectConter = ([wmiclass] "\\$($sccmConnectionInfo.ComputerName)\root\SMS\SITE_$($($sccmConnectionInfo.SiteCode)):SMS_ObjectContainerNode").CreateInstance()
} #End New-CMNObjectContainer

Function New-CMNPackage {
    [cmdletbinding()]
    PARAM
    (
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection info, can be set with Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $false, HelpMessage = 'Package Description')]
        [String]$description,

        [Parameter(Mandatory = $false, HelpMessage = 'Language')]
        [String]$language = 'English',

        [Parameter(Mandatory = $false, HelpMessage = 'Manufacturer')]
        [String]$manufacturer,

        [Parameter(Mandatory = $true, HelpMessage = 'Package Name')]
        [String]$name,

        [Parameter(Mandatory = $false, HelpMessage = 'Package Source Path')]
        [String]$pkgSourcePath,

        [Parameter(Mandatory = $false, HelpMessage = 'Version')]
        [String]$version,

        #Copy Content Flag
        [Parameter(Mandatory = $false)]
        [Switch]$copyContent = $false,

        #Prestage
        [Parameter(Mandatory = $false)]
        [Switch]$doNotDownload = $false,

        #Pesist in cache
        [Parameter(Mandatory = $false)]
        [Switch]$persistInCache = $false,

        #Enable Binary Replication
        [Parameter(Mandatory = $false)]
        [Switch]$useBinaryDeltaRep = $true,

        #Source Files
        [Parameter(Mandatory = $false)]
        [Switch]$noPackage = $false,

        #Use special MIF's
        [Parameter(Mandatory = $false)]
        [Switch]$useSpecialMif = $false,

        #Distribute on demand
        [Parameter(Mandatory = $false)]
        [Switch]$distributOnDemand = $false,

        #Enable nomad
        [Parameter(Mandatory = $false)]
        [Switch]$enableNomad = $true,

        #OSD Package
        [Parameter(Mandatory = $false)]
        [Switch]$isOSD
    )
    $NewPackage = ([wmiclass] "\\$($sccmConnectionInfo.ComputerName)\root\SMS\SITE_$($($sccmConnectionInfo.SiteCode)):SMS_Package").CreateInstance()
    $NewPackage.Description = $description
    $NewPackage.Language = $language
    $NewPackage.Manufacturer = $manufacturer
    $NewPackage.Name = $name
    $NewPackage.PkgSourcePath = $pkgSourcePath
    $NewPackage.Version = $version
    $NewPackage.PackageType = 0
    $NewPackage.Priority = 2
    $NewPackage.PkgSourceFlag = 2
    $NewPackage.PkgFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Package_PkgFlags -CurrentValue $NewPackage.PkgFlags -ProposedValue $($copyContent.IsPresent) -KeyName Copy_Content
    $NewPackage.PkgFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Package_PkgFlags -CurrentValue $NewPackage.PkgFlags -ProposedValue $doNotDownload.IsPresent -KeyName Do_Not_Download
    $NewPackage.PkgFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Package_PkgFlags -CurrentValue $NewPackage.PkgFlags -ProposedValue $persistInCache.IsPresent -KeyName Persist_In_Cache
    $NewPackage.PkgFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Package_PkgFlags -CurrentValue $NewPackage.PkgFlags -ProposedValue $useBinaryDeltaRep.IsPresent -KeyName Use_Binary_Delta_Rep
    $NewPackage.PkgFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Package_PkgFlags -CurrentValue $NewPackage.PkgFlags -ProposedValue $noPackage.IsPresent -KeyName No_Package
    $NewPackage.PkgFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Package_PkgFlags -CurrentValue $NewPackage.PkgFlags -ProposedValue $useSpecialMif.IsPresent -KeyName Use_Special_Mif
    $NewPackage.PkgFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Package_PkgFlags -CurrentValue $NewPackage.PkgFlags -ProposedValue $distributOnDemand.IsPresent -KeyName Distribute_On_Demand
    if ($enableNomad.IsPresent) {
        $NewPackage.AlternateContentProviders = '<AlternateDownloadSettings SchemaVersion="1.0"><Provider Name="NomadBranch"><Data><ProviderSettings /><pc>1</pc></Data></Provider></AlternateDownloadSettings>'
    }
    if ($isOSD.IsPresent) {
        $NewPackage.AlternateContentProviders = '<AlternateDownloadSettings SchemaVersion="1.0"><Provider Name="NomadBranch"><Data><ProviderSettings /><pc>9</pc><mc /></Data></Provider></AlternateDownloadSettings>'
    }
    $NewPackage.Put()
    $NewPackage.Get()

    Return $NewPackage
} #End New-CMNPackage

Function New-CMNPackageDeployment {
    <#
		.SYNOPSIS
            Creates a new package deployment

		.DESCRIPTION
            Creates a new package deployment.

		.PARAMETER SCCMConnectionInfo
			This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
			Get-CMNSCCMConnectionInfo in a variable and passing that variable.

        .PARAMETER packageID
            Package ID in source site

        .PARAMETER programName
            Program name to be used in the deployment

        .PARAMETER collectionID
            Destination collection ID

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
			FileName:    New-CMNPackageDeployment.ps1
			Author:      James Parris
			Contact:     jim@ConfigMan-Notes.com
			Created:     2016-03-22
			Updated:     2016-03-22
			Version:     1.0.0

            SMS_Advertisement
            SMS_Package
            SMS_Program
	#>

    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Low')]

    PARAM
    (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Source SCCM Connection Info')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true,
            HelpMessage = 'package ID')]
        [String]$packageID,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Program Name')]
        [String]$programName,

        [Parameter(Mandatory = $true,
            HelpMessage = 'collection ID')]
        [String]$collectionID,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Comment')]
        [String]$comment,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Available time')]
        [Alias('startTime')]
        [DateTime]$availableTime = $(Get-Date),

        [Parameter(Mandatory = $false,
            HelpMessage = 'Time to expire deployment')]
        [DateTime]$expireTime,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Array of runtimes for the schedule')]
        [DateTime[]]$runTimes,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Override maintenance windows')]
        [Switch]$overRideMaintenanceWindow,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Reboot outside of maintenance windows')]
        [Switch]$rebootOutsideMaintenanceWindow,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Run From DP')]
        [Switch]$rdp,

        [Parameter(Mandatory = $false,
            HelpMessage = "Rerun mode, valid options are 'Always Rerurn', 'Rerun if Failed', and 'Never Rerun'")]
        [ValidateSet('Always Rerun', 'Rerun if Failed', 'Never Rerun')]
        [String]$reRunMode = 'Rerun if Failed',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Remove existing deployment if present')]
        [Switch]$replaceExisting,

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
        $NewLogEntry = @{
            logFile       = $logFile;
            component     = 'New-CMNPackageDeployment';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }
        $WMIQueryParameters = @{
            ComputerName = $sccmConnectionInfo.ComputerName;
            NameSpace    = $sccmConnectionInfo.NameSpace;
        }
        if ($PSBoundParameters['clearLog']) {
            if (Test-Path -Path $logFile) {
                Remove-Item -Path $logFile
            }
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "SCCMConnectionInfo = $sccmConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "availableTime = $availableTime" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "collectionID = $collectionID" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "comment = $comment" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "expireTime = $expireTime" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "overRideMaintenanceWindow = $overRideMaintenanceWindow" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "packageID = $packageID" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "rebootOutsideMaintenanceWindow = $rebootOutsideMaintenanceWindow" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "rdp = $rdp" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "reRunMode = $reRunMode" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "replaceExisting = $replaceExisting" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "runTimes = $runTimes" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
        }
    }

    process {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry
        }
        if ($PSCmdlet.ShouldProcess($packageID)) {
            #Verify package
            if ($PSBoundParameters['logEntries']) {
                New-CMNLogEntry -entry 'Verifying package' -type 1 @NewLogEntry
            }
            $query = "Select * from SMS_Package where PackageID = '$packageID'"
            $package = Get-WmiObject -Query $query @WMIQueryParameters
            if ($package) {
                #Verify program
                if ($PSBoundParameters['logEntries']) {
                    New-CMNLogEntry -entry 'Package exists, checking that program exists' -type 1 @NewLogEntry
                }
                $query = "SELECT * from SMS_Program where PackageID = '$packageID' and ProgramName = '$programName'"
                $program = Get-WmiObject -Query $query @WMIQueryParameters
                if ($program) {
                    if ($PSBoundParameters['logEntries']) {
                        New-CMNLogEntry -entry 'Program exists, checking if deployment already exists' -type 1 @NewLogEntry
                    }
                    $query = "Select * from SMS_Advertisement where CollectionID = '$collectionID' and PackageID = '$packageID' and ProgramName = '$programName'"
                    $deployment = Get-WmiObject -Query $query @WMIQueryParameters
                    if (-not ($deployment) -or $PSBoundParameters['replaceExisting']) {
                        if ($deployment -and $PSBoundParameters['replaceExisting']) {
                            if ($PSBoundParameters['logEntries']) {
                                New-CMNLogEntry -entry 'Deployment exists, but is being replaced. Removing and verifying collection exist' -type 2 @NewLogEntry
                            }
                            $result = $deployment | Remove-WmiObject
                            if ($PSBoundParameters['logEntries']) {
                                New-CMNLogEntry -entry "Results = $result" -type 2 @NewLogEntry
                            }
                        }
                        else {
                            if ($PSBoundParameters['logEntries']) {
                                New-CMNLogEntry -entry 'Deployment does not exist, verifying collection exists' -type 1 @NewLogEntry
                            }
                        }
                        $query = "Select * from SMS_Collection where CollectionID = '$collectionID'"
                        $collection = Get-WmiObject -Query $query @WMIQueryParameters
                        if ($collection) {
                            $deploymentName = "$($package.Name) ($($package.PackageID)) - $($collection.Name) ($($collection.CollectionID))"
                            #Create deployment
                            $deployment = ([WMIClass]"\\$($sccmConnectionInfo.ComputerName)\$($sccmConnectionInfo.NameSpace):SMS_Advertisement").CreateInstance()
                            #set advertFlags
                            #user can not run independent of assignment
                            $advertFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_AdvertFlags -KeyName NO_DISPLAY -CurrentValue 0
                            #mandatory over slow networks
                            $advertFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_AdvertFlags -KeyName ONSLOWNET -CurrentValue $advertFlags
                            #if requested, override maintenance window
                            if ($PSBoundParameters['overRideMaintenanceWindow']) {
                                $advertFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_AdvertFlags -KeyName OVERRIDE_SERVICE_WINDOWS -CurrentValue $advertFlags
                            }
                            #if requested, reboot outside of maintenance window
                            if ($PSBoundParameters['rebootOutsideMaintenanceWindow']) {
                                $advertFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_AdvertFlags -KeyName REBOOT_OUTSIDE_OF_SERVICE_WINDOWS -CurrentValue $advertFlags
                            }
                            $deployment.AdvertFlags = $advertFlags
                            $deployment.AdvertisementName = $deploymentName
                            foreach ($runTime in $runTimes) {
                                $ScheduleTime = ([WMIClass] "\\$($sccmConnectionInfo.ComputerName)\$($sccmConnectionInfo.NameSpace):SMS_ST_NonRecurring").CreateInstance()
                                $ScheduleTime.DayDuration = 0
                                $ScheduleTime.HourDuration = 0
                                $ScheduleTime.IsGMT = $false
                                $ScheduleTime.StartTime = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime((Get-Date $runTime -Format G))
                                $deployment.AssignedSchedule += $ScheduleTime
                            }
                            $deployment.AssignedScheduleEnabled = $true
                            $deployment.AssignedScheduleIsGMT = $false
                            $deployment.CollectionID = $collectionID
                            $deployment.Comment = $comment
                            if ($expireTime) {
                                $deployment.ExpirationTime = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime((Get-Date $expireTime -Format G))
                                $deployment.ExpirationTimeEnabled = $true
                            }
                            $deployment.PackageID = $packageID
                            $deployment.PresentTime = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime((Get-Date $availableTime -Format G))
                            $deployment.PresentTimeEnabled = $true
                            $deployment.PresentTimeIsGMT = $false
                            $deployment.Priority = 2
                            $deployment.ProgramName = $programName
                            #set RemoteClientFlags
                            #if run from dp
                            if ($PSBoundParameters['rdp']) {
                                $remoteClientFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_RemoteClientFlags -KeyName RUN_FROM_LOCAL_DISPPOINT -CurrentValue 0
                                $remoteClientFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_RemoteClientFlags -KeyName RUN_FROM_REMOTE_DISPPOINT -CurrentValue $remoteClientFlags
                            }
                            else {
                                $remoteClientFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_RemoteClientFlags -KeyName DOWNLOAD_FROM_LOCAL_DISPPOINT -CurrentValue 0
                                $remoteClientFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_RemoteClientFlags -KeyName DOWNLOAD_FROM_REMOTE_DISPPOINT -CurrentValue $remoteClientFlags
                            }
                            switch ($reRunMode) {
                                'Always Rerurn' {
                                    $remoteClientFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_RemoteClientFlags -KeyName RERUN_ALWAYS -CurrentValue $remoteClientFlags
                                }
                                'Rerun if Failed' {
                                    $remoteClientFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_RemoteClientFlags -KeyName RERUN_IF_FAILED -CurrentValue $remoteClientFlags
                                }
                                'Never Rerun' {
                                    $remoteClientFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_RemoteClientFlags -KeyName RERUN_NEVER -CurrentValue $remoteClientFlags
                                }
                            }
                            $deployment.RemoteClientFlags = $remoteClientFlags
                            #set TimeFlags
                            $timeFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_TimeFlags -KeyName ENABLE_PRESENT -CurrentValue 0
                            $timeFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_TimeFlags -KeyName ENABLE_MANDATORY -CurrentValue $timeFlags
                            $deployment.TimeFlags = $timeFlags
                            $deployment.Put() | Out-Null
                        }
                        else {
                            if ($PSBoundParameters['logEntries']) {
                                New-CMNLogEntry -entry "Collection $collectionID does not exist" -type 3 @NewLogEntry
                            }
                        }
                    }
                    else {
                        if ($PSBoundParameters['logEntries']) {
                            New-CMNLogEntry -entry "Deployment already exists on collection $collectionID" -type 2 @NewLogEntry
                        }
                        Throw 'Already exists'
                    }
                }
                else {
                    if ($PSBoundParameters['logEntries']) {
                        New-CMNLogEntry -entry 'Program does not exist on source package' -type 3 @NewLogEntry
                    }
                    Throw 'Program does not exist on source'
                }
            }
            else {
                if ($PSBoundParameters['logEntries']) {
                    New-CMNLogEntry -entry "Package $srcPackageID does not exist on source" -type 3 @NewLogEntry
                }
                Throw 'Source Package does not exist'
            }
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        }
    }
} #End New-CMNPackageDeployment

Function New-CMNProgram {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'Package ID')]
        [String]$packageID,

        [Parameter(Mandatory = $true, HelpMessage = 'Command Line')]
        [String]$commandLine,

        #User Description
        [Parameter(Mandatory = $false)]
        [String]$comment,

        #Category
        [Parameter(Mandatory = $false)]
        [String]$description,

        #Format NNN SS where N is number and S is a size (MB, KB, GB)
        [Parameter(Mandatory = $true, HelpMessage = 'Disk Space Required')]
        [String]$diskSpaceReq,

        [Parameter(Mandatory = $false)]
        [String]$driveLetter,

        [Parameter(Mandatory = $true, HelpMessage = 'Duration')]
        [Int32]$duration,

        [Parameter(Mandatory = $true, HelpMessage = 'Program Name')]
        [String]$programName,

        [Parameter(Mandatory = $true, HelpMessage = 'Operating Systems Supported')]
        [String[]]$supportedOperatingSystems,

        [Parameter(Mandatory = $false)]
        [String]$workingDirectory,

        [Parameter(Mandatory = $false)]
        [Switch]$authorizedDynamicInstall = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$useCustomProgressMsg = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$defaultProgram = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$disableMomAlertOnRunning = $true,

        [Parameter(Mandatory = $false)]
        [Switch]$momAlertOnFail = $true,

        [Parameter(Mandatory = $false)]
        [Switch]$runDependantAlways = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$windowsCE = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$countdown = $true,

        #Suppress Notifications
        [Parameter(Mandatory = $false)]
        [Switch]$unattended = $true,

        [Parameter(Mandatory = $false)]
        [Switch]$usercontext = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$adminrights = $true,

        [Parameter(Mandatory = $false)]
        [Switch]$everyuser = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$nouserloggedin = $false,

        #Program Restart Computer
        [Parameter(Mandatory = $false)]
        [Switch]$oktoquit = $false,

        #ConfMGR Restarts Computer
        [Parameter(Mandatory = $false)]
        [Switch]$oktoreboot = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$useuncpath = $true,

        [Parameter(Mandatory = $false)]
        [Switch]$persistconnection = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$runminimized = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$runmaximized = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$hidewindow = $false,

        #ConfigMGR logs user off
        [Parameter(Mandatory = $false)]
        [Switch]$oktologoff = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$anyPlatform = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$supportUninstall = $false
    )

    begin {
        $Package = Get-WmiObject -Class SMS_Package -Filter "PackageID = '$packageID'" -ComputerName $sccmConnectionInfo.ComputerName -Namespace "root\sms\site_$($sccmConnectionInfo.SiteCode)"
    }

    process {
        $NewProgram = ([wmiclass] "\\$($sccmConnectionInfo.ComputerName)\root\SMS\SITE_$($($sccmConnectionInfo.SiteCode)):SMS_Program").CreateInstance()
        $NewProgram.PackageID = $packageID
        $NewProgram.CommandLine = $commandLine
        $NewProgram.Comment = $comment
        $NewProgram.Description = $description
        $NewProgram.DiskSpaceReq = $diskSpaceReq
        $NewProgram.DriveLetter = $driveLetter
        $NewProgram.Duration = $duration
        $NewProgram.ProgramName = $programName
        $NewProgram.WorkingDirectory = $workingDirectory
        $NewProgram.PackageName = $Package.Name
        $NewProgram.PackageType = 0

        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $authorizedDynamicInstall.IsPresent -KeyName Authorized_Dynamic_Install
        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $useCustomProgressMsg.IsPresent -KeyName useCustomProgressMsg
        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $defaultProgram.IsPresent -KeyName Default_Program
        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $disableMomAlertOnRunning.IsPresent -KeyName disableMomAlertOnRunning
        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $momAlertOnFail.IsPresent -KeyName momAlertOnFail
        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $runDependantAlways.IsPresent -KeyName Run_Dependant_Always
        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $WindowsCE.IsPresent -KeyName Windows_CE
        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $countdown.IsPresent -KeyName countdown
        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $unattended.IsPresent -KeyName unattended
        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $usercontext.IsPresent -KeyName usercontext
        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $adminrights.IsPresent -KeyName adminrights
        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $everyuser.IsPresent -KeyName everyuser
        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $nouserloggedin.IsPresent -KeyName nouserloggedin
        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $oktoquit.IsPresent -KeyName oktoquit
    }

    end {
        try {
            $NewProgram.Put() | Out-Null
            $NewProgram.get()
        }

        Catch {
            Write-Error 'Unable to create program'
        }
    }
} #End New-CMNProgram

Function New-CMNSCCMSiteSystemCollections {
    <#
	.SYNOPSIS

	.DESCRIPTION

	.PARAMETER ObjectID

	.EXAMPLE

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:
		PSVer:	2.0/3.0
		Updated:
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param
    (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(
            Mandatory = $true,
            HelpMessage = 'Folder to put the collections in (0 for root)')]
        [String]$CollectionFolder
    )

    begin {
        $ContainerID = Get-CMNObjectContainerNodeID -SCCMConnectionInfo $sccmConnectionInfo -Name $CollectionFolder -ObjectType SMS_Collection_Device
    }

    process {
        Write-Verbose "Beginning process loop"
        $roles = Get-WmiObject -Class SMS_R_System -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName | Select-Object -ExpandProperty SystemRoles | Sort-Object -Unique
        foreach ($role in $roles) {
            $collectionName = "SCCM $($role -replace 'SMS (.*)','$1')"
            $collection = Get-WmiObject -Class SMS_Collection -Filter "Name = '$collectionName'" -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
            if ($collection) {
                Write-Verbose "$($collection.Name) already exists, skipping."
                if ($ContanerID -ne 0) {
                    Move-CMNObject -SCCMConnectionInfo $sccmConnectionInfo -objectID $collection.CollectionID -destinationContainerID $ContainerID -objectType SMS_Collection_Device | Out-Null
                }
            }
            else {
                Write-Verbose "Creating $collectionName"
                $collection = New-CMNDeviceCollection -SCCMConnectionInfo $sccmConnectionInfo -Comment "SCCM $role Systems" -LimitToCollectionID SMS00001 -Name $collectionName
                $query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemRoles = '$role'"
                New-CMNDeviceCollectionQueryMemberRule -SCCMConnectionInfo $sccmConnectionInfo -CollectionID $collection.CollectionID -query $query -ruleName $role | Out-Null
                [DateTime]$startTime = Get-Date "01:00 AM"
                New-CMNDailySchedule -SCCMConnectionInfo $sccmConnectionInfo -collectionID $collection.CollectionID -startTime $startTime | Out-Null
                if ($ContanerID -ne 0) {
                    Move-CMNObject -SCCMConnectionInfo $sccmConnectionInfo -objectID $collection.CollectionID -destinationContainerID $ContainerID -objectType SMS_Collection_Device | Out-Null
                }
            }
        }
    }

    end {
    }
} #End New-CMNSCCMSiteSystemCollections

Function Remove-CMNCollection {
    <#
    .SYNOPSIS

    .DESCRIPTION

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
        Date:	    yyyy-mm-dd
        Updated:
        PSVer:	    3.0
        Version:    1.0.0
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'CollectionID to remove')]
        [String]$collectionID,

        [Parameter(Mandatory = $false, HelpMessage = 'Do we delete if it is an inlcude or exclude collection?')]
        [Switch]$doForce,

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
        if ($PSBoundParameters['logEntries']) {
            $logEntries = $true
        }
        else {
            $logEntries = $false
        }

        #Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'Remove-CMNCollection';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        # Create a hashtable with your output info
        $returnHashTable = @{ }

        $cimSession = New-CimSession -ComputerName $sccmConnectionInfo.ComputerName
        $collection = Get-CimInstance -Query "Select * from SMS_Collection where CollectionID = '$collectionID'" -Namespace $sccmConnectionInfo.NameSpace -CimSession $cimSession

        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "SCCMConnectionInfo = $SCCMConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "collectionID = $collectionID" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "doForce =$doForce" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
        }
    }

    process {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry
        }

        if ($PSCmdlet.ShouldProcess($collectionID)) {
            #check for dependencies
            $isLimitingCollection = $false
            $isIncludeCollection = $false
            $isExcludeCollection = $false
            $dependencies = Get-CimInstance -query "Select * from SMS_CollectionDependencies where SourceCollectionID = '$collectionID'" -CimSession $cimSession -Namespace $sccmConnectionInfo.NameSpace
            foreach ($dependency in $dependencies) {
                switch ($dependency.RelationShipType) {
                    1 {
                        #Limiting collection
                        if ($logEntries) {
                            New-CMNLogEntry -entry "Collection $depCollectionID is the limiting collection for collection $($dependency.DependentCollectionID)" -type 3 @NewLogEntry
                        }
                        $returnHashTable['LimitingCollectionFor'] += [Array]$dependency.DependentCollectionID
                        $isLimitingCollection = $true
                    }

                    2 {
                        #Include collection
                        if ($logEntries) {
                            New-CMNLogEntry -entry "Collection $depCollectionID is included in collection $($dependency.DependentCollectionID)" -type 1 @NewLogEntry
                        }
                        $returnHashTable['IncludeCollectionFor'] += [Array]$dependency.DependentCollectionID
                        $isIncludeCollection = $true
                        if ($doForce) {
                            $depCollection = Get-CimInstance -Query "Select * from SMS_Collection where CollectionID = '$($dependency.DependentCollectionID)'" -Namespace $sccmConnectionInfo.NameSpace -CimSession $cimSession
                            $depCollection = $depCollection | Get-CimInstance
                            foreach ($depCollectionRule in $depCollection.CollectionRules) {
                                if ($depCollectionRule.IncludeCollectionID -eq $collectionID) {
                                    try {
                                        if ($logEntries) {
                                            New-CMNLogEntry -entry "Removing rule from $($depCollection.Name) ($($depCollection.CollectionID))" -type 1 @NewLogEntry
                                        }
                                        Invoke-CimMethod -InputObject $depCollection -CimSession $cimSession -MethodName DeleteMembershipRule -Arguments @{collectionRule = $depCollectionRule } | Out-Null
                                    }
                                    catch {
                                        $message = "Failed to remove rule from collection $($depCollection.Name) ($($dependency.DependentCollectionID))"
                                        if ($logEntries) {
                                            New-CMNLogEntry -entry $message -type 3 @NewLogEntry
                                        }
                                        throw $message
                                    }
                                }
                            }
                        }
                    }

                    3 {
                        #Exclude collection
                        if ($logEntries) {
                            New-CMNLogEntry -entry "Collection $collectionID is excluded in collection $($dependency.DependentCollectionID)" -type 1 @NewLogEntry
                        }
                        $returnHashTable['ExludeCollectionFor'] += [Array]$dependency.DependentCollectionID
                        $isExcludeCollection = $true
                        if ($doForce) {
                            $depCollection = Get-CimInstance -Query "Select * from SMS_Collection where CollectionID = '$($dependency.DependentCollectionID)'" -Namespace $sccmConnectionInfo.NameSpace -CimSession $cimSession
                            $depCollection = $depCollection | Get-CimInstance

                            foreach ($depCollectionRule in $depCollection.CollectionRules) {
                                if ($depCollectionRule.ExcludeCollectionID -eq $collectionID) {
                                    try {
                                        if ($logEntries) {
                                            New-CMNLogEntry -entry "Removing rule from $($depCollection.Name) ($($depCollection.CollectionID))" -type 1 @NewLogEntry
                                        }
                                        Invoke-CimMethod -InputObject $depCollection -CimSession $cimSession -MethodName DeleteMembershipRule -Arguments @{collectionRule = $depCollectionRule } | Out-Null
                                    }
                                    catch {
                                        $message = "Failed to remove rule from collection $($depCollection.Name) ($($dependency.DependentCollectionID))"
                                        if ($logEntries) {
                                            New-CMNLogEntry -entry $message -type 3 @NewLogEntry
                                        }
                                        throw $message
                                    }
                                }
                            }
                        }
                    }
                }
            }
            #delete collection
            try {
                if ($logEntries) {
                    New-CMNLogEntry -entry "Removing collection $collectionID" -type 1 @NewLogEntry
                }
                Remove-CimInstance -inputObject $collection -ErrorAction SilentlyContinue | Out-Null
            }

            catch {
                $message = "Failed to remove collection $($collection.Name) ($collectionID)"
                if ($logEntries) {
                    New-CMNLogEntry -entry $message -type 3 @NewLogEntry
                }
                throw $message
            }
        }
    }

    End {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        }
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.DeleteCollectionResults')
        Return $obj
    }
} #End Remove-CMNCollection

Function Remove-CMNDPContent {
    <#
    .Synopsis
        This function will remove the package from the DP's and DP Group's.

    .DESCRIPTION
        This function will remove the package from the DP's and DP Group's.

    .PARAMETER PackageID
        This is the PackageID to be removed

	.PARAMETER DPKeeps
		This is the list of DP Group's that if the package is on, should be kept on.

    .EXAMPLE

    .LINK
        http://configman-notes.com

    .NOTES

    #>

    Param
    (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'SCCM Connection Info')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true)]
        [String]$PackageID,

        [Parameter(Mandatory = $false)]
        [Array]$DPkeeps = @()
    )

    #First, get a list of DP/DPGroup's the package is on
    Write-Verbose 'Starting Function Remove-CMNDPContent'
    Write-Verbose "Package -  $PackageID"

    #Get DP deployment status for PackageID
    $DPStatus = Get-WmiObject -Class SMS_PackageContentServerInfo -Filter "ObjectID = '$PackageID'" -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName

    #Go through and remove each DP/DPGroup, if it exists
    if ($DPStatus) {
        foreach ($DP in $DPStatus) {
            if ($DP.Name -match '\\') {
                $DPName = $DP.Name -replace '([\[])', '[$1]' -replace '(\\)', '$1' -replace '\\\\(.*)', '$1'
            }
            else {
                $DPName = $DP.Name
            }

            foreach ($DPK in $DPKeeps) {
                if ($DPName -match $DPK) {
                    #New-LogEntry "Package $PackageID exists on a $DPName so we'll need to add that back." 1 'Remove-CMDPPackage'

                    #See if it's in the list
                    $DPKeepExists = $false
                    foreach ($x in $DPTargets) {
                        if ($DPName -match $x) {
                            $DPKeepExists = $true
                        }
                    }

                    if (-not ($DPKeepExists)) {
                        $DPTargets = $DPTargets + $DPName
                    }
                }
            }
            if ($DP.ContentServerType -eq 1) {
                #Is it on a DP
                Write-Verbose "Removing Package $PackageID from $DPName"
                $DistPoint = Get-WmiObject -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName -Class SMS_DistributionPoint -Filter "PackageID = '$PackageID'" | Where-Object { $_.ServerNALPath -match $DPName }
                $DistPoint | Remove-WmiObject
            }
            else {
                #It's on a DP Group
                Write-Verbose "Removing Package $PackageID from $DPName"
                $DistPointGroup = Get-WmiObject -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName -Class SMS_DPGroupContentInfo -Filter "PackageID = '$PackageID'"
                $DistPointGroupInfo = Get-WmiObject -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName -Class SMS_DistributionPointGroup  -Filter "GroupID = '$($DistPointGroup.GroupID)'"# and PkgID = '$PackageID'"
                $DistPointGroupInfo.RemovePackages($PackageID) | Out-Null
            }
        }
        Return , $DPkeeps
    }
    #If DPStatus is null, no package content is distributed
    else {
        Write-Verbose "Package $PackageID is not currently distributed"
    }
} #End Remove-CMNDPContent

Function Remove-CMNPackageFromCache {
    <#
		.SYNOPSIS

		.DESCRIPTION

		.PARAMETER SCCMConnectionInfo
			This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
			Get-CMNSCCMConnectionInfo in a variable and passing that variable.

		.PARAMETER showProgress
			Show a progressbar displaying the current operation.

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
			FileName:    Remove-CMNPackageFromCache.ps1
			Author:      James Parris
			Contact:     jim@ConfigMan-Notes.com
			Created:     2016-03-22
			Updated:     2016-03-22
			Version:     1.0.0
	#>

    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Low')]

    PARAM
    (
        [Parameter(Mandatory = $true,
            HelpMessage = 'PackageID to remove')]
        [String]$packageID
    )

    begin {
    }

    process {
        #Connect to Resource Manager COM Object
        $resman = New-Object -ComObject "UIResource.UIResourceMgr"
        $cacheInfo = $resman.GetCacheInfo()

        #Enum Cache elements, compare date, and delete older than 60 days
        $element = $cacheinfo.GetCacheElements() | Where-Object { $_.ContentID -eq $packageID }
        if ($element) {
            $cacheInfo.DeleteCacheElement($element.CacheElementID)
        }
    }

    end {
    }
} #End Remove-CMNPackageFromCache

Function Remove-CMNRoleOnObject {
    <#
	.SYNOPSIS
		This Function will remove a role from an object
	.DESCRIPTION
		You provide the ObjectID to remove the scope from, the Type of object, and the RoleName

		This function expects the variable $WMIQueryParameters to be used, if you have your site server, you can use the info below
		to get your necessary information:

		$SiteServer = '<InsertServerName>'
		$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

		$WMIQueryParameters = @{
			ComputerName = $SiteServer
			Namespace = "root\sms\site_$SiteCode"

	.EXAMPLE
		Remove-CMNRoleOnObject 'CAS003F2' 2 'Workstations'

		This will remove the Workstations Role from PackageID CAS003F2

	.PARAMETER ObjectID
		This is the ID of the object to remove the role from

	.PARAMETER ObjectTypeID
		ObjectTypeID for the object you are working with. Valid values are:
			2
			3
			7
			8
			9
			11
			14
			17
			18
			19
			20
			21
			23
			25
			1011
			2011
			5000
			5001
			6000
			6001

	.PARAMETER RoleName
		The Role to remove from the Object

	.NOTES
		If you remove a role that is not there, the function generate an error

		https://social.technet.microsoft.com/Forums/en-US/d3e0d59a-2f6e-4e35-90b7-cea730436f88/how-do-i-use-the-powershell-parameter-securedscopenames-within-setcmpackage?forum=configmanagergeneral
		https://msdn.microsoft.com/en-us/library/hh948702.aspx
		https://msdn.microsoft.com/en-us/library/hh948196.aspx

	.LINK
		http://configman-notes.com
	#>

    PARAM
    (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'SCCM Connection Info')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'Package to Add Scope to')]
        [Array]$ObjectID,

        [Parameter(Mandatory = $true, HelpMessage = 'ObjectTypeID')]
        [ValidateSet('2', '3', '7', '8', '9', '11', '14', '17', '18', '19', '20', '21', '23', '25', '1011', '2011', '5000', '5001', '6000', '6001')]
        [String]$ObjectTypeID,

        [Parameter(Mandatory = $true, HelpMessage = 'Role to add')]
        [String]$RoleName
    )

    #New-LogEntry 'Starting Script' 1 'Remove-CMNRoleOnObject'
    [ARRAY]$SecurityScopeCategoryID = (Get-WmiObject -Class SMS_SecuredCategory -Filter "CategoryName = '$RoleName'" -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName).CategoryID

    Invoke-WmiMethod -Name RemoveMemberShips -Class SMS_SecuredCategoryMemberShip -ArgumentList $SecurityScopeCategoryID, $ObjectiD, $ObjectTypeID -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName | Out-Null
} #End Remove-CMNRoleOnObject

Function Reset-CMNPolicy {
    <#
	.Synopsis

	.DESCRIPTION

	.PARAMETER

	.EXAMPLE

	.LINK
		http://parrisfamily.com

	.NOTES

	#>

    [cmdletbinding()]
    Param
    (
        [Parameter(Mandatory = $false)]
        [String[]]$ComputerNames = ('localhost'),

        [Parameter(Mandatory = $false)]
        [Switch]$purge
    )

    foreach ($ComputerName in $ComputerNames) {
        if ($PSBoundParameters['purge']) {
            Invoke-WmiMethod -ComputerName $ComputerName -Namespace root\ccm -Class sms_client -Name ResetPolicy -ArgumentList @(1)
        }
        else {
            Invoke-WmiMethod -ComputerName $ComputerName -Namespace root\ccm -Class sms_client -Name ResetPolicy -ArgumentList @(0)
        }
        Get-Service -ComputerName $ComputerName -Name 'SMS Agent Host' | Stop-Service -Force
        Get-Service -ComputerName $ComputerName -Name 'SMS Agent Host' | Start-Service
    }
} #End Reset-CMNPolicy

Function Set-CMNBitFlagForControl {
    <#
	.SYNOPSIS

	.DESCRIPTION
		We have defined the following BitFlagHashTables:
			$SMS_Advertisement_AdvertFlags
			$SMS_Advertisement_DeviceFlags
			$SMS_Advertisement_RemoteClientFlags
			$SMS_Advertisement_TimeFlags
			$SMS_Package_PkgFlags
			$SMS_Program_ProgramFlags

	.EXAMPLE

	.PARAMETER Text

	.NOTES

	.LINK
		http://configman-notes.com
	#>
    PARAM
    (
        [Parameter(Mandatory = $true)]
        [Bool]$ProposedValue,

        [Parameter(Mandatory = $true)]
        [HashTable]$BitFlagHashTable,

        [Parameter(Mandatory = $true)]
        [String]$KeyName,

        [Parameter(Mandatory = $true)]
        [Int64]$CurrentValue
    )
    if ($ProposedValue) {
        $CurrentValue = $CurrentValue -bor $BitFlagHashTable.Item($KeyName)
    }
    elseif ($CurrentValue -band $BitFlagHashTable.Item($KeyName)) {
        $CurrentValue = ($CurrentValue -bxor $BitFlagHashTable.Item($KeyName))
    }
    return $CurrentValue
} #End Set-CMNBitFlagForControl

Function Set-CMNLimitingCollection {
    <#
	.SYNOPSIS
		This will change the limiting collection for a collection

	.DESCRIPTION
		This changes the limiting collection on the CollectionID(s) passed to the New ID in teh LimitingToCollectionIDNew parameter

		We have defined the following BitFlagHashTables:
			$SMS_Advertisement_AdvertFlags
			$SMS_Advertisement_DeviceFlags
			$SMS_Advertisement_RemoteClientFlags
			$SMS_Advertisement_TimeFlags
			$SMS_Package_PkgFlags
			$SMS_Program_ProgramFlags

		This function expects the variable $WMIQueryParameters to be used, if you have your site server, you can use the info below
		to get your necessary information:

		$SiteServer = '<InsertServerName>'
		$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

		$WMIQueryParameters = @{
			ComputerName = $SiteServer
			Namespace = "root\sms\site_$SiteCode"

	.PARAMETER SCCMConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.

	.PARAMETER CollectionID
		The CollectionID(s) of the collection to be updated

	.PARAMETER logFile
		File for writing fs to

    .PARAMETER logEntries
        Switch to say whether or not to create a log file

	.PARAMETER LimitingToCollectionIDNew
		The CollectionID for the new limiting collection

	.EXAMPLE
		Set-CMNLimitingCollection 'CAS00416' 'CAS00585'

	.EXAMPLE
		'CAS00416' | Set-CMNLimitingCollection -LimitingToCollectionIDNew 'CAS00586'

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:	2/25/2016
		PSVer:	2.0/3.0
		Updated:
	#>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true,
            HelpMessage = 'SCCM Connection Info',
            Position = 1)]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true,
            HelpMessage = 'CollectionID for collection to change',
            Position = 2,
            ValueFromPipeLine = $true)]
        [string[]]$CollectionID,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Change the limiting collection to this CollectionID',
            Position = 3)]
        [string]$LimitingToCollectionIDNew,

        [Parameter(Mandatory = $false,
            HelpMessage = 'LogFile Name',
            Position = 4)]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries',
            Position = 5)]
        [Switch]$logEntries = $false,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Max Log size',
            Position = 6)]
        [Int32]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Max number of history logs',
            Position = 7)]
        [Int32]$maxLogHistory = 5
    )

    begin {
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'Set-CMNLimitingCollection'
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }
        $WMIQueryParameters = @{
            ComputerName = $sccmConnectionInfo.ComputerName;
            NameSpace    = $sccmConnectionInfo.NameSpace;
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        }
    }

    process {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Set-CMNLimitingCollection' -type 1 @NewLogEntry
        }
        foreach ($CollID in $CollectionID) {
            $Collection = Get-WmiObject -Class SMS_Collection -Filter "CollectionID = '$CollID'" @WMIQueryParameters
            $Collection.Get()
            $LimitingCollection = Get-WmiObject -Class SMS_Collection -Filter "CollectionID = '$LimitingToCollectionIDNew'" @WMIQueryParameters
            if ($PSBoundParameters['logEntries']) {
                New-CMNLogEntry -entry "Changing $($Collection.Name) limiting collection from $($Collection.LimitToCollectionName) to $($LimitingCollection.Name)" -type 1 @NewLogEntry
            }
            $Collection.LimitToCollectionID = $(($LimitingCollection.CollectionID).ToString())
            $Collection.LimitToCollectionName = $(($LimitingCollection.Name).ToString())
            $Collection.Put() | Out-Null
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Completing function' -type 1 @NewLogEntry
        }
    }
} #End Set-CMNLimitingCollection

Function Set-CMNScriptTimeout {
    <#
	.SYNOPSIS - Test

	.DESCRIPTION

	.PARAMETER

	.EXAMPLE

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:
		PSVer:	2.0/3.0
		Updated:
	#>

    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Low')]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'What computer name would you like to target?',
            Position = 1)]
        [Alias('host')]
        [ValidateLength(3, 30)]
        [string[]]$computername
    )

    begin {
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'FunctionName';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        }
    }

    process {
        Write-Verbose "Beginning process loop"
        $class = Get-CimInstance -ClassName SMS_SCI_ClientComp -ComputerName LOUAPPWPS1825 -Namespace root/sms/site_sp1 -Filter "ItemName = 'Configuration Management Agent' and ItemType = 'Client Component'"
        if ($class) {
            foreach ($item in $class.Props) {
                if ($item.PropertyName -eq 'ScriptExecutionTimeout') {
                    $item.Value = 600
                }
            }
        }
        foreach ($computer in $computername) {
            # create a hashtable with your output info
            $returnHashTable = @{
                'info1' = $value1;
                'info2' = $value2;
                'info3' = $value3;
                'info4' = $value4
            }
            $LimitingCollection = Get-WmiObject -Class SMS_Collection -Filter "CollectionID = '$LimitToCollectionID'" -Namespace root/sms/site_$($sccmConnectionInfo.SiteCode) -ComputerName $sccmConnectionInfo.ComputerName
            Write-Verbose "Processing $computer"
            # use $computer to target a single computer

            if ($PSCmdlet.ShouldProcess($CIID)) {
            }
            Write-Output (New-Object ?TypenamePSObject ?Prop $returnHashTable)
            $obj = New-Object -TypeName PSObject -Property $ReturnHashTable
            $obj.PSObject.TypeNames.Insert(0, 'CMN.ObjectType')
            Return $obj
        }
    }

    end {
    }
} # End Set-CMNScriptTimeout

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
            LogFile       = $logFile;
            Component     = 'Set-CMNUpdateDeploymentCollections';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }
        #Build splats for WMIQueries
        $WMIQueryParameters = @{
            ComputerName = $sccmConnectionInfo.ComputerName;
            NameSpace    = $sccmConnectionInfo.NameSpace;
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
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry
        }

        # Get Maintenance Window FolderID
        if ($PSBoundParameters['logEntries']) {
            $maintenanceFolderID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $sccmConnectionInfo -Name $maintenanceWindowFolder -ObjectType SMS_Collection_Device -logFile $logFile -logEntries
        }
        else {
            $maintenanceFolderID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $sccmConnectionInfo -Name $maintenanceWindowFolder -ObjectType SMS_Collection_Device
        }

        # Get Deployment Folder ID
        if ($PSBoundParameters['logEntries']) {
            $deploymentFolderID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $sccmConnectionInfo -Name $deploymentFolder -ObjectType SMS_Collection_Device -logFile $logFile -logEntries
        }
        else {
            $deploymentFolderID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $sccmConnectionInfo -Name $deploymentFolder -ObjectType SMS_Collection_Device
        }

        # Get Deployment Reboot Folder ID
        if ($PSBoundParameters['logEntries']) {
            $deploymentRebootFolderID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $sccmConnectionInfo -Name "$deploymentFolder\Reboot" -ObjectType SMS_Collection_Device -logFile $logFile -logEntries
        }
        else {
            $deploymentRebootFolderID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $sccmConnectionInfo -Name $"$deploymentFolder\Reboot" -ObjectType SMS_Collection_Device
        }

        # Get Deployment NoReboot Folder ID
        if ($PSBoundParameters['logEntries']) {
            $deploymentNoRebootFolderID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $sccmConnectionInfo -Name "$deploymentFolder\NoReboot" -ObjectType SMS_Collection_Device -logFile $logFile -logEntries
        }
        else {
            $deploymentNoRebootFolderID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $sccmConnectionInfo -Name "$deploymentFolder\NoReboot" -ObjectType SMS_Collection_Device
        }

        # Get collectionID's under the deployment folder
        if ($PSBoundParameters['logEntries']) {
            $deployToCollectionIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $sccmConnectionInfo -parentContainerNodeID $deploymentFolderID -ObjectType SMS_Collection_Device -logFile $logFile -logEntries
        }
        else {
            $deployToCollectionIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $sccmConnectionInfo -parentContainerNodeID $deploymentFolderID -ObjectType SMS_Collection_Device
        }

        # Get collectionID's under the reboot folder
        if ($PSBoundParameters['logEntries']) {
            $rebootCollectionIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $sccmConnectionInfo -parentContainerNodeID $deploymentRebootFolderID -ObjectType SMS_Collection_Device -Recurse -logFile $logFile -logEntries
        }
        else {
            $rebootCollectionIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $sccmConnectionInfo -parentContainerNodeID $deploymentRebootFolderID -ObjectType SMS_Collection_Device -Recurse
        }

        # Get collectionID's under the noReboot folder
        if ($PSBoundParameters['logEntries']) {
            $noRebootCollectionIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $sccmConnectionInfo -parentContainerNodeID $deploymentNoRebootFolderID -ObjectType SMS_Collection_Device -Recurse -logFile $logFile -logEntries
        }
        else {
            $noRebootCollectionIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $sccmConnectionInfo -parentContainerNodeID $deploymentNoRebootFolderID -ObjectType SMS_Collection_Device -Recurse
        }

        # Now that we have the reboot/noreboot collectionIDs, let's get collectionID's under folder (no recursion)
        if ($PSBoundParameters['logEntries']) {
            $mwCollectionIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $sccmConnectionInfo -parentContainerNodeID $maintenanceFolderID -ObjectType SMS_Collection_Device -logFile $logFile -logEntries | Where-Object { $_ -ne '' }
        }
        else {
            $mwCollectionIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $sccmConnectionInfo -parentContainerNodeID $maintenanceFolderID -ObjectType SMS_Collection_Device | Where-Object { $_ -ne '' }
        }

        # Cycle through the ID's and build the Reboot/NoReboot Collection Objects
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Building include rules for later' -type 1 @NewLogEntry
        }
        $noRebootColRules = New-Object System.Collections.ArrayList
        $rebootColRules = New-Object System.Collections.ArrayList
        foreach ($mwCollectionID in $mwCollectionIDs) {
            $query = "select * from sms_collection where collectionID = '$mwCollectionID'"
            $collection = Get-WmiObject -Query $query @WMIQueryParameters
            $includeRule = ([WMIClass]"//$($sccmConnectionInfo.ComputerName)/$($sccmConnectionInfo.NameSpace):SMS_CollectionRuleIncludeCollection").CreateInstance()
            $includeRule.IncludeCollectionID = $mwCollectionID
            $includeRule.RuleName = $collection.Name
            if ($collection.Name -match 'NoReboot' -or $collection.Name -match 'No Reboot') {
                if ($PSBoundParameters['logEntries']) {
                    New-CMNLogEntry -entry "Adding $($collection.Name) to noReboot rules" -type 1 @NewLogEntry
                }
                $noRebootColRules.Add($includeRule) | Out-Null
            }
            elseif ($collection.name -notmatch 'Do Not Patch') {
                if ($PSBoundParameters['logEntries']) {
                    New-CMNLogEntry -entry "Adding $($collection.Name) to reboot rules" -type 1 @NewLogEntry
                }
                $rebootColRules.Add($includeRule) | Out-Null
            }
        }

        # Cycle throgh and verify/create reboot/noreboot collections
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Updating Deploy to collections with new include rules' -type 1 @NewLogEntry
        }
        foreach ($deployToCollectionID in $deployToCollectionIDs) {
            $query = "Select * from SMS_Collection where CollectionID = '$deployToCollectionID'"
            $collection = Get-WmiObject -Query $query @WMIQueryParameters
            if ($PSBoundParameters['logEntries']) {
                New-CMNLogEntry -entry "Processing $($collection.Name)" -type 1 @NewLogEntry
            }

            # if we don't get a collection, we've got a problem
            if ($collection) {
                $rebootCollectionName = "$($collection.Name) - Reboot"
                $noRebootCollectionName = "$($collection.Name) - NoReboot"
                # See if Reboot Collection Exists
                $query = "Select * from SMS_Collection where Name = '$rebootCollectionName'"
                $rebootCollection = Get-WmiObject -Query $query @WMIQueryParameters
                if (-not($rebootCollection)) {
                    if ($PSBoundParameters['logEntries']) {
                        New-CMNLogEntry -entry "$rebootCollectionName doesn't exist, creating." -type 1 @NewLogEntry
                    }
                    $rebootCollection = New-CMNDeviceCollection -SCCMConnectionInfo $sccmConnectionInfo -limitToCollectionID $collection.CollectionID -name $rebootCollectionName -comment 'Created by script'
                    Move-CMNObject -SCCMConnectionInfo $sccmConnectionInfo -objectID $rebootCollection.CollectionID -destinationContainerID $deploymentRebootFolderID -objectType SMS_Collection_Device
                }

                # See if NoReboot Collection Exists
                $query = "Select * from SMS_Collection where name = '$noRebootCollectionName'"
                $noRebootCollection = Get-WmiObject -Query $query @WMIQueryParameters
                if (-not($noRebootCollection)) {
                    if ($PSBoundParameters['logEntries']) {
                        New-CMNLogEntry -entry "$noRebootCollectionName doesn't exist, creating." -type 1 @NewLogEntry
                    }
                    $noRebootCollection = New-CMNDeviceCollection -SCCMConnectionInfo $sccmConnectionInfo -limitToCollectionID $collection.CollectionID -name $noRebootCollectionName -comment 'Created by script'
                    Move-CMNObject -SCCMConnectionInfo $sccmConnectionInfo -objectID $noRebootCollection.CollectionID -destinationContainerID $deploymentNoRebootFolderID -objectType SMS_Collection_Device
                }

                # Get rid of the existing rules
                if ($PSBoundParameters['logEntries']) {
                    New-CMNLogEntry -entry "Removing rules from $rebootCollectionName" -type 1 @NewLogEntry
                }
                $rebootCollection.get()
                $rebootCollection.DeleteMembershipRules($rebootCollection.CollectionRules)
                if ($PSBoundParameters['logEntries']) {
                    New-CMNLogEntry -entry "Adding rules to $rebootCollectionName" -type 1 @NewLogEntry
                }
                $rebootCollection.get()
                $rebootCollection.AddMemberShipRules($rebootColRules) | Out-Null

                if ($PSBoundParameters['logEntries']) {
                    New-CMNLogEntry -entry "Removing rules from $noRebootCollectionName" -type 1 @NewLogEntry
                }
                $noRebootCollection.get()
                $noRebootCollection.DeleteMembershipRules($noRebootCollection.CollectionRules)
                if ($PSBoundParameters['logEntries']) {
                    New-CMNLogEntry -entry "Adding rules to $noRebootCollectionName" -type 1 @NewLogEntry
                }
                $noRebootCollection.get()
                $noRebootCollection.AddMemberShipRules($noRebootColRules) | Out-Null
            }
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        }
    }
} #End Set-CMNUpdateDeploymentCollections

Function Show-CMNLogs {
    <#
	    .SYNOPSIS
		    Opens logfiles using CMTrace for particular activity

	    .DESCRIPTION
		    You specify what activity you want to view logs for, this will open CMtrace showing those log files.
            This script assumes you have CMTrace in the directory you are in or in your path

	    .PARAMETER computerName
            Name of computer you want to view the logs for, defaults to localhost

        .PARAMETER activity
            Activity you are interested in, default is Default. Available values are:
                Default
                ClientDeployment
                ClientInventory
                Updates

	    .EXAMPLE
            Show-CMNLogs -computerName Computer1 -logs ClientDeployment
	    .LINK
		    http://configman-notes.com

	    .NOTES
		    Author:	Jim Parris
		    Email:	Jim@ConfigMan-Notes
		    Date:	2/1/2017
		    PSVer:	2.0/3.0
    #>

    [cmdletbinding()]
    PARAM
    (
        [Parameter(Mandatory = $false,
            HelpMessage = 'Computer name')]
        [ValidateScript( { Test-Connection -ComputerName $_ -Count 1 -Quiet })]
        [String]$computerName = 'localHost',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Logs to look at')]
        [ValidateSet('Default', 'Application', 'ClientDeployment', 'ClientInventory', 'Updates', 'DCM', 'Schedule')]
        [String]$activity = 'Default'
    )
    #Hash table for log lists
    $sccmLogs = @{
        Default          = ('CAS.log', 'NomadBranch.log', 'PolicyAgent.log', 'ccmexec.log', 'execmgr.log');
        Application      = ('AppDiscovery.log', 'AppEnforce.log', 'CAS.log', 'NomadBranch.log', 'PolicyAgent.log', 'ccmexec.log', 'execmgr.log');
        ClientDeployment = ('ContentTransferManager.log', 'DataTransferService.log', 'LocationServices.log', 'ClientLocation.log', 'NomadBranch.log', 'ClientIDManagerStartup.log', 'PolicyAgent.log', 'CCMExec.log', 'ExecMgr.log');
        ClientInventory  = ('InventoryProvider.log', 'InventoryAgent.log', 'NomadBranch.log', 'PolicyAgent.log', 'CCMExec.log', 'ExecMgr.log');
        Updates          = ('CIDownloader.log', 'DataTransferService.log', 'ContentTransferManager.log', 'CAS.log', 'Scheduler.log', 'ServiceWindowManager.log', 'WUAhandler.log', 'UpdatesDeployment.log', 'ScanAgent.log', 'PolicyAgent.log', 'CCMExec.log', 'ExecMgr.log');
        DCM              = ('CIAgent.log', 'DCMWMIProvider.log', 'DCMAgent.log', 'DCMReporting.log', 'PolicyAgent.log', 'CCMExec.log', 'ExecMgr.log');
        Schedule         = ('ServiceWindowManager.log', 'Scheduler.log', 'CAS.log', 'NomadBranch.log', 'PolicyAgent.log', 'ccmexec.log', 'execmgr.log');
    }

    $nonSCCMLogs = @{
        ClientDeployment = ('\\ComputerName\C$\Windows\CCMSetup\Logs\CCMSetup.log', '\\ComputerName\C$\temp\Software_Install_Logs\System Center Configuration Manager (SCCM) Client_PSAppDeployToolkit_Install.log', '\\ComputerName\C$\temp\Software_Install_Logs\System Center Configuration Manager (SCCM) Client_PSAppDeployToolkit_Uninstall.log');
        Updates          = ('\\ComputerName\C$\Windows\WindowsUpdate.log');
    }

    #Make sure we have a good computername
    if ($computerName -eq 'localhost') {
        $computerName = $env:COMPUTERNAME
    }

    #get log base directory from registry
    $key = 'SOFTWARE\\Microsoft\\CCM\\Logging\\@Global'
    $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computerName)
    $RegKey = $Reg.OpenSubKey($key)
    $ccmLogDir = $RegKey.GetValue("LogDirectory")
    #"(?<pre>.*)st",'${pre}ar'
    $ccmLogDir -match '(.):\\(.*)' | Out-Null
    $ccmLogDir = "\\$computerName\$($Matches[1])$\$($Matches[2])"

    #Time to build the command
    $command = 'CMTrace'

    #Add the Non-SCCM logs first
    foreach ($log in $nonSCCMLogs[$activity]) {
        $line = $log -replace 'ComputerName', $computerName
        $command = "$command ""$line"""
    }

    foreach ($log in $sccmLogs[$activity]) {
        $command = "$command ""$ccmLogDir\$log"""
    }

    Invoke-Expression -Command $command
} # End Show-CMNLogs

Function Show-CMNPendingReboot {
    <#
	.SYNOPSIS
		Gets the pending reboot status on a local or remote computer.

	.DESCRIPTION
		This function will query the registry on a local or remote computer and determine if the
		system is pending a reboot, from either Microsoft Patching or a Software Installation.
		For Windows 2008+ the function will query the CBS registry key as another factor in determining
		pending reboot state.  "PendingFileRenameOperations" and "Auto Update\RebootRequired" are observed
		as being consistant across Windows Server 2003 & 2008.

		CBServicing = Component Based Servicing (Windows 2008)
		WindowsUpdate = Windows Update / Auto Update (Windows 2003 / 2008)
		CCMClientSDK = SCCM 2012 Clients only (DetermineIfRebootPending method) otherwise $null value
		PendFileRename = PendingFileRenameOperations (Windows 2003 / 2008)

	.PARAMETER ComputerName
		A single Computer or an array of computer names.  The default is localhost ($env:COMPUTERNAME).

	.PARAMETER ErrorLog
		A single path to send error data to a log file.

	.EXAMPLE
		PS C:\> Get-PendingReboot -ComputerName (Get-Content C:\ServerList.txt) | Format-Table -AutoSize

		Computer CBServicing WindowsUpdate CCMClientSDK PendFileRename PendFileRenVal RebootPending
		-------- ----------- ------------- ------------ -------------- -------------- -------------
		DC01     False   False           False      False
		DC02     False   False           False      False
		FS01     False   False           False      False

		This example will capture the contents of C:\ServerList.txt and query the pending reboot
		information from the systems contained in the file and display the output in a table. The
		null values are by design, since these systems do not have the SCCM 2012 client installed,
		nor was the PendingFileRenameOperations value populated.

	.EXAMPLE
		PS C:\> Get-PendingReboot

		Computer     : WKS01
		CBServicing  : False
		WindowsUpdate      : True
		CCMClient    : False
		PendComputerRename : False
		PendFileRename     : False
		PendFileRenVal     :
		RebootPending      : True

		This example will query the local machine for pending reboot information.

	.EXAMPLE
		PS C:\> $Servers = Get-Content C:\Servers.txt
		PS C:\> Get-PendingReboot -Computer $Servers | Export-Csv C:\PendingRebootReport.csv -NoTypeInformation

		This example will create a report that contains pending reboot information.

	.LINK
		Component-Based Servicing:
		http://technet.microsoft.com/en-us/library/cc756291(v=WS.10).aspx

		PendingFileRename/Auto Update:
		http://support.microsoft.com/kb/2723674
		http://technet.microsoft.com/en-us/library/cc960241.aspx
		http://blogs.msdn.com/b/hansr/archive/2006/02/17/patchreboot.aspx

		SCCM 2012/CCM_ClientSDK:
		http://msdn.microsoft.com/en-us/library/jj902723.aspx

	.NOTES
		Author:  Brian Wilhite
		Email:   bcwilhite (at) live.com
		Date:    29AUG2012
		PSVer:   2.0/3.0/4.0/5.0
		Updated: 01DEC2014
		UpdNote: Added CCMClient property - Used with SCCM 2012 Clients only
		   Added ValueFromPipelineByPropertyName=$true to the ComputerName Parameter
		   Removed $Data variable from the PSObject - it is not needed
		   Bug with the way CCMClientSDK returned null value if it was false
		   Removed unneeded variables
		   Added PendFileRenVal - Contents of the PendingFileRenameOperations Reg Entry
		   Removed .Net Registry connection, replaced with WMI StdRegProv
		   Added ComputerPendingRename
	#>

    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("CN", "Computer")]
        [String[]]$ComputerName = "$env:COMPUTERNAME",
        [String]$ErrorLog
    )

    begin {
    }## End Begin Script Block
    process {
        Foreach ($Computer in $ComputerName) {
            Try {
                ## Setting pending values to false to cut down on the number of else statements
                $CompPendRen, $PendFileRename, $Pending, $SCCM = $false, $false, $false, $false

                ## Setting CBSRebootPend to null since not all versions of Windows has this value
                $CBSRebootPend = $null

                ## Querying WMI for build version
                $WMI_OS = Get-WmiObject -Class Win32_OperatingSystem -Property BuildNumber, CSName -ComputerName $Computer -ErrorAction Stop

                ## Making registry connection to the local/remote computer
                $HKLM = [UInt32] "0x80000002"
                $WMI_Reg = [WMIClass] "\\$Computer\root\default:StdRegProv"

                ## If Vista/2008 & Above query the CBS Reg Key
                If ([Int32]$WMI_OS.BuildNumber -ge 6001) {
                    $RegSubKeysCBS = $WMI_Reg.EnumKey($HKLM, "SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\")
                    $CBSRebootPend = $RegSubKeysCBS.sNames -contains "RebootPending"
                }

                ## Query WUAU from the registry
                $RegWUAURebootReq = $WMI_Reg.EnumKey($HKLM, "SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\")
                $WUAURebootReq = $RegWUAURebootReq.sNames -contains "RebootRequired"

                ## Query PendingFileRenameOperations from the registry
                $RegSubKeySM = $WMI_Reg.GetMultiStringValue($HKLM, "SYSTEM\CurrentControlSet\Control\Session Manager\", "PendingFileRenameOperations")
                $RegValuePFRO = $RegSubKeySM.sValue

                ## Query ComputerName and ActiveComputerName from the registry
                $ActCompNm = $WMI_Reg.GetStringValue($HKLM, "SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName\", "ComputerName")
                $CompNm = $WMI_Reg.GetStringValue($HKLM, "SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\", "ComputerName")
                If ($ActCompNm -ne $CompNm) {
                    $CompPendRen = $true
                }

                ## If PendingFileRenameOperations has a value set $RegValuePFRO variable to $true
                If ($RegValuePFRO) {
                    $PendFileRename = $true
                }

                ## Determine SCCM 2012 Client Reboot Pending Status
                ## To avoid nested 'if' statements and unneeded WMI calls to determine if the CCM_ClientUtilities class exist, setting EA = 0
                $CCMClientSDK = $null
                $CCMSplat = @{
                    NameSpace    = 'ROOT\ccm\ClientSDK'
                    Class        = 'CCM_ClientUtilities'
                    Name         = 'DetermineIfRebootPending'
                    ComputerName = $Computer
                    ErrorAction  = 'Stop'
                }
                ## Try CCMClientSDK
                Try {
                    $CCMClientSDK = Invoke-WmiMethod @CCMSplat
                }
                Catch [System.UnauthorizedAccessException] {
                    $CcmStatus = Get-Service -Name CcmExec -ComputerName $Computer -ErrorAction SilentlyContinue
                    If ($CcmStatus.Status -ne 'Running') {
                        Write-Warning "$Computer`: Error - CcmExec service is not running."
                        $CCMClientSDK = $null
                    }
                }
                Catch {
                    $CCMClientSDK = $null
                }

                If ($CCMClientSDK) {
                    If ($CCMClientSDK.ReturnValue -ne 0) {
                        Write-Warning "Error: DetermineIfRebootPending returned error code $($CCMClientSDK.ReturnValue)"
                    }
                    If ($CCMClientSDK.IsHardRebootPending -or $CCMClientSDK.RebootPending) {
                        $SCCM = $true
                    }
                }

                Else {
                    $SCCM = $null
                }

                ## Creating Custom PSObject and Select-Object Splat
                $SelectSplat = @{
                    Property = (
                        'Computer',
                        'CBServicing',
                        'WindowsUpdate',
                        'CCMClientSDK',
                        'PendComputerRename',
                        'PendFileRename',
                        'PendFileRenVal',
                        'RebootPending'
                    )
                }
                New-Object -TypeName PSObject -Property @{
                    Computer           = $WMI_OS.CSName
                    CBServicing        = $CBSRebootPend
                    WindowsUpdate      = $WUAURebootReq
                    CCMClientSDK       = $SCCM
                    PendComputerRename = $CompPendRen
                    PendFileRename     = $PendFileRename
                    PendFileRenVal     = $RegValuePFRO
                    RebootPending      = ($CompPendRen -or $CBSRebootPend -or $WUAURebootReq -or $SCCM -or $PendFileRename)
                } | Select-Object @SelectSplat
            }
            Catch {
                Write-Warning "$Computer`: $_"
                ## If $ErrorLog, log the file to a user specified location/path
                If ($ErrorLog) {
                    Out-File -InputObject "$Computer`,$_" -FilePath $ErrorLog -Append
                }
            }
        }## End Foreach ($Computer in $ComputerName)
    }## End Process

    end {
    }## End End
}## End Function Show-CMNPendingReboot

Function Test-CMNPendingReboot {
    <#
	.SYNOPSIS
		Gets the pending reboot status on a local or remote computer.

	.DESCRIPTION
		This function will query the registry on a local or remote computer and determine if the
		system is pending a reboot, from either Microsoft Patching or a Software Installation.
		For Windows 2008+ the function will query the CBS registry key as another factor in determining
		pending reboot state.  "PendingFileRenameOperations" and "Auto Update\RebootRequired" are observed
		as being consistant across Windows Server 2003 & 2008.

		CBServicing = Component Based Servicing (Windows 2008)
		WindowsUpdate = Windows Update / Auto Update (Windows 2003 / 2008)
		CCMClientSDK = SCCM 2012 Clients only (DetermineIfRebootPending method) otherwise $null value
		PendFileRename = PendingFileRenameOperations (Windows 2003 / 2008)

	.PARAMETER ComputerName
		A single Computer or an array of computer names.  The default is localhost ($env:COMPUTERNAME).

	.PARAMETER ErrorLog
		A single path to send error data to a log file.

	.EXAMPLE
		PS C:\> Get-PendingReboot -ComputerName (Get-Content C:\ServerList.txt) | Format-Table -AutoSize

		Computer CBServicing WindowsUpdate CCMClientSDK PendFileRename PendFileRenVal RebootPending
		-------- ----------- ------------- ------------ -------------- -------------- -------------
		DC01     False   False           False      False
		DC02     False   False           False      False
		FS01     False   False           False      False

		This example will capture the contents of C:\ServerList.txt and query the pending reboot
		information from the systems contained in the file and display the output in a table. The
		null values are by design, since these systems do not have the SCCM 2012 client installed,
		nor was the PendingFileRenameOperations value populated.

	.EXAMPLE
		PS C:\> Get-PendingReboot

		Computer     : WKS01
		CBServicing  : False
		WindowsUpdate      : True
		CCMClient    : False
		PendComputerRename : False
		PendFileRename     : False
		PendFileRenVal     :
		RebootPending      : True

		This example will query the local machine for pending reboot information.

	.EXAMPLE
		PS C:\> $Servers = Get-Content C:\Servers.txt
		PS C:\> Get-PendingReboot -Computer $Servers | Export-Csv C:\PendingRebootReport.csv -NoTypeInformation

		This example will create a report that contains pending reboot information.

	.LINK
		Component-Based Servicing:
		http://technet.microsoft.com/en-us/library/cc756291(v=WS.10).aspx

		PendingFileRename/Auto Update:
		http://support.microsoft.com/kb/2723674
		http://technet.microsoft.com/en-us/library/cc960241.aspx
		http://blogs.msdn.com/b/hansr/archive/2006/02/17/patchreboot.aspx

		SCCM 2012/CCM_ClientSDK:
		http://msdn.microsoft.com/en-us/library/jj902723.aspx

	.NOTES
		Author:  Brian Wilhite
		Email:   bcwilhite (at) live.com
		Date:    29AUG2012
		PSVer:   2.0/3.0/4.0/5.0
		Updated: 01DEC2014
		UpdNote: Added CCMClient property - Used with SCCM 2012 Clients only
		   Added ValueFromPipelineByPropertyName=$true to the ComputerName Parameter
		   Removed $Data variable from the PSObject - it is not needed
		   Bug with the way CCMClientSDK returned null value if it was false
		   Removed unneeded variables
		   Added PendFileRenVal - Contents of the PendingFileRenameOperations Reg Entry
		   Removed .Net Registry connection, replaced with WMI StdRegProv
		   Added ComputerPendingRename
	#>

    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("CN", "Computer")]
        [String[]]$ComputerName = "$env:COMPUTERNAME",
        [String]$ErrorLog
    )

    begin {
    }## End Begin Script Block
    process {
        Foreach ($Computer in $ComputerName) {
            Try {
                ## Setting pending values to false to cut down on the number of else statements
                $CompPendRen, $PendFileRename, $Pending, $SCCM = $false, $false, $false, $false

                ## Setting CBSRebootPend to null since not all versions of Windows has this value
                $CBSRebootPend = $null

                ## Querying WMI for build version
                $WMI_OS = Get-WmiObject -Class Win32_OperatingSystem -Property BuildNumber, CSName -ComputerName $Computer -ErrorAction Stop

                ## Making registry connection to the local/remote computer
                $HKLM = [UInt32] "0x80000002"
                $WMI_Reg = [WMIClass] "\\$Computer\root\default:StdRegProv"

                ## If Vista/2008 & Above query the CBS Reg Key
                If ([Int32]$WMI_OS.BuildNumber -ge 6001) {
                    $RegSubKeysCBS = $WMI_Reg.EnumKey($HKLM, "SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\")
                    $CBSRebootPend = $RegSubKeysCBS.sNames -contains "RebootPending"
                }

                ## Query WUAU from the registry
                $RegWUAURebootReq = $WMI_Reg.EnumKey($HKLM, "SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\")
                $WUAURebootReq = $RegWUAURebootReq.sNames -contains "RebootRequired"

                ## Query PendingFileRenameOperations from the registry
                $RegSubKeySM = $WMI_Reg.GetMultiStringValue($HKLM, "SYSTEM\CurrentControlSet\Control\Session Manager\", "PendingFileRenameOperations")
                $RegValuePFRO = $RegSubKeySM.sValue

                ## Query ComputerName and ActiveComputerName from the registry
                $ActCompNm = $WMI_Reg.GetStringValue($HKLM, "SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName\", "ComputerName")
                $CompNm = $WMI_Reg.GetStringValue($HKLM, "SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\", "ComputerName")
                If ($ActCompNm -ne $CompNm) {
                    $CompPendRen = $true
                }

                ## If PendingFileRenameOperations has a value set $RegValuePFRO variable to $true
                If ($RegValuePFRO) {
                    $PendFileRename = $true
                }

                ## Determine SCCM 2012 Client Reboot Pending Status
                ## To avoid nested 'if' statements and unneeded WMI calls to determine if the CCM_ClientUtilities class exist, setting EA = 0
                $CCMClientSDK = $null
                $CCMSplat = @{
                    NameSpace    = 'ROOT\ccm\ClientSDK'
                    Class        = 'CCM_ClientUtilities'
                    Name         = 'DetermineIfRebootPending'
                    ComputerName = $Computer
                    ErrorAction  = 'Stop'
                }
                ## Try CCMClientSDK
                Try {
                    $CCMClientSDK = Invoke-WmiMethod @CCMSplat
                }
                Catch [System.UnauthorizedAccessException] {
                    $CcmStatus = Get-Service -Name CcmExec -ComputerName $Computer -ErrorAction SilentlyContinue
                    If ($CcmStatus.Status -ne 'Running') {
                        Write-Warning "$Computer`: Error - CcmExec service is not running."
                        $CCMClientSDK = $null
                    }
                }
                Catch {
                    $CCMClientSDK = $null
                }

                If ($CCMClientSDK) {
                    If ($CCMClientSDK.ReturnValue -ne 0) {
                        Write-Warning "Error: DetermineIfRebootPending returned error code $($CCMClientSDK.ReturnValue)"
                    }
                    If ($CCMClientSDK.IsHardRebootPending -or $CCMClientSDK.RebootPending) {
                        $SCCM = $true
                    }
                }

                Else {
                    $SCCM = $null
                }

                ## Creating Custom PSObject and Select-Object Splat
                $SelectSplat = @{
                    Property = (
                        'Computer',
                        'CBServicing',
                        'WindowsUpdate',
                        'CCMClientSDK',
                        'PendComputerRename',
                        'PendFileRename',
                        'PendFileRenVal',
                        'RebootPending'
                    )
                }
                New-Object -TypeName PSObject -Property @{
                    Computer           = $WMI_OS.CSName
                    CBServicing        = $CBSRebootPend
                    WindowsUpdate      = $WUAURebootReq
                    CCMClientSDK       = $SCCM
                    PendComputerRename = $CompPendRen
                    PendFileRename     = $PendFileRename
                    PendFileRenVal     = $RegValuePFRO
                    RebootPending      = ($CompPendRen -or $CBSRebootPend -or $WUAURebootReq -or $SCCM -or $PendFileRename)
                } | Select-Object @SelectSplat
            }
            Catch {
                Write-Warning "$Computer`: $_"
                ## If $ErrorLog, log the file to a user specified location/path
                If ($ErrorLog) {
                    Out-File -InputObject "$Computer`,$_" -FilePath $ErrorLog -Append
                }
            }
        }## End Foreach ($Computer in $ComputerName)
    }## End Process

    end {
    }## End End
}## End Function Test-CMNPendingReboot

Function Test-CMNPackageExists {
    <#
	.SYNOPSIS
		Tests to see if a package exists or not

	.DESCRIPTION
		Tests to see if a package exists or not

	.PARAMETER SCCMConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.

	.PARAMETER PackageID
		PackageID to test for

	.EXAMPLE

	.NOTES

	.LINK
		http://configman-notes.com
	#>
    PARAM
    (
        [Parameter(Mandatory = $true,
            HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true,
            HelpMessage = 'PackageID to test for')]
        [String]$packageID
    )
    $package = Get-WmiObject -Class SMS_Package -Filter "PackageID = '$packageID'" -ComputerName $sccmConnectionInfo.ComputerName -Namespace $sccmConnectionInfo.NameSpace
    if ($package) {
        Write-Output $true
    }
    else {
        Write-Output $false
    }
} #End Test-CMNPackageExists
Function Start-CMNApplicationDeployment {
    <#
	.SYNOPSIS
		Deploys an application to a specified collection.

	.DESCRIPTION

		This function expects the variable $WMIQueryParameters to be used, if you have your site server, you can use the info below
		to get your necessary information:

		$SiteServer = '<InsertServerName>'
		$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

		$WMIQueryParameters = @{
			ComputerName = $SiteServer
			Namespace = "root\sms\site_$SiteCode"

	.PARAMETER CollectionID
		CollectionID of the target collection

	.PARAMETER ApplicationName
		Application to be deployed

	.PARAMETER Purpose
		Is this an Install or Uninstall

	.PARAMTER OfferType
		Available or Required

	.PARAMTER EnforcementDeadline
		For Required deployments, the Scheduled Start Time.

	.EXAMPLE
		Start-CMNApplicationDeployment 'SMS00001' 'Adobe Reader' 'Install' 'Available'

	.NOTES

	.LINK
		http://configman-notes.com
	#>
    PARAM
    (
        [Parameter(Mandatory = $true)]
        [String]$CollectionID,
        [Parameter(Mandatory = $true)]
        [String]$ApplicationName,
        [Parameter(Mandatory = $true, HelpMessage = 'Install or Uninstall')]
        [String]$Purpose,
        [Parameter(Mandatory = $true, HelpMessage = 'Available/Required')]
        [String]$OfferType,
        [Parameter(Mandatory = $false)]
        [String]$EnforcementDeadline
    )

    $Query = "SELECT * FROM SMS_Application WHERE LocalizedDisplayName = '$ApplicationName'"
    $Application = Get-WmiObject -Query $Query @WMIQueryParameters

    $Query = "Select * from SMS_ApplicationAssignment where TargetCollectionID = '$CollectionID' and AssignedCIs = '$($Application[$Application.count - 1].CI_ID)'"
    $Deployments = Get-WmiObject -Query $Query @WMIQueryParameters
    if ($Deployments) {
        Throw "Already a deployment to that collection"
    }
    else {
        $Query = "select * from SMS_Collection where CollectionID = '$CollectionID'"
        $Collection = Get-WmiObject -Query $Query @WMIQueryParameters

        $ApplicationAssignmentClass = [wmiclass] "\\$SiteServer\root\SMS\SITE_$($SiteCode):SMS_ApplicationAssignment"
        $newApplicationAssingment = $ApplicationAssignmentClass.CreateInstance()
        $newApplicationAssingment.ApplicationName = $Application[$Application.count - 1].localizedDisplayName
        $newApplicationAssingment.AssignmentName = "$($Application[$Application.count - 1].LocalizedDisplayName) to $($Collection.Name)"
        $newApplicationAssingment.AssignedCIs = $Application[$Application.count - 1].CI_ID
        $newApplicationAssingment.AssignmentType = 2
        $newApplicationAssingment.AssignmentDescription = 'Created by Orcestrator'
        $newApplicationAssingment.CollectionName = $Collection.Name
        $newApplicationAssingment.CreationTime = $newApplicationAssingment.ConvertFromDateTime($(Get-Date))
        $newApplicationAssingment.LocaleID = 1033
        $newApplicationAssingment.SourceSite = $SiteCode
        $newApplicationAssingment.StartTime = $newApplicationAssingment.ConvertFromDateTime($(Get-Date))
        $newApplicationAssingment.SuppressReboot = $true
        $newApplicationAssingment.NotifyUser = $true
        $newApplicationAssingment.TargetCollectionID = $($Collection.CollectionID)
        $newApplicationAssingment.WoLEnabled = $false
        $newApplicationAssingment.RebootOutsideOfServiceWindows = $false
        $newApplicationAssingment.OverrideServiceWindows = $false
        $newApplicationAssingment.UseGMTTimes = $false
        if ($OfferType -match 'Available') {
            $newApplicationAssingment.OfferTypeID = 2
        }
        else {
            $newApplicationAssingment.OfferTypeID = 0
            $newApplicationAssingment.EnforcementDeadline = $newApplicationAssingment.ConvertFromDateTime($EnforcementDeadline)
        }

        [void] $newApplicationAssingment.Put()
        Return $newApplicationAssingment.AssignmentID
    }
} #End Start-CMNApplicationDeployment

Function Start-CMNPackageContentDistribution {
    <#
	.SYNOPSIS
		Distributes a package to a specified DPGroup

	.DESCRIPTION
		Distributes a package to a specified DPGroup

		This function expects the variable $WMIQueryParameters to be used, if you have your site server, you can use the info below
		to get your necessary information:

		$SiteServer = '<InsertServerName>'
		$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

		$WMIQueryParameters = @{
			ComputerName = $SiteServer
			Namespace = "root\sms\site_$SiteCode"

	.PARAMETER PackageID
		ID of Package to be Distributed

	.PARAMETER DPGroup
		The DP Group to receive the content

	.EXAMPLE
		Start-CMNPackageContentDistribution 'SMS00001' 'All DP''s'

	.NOTES
		Use ConvertTo-CMNWMISingleQuotedString to translate the DPGroup name if it has single quotes

	.LINK
		http://configman-notes.com
	#>
    PARAM
    (
        [Parameter(Mandatory = $true)]
        [PSObject]$sccmConnectionInfo,
        [Parameter(Mandatory = $true)]
        [String]$PackageID,
        [Parameter(Mandatory = $true)]
        [String]$DPGroup
    )

    $DPGroup = ConvertTo-CMNWMISingleQuotedString -Text $DPGroup

    $ExitCode = ((Get-WmiObject -Class SMS_DistributionPointGroup -Filter "Name = '$DPGroup'"  -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName).AddPackages($PackageID)).ReturnValue
    return $ExitCode
} #End Start-CMNPackageContentDistribution

Function Start-CMNPackageDeployment {
    <#
	.SYNOPSIS
		Deploys a package to a specified collection

	.DESCRIPTION

		This function expects the variable $WMIQueryParameters to be used, if you have your site server, you can use the info below
		to get your necessary information:

		$SiteServer = '<InsertServerName>'
		$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

		$WMIQueryParameters = @{
			ComputerName = $SiteServer
			Namespace = "root\sms\site_$SiteCode"

	.PARAMETER CollectionID
		CollectionID of the target collection

	.PARAMETER PackageID
		ID of Package to be deployed

	.PARAMETER Purpose
		Is this Available or Required

	.PARAMTER ProgramName
		Program from package to run

	.PARAMTER RequiredTime
		For Required deployments, the Scheduled Start Time.

	.PARAMETER Comment
		Comment for deployment

	.EXAMPLE
		Start-CMNPackageDeployment 'SMS00001' 'SMS00032' 'Available' 'Install'

	.NOTES

	.LINK
		http://configman-notes.com
	#>
    PARAM
    (
        [Parameter(Mandatory = $true)]
        [PSObject]$sccmConnectionInfo,
        [Parameter(Mandatory = $true)]
        [String]$CollectionID,
        [Parameter(Mandatory = $true)]
        [String]$PackageID,
        [Parameter(Mandatory = $true, HelpMessage = 'Available/Required')]
        [String]$Purpose,
        [Parameter(Mandatory = $true, HelpMessage = 'Program to run')]
        [String]$ProgramName,
        [Parameter(Mandatory = $false, HelpMessage = 'Program Available Time')]
        [DateTime]$AvailableTime = (Get-Date),
        [Parameter(Mandatory = $false, HelpMessage = 'Program required time (only required if purpose is "Required")')]
        [String]$RequiredTime,
        [Parameter(Mandatory = $false, HelpMessage = 'Comment for deployment')]
        [String]$Comment,
        [Parameter(Mandatory = $false, HelpMessage = 'Set this deployment for Download and Run')]
        [switch]$IsDNR
    )

    #Check to see if the package already has a deployment to that collection.
    if (-not(Get-WmiObject -Class SMS_Advertisement -Filter "CollectionID = '$CollectionID' and PackageID = '$PackageID'" -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName)) {
        $Collection = Get-WmiObject -Class SMS_Collection -Filter "CollectionID = '$CollectionID'" @WMIQueryParameters
        $AdvertisementName = "$($Collection.Name) - $ProgramName"
        if ($Purpose -match 'Available') {
            $Purpose = 2
            $CMSchedule = $null
            $AssignScheduelEnabled = $false
        }
        else {
            $Purpose = 0
            $AssignScheduelEnabled = $true
            #Create Schedule Object
            $CMSchedule = ([WMIClass]"\\$($SiteServer)\Root\sms\site_$($SiteCode):SMS_ST_NonRecurring").CreateInstance()
            $CMSchedule.StartTime = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime((Get-Date $RequiredTime -Format "MM/dd/yyy hh:mm:ss"))
        }
        $NewDeployment = ([WMICLASS]"\\$($SiteServer)\root\sms\site_$($SiteCode):SMS_Advertisement").CreateInstance()
        $NewDeployment.ActionInProgress = 2;
        $NewDeployment.AdvertisementName = $AdvertisementName;
        $NewDeployment.AssignedScheduleEnabled = $AssignScheduelEnabled;
        $NewDeployment.AssignedScheduleIsGMT = $false;
        $NewDeployment.CollectionID = $CollectionID;
        $NewDeployment.Comment = $Comment;
        $NewDeployment.DeviceFlags = 0;
        $NewDeployment.OfferType = $Purpose;
        $NewDeployment.PackageID = $PackageID;
        $NewDeployment.PresentTime = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime($AvailableTime);
        if ($AssignScheduelEnabled) {
            $NewDeployment.PresentTime = ConvertTo-CMNNDMTFDateTime $AvailableTime;
            $NewDeployment.AssignedSchedule = $CMSchedule;
            $NewDeployment.TimeFlags = Set-BitFlagForControl -IsControlEnabled $true -BitFlagHashTable $TimeFlags -CurrentValue $NewDeployment.TimeFlags -KeyName 'ENABLE_MANDATORY'
        }
        $NewDeployment.PresentTimeEnabled = $true;
        $NewDeployment.PresentTimeIsGMT = $false;
        $NewDeployment.Priority = 2;
        $NewDeployment.ProgramName = $ProgramName;
        if ($isDNR) {
            $NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $true -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'DOWNLOAD_FROM_REMOTE_DISPPOINT'
            $NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $true -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'DOWNLOAD_FROM_LOCAL_DISPPOINT'
            $NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'RUN_FROM_REMOTE_DISPPOINT'
            $NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'RUN_FROM_LOCAL_DISPPOINT'
        }
        else {
            $NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'DOWNLOAD_FROM_REMOTE_DISPPOINT'
            $NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'DOWNLOAD_FROM_LOCAL_DISPPOINT'
            $NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $true -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'RUN_FROM_REMOTE_DISPPOINT'
            $NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $true -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'RUN_FROM_LOCAL_DISPPOINT'
        }

        $NewDeployment.SourceSite = $SiteCode
        $NewDeployment.TimeFlags = Set-BitFlagForControl -IsControlEnabled $true -BitFlagHashTable $TimeFlags -CurrentValue $NewDeployment.TimeFlags -KeyName 'ENABLE_PRESENT'
        $NewDeployment.Put() | Out-Null
    }
} #End Start-CMNPackageDeployment

Function Start_CMNSoftwareUpdateDistribution {
    <#
	.SYNOPSIS
		Distributes a Software Update Group to a specified DPGroup

	.DESCRIPTION
		Distributes a Software Update Group to a specified DPGroup

		This function expects the variable $WMIQueryParameters to be used, if you have your site server, you can use the info below
		to get your necessary information:

		$SiteServer = '<InsertServerName>'
		$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

		$WMIQueryParameters = @{
			ComputerName = $SiteServer
			Namespace = "root\sms\site_$SiteCode"

	.PARAMETER PackageID
		ID of Package to be Distributed

	.PARAMETER DPGroup
		The DP Group to receive the content

	.EXAMPLE
		Start_CMNSoftwareUpdateDistribution 'SMS00001' 'All DP''s'

	.NOTES
		Use ConvertTo-CMNWMISingleQuotedString to translate the DPGroup name if it has single quotes
		SMS_AuthorizationList - Contains the SUG's
            SMS_UpdateGroupAssignment - Represents the deployment of an update

            .LINK
            http://configman-notes.com
            #>
    PARAM
    (
        [Parameter(Mandatory = $true)]
        [String]$PackageID,
        [Parameter(Mandatory = $true)]
        [String]$DPGroup
    )

    $ExitCode = ((Get-WmiObject -Class SMS_DistributionPointGroup -Filter "Name = '$DPGroup'" @WMIQueryParameters).AddPackages($PackageID)).ReturnValue
    return $ExitCode
} #End Start_CMNSoftwareUpdateDistribution

Function Test-CMNBitFlagSet {
    <#
	.SYNOPSIS
		Tests to see if the Keyname in the BitFlagHashTable matches the CurrentValue

	.DESCRIPTION
		Used to test of a bitflag is set from a hashtable

	.PARAMETER BitFlagHashTable
		This contains the list of the bitflags, for example the WMI Class SMS_Advertisement has a bitflag called AdvertFlags

		We have defined the following BitFlagHashTables:
			$SMS_Advertisement_AdvertFlags
			$SMS_Advertisement_DeviceFlags
			$SMS_Advertisement_RemoteClientFlags
			$SMS_Advertisement_TimeFlags
			$SMS_Package_PkgFlags
			$SMS_Program_ProgramFlags
	.PARAMETER KeyName
		Using the above example, you may be looking for the IMMEDIATE Key name

	.PARAMETER CurrentValue
		This is the BitFlag current value, what you are trying to see if the KeyName from the BitFlagHashTable is set.

	.EXAMPLE
		Test-CMNBitFlagSet $SMS_Advertisement_AdvertFlags 'IMMEDIATE' $($SMSAdvert.AdvertFlags)

		This will return ture if the IMMEDIATE key is set in the $SMSAdvert.AdvertFlags object, false if it is not

	.NOTES

	.LINK
		http://configman-notes.com
	#>
    PARAM
    (
        [Parameter(Mandatory = $true)]
        [HashTable]$BitFlagHashTable,

        [Parameter(Mandatory = $true)]
        [String]$KeyName,

        [Parameter(Mandatory = $true)]
        [String]$CurrentValue
    )
    if ($CurrentValue -band $BitFlagHashTable.Item($KeyName)) {
        return $True
    }
    else {
        return $False
    }
} #End Test-CMNBitFlagSet

Function Test-CMNPackageExists {
    <#
	.SYNOPSIS
		Tests to see if a package exists or not

	.DESCRIPTION
		Tests to see if a package exists or not

	.PARAMETER SCCMConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.

	.PARAMETER PackageID
		PackageID to test for

	.EXAMPLE

	.NOTES

	.LINK
		http://configman-notes.com
	#>
    PARAM
    (
        [Parameter(Mandatory = $true,
            HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true,
            HelpMessage = 'PackageID to test for')]
        [String]$packageID
    )
    $package = Get-WmiObject -Class SMS_Package -Filter "PackageID = '$packageID'" -ComputerName $sccmConnectionInfo.ComputerName -Namespace $sccmConnectionInfo.NameSpace
    if ($package) {
        Write-Output $true
    }
    else {
        Write-Output $false
    }
} #End Test-CMNPackageExists

Function Test-CMNPKGReferenced {
    #Rename
    <#
        .Synopsis
            This function will return true if the PackageID is referenced by a task sequence or used in a deployment

        .DESCRIPTION
            This function will return true if the PackageID is referenced by a task sequence or used in a deployment

        .PARAMETER PackageID
            This is the PackageID to be checked

        .EXAMPLE

        .LINK
            http://configman-notes.com

        .NOTES

        #>
    Param
    (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'SCCM Connection Info')]
        [PSObject]$sccmConnectionInfo,

        [parameter(Mandatory = $True)]
        [String]$PackageID
    )

    $WMIQueryParameters = $sccmConnectionInfo.WMIParameters
    #New-LogEntry 'Starting Function IsPKGReferenced' 1 'IsPKGReferenced'
    $Package = Get-WmiObject -Class SMS_Package -Filter "PackageID = '$PackageID'" @WMIQueryParameters
    #New-LogEntry "Package - $PackageID" 1 'IsPKGReferenced'
    $IsPKGReferenced = $false

    #Check for task sequence
    $TaskSequence = Get-WmiObject -Class SMS_TaskSequenceReferencesInfo -Filter "ReferencePackageID = '$PackageID'"  -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
    if ($TaskSequence) {
        $IsPKGReferenced = $True
        #New-LogEntry 'It is referenced by a task sequence' 1 'IsPKGReferenced'
    }
    else {
        #New-LogEntry 'It is not referenced by a task sequence' 1 'IsPKGReferenced'
    }

    #Check for distribution
    $DistributionStatus = Get-WmiObject -Class SMS_Advertisement -Filter "PackageID = '$PackageID'"  -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
    if ($DistributionStatus) {
        $IsPKGReferenced = $True
        #New-LogEntry 'It is referenced by a distribution' 1 'IsPKGReferenced'
    }
    else {
        #New-LogEntry 'It is not referenced by a distribution' 1 'IsPKGReferenced'
    }
    #New-LogEntry "End Function - Returning $IsPKGReferenced" 1 'IsPKGReferenced'
    return $IsPKGReferenced
} #End Test-CMNPKGReferenced

Function Test-CMNPendingReboot {
    <#
	.SYNOPSIS
		Gets the pending reboot status on a local or remote computer.

	.DESCRIPTION
		This function will query the registry on a local or remote computer and determine if the
		system is pending a reboot, from either Microsoft Patching or a Software Installation.
		For Windows 2008+ the function will query the CBS registry key as another factor in determining
		pending reboot state.  "PendingFileRenameOperations" and "Auto Update\RebootRequired" are observed
		as being consistant across Windows Server 2003 & 2008.

		CBServicing = Component Based Servicing (Windows 2008)
		WindowsUpdate = Windows Update / Auto Update (Windows 2003 / 2008)
		CCMClientSDK = SCCM 2012 Clients only (DetermineIfRebootPending method) otherwise $null value
		PendFileRename = PendingFileRenameOperations (Windows 2003 / 2008)

	.PARAMETER ComputerName
		A single Computer or an array of computer names.  The default is localhost ($env:COMPUTERNAME).

	.PARAMETER ErrorLog
		A single path to send error data to a log file.

	.EXAMPLE
		PS C:\> Get-PendingReboot -ComputerName (Get-Content C:\ServerList.txt) | Format-Table -AutoSize

		Computer CBServicing WindowsUpdate CCMClientSDK PendFileRename PendFileRenVal RebootPending
		-------- ----------- ------------- ------------ -------------- -------------- -------------
		DC01     False   False           False      False
		DC02     False   False           False      False
		FS01     False   False           False      False

		This example will capture the contents of C:\ServerList.txt and query the pending reboot
		information from the systems contained in the file and display the output in a table. The
		null values are by design, since these systems do not have the SCCM 2012 client installed,
		nor was the PendingFileRenameOperations value populated.

	.EXAMPLE
		PS C:\> Get-PendingReboot

		Computer     : WKS01
		CBServicing  : False
		WindowsUpdate      : True
		CCMClient    : False
		PendComputerRename : False
		PendFileRename     : False
		PendFileRenVal     :
		RebootPending      : True

		This example will query the local machine for pending reboot information.

	.EXAMPLE
		PS C:\> $Servers = Get-Content C:\Servers.txt
		PS C:\> Get-PendingReboot -Computer $Servers | Export-Csv C:\PendingRebootReport.csv -NoTypeInformation

		This example will create a report that contains pending reboot information.

	.LINK
		Component-Based Servicing:
		http://technet.microsoft.com/en-us/library/cc756291(v=WS.10).aspx

		PendingFileRename/Auto Update:
		http://support.microsoft.com/kb/2723674
		http://technet.microsoft.com/en-us/library/cc960241.aspx
		http://blogs.msdn.com/b/hansr/archive/2006/02/17/patchreboot.aspx

		SCCM 2012/CCM_ClientSDK:
		http://msdn.microsoft.com/en-us/library/jj902723.aspx

	.NOTES
		Author:  Brian Wilhite
		Email:   bcwilhite (at) live.com
		Date:    29AUG2012
		PSVer:   2.0/3.0/4.0/5.0
		Updated: 01DEC2014
		UpdNote: Added CCMClient property - Used with SCCM 2012 Clients only
		   Added ValueFromPipelineByPropertyName=$true to the ComputerName Parameter
		   Removed $Data variable from the PSObject - it is not needed
		   Bug with the way CCMClientSDK returned null value if it was false
		   Removed unneeded variables
		   Added PendFileRenVal - Contents of the PendingFileRenameOperations Reg Entry
		   Removed .Net Registry connection, replaced with WMI StdRegProv
		   Added ComputerPendingRename
	#>

    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("CN", "Computer")]
        [String[]]$ComputerName = "$env:COMPUTERNAME",
        [String]$ErrorLog
    )

    begin {
    }## End Begin Script Block

    process {
        Foreach ($Computer in $ComputerName) {
            Try {
                ## Setting pending values to false to cut down on the number of else statements
                $CompPendRen, $PendFileRename, $Pending, $SCCM = $false, $false, $false, $false

                ## Setting CBSRebootPend to null since not all versions of Windows has this value
                $CBSRebootPend = $null

                ## Querying WMI for build version
                $WMI_OS = Get-WmiObject -Class Win32_OperatingSystem -Property BuildNumber, CSName -ComputerName $Computer -ErrorAction Stop

                ## Making registry connection to the local/remote computer
                $HKLM = [UInt32] "0x80000002"
                $WMI_Reg = [WMIClass] "\\$Computer\root\default:StdRegProv"

                ## If Vista/2008 & Above query the CBS Reg Key
                If ([Int32]$WMI_OS.BuildNumber -ge 6001) {
                    $RegSubKeysCBS = $WMI_Reg.EnumKey($HKLM, "SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\")
                    $CBSRebootPend = $RegSubKeysCBS.sNames -contains "RebootPending"
                }

                ## Query WUAU from the registry
                $RegWUAURebootReq = $WMI_Reg.EnumKey($HKLM, "SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\")
                $WUAURebootReq = $RegWUAURebootReq.sNames -contains "RebootRequired"

                ## Query PendingFileRenameOperations from the registry
                $RegSubKeySM = $WMI_Reg.GetMultiStringValue($HKLM, "SYSTEM\CurrentControlSet\Control\Session Manager\", "PendingFileRenameOperations")
                $RegValuePFRO = $RegSubKeySM.sValue

                ## Query ComputerName and ActiveComputerName from the registry
                $ActCompNm = $WMI_Reg.GetStringValue($HKLM, "SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName\", "ComputerName")
                $CompNm = $WMI_Reg.GetStringValue($HKLM, "SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\", "ComputerName")
                If ($ActCompNm -ne $CompNm) {
                    $CompPendRen = $true
                }

                ## If PendingFileRenameOperations has a value set $RegValuePFRO variable to $true
                If ($RegValuePFRO) {
                    $PendFileRename = $true
                }

                ## Determine SCCM 2012 Client Reboot Pending Status
                ## To avoid nested 'if' statements and unneeded WMI calls to determine if the CCM_ClientUtilities class exist, setting EA = 0
                $CCMClientSDK = $null
                $CCMSplat = @{
                    NameSpace    = 'ROOT\ccm\ClientSDK'
                    Class        = 'CCM_ClientUtilities'
                    Name         = 'DetermineIfRebootPending'
                    ComputerName = $Computer
                    ErrorAction  = 'Stop'
                }

                ## Try CCMClientSDK
                Try {
                    $CCMClientSDK = Invoke-WmiMethod @CCMSplat
                }
                Catch [System.UnauthorizedAccessException] {
                    $CcmStatus = Get-Service -Name CcmExec -ComputerName $Computer -ErrorAction SilentlyContinue
                    If ($CcmStatus.Status -ne 'Running') {
                        Write-Warning "$Computer`: Error - CcmExec service is not running."
                        $CCMClientSDK = $null
                    }
                }
                Catch {
                    $CCMClientSDK = $null
                }

                If ($CCMClientSDK) {
                    If ($CCMClientSDK.ReturnValue -ne 0) {
                        Write-Warning "Error: DetermineIfRebootPending returned error code $($CCMClientSDK.ReturnValue)"
                    }
                    If ($CCMClientSDK.IsHardRebootPending -or $CCMClientSDK.RebootPending) {
                        $SCCM = $true
                    }
                }

                Else {
                    $SCCM = $null
                }
                Return ($CompPendRen -or $CBSRebootPend -or $WUAURebootReq -or $SCCM -or $PendFileRename)
            }

            Catch {
                Write-Warning "$Computer`: $_"
                ## If $ErrorLog, log the file to a user specified location/path
                If ($ErrorLog) {
                    Out-File -InputObject "$Computer`,$_" -FilePath $ErrorLog -Append
                }
            }
        }## End Foreach ($Computer in $ComputerName)
    }## End Process

    end {
    }## End End
}## End Function Test-CMNPendingReboot

Function Update-CMNPackageSource {
    <#
	.SYNOPSIS

	.DESCRIPTION

	.PARAMETER ObjectID

	.EXAMPLE

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:
		PSVer:	2.0/3.0
		Updated:
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'SCCM Connection Info')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'Package ID')]
        [String[]]$PackageIDs,

        [Parameter(Mandatory = $true, HelpMessage = 'Updated Pacakge Source')]
        [String]$PackageSource,

        [string]$logname = 'Update-CMNPackageSource.txt'
    )

    begin {
    }

    process {
        Write-Verbose "Beginning process loop"

        foreach ($PackageID in $PackageIDs) {
            if ($PSCmdlet.ShouldProcess($PackageID)) {
                $Package = Get-WmiObject -Class SMS_Package -Namespace root/sms/site_$($sccmConnectionInfo.SiteCode) -ComputerName $sccmConnectionInfo.ComputerName -Filter "PackageID = '$PackageID'"

                Write-Verbose "Processing $($Package.Name)"

                $Package.Get()
                $Package.PkgSourcePath = $PackageSource
                $Package.RefreshPkgSourceFlag = $true

                Write-Verbose 'Applying settings'
                $Package.Put()

                Write-Output $Package
            }
        }
    }

    end {
    }
} #End Update-CMNPackageSource

$FeatureTypes = @("Unknown", "Application", "Program", "Invalid", "Invalid", "Software Update", "Invalid", "Task Sequence")

$OfferTypes = @("Required", "Not Used", "Available")

$FastDPOptions = @('RunProgramFromDistributionPoint', 'DownloadContentFromDistributionPointAndRunLocally')

$ObjectIDtoObjectType = @{
    2    = 'SMS_Package';
    3    = 'SMS_Advertisement';
    7    = 'SMS_Query';
    8    = 'SMS_Report';
    9    = 'SMS_MeteredProductRule';
    11   = 'SMS_ConfigurationItem';
    14   = 'SMS_OperatingSystemInstallPackage';
    17   = 'SMS_StateMigration';
    18   = 'SMS_ImagePackage';
    19   = 'SMS_BootImagePackage';
    20   = 'SMS_TaskSequencePackage';
    21   = 'SMS_DeviceSettingPackage';
    23   = 'SMS_DriverPackage';
    25   = 'SMS_Driver';
    1011 = 'SMS_SoftwareUpdate';
    2011 = 'SMS_ConfigurationBaselineInfo';
    5000 = 'SMS_Collection_Device';
    5001 = 'SMS_Collection_User';
    6000 = 'SMS_ApplicationLatest';
    6001 = 'SMS_ConfigurationItemLatest';
}

$ObjectTypetoObjectID = @{
    'SMS_Package'                       = 2;
    'SMS_Advertisement'                 = 3;
    'SMS_Query'                         = 7;
    'SMS_Report'                        = 8;
    'SMS_MeteredProductRule'            = 9;
    'SMS_ConfigurationItem'             = 11;
    'SMS_OperatingSystemInstallPackage' = 14;
    'SMS_StateMigration'                = 17;
    'SMS_ImagePackage'                  = 18;
    'SMS_BootImagePackage'              = 19;
    'SMS_TaskSequencePackage'           = 20;
    'SMS_DeviceSettingPackage'          = 21;
    'SMS_DriverPackage'                 = 23;
    'SMS_Driver'                        = 25;
    'SMS_SoftwareUpdate'                = 1011;
    'SMS_ConfigurationBaselineInfo'     = 2011;
    'SMS_Collection_Device'             = 5000;
    'SMS_Collection_User'               = 5001;
    'SMS_ApplicationLatest'             = 6000;
    'SMS_ConfigurationItemLatest'       = 6001;
}

$RerunBehaviors = @{
    RERUN_ALWAYS       = 'AlwaysRerunProgram';
    RERUN_NEVER        = 'NeverRerunDeployedProgra';
    RERUN_IF_FAILED    = 'RerunIfFailedPreviousAttempt';
    RERUN_IF_SUCCEEDED = 'RerunIfSucceededOnpreviousAttempt';
}

$SlowDPOptions = @('DoNotRunProgram', 'DownloadContentFromDistributionPointAndLocally', 'RunProgramFromDistributionPoint')

$SMS_Advertisement_AdvertFlags = @{
    IMMEDIATE                         = "0x00000020";
    ONSYSTEMSTARTUP                   = "0x00000100";
    ONUSERLOGON                       = "0x00000200";
    ONUSERLOGOFF                      = "0x00000400";
    WINDOWS_CE                        = "0x00008000";
    ENABLE_PEER_CACHING               = "0x00010000";
    DONOT_FALLBACK                    = "0x00020000";
    ENABLE_TS_FROM_CD_AND_PXE         = "0x00040000";
    OVERRIDE_SERVICE_WINDOWS          = "0x00100000";
    REBOOT_OUTSIDE_OF_SERVICE_WINDOWS = "0x00200000";
    WAKE_ON_LAN_ENABLED               = "0x00400000";
    SHOW_PROGRESS                     = "0x00800000";
    NO_DISPLAY                        = "0x02000000";
    ONSLOWNET                         = "0x04000000";
}

$SMS_Advertisement_DeviceFlags = @{
    AlwaysAssignProgramToTheClient = "0x01000000";
    OnlyIfDeviceHighBandwidth      = "0x02000000";
    AssignIfDocked                 = "0x04000000";
}

$SMS_Advertisement_ProgramFlags = @{
    DYNAMIC_INSTALL            = "0x00000001";
    TS_SHOW_PROGRESS           = "0x00000002";
    DEFAULT_PROGRAM            = "0x0000001";
    DISABLE_MOM_ALERTS         = "0x00000020";
    GENERATE_MOM_ALERT_IF_FAIL = "0x00000040";
    ADVANCED_CLIENT            = "0x00000080";
    DEVICE_PROGRAM             = "0x00000100";
    RUN_DEPENDENT              = "0x00000200";
    NO_COUNTDOWN_DIALOG        = "0x00000400";
    RESTART_ADR                = "0x00000800";
    PROGRAM_DISABLED           = "0x00001000";
    NO_USER_INTERACTION        = "0x00002000";
    RUN_IN_USER_CONTEXT        = "0x00004000";
    RUN_AS_ADMINISTRATOR       = "0x00008000";
    RUN_FOR_EVERY_USER         = "0x00010000";
    NO_USER_LOGGED_ON          = "0x00020000";
    EXIT_FOR_RESTART           = "0x00080000";
    USE_UNC_PATH               = "0x00100000";
    PERSIST_CONNECTION         = "0x00200000";
    RUN_MINIMIZED              = "0x00400000";
    RUN_MAXIMIZED              = "0x00800000";
    RUN_HIDDEN                 = "0x01000000";
    LOGOFF_WHEN_COMPLETE       = "0x02000000"
    ADMIN_ACCOUNT_DEFINED      = "0x04000000";
    OVERRIDE_PLATFORM_CHECK    = "0x08000000";
    UNINSTALL_WHEN_EXPIRED     = "0x20000000";
    PLATFORM_NOT_SUPPORTED     = "0x40000000"
    DISPLAY_IN_ADR             = "0x80000000";
}

$SMS_Advertisement_RemoteClientFlags = @{
    BATTERY_POWER                     = "0x00000001";
    RUN_FROM_CD                       = "0x00000002";
    DOWNLOAD_FROM_CD                  = "0x00000004";
    RUN_FROM_LOCAL_DISPPOINT          = "0x00000008";
    DOWNLOAD_FROM_LOCAL_DISPPOINT     = "0x00000010";
    DONT_RUN_NO_LOCAL_DISPPOINT       = "0x00000020";
    DOWNLOAD_FROM_REMOTE_DISPPOINT    = "0x00000040";
    RUN_FROM_REMOTE_DISPPOINT         = "0x00000080";
    DOWNLOAD_ON_DEMAND_FROM_LOCAL_DP  = "0x00000100";
    DOWNLOAD_ON_DEMAND_FROM_REMOTE_DP = "0x00000200";
    BALLOON_REMINDERS_REQUIRED        = "0x00000400";
    RERUN_ALWAYS                      = "0x00000800";
    RERUN_NEVER                       = "0x00001000";
    RERUN_IF_FAILED                   = "0x00002000";
    RERUN_IF_SUCCEEDED                = "0x00004000";
    PERSIST_ON_WRITE_FILTER_DEVICES   = "0x00008000";
    DONT_FALLBACK                     = "0x00020000";
    DP_ALLOW_METERED_NETWORK          = "0x00040000";
}

$SMS_Advertisement_TimeFlags = @{
    ENABLE_PRESENT     = '0x00000001';
    ENABLE_EXPIRATION  = '0x00000002';
    ENABLE_AVAILABLE   = '0x00000004';
    ENABLE_UNAVAILABLE = '0x00000008';
    ENABLE_MANDATORY   = '0x00000010';
    GMT_PRESENT        = '0x00000020';
    GMT_EXPIRATION     = '0x00000040';
    GMT_AVAILABLE      = '0x00000080';
    GMT_UNAVAILABLE    = '0x00000100';
    GMT_MANDATORY      = '0x00000200';
}

$SMS_Package_PkgFlags = @{
    COPY_CONTENT         = '0x00000080';
    DO_NOT_DOWNLOAD      = '0x01000000';
    PERSIST_IN_CACHE     = '0x02000000';
    USE_BINARY_DELTA_REP = '0x04000000';
    NO_PACKAGE           = '0x10000000';
    USE_SPECIAL_MIF      = '0x20000000';
    DISTRIBUTE_ON_DEMAND = '0x40000000';
}

$SMS_Program_ProgramFlags = @{
    AUTHORIZED_DYNAMIC_INSTALL = '0x00000001';
    USECUSTOMPROGRESSMSG       = '0x00000002';
    DEFAULT_PROGRAM            = '0x00000010';
    DISABLEMOMALERTONRUNNING   = '0x00000020';
    MOMALERTONFAIL             = '0x00000040';
    RUN_DEPENDANT_ALWAYS       = '0x00000080'
    WINDOWS_CE                 = '0x00000100';
    COUNTDOWN                  = '0x00000400';
    FORCERERUN                 = '0x00000800';
    DISABLED                   = '0x00001000';
    UNATTENDED                 = '0x00002000';
    USERCONTEXT                = '0x00004000';
    ADMINRIGHTS                = '0x00008000';
    EVERYUSER                  = '0x00010000';
    NOUSERLOGGEDIN             = '0x00020000';
    OKTOQUIT                   = '0x00040000';
    OKTOREBOOT                 = '0x00080000';
    USEUNCPATH                 = '0x00100000';
    PERSISTCONNECTION          = '0x00200000';
    RUNMINIMIZED               = '0x00400000';
    RUNMAXIMIZED               = '0x00800000';
    HIDEWINDOW                 = '0x01000000';
    OKTOLOGOFF                 = '0x02000000';
    RUNACCOUNT                 = '0x04000000';
    ANY_PLATFORM               = '0x08000000';
    SUPPORT_UNINSTALL          = '0x20000000';
}

Export-ModuleMember -Function Add-CMNRoleOnObject
Export-ModuleMember -Function ConvertTo-CMNWMISingleQuotedString
Export-ModuleMember -Function ConvertTo-CMNSingleQuotedString
Export-ModuleMember -Function Copy-CMNClientSettings
Export-ModuleMember -Function Copy-CMNCollection
Export-ModuleMember -Function Copy-CMNPackage
Export-ModuleMember -Function Copy-CMNPackageDeployment
Export-ModuleMember -Function Copy-CMNUpdateSettings
Export-ModuleMember -Function Get-CMNApplicationCI_ID
Export-ModuleMember -Function Get-CMNApplicationModelName
Export-ModuleMember -Function Get-CMNAuthorizationListCI_ID
Export-ModuleMember -Function Get-CMNBitFlagSet
Export-ModuleMember -Function Get-CMNClientServiceWindow
Export-ModuleMember -Function Get-CMNClientSite
Export-ModuleMember -Function Get-CMNComputersInCollection
Export-ModuleMember -Function Get-CMNConnectionString
Export-ModuleMember -Function Get-CMNDatabaseData
Export-ModuleMember -Function Get-CMNObjectID
Export-ModuleMember -Function Get-CMNObjectContainerNodeID
Export-ModuleMember -Function Get-CMNObjectContainerNodeIDbyName
Export-ModuleMember -Function Get-CMNObjectFolderPath
Export-ModuleMember -Function Get-CMNObjectIDsBelowFolder
Export-ModuleMember -Function Get-CMNPackageForSoftwareUpdate
Export-ModuleMember -Function Get-CMNPatchTuesday
Export-ModuleMember -Function Get-CMNRoleOnApplication
Export-ModuleMember -Function Get-CMNRoleOnPackage
Export-ModuleMember -Function Get-CMNSCCMConnectionInfo
Export-ModuleMember -Function Get-CMNSiteSystems
Export-ModuleMember -Function Get-CMNMWStartTime
Export-ModuleMember -Function Invoke-CMNDatabaseQuery
Export-ModuleMember -Function Move-CMNObject
Export-ModuleMember -Function New-CMNDailySchedule
Export-ModuleMember -Function New-CMNDeviceCollection
Export-ModuleMember -Function New-CMNDeviceCollectionDirectMemberRule
Export-ModuleMember -Function New-CMNDeviceCollectionExcludeRule
Export-ModuleMember -Function New-CMNDeviceCollectionIncludeRule
Export-ModuleMember -Function New-CMNDeviceCollectionQueryMemberRule
Export-ModuleMember -Function New-CMNLogEntry
Export-ModuleMember -Function New-CMNObjectContainer
Export-ModuleMember -Function New-CMNPackage
Export-ModuleMember -Function New-CMNPackageDeployment
Export-ModuleMember -Function New-CMNProgram
Export-ModuleMember -Function Remove-CMNCollection
Export-ModuleMember -Function Remove-CMNDPContent
Export-ModuleMember -Function Remove-CMNRoleOnObject
Export-ModuleMember -Function Reset-CMNPolicy
Export-ModuleMember -Function Set-CMNBitFlagForControl
Export-ModuleMember -Function Set-CMNLimitingCollection
Export-ModuleMember -Function Show-CMNLogs
Export-ModuleMember -Function Show-CMNPendingReboot
Export-ModuleMember -Function Start-CMNApplicationDeployment
Export-ModuleMember -Function Start-CMNPackageContentDistribution
Export-ModuleMember -Function Start-CMNPackageDeployment
Export-ModuleMember -Function Start_CMNSoftwareUpdateDistribution
Export-ModuleMember -Function Test-CMNBitFlagSet
Export-ModuleMember -Function Test-CMNPackageExists
Export-ModuleMember -Function Test-CMNPendingReboot
Export-ModuleMember -Function Test-CMNPKGReferenced
Export-ModuleMember -Function Update-CMNPackageSource
Export-ModuleMember -Variable SMS_Program_ProgramFlags
Export-ModuleMember -Variable SMS_Package_PkgFlags
Export-ModuleMember -Variable SMS_Advertisement_AdvertFlags
Export-ModuleMember -Variable SMS_Advertisement_DeviceFlags
Export-ModuleMember -Variable SMS_Advertisement_RemoteClientFlags
Export-ModuleMember -Variable SMS_Advertisement_TimeFlags