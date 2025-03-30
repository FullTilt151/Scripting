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

    begin {}

    process {
        if ($PSCmdlet.ShouldProcess($objectID)) {
            $sourceContainerID = (Get-WmiObject -Class SMS_ObjectContainerItem -Filter "InstanceKey = '$objectID' and ObjectType = '$($ObjectTypetoObjectID[$objectType])'" -Namespace $sccmConnectionInfo.NameSpace -ComputerName ($sccmConnectionInfo.ComputerName)).ContainerNodeID
            if ($sourceContainerID -eq $null -or $sourceContainerID -eq '') {$sourceContainerID = 0}
            Invoke-WmiMethod -Class SMS_ObjectContainerItem -Name MoveMembers -ArgumentList $sourceContainerID, $objectID, $ObjectTypetoObjectID[$objectType], $destinationContainerID -Namespace $sccmConnectionInfo.NameSpace -ComputerName ($sccmConnectionInfo.ComputerName)
        }
    }

    end {}
} # End Move-CMNObject
