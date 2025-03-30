<#
.Synopsis
    This script will create the operating system limiting collections.
.DESCRIPTION
   This script will create the operating system limiting collections. The variable $OperatingSystems contains the operating systems.
   The variable $OPeratingSystemQueries contains the value we are looking for in V_R_System.OperatingSystemNameandVersion.

    All my functions assume you are using the Get-CMNSCCMConnectoinInfo and New-CMNLogEntry functions for these scripts, 
    please make sure you account for that.

.PARAMETER sccmConnectionInfo
    This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
    Get-CMNsccmConnectionInfo in a variable and passing that variable.

.PARAMETER logFile
    File for writing logs to, default is c:\temp\eror.log

.PARAMETER logEntries
    Switch for logging entries, default is $false

.PARAMETER maxLogSize
    Max size for the log. Defaults to 5MB.

.PARAMETER maxLogHistory
        Specifies the number of history log files to keep, default is 5

.EXAMPLE

.LINK
    http://configman-notes.com

.NOTES
    Author:	    Jim Parris
    Email:	    Jim@ConfigMan-Notes.com
    Date:	    yyyy-mm-dd
    Updated:    
    PSVer:	    3.0
    Version:    1.0.0		
 #>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]

Param(
    [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
    [PSObject]$sccmConnectionInfo,

    [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
    [String]$logFile = 'C:\Temp\Error.log',

    [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
    [Switch]$logEntries,

    [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
    [Int]$maxLogSize = 5242880,

    [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
    [Int]$maxLogHistory = 5
)


#SCCM Import Module
import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + '\ConfigurationManager.psd1')

$Site = $(Get-WmiObject -ComputerName $Server -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

Push-Location
Set-Location "$($site):"

#Build variables for New-LogEntry Function

$ScriptName = $MyInvocation.MyCommand.Name
if (-not ($LogFileDir -match '\\$')) {$LogFileDir = "$LogFileDir\"}
$LogFile = $ScriptName -replace '(.*)\.ps1', '$1'
$LogFile = $LogFileDir + $LogFile + '.log'

New-LogEntry 'Starting Script'
New-LogEntry "Server - $Server"
New-LogEntry "LogLevel - $LogLevel"
New-LogEntry "LogFileDir - $LogFileDir"

$OperatingSystems = @('Windows Server 2003', 'Windows Server 2008', 'Windows Server 2008 R2', 'Windows Server 2012 R2', 'Windows Server 2008', 'Windows Server 2008 R2', 'Windows Server 2012', 'Windows Server 2012 R2', 'Windows 10'`
        , 'Windows XP', 'Windows 7', 'Windows 8.1')
$OPeratingSystemQueries = @('Microsoft Windows NT Advanced Server 5.2', 'Microsoft Windows NT Advanced Server 6.0', 'Microsoft Windows NT Advanced Server 6.1', 'Microsoft Windows NT Advanced Server 6.3'`
        , 'Microsoft Windows NT Server 6.0', 'Microsoft Windows NT Server 6.1', 'Microsoft Windows NT Server 6.2', 'Microsoft Windows NT Server 6.3', 'Microsoft Windows NT Workstation 10.0', 'Microsoft Windows NT Workstation 5.1'`
        , 'Microsoft Windows NT Workstation 6.1', 'Microsoft Windows NT Workstation 6.3')
for ($x = 0; $x -lt $OperatingSystems.Count; $x++) {
    New-LogEntry "Checking if a collection called All $($OperatingSystems[$x]) Security Collection exists"
    $Query = "Select * from SMS_Collection where Name = 'All $($OperatingSystems[$x]) Security Collection'"
    $Collection = Get-WmiObject -ComputerName $Server -Namespace root\sms\site_$Site -Query $Query
    if ($Collection.Length -eq 0) {
        New-LogEntry 'Nope, going to have to create it. First, building variables'
        $Schedule = New-CMSchedule -RecurInterval Days -RecurCount 1 -Start '02:00'
        $CollectionName = "All $($OperatingSystems[$x]) Security Collection"
        $CollectionQuery = "select *  from  SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like ""%$($OPeratingSystemQueries[$x])%"" and SMS_R_System.Client = ""1"""
        New-LogEntry 'Creating Collection'
        $CollectionID = New-CMDeviceCollection -LimitingCollectionId 'SMS00001' -Name $CollectionName -RefreshSchedule $Schedule -RefreshType Periodic
        New-LogEntry 'Moving to Security Collections Folder'
        Move-CMObject -FolderPath "$($Site):\DeviceCollection\Limiting Collections\Security Collections" -InputObject $CollectionID
        New-LogEntry 'Adding query'
        Add-CMDeviceCollectionQueryMembershipRule -CollectionId $CollectionID.CollectionID -QueryExpression $CollectionQuery -RuleName "All $($OperatingSystems[$x])"

        New-LogEntry "Checking if a collection called All $($OperatingSystems[$x]) Limiting Collection exists"
        $Query = "Select * from SMS_Collection where Name = 'All $($OperatingSystems[$x]) Limiting Collection'"
        $Collection = Get-WmiObject -ComputerName $Server -Namespace root\sms\site_$Site -Query $Query
        if ($Collection.Length -eq 0) {
            New-LogEntry "Nope! Bulding All $($OperatingSystems[$x]) Limiting Collection"
            New-LogEntry 'Building variables'
            $Schedule = New-CMSchedule -RecurInterval Days -RecurCount 1 -Start '03:00'
            $CollectionName = "All $($OperatingSystems[$x]) Limiting Collection"
            New-LogEntry 'Creating Collection'
            $CollectionID2 = New-CMDeviceCollection -LimitingCollectionId $CollectionID.CollectionID -Name $CollectionName -RefreshSchedule $Schedule -RefreshType Periodic
            New-LogEntry 'Moving to Limiting Collections Folder'
            Move-CMObject -FolderPath "$($Site):\DeviceCollection\Limiting Collections" -InputObject $CollectionID2
            New-LogEntry 'Adding Include Membership rule'
            Add-CMDeviceCollectionIncludeMembershipRule -CollectionId $CollectionID2.CollectionID -IncludeCollectionId $CollectionID.CollectionID
        }
        else {
            New-LogEntry "All $($OperatingSystems[$x]) Limiting Collection does exist"
        }
    }
    else {
        New-LogEntry "All $($OperatingSystems[$x]) Security Collection already exists"
    }
}

New-LogEntry 'Finished Script'
Pop-Location