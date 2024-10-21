#Parameters in script for New-LogEntry

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [parameter(Mandatory=$False,HelpMessage="Enter the root collection id to search from")]
    [string]$collectionid = 'SMS00001',
    [parameter(Mandatory=$true,HelpMessage="Enter the name of the SMS Provider server")]
    [string]$SiteServer,
    [parameter(Mandatory=$false,HelpMessage="Sets the Log Level, 1 - Informational, 2 - Warning, 3 - Error")]
    [Int32]$LogLevel = 2,
    [parameter(Mandatory=$false,HelpMessage="Log File Directory")]
    [string]$LogFileDir = 'C:\Temp\'
)

#Begin New-LogEntry Function
Function New-LogEntry
{
    # Writes to the log file
    Param
    (
        [Parameter(Position=0,Mandatory=$true)]
        [STRING] $Entry,

        [Parameter(Position=1,Mandatory=$false)]
        [INT32] $type = 1,

        [Parameter(Position=2,Mandatory=$false)]
        [STRING] $component = $ScriptName
    )
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

Function DocumentCollectionTree
{
    param($LimitCollectionID)
    $Collection = Get-WmiObject -ComputerName $SiteServer -Namespace root\sms\site_$Site -Query "Select * from SMS_Collection where CollectionID = '$LimitCollectionID'"
    $subcollections = Get-WmiObject -ComputerName $SiteServer -namespace root\sms\site_$Site -query "select * from SMS_Collection where LimitToCollectionID = '$LimitCollectionID'"
    if ($Level -eq 0) {$info = $Collection.Name}
    if ($subcollections -ne $null)
    {
        $Level++
        foreach ($subcoll in $subcollections)
        {
            $info += ", $($subcoll.Name)"
            DocumentCollectionTree $subcoll.collectionid
        }
    }
    else
    {
        Write-Host "$info - Level $Level"
        $info | Out-File -FilePath "c:\temp\collections.csv" -Append -Force
        $info = $info -replace '(.*),.*$', '$1'
    }
    $Level--
 }

#Build variables for New-LogEntry Function

$ScriptName = $MyInvocation.MyCommand.Name
if(-not ($LogFileDir -match '\\$')){$LogFileDir = "$LogFileDir\"}
$LogFile = $ScriptName -replace '(.*)\.ps1', '$1'
$LogFile = $LogFileDir + $LogFile + '.log'

$Site = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

[int]$Level=0
$info = ''
DocumentCollectionTree $collectionid