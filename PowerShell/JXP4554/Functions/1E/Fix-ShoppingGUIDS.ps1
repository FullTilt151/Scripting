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

    [Parameter(Mandatory = $true, HelpMessage = 'Shopping Database Server')]
    [String]$ShoppingDBServer,

    [Parameter(Mandatory = $true, HelpMessage = 'Shopping Database')]
    [String]$ShoppingDB,

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
$ShoppingConnectionString = Get-CMNConnectionString -DatabaseServer $ShoppingDBServer -Database $ShoppingDB
$SCCMConnectionString = Get-CMNConnectionString -DatabaseServer ($SCCMConnectionInfo.SCCMDBServer) -Database ($SCCMConnectionInfo.SCCMDB)

#Query shopping and get MachineID, MachineName, ResourceGuid
$Query = "select MachineId [PK_ID], MachineName [WKID], ResourceGuid [GUID]`
from tb_Machine`
where ResourceGUID != 'INVALID'`
--and MachineName like 'LOUXDWSTDB094%'`
order by MachineName"

$ShoppingComputers = Get-CMNDatabaseData -connectionString $ShoppingConnectionString -query $Query -isSQLServer
[Int32]$CurrentItem = 0
[Int32]$ObsoleteIDs = 0
[Int32]$MisMatchGuids = 0

#Cycle through the list
foreach ($ShoppingComputer in $ShoppingComputers) {
    #Query SCCM for the GUID
    $CurrentItem++
    $DisplayInfo = $false
    Write-Progress -Activity 'Checking against SCCM' -Status "Working on $($ShoppingComputer.WKID)" -PercentComplete ($CurrentItem / $($ShoppingComputers.Count) * 100) -CurrentOperation "$CurrentItem/$($ShoppingComputers.Count)"
    $Query = "select ResourceID [PK_ID], Netbios_Name0 [WKID], SMS_Unique_Identifier0 [GUID], Active0 [Active], Client0 [Client], Obsolete0 [Obsolete]`
            from v_R_System`
            where SMS_Unique_Identifier0 = '$($ShoppingComputer.GUID)'"
    $SCCMComputers = Get-CMNDatabaseData -connectionString $SCCMConnectionString -query $Query -isSQLServer
    foreach ($SCCMComputer in $SCCMComputers) {
        if ($SCCMInfo.PK_ID -gt 0) {
            if ($SCCMInfo.Obsolete -eq 1) {
                $ObsoleteIDs++
                $DisplayInfo = $true
                Write-Output "$($SCCMInfo.WKID)/$($ShoppingComputer.WKID) is obsolete"
                Write-Output "Shopping Info"
                $ShoppingComputer | fl
                Write-Output "SCCM Info"
                $SccmInfo
            }
            if ($SCCMInfo.GUID -ne $ShoppingComputer.GUID) {
                $MisMatchGuids++
                $DisplayInfo = $true
                Write-Output "$($SCCMInfo.WKID)/$($SCCMInfo.GUID) != $($ShoppingComputer.WKID)/$($ShoppingComputer.GUID)"
                Write-Output "Shopping Info"
                $ShoppingComputer | fl
                Write-Output "SCCM Info"
                $SccmInfo
            }
            #Is Client Installed Active and Not obsolete
            #Yes - All is well
            #No - What to do
            if ($DisplayInfo) {Write-Output '*********************'}
        }
    }
}
Write-Progress -Activity 'Checking against SCCM' -Completed
Write-Output "Obsolete Count: $ObsoleteIDs - MisMatchGUID Count: $MisMatchGuids"