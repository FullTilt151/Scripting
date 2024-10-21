<#
.SYNOPSIS
	This script cleans up collection schedules.

.DESCRIPTION
	It cycles through all collecitons, checks to see if the collection has a query rule. If it does not,
    it logs and adds to a spreadsheet. If you set the ClearSchedules switch, it will set turn off the
    schedule on that collection.

    It also will log and add to the spreadsheet if the collection has 0 members or has not had a membership
    change in more then <MinNumDays>

    The spreadsheet and log will both be in the LogFileDir (Default C:\Temp)

.PARAMETER SiteServer
    ConfigMGR site server

.PARAMETER MinNumDays
    Minimum number of days that a collection membership has changed before it's logged.

.PARAMETER ClearSchedules
    When set, any collection that does not have a query based membership rule will have the schedule turned
    off.

.PARAMETER LogLevel
    Sets the minimum logging level, default is 1.
    1 - Informational
    2 - Warning
    3 - Error

.PARAMETER LogFileDir
    Directory where you want the log file. Defaults to C:\Temp\

.PARAMETER ClearLog
    This will clear both the log and the CSV file

.EXAMPLE
	Clear-CMNCollectionFullSchedule -SiteServer ConfgMGR01 -MinNumDays 250

.NOTES
    https://msdn.microsoft.com/en-us/library/hh948939.aspx
    Need to use excel object and clean up export

.LINK
	http://configman-notes.com
#>

PARAM(
    [Parameter(Mandatory = $true, HelpMessage = 'Site Server')]
    [ValidateScript( {Test-Connection -ComputerName $_ -Count 1 -Quiet})]
    [String]$SiteServer,
    [Parameter(Mandatory = $false, HelpMessage = 'Minimum number of days for membership change')]
    [Int32]$MinNumDays = 180,
    [Parameter(Mandatory = $false, HelpMessage = 'Clean schedules?')]
    [Switch]$ClearSchedules = $false,
    #Parameters in script for New-LogEntry
    [Parameter(Mandatory = $false, HelpMessage = "Sets the Log Level, 1 - Informational, 2 - Warning, 3 - Error")]
    [Int32]$LogLevel = 2,
    [Parameter(Mandatory = $false, HelpMessage = "Log File Directory")]
    [String]$LogFileDir = 'C:\Temp\',
    [Parameter(Mandatory = $false, HelpMessage = "Clear any existing log file")]
    [Switch]$ClearLog
)

#Begin New-LogEntry Function
Function New-LogEntry {
    # Writes to the log file
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [String] $Entry,

        [Parameter(Position = 1, Mandatory = $false)]
        [INT32] $type = 1,

        [Parameter(Position = 2, Mandatory = $false)]
        [String] $component = $ScriptName
    )
    Write-Verbose $Entry
    if ($type -ge $Script:LogLevel) {
        if ($Entry.Length -eq 0) {
            $Entry = 'N/A'
        }
        $TZOffset = ([TimeZoneInfo]::Local).BaseUTcOffset.TotalMinutes
        $TZOffset = "$(Get-Date -Format "HH:mm:ss.fff")+$(-$TZOffset)"
        $Entry = "<![LOG[{0}]LOG]!><time=""{2}"" date=""{1}"" component=""{5}"" context="""" type=""{4}"" thread=""{3}"">" -f $Entry, (Get-Date -Format "MM-dd-yyyy"), $TZOffset, $pid, $type, $component
        $Entry | Out-File $Script:LogFile -Append -Encoding ascii
    }
}
#End New-LogEntry

#Build variables for New-LogEntry Function

$ScriptName = $MyInvocation.MyCommand.Name
if (-not ($LogFileDir -match '\\$')) {$LogFileDir = "$LogFileDir\"}
$LogFile = $ScriptName -replace '(.*)\.ps1', '$1'
$OutFile = $LogFileDir + $LogFile + '.csv'
$LogFile = $LogFileDir + $LogFile + '.log'
if ($ClearLog) {
    if (Test-Path $Logfile) {Remove-Item $LogFile}
    if (Test-Path $OutFile) {Remove-Item $OutFile}
}

New-LogEntry 'Starting Script'
New-LogEntry "SiteServer - $SiteServer"
New-LogEntry "MinNumDays -$MinNumDays"
New-LogEntry "ClearSchedules - $ClearSchedules"
New-LogEntry "LogLevel - $LogLevel"
New-LogEntry "LogFileDir - $LogFileDir"
New-LogEntry "ClearLog - $ClearLog"

"CollectionID,CollectionName,Check" | Out-File -FilePath $OutFile -Append -Encoding ascii

$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

$WMIQueryParameters = @{
    ComputerName = $SiteServer
    Namespace    = "root\sms\site_$SiteCode"
}

New-LogEntry 'Getting CollectionID''s'

$CollectionIDs = (Get-WmiObject -Class SMS_Collection -Filter "CollectionType = 2" @WMIQueryParameters).CollectionID | Sort-Object
[Int32]$UpdateCount = 0

New-LogEntry "Starting to go through list of $($CollectionIDs.Count) CollectionID's"

Foreach ($CollectionID in $CollectionIDs) {
    #New-LogEntry 'Retrieving Collection'
    $Collection = Get-WmiObject -Class SMS_Collection -Filter "CollectionID = '$CollectionID'" @WMIQueryParameters
    $Collection.Get()
    #New-LogEntry "Working on $($Collection.Name)"

    #Collections with no query schedule - This will be fixed. Set RefreshType to 1
    if ($Collection.RefreshType -ne 1) {
        $QueryRule = $false
        $ColRules = $Collection.CollectionRules
        foreach ($ColRule in $ColRules) {
            if ($ColRule.QueryExpression) {
                #New-LogEntry "Collection $($Collection.Name) - $($Collection.CollectionID) has a query"
                $QueryRule = $true
            }
        }
        if (!$QueryRule) {
            $UpdateCount++
            if ($ClearSchedules) {
                $Collection.RefreshType = 1
                $Collection.Put() | Out-Null
                New-LogEntry "$UpdateCount - $($Collection.CollectionID) - Collection $($Collection.Name) schedule has been removed." 2
            }
            else {
                New-LogEntry "$UpdateCount - $($Collection.CollectionID) - Collection $($Collection.Name) schedule would be removed."
            }
            "$($Collection.CollectionID),$($Collection.Name),QueryRule" | Out-File -FilePath $OutFile -Append -Encoding ascii
        }
    }

    #Check for collections with 0 members
    if ($Collection.MemberCount -eq 0) {
        New-LogEntry "$($CollectionID) - $($Collection.Name) has 0 members"
        "$($Collection.CollectionID),$($Collection.Name),0 Members" | Out-File -FilePath $OutFile -Append -Encoding ascii
    }
    #Collections with no deployments or not used as a limiting collection - Flag
    #Collections with no membership change in 6 months - Flag
    If (((get-date) - ([System.Management.ManagementDateTimeConverter]::ToDateTime($Collection.LastMemberChangeTime))).days -gt $MinNumDays) {
        New-LogEntry "$($CollectionID) - $($Collection.Name) has not been modified in over $MinNumDays days"
        "$($Collection.CollectionID),$($Collection.Name),Min Days Rule" | Out-File -FilePath $OutFile -Append -Encoding ascii
    }
}

New-LogEntry "Total of $UpdateCount schedules were removed" 2
New-LogEntry 'Script Finished'