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
            LogFile = $logFile;
            Component = 'Get-CMNObjectFolderPath'
        }
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Starting function' -type 1 @NewLogEntry}
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
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Completing function' -type 1 @NewLogEntry}
        Return $ObjectIDs
    }
} #End Get-CMNObjectIDsBelowFolder
