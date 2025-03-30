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
            LogFile = $logFile;
            Component = 'Get-CMNObjectContainerNodeIDbyName'
        }
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Starting function' -type 1 @NewLogEntry}
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
                    if ($FolderID -eq $null) {throw 'Unknown Object'}
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
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Completing function' -type 1 @NewLogEntry}
    }
} #End Get-CMNObjectContainerNodeIDbyName
