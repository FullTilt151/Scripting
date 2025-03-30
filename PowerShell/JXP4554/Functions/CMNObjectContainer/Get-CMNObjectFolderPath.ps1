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
            LogFile = $logFile;
            Component = 'Get-CMNObjectFolderPath';
        }
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Starting function' -type 1 @NewLogEntry}
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
        if (!($Path -match '\^') -and ($Path.Length -ne 1)) {$Path = "\$Path"}
    }

    end {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Completing function' -type 1 @NewLogEntry}
        Return $Path
    }
} #End Get-CMNObjectFolderPath
