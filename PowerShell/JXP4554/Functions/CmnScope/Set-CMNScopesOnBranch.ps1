PARAM
(
    [Parameter(Mandatory=$true,HelpMessage='Site server where the SMS Provider is installed')]
    [ValidateScript({Test-Connection -ComputerName $_ -Count 1 -Quiet})]
    [string]$SiteServer,
	[Parameter(Mandatory=$true,HelpMessage='Branch to modify')]
	[String]$Branch,
	[Parameter(Mandatory=$true,HelpMessage='Type of object being updated')]
	[ValidateSet('SMS_Collection_Device','SMS_Package','SMS_Advertisement','SMS_Query','SMS_Report','SMS_MeteredProductRule','SMS_ConfigurationItem','SMS_OperatingSystemInstallPackage','SMS_StateMigration','SMS_ImagePackage','SMS_BootImagePackage','SMS_TaskSequencePackage','SMS_DeviceSettingPackage','SMS_DriverPackage','SMS_Driver','SMS_SoftwareUpdate','SMS_ConfigurationItem','SMS_ApplicationLatest','SMS_ConfigurationItemLatest')]
	[String]$ObjectType,
	#Parameters in script for New-LogEntry
    [Parameter(Mandatory=$false,HelpMessage='Sets the Log Level, 1 - Informational, 2 - Warning, 3 - Error')]
    [ValidateSet(1, 2, 3)]
    [Int32]$LogLevel = 2,
    [Parameter(Mandatory=$false,HelpMessage='Log File Directory')]
    [String]$LogFileDir = 'C:\Temp\',
    [Parameter(Mandatory=$false,HelpMessage='Clear any existing log file')]
    [Switch]$ClearLog
)

Function ConvertTo-CMNWMISingleQuotedString
{
	<#
	.SYNOPSIS
		This will replace a ' with ''

	.DESCRIPTION
		This will replace a ' with '' to make the text compatable for SQL queries or any query that uses the ' as an escape/delimiter

	.PARAMETER Text
		Text to be fixed

	.EXAMPLE
		Get-CMNQuotedVersion -Text "Windows 7 Workstation's"

	.NOTES

	.LINK
		http://configman-notes.com
	#>

    Param
    (
        [Parameter(Mandatory=$true)]
        [String]$Text
    )
	New-LogEntry "Converting $Text" 1 'ConvertTo-CMNWMISingleQuotedString'
    return ([regex]::Replace($Text,'(?<SingleQuote>\\)','\${SingleQuote}'))
}
#End ConvertTo-CMNWMISingleQuotedString

