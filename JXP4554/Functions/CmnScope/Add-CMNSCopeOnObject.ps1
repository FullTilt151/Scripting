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
            LogFile = $logFile;
            Component = 'Add-CMNScopeOnObject';
            maxLogSize = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        #Build splat for WMIQueries
        $WMIQueryParameters = @{
            ComputerName = $sccmConnectionInfo.ComputerName;
            NameSpace = $sccmConnectionInfo.NameSpace;
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
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "SecurityScopeCategoryID is $securityScopeCategoryID" -Type 1 @NewLogEntry}
    }

    process {
        if ($pscmdlet.ShouldProcess($scopeName)) {
            if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Beginning processing loop' -Type 1 @NewLogEntry}
            foreach ($objID in $objectID) {
                try {
                    Invoke-WmiMethod -Name AddMemberShips -Class SMS_SecuredCategoryMemberShip -ArgumentList $securityScopeCategoryID, $objID, $objectTypetoObjectID[$objectType] @WMIQueryParameters | Out-Null
                }

                catch {
                    if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Failed to add $scopeName to $objID" -Type 3 @NewLogEntry}
                    Write-Error "Failed to add $scopeName to $objID"
                }
            }
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Completed Function' -Type 1 @NewLogEntry}
    }
} #End Add-CMNScopeOnObject