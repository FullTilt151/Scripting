<#
.Synopsis 
	Removes any collection that has $LimitingToCollectionID as it's limiting collection and replaces it with NewLimitingToCollectionID

.DESCRIPTION

.PARAMETER

.EXAMPLE

.LINK
    http://parrisfamily.com

.NOTES

#>
[CmdletBinding(SupportsShouldProcess = $true)]
PARAM(
    [PARAMETER(Mandatory = $true, HelpMessage = 'Site Server')]
    [STRING]$SiteServer,
    [PARAMETER(Mandatory = $TRUE, HelpMessage = 'CollectionID to be removed')]
    [STRING]$LimitingToCollectionID,
    [PARAMETER(Mandatory = $TRUE, HelpMessage = 'CollectionID to replace')]
    [STRING]$NewLimitingToCollectionID,
    [Parameter(Mandatory = $false, HelpMessage = "Sets the Log Level, 1 - Informational, 2 - Warning, 3 - Error")]
    [Int32]$LogLevel = 1,
    [Parameter(Mandatory = $false, HelpMessage = "Log File Directory")]
    [String]$LogFileDir = 'C:\Temp\'
)

#Begin Functions

#Begin New-LogEntry Function
Function New-LogEntry {
    # Writes to the log file
    Param(
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

#End Functions

#Build variables for New-LogEntry Function

$ScriptName = $MyInvocation.MyCommand.Name
if (-not ($LogFileDir -match '\\$')) {$LogFileDir = "$LogFileDir\"}
$LogFile = $ScriptName -replace '(.*)\.ps1', '$1'
$LogFile = $LogFileDir + $LogFile + '.log'

New-LogEntry 'Starting Script'
$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

$WMIQueryParameters = @{
    ComputerName = $SiteServer
    Namespace    = "root\sms\site_$SiteCode"
}

$LimitingCollection = Get-WmiObject @WMIQueryParameters -Class SMS_Collection -Filter "CollectionID = '$NewLimitingToCollectionID'"
$Collections = Get-WmiObject @WMIQueryParameters -Class SMS_collection -Filter "LimitToCollectionID = '$LimitingToCollectionID'"
New-LogEntry "New Limiting To Collection is $($LimitingCollection.CollectionID) - $($LimitingCollection.Name)"

foreach ($Collection in $Collections) {
    New-LogEntry "Changing $($Collection.CollectionID) - $($Collection.Name) from $($Collection.LimitToCollectionID) - $($Collection.LimitToCollectionName)"
    $Collection.Get()
    $Collection.LimitToCollectionID = $($LimitingCollection).CollectionID
    $Collection.Put() | Out-Null
}