#Begin New-LogEntry Function
Function New-LogEntry
{
    # Writes to the log file
    Param
    (
        [Parameter(Position=0,Mandatory=$true)]
        [String] $Entry,

        [Parameter(Position=1,Mandatory=$false)]
	    [ValidateSet(1, 2, 3)]
        [INT32] $type = 1,

        [Parameter(Position=2,Mandatory=$false)]
        [String] $component = $ScriptName
    )
    Write-Verbose $Entry
    if ($type -ge $Script:LogLevel)
    {
        if ($Entry.Length -eq 0)
        {
            $Entry = 'N/A'
        }
        $TZOffset = ([TimeZoneInfo]::Local).BaseUTcOffset.TotalMinutes
        $TZOffset = "$(Get-Date -Format "HH:mm:ss.fff")+$(-$TZOffset)"
        $Entry = "<![LOG[{0}]LOG]!><time=""{2}"" date=""{1}"" component=""{5}"" context="""" type=""{4}"" thread=""{3}"">" -f $Entry, (Get-Date -Format "MM-dd-yyyy"), $TZOffset, $pid, $type, $component
        $Entry | Out-File $Script:LogFile -Append -Encoding ascii
    }
}
#End New-LogEntry

#Begin Function Get-CMNObjectFolder
Function Get-CMNObjectFolder
{
	<#
	.SYNOPSIS

	.DESCRIPTION

	.EXAMPLE

	.PARAMETER Text

	.NOTES
		SMS_ObjectContainerNode - Maps Folder name to ConatainerNodeID
			ObjectTypes:	
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
				2011 - SMS_ConfigurationItem (Configuration baseline)
				5000 - SMS_Collection_Device
				5001 - SMS_Collection_User
				6000 - SMS_ApplicationLatest
				6001 - SMS_ConfigurationItemLatest
 
		SMS_ObjectContainerItem - Maps ContainerNodeID to CollectionID

	.LINK
		http://configman-notes.com
	#>
    PARAM
    (
        [Parameter(Mandatory=$true,HelpMessage='Object to locate')]
        [string]$ObjectiD,
        [Parameter(Mandatory=$true)]
        [ValidateSet('SMS_Collection_Device','SMS_Package','SMS_Advertisement','SMS_Query','SMS_Report','SMS_MeteredProductRule','SMS_ConfigurationItem','SMS_OperatingSystemInstallPackage','SMS_StateMigration','SMS_ImagePackage','SMS_BootImagePackage','SMS_TaskSequencePackage','SMS_DeviceSettingPackage','SMS_DriverPackage','SMS_Driver','SMS_SoftwareUpdate','SMS_ConfigurationItem','SMS_ApplicationLatest','SMS_ConfigurationItemLatest')]
        [String]$ObjectType
    )
	#New-LogEntry 'Starting Script' 1 'Get-CMNObjectFolder'
    $FolderID = Get-WmiObject -Class SMS_ObjectContainerItem -Filter "InstanceKey = '$ObjectiD' and ObjectTypeName = '$ObjectType'" @WMIQueryParameters
    $Folder = Get-WmiObject -Class SMS_ObjectContainerNode -Filter "ContainerNodeID = '$($FolderID.ContainerNodeID)'" @WMIQueryParameters

    do
    {
        $Path = "$($Folder.Name)\$Path"
        $Folder = Get-WmiObject -Class SMS_ObjectContainerNode -Filter "ContainerNodeID = '$($Folder.ParentContainerNodeID)'" @WMIQueryParameters
    } until ($($Folder.ParentContainerNodeID) -ne 0)
    if(!($Path -match '\^') -and ($Path.Length -ne 1)){$Path = "\$Path"}
	#New-LogEntry "Returning $Path" 1 'Get-CMNObjectFolder'
    Return $Path

}
#End Get-CMNObjectFolder

$ScriptName = $MyInvocation.MyCommand.Name
if(-not ($LogFileDir -match '\\$')){$LogFileDir = "$LogFileDir\"}
$LogFile = $ScriptName -replace '(.*)\.ps1', '$1'
$LogFile = $LogFileDir + $LogFile + '.log'
if($ClearLog)
{
    if(Test-Path $Logfile) {Remove-Item $LogFile}
}

$Branch = ConvertTo-CMNWMISingleQuotedString $Branch

New-LogEntry 'Starting Script'
New-LogEntry "SiteServer - $SiteServer"
New-LogEntry "Branch - $Branch"
New-LogEntry "ObjectType - $ObjectType"

New-LogEntry 'Getting Site Code'
$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode
New-LogEntry "SiteCode - $SiteCode"

$WMIQueryParameters = @{
    ComputerName = $SiteServer
    Namespace = "root\sms\site_$SiteCode"
}

Switch ($ObjectType)
{
	'SMS_Collection_Device' {
		$ObjectList = (Get-WmiObject -Class SMS_Collection @WMIQueryParameters).CollectionID
        Break
	}
    'SMS_Package' {
        $ObjectList = (Get-WmiObject -Class SMS_Package @WMIQueryParameters).PackageID}
    Default {throw "Unknown Type"}
}

foreach($Object in $ObjectList)
{
    $Folder = Get-CMNObjectFolder $Object $ObjectType
    Switch ($ObjectType)
    {
        'SMS_Collection_Device' {$NodeName = (Get-WmiObject -Class SMS_Collection -Filter "CollectionID = '$Object'" @WMIQueryParameters).Name}
        'SMS_Package' {$NodeName = (Get-WmiObject -Class SMS_Package -Filter "PackageID = '$Object'" @WMIQueryParameters).Name}
    }
    If($Folder -match $Branch){Write-Host -ForegroundColor Green "$Folder$NodeName"}
    else{Write-Host -ForegroundColor Red "$Folder$NodeName"}
    
}