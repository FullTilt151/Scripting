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

.PARAMETER ShowProgress
	Show a progressbar displaying the current operation.
 
.EXAMPLE
     
.LINK
	http://configman-notes.com

.NOTES
	FileName:    FileName.ps1
	Author:      James Parris
	Contact:     jim@ConfigMan-Notes.com
	Created:     2016-03-22
	Updated:     2016-03-22
	Version:     1.0.0
#>
[cmdletbinding()]

PARAM
(
	[Parameter(Mandatory = $true,
		HelpMessage = 'SCCM Connection Info',
		Position = 1)]
	[String]$siteServer,

    [Parameter(Mandatory = $false,
        HelpMessage = 'Computer to scan',
        Position = 2)]
    [String]$wkid = 'localhost',

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
    [Switch]$clearLog
)


$NewLogEntry = @{
	LogFile = $logFile;
	Component = 'Show-CMDriverVersions'
}
if($PSBoundParameters['clearLog']){if(Test-Path -Path $logFile){Remove-Item -Path $logFile}}
if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry}
if($wkid -eq 'localhost'){$wkid = $env:COMPUTERNAME}
$sccmConnectionInfo = Get-CMNSCCMConnectionInfo -SiteServer $siteServer
$sccmCS = Get-CMNConnectionString -DatabaseServer $sccmConnectionInfo.SCCMDBServer -Database $sccmConnectionInfo.SCCMDB
if($PSBoundParameters["logEntries"])
{
    New-CMNLogEntry -entry "ComputerName: $($sccmConnectionInfo.ComputerName)" -type 1 @NewLogEntry
    New-CMNLogEntry -entry "NameSpace: $($sccmConnectionInfo.NameSpace)" -type 1 @NewLogEntry
    New-CMNLogEntry -entry "SCCMDB: $($sccmConnectionInfo.SCCMDB)" -type 1 @NewLogEntry
    New-CMNLogEntry -entry "SCCMDBServer: $($sccmConnectionInfo.SCCMDBServer)" -type 1 @NewLogEntry
    New-CMNLogEntry -entry "SiteCode: $($sccmConnectionInfo.SiteCode)" -type 1 @NewLogEntry
    New-CMNLogEntry -entry "SCCMCS: $sccmCS" -type 1 @NewLogEntry
    New-CMNLogEntry -entry "WKID: $wkid" -type 1 @NewLogEntry
}
if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry}
$pnpDrivers = Get-WmiObject -Query 'SELECT * FROM Win32_PnpSignedDriver_Custom' -ComputerName $wkid
foreach($pnpDriver in $pnpDrivers)
{
    $query = "Select Distinct DriverVersion0
        from v_GS_PNP_SIGNED_DRIVER_CUSTOM
        where HardwareID0 = '$($pnpDriver.HardwareID)'"
    $Versions = (Get-CMNDatabaseData -connectionString $sccmCS -query $query -isSQLServer).DriverVersion0
    $maxVersion = Get-CMNMaxVersion -SCCMConnectionInfo $sccmConnectionInfo -versions $Versions
    $message = "DeviceName:$($pnpDriver.DeviceName), DriverProviderName:$($pnpDriver.DRiverProviderName), HardwareID:$($pnpDriver.HardwareID), DriverVersion:$($pnpDriver.DriverVersion), MaxVerson:$maxVersion"
    if($pnpDriver.DriverVersion -ne $maxVersion)
    {
        $type = 3
        Write-Host -ForegroundColor Yellow $message
    }
    else
    {
        $type = 2
        Write-Host -ForegroundColor Green $message
    }
    if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry $message -type $type @NewLogEntry}
}
if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
