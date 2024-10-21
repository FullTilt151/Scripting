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
            LogFile = $logFile;
            Component = 'Get-CMNObjectContainerNodeID'
        }
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Starting function' -type 1 @NewLogEntry}
    }

    process {
        if ($PSCmdlet.ShouldProcess($ObjectID)) {
            $query = "Select ContainerNodeID from SMS_ObjectContainerItem where InstanceKey = '$ObjectID' and ObjectType = $($ObjectTypetoObjectID[$ObjectType])"
            if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Query = $query" -type 1 @NewLogEntry}
            $ObjID = (Get-WmiObject -Query $query -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName).ContainerNodeID
            if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "ObjID = $ObjID" -type 1 @NewLogEntry}
            if ($ObjID -eq $null -or $ObjID -eq '') {$ObjID = 0}
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Completing function' -type 1 @NewLogEntry}
        Return $ObjID
    }
} #End Get-CMNObjectContainerNodeID
