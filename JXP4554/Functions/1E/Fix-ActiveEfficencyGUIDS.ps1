<#
.SYNOPSIS

.DESCRIPTION

.PARAMETER SiteServer

.PARAMETER LogLevel
	Minimum logging level:
	1 - Informational
	2 - Warning (default)
	3 - Error

.PARAMETER LogFileDir
	Directory where log file will be created. Default C:\Temp.

.PARAMETER ClearLog
    Clears exisiting log file.

.EXAMPLE

.LINK
	Blog
	http://configman-notes.com

.NOTES
 
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [parameter(Mandatory = $true, HelpMessage = "Site server where the SMS Provider is installed")]
    [ValidateScript( {Test-Connection -ComputerName $_ -Count 1 -Quiet})]
    [string]$SiteServer,

    [Parameter(Mandatory = $true, HelpMessage = 'ActiveEfficiency Database Server')]
    [String]$ActiveEfficiencyDBServer,

    [Parameter(Mandatory = $true, HelpMessage = 'ActiveEfficiency Database')]
    [String]$ActiveEfficiencyDB,

    [Parameter(Mandatory = $false, HelpMessage = 'Show Progress Bars')]
    [Switch]$ShowProgress,

    [parameter(Mandatory = $false, HelpMessage = "Logging Level")]
    [ValidateSet(1, 2, 3)]
    [Int32]$LogLevel = 2,

    [parameter(Mandatory = $false, HelpMessage = "Log File Directory")]
    [string]$LogFileDir = 'C:\Temp\',

    [parameter(Mandatory = $false, HelpMessage = "Clear any existing log file")]
    [switch]$ClearLog
)

$SCCMConnectionInfo = Get-CMNSCCMConnectionInfo -SiteServer $SiteServer
$ActiveEfficiencyConnectionString = Get-CMNConnectionString -DatabaseServer $ActiveEfficiencyDBServer -Database $ActiveEfficiencyDB
$SCCMConnectionString = Get-CMNConnectionString -DatabaseServer ($SCCMConnectionInfo.SCCMDBServer) -Database ($SCCMConnectionInfo.SCCMDB)

#Query ActiveEfficiency and get MachineID, MachineName, ResourceGuid
$Query = "select DID.[Identity] [ResourceID], DEV.Id [PK_ID], DEV.HostName [WKID], DET.StringValue [GUID]`
            from Devices DEV`
            join DeviceTags DET on DEV.Id = DET.DeviceId`
            join DeviceIdentities DID on DID.DeviceId = DEV.Id`
            where DET.Name = 'UniqueID'`
            and DID.Source = 'ConfigMgrResourceId'`
            order by HostName"

$ActiveEfficiencyServers = Get-CMNDatabaseData -connectionString $ActiveEfficiencyConnectionString -query $Query -isSQLServer
[Int32]$CurrentItem = 0
[Int32]$ObsoleteIDs = 0
[Int32]$MisMatchGuids = 0

#Cycle through the list
foreach ($ActiveEfficiencyServer in $ActiveEfficiencyServers) {
    #Query SCCM for the GUID
    $DisplayInfo = $false
    $CurrentItem++
    Write-Progress -Activity 'Checking against SCCM' -Status "Working on $($ActiveEfficiencyServer.WKID)" -PercentComplete ($CurrentItem / $($ActiveEfficiencyServers.Count) * 100) -CurrentOperation "$CurrentItem/$($ActiveEfficiencyServers.Count)"
    $Query = "select ResourceID [PK_ID], Netbios_Name0 [WKID], SMS_Unique_Identifier0 [GUID], Active0 [Active], Client0 [Client], Obsolete0 [Obsolete]`
            from v_R_System`
            where ResourceID = '$($ActiveEfficiencyServer.ResourceID)'"
    $SCCMInfo = Get-CMNDatabaseData -connectionString $SCCMConnectionString -query $Query -isSQLServer
    if ($SCCMInfo.PK_ID -gt 0) {
        if ($SCCMInfo.Obsolete -eq 1) {
            $ObsoleteIDs++
            $DisplayInfo = $true
            Write-Output "$($SCCMInfo.WKID)/$($ActiveEfficiencyServer.WKID) is obsolete"
            Write-Output "AE Info"
            $ActiveEfficiencyServer | Format-List
            Write-Output "SCCM Info"
            $SccmInfo
        }
        if ($SCCMInfo.GUID -ne "GUID:$($ActiveEfficiencyServer.GUID)") {
            $MisMatchGuids++
            $DisplayInfo = $true
            Write-Output "$($SCCMInfo.WKID)/$($SCCMInfo.GUID) != $($ActiveEfficiencyServer.WKID)/$($ActiveEfficiencyServer.GUID)"
            Write-Output "AE Info"
            $ActiveEfficiencyServer | Format-List
            Write-Output "SCCM Info"
            $SccmInfo
        }
        #Is Client Installed Active and Not obsolete
        #Yes - All is well
        #No - What to do
        if ($DisplayInfo) {Write-Output '*********************'}
    }
}
Write-Progress -Activity 'Checking against SCCM' -Completed
Write-Output "Obsolete Count: $ObsoleteIDs - MisMatchGUID Count: $MisMatchGuids"