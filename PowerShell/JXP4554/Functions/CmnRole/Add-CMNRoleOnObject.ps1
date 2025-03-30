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
            LogFile = $logFile;
            Component = 'Add-CMNRoleOnObject';
            maxLogSize = $maxLogSize;
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
                if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Setting Role on $objectID" -type 1 @NewLogEntry}
                Invoke-WmiMethod -Name AddMemberShips -Class SMS_SecuredCategoryMemberShip -ArgumentList $securityScopeCategoryID, $objectID, $objectTypetoObjectID[$objectType] @WMIQueryParameters | Out-Null
            }
        }

        catch {
            if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Failed to add $roleName to $objID" -Type 3 @NewLogEntry}
            Throw "Failed to add $roleName to $objID"
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
    }
} #End Add-CMNRoleOnObject
