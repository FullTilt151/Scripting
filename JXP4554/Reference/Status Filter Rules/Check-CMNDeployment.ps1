[CmdletBinding(SupportsShouldProcess = $true,
		ConfirmImpact = 'Low')]
PARAM
(
 	[Parameter(Mandatory = $true,
		HelpMessage = 'SCCM Site code',
		position = 1)]
	[String]$SiteCode,

	[Parameter(Mandatory = $true,
		HelpMessage = 'Location of Excel file to import',
		position = 2)]
	[String]$AdvertisementID
)

#Build hash
$WMIQueryParameters = @{
	NameSpace = "root\sms\site_$SiteCode";
	ComputerName = 'LOUAPPWTS1140';
}

$NewLogEntry = @{
	LogFile = 'C:\Temp\Check-CMNDeployments.log';
	Component = 'Check-CMNDeployments';
}

#Get Deployment
$Query = "Select * from SMS_Advertisement where AdvertisementID = '$AdvertisementID'"
$Deployment = Get-WmiObject -Query $Query @WMIQueryParameters
$Deployment.Get()
$isChanged = $false

New-CMNLogEntry -entry "Checking Deployment $($Deployment.AdvertisementName) ($($Deployment.AdvertisementID))" -type 1 @NewLogEntry

#Check that we aren't ignoring maintenance windows
if(Test-CMNBitFlagSet -BitFlagHashTable $SMS_Advertisement_AdvertFlags -KeyName OVERRIDE_SERVICE_WINDOWS -CurrentValue $Deployment.AdvertFlags)
{
	New-CMNLogEntry -entry "Deployment ignores maintenance windows" -type 2 @NewLogEntry
	$Deployment.AdvertFlags = Set-CMNBitFlagForControl -ProposedValue $false -BitFlagHashTable $SMS_Advertisement_AdvertFlags -KeyName OVERRIDE_SERVICE_WINDOWS -CurrentValue $Deployment.AdvertFlags
	$isChanged = $true
}

if(Test-CMNBitFlagSet -BitFlagHashTable $SMS_Advertisement_AdvertFlags -KeyName REBOOT_OUTSIDE_OF_SERVICE_WINDOWS -CurrentValue $Deployment.AdvertFlags)
{
	New-CMNLogEntry -entry "Deployment reboots outside of window" -type 2 @NewLogEntry
	$Deployment.AdvertFlags = Set-CMNBitFlagForControl -ProposedValue $false -BitFlagHashTable $SMS_Advertisement_AdvertFlags -KeyName REBOOT_OUTSIDE_OF_SERVICE_WINDOWS -CurrentValue $Deployment.AdvertFlags
	$isChanged = $true
}

if($isChanged)
{
	New-CMNLogEntry -entry "Deployment updated" -type 2 @NewLogEntry
	$Deployment.Put() | Out-Null
}
else
{
	New-CMNLogEntry -entry "Deployment Good!" -type 1 @NewLogEntry
}