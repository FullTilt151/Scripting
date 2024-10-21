<#
.Synopsis

.DESCRIPTION

.PARAMETER

.EXAMPLE

.LINK
    http://parrisfamily.com

.NOTES

SiteCode - TST	Check-CollectionMemberChange.ps1	9/2/2015 2:31:29 PM	1588 (0x0634)
SiteServer - LOUAPPWTS872.rsc.humad.com	Check-CollectionMemberChange.ps1	9/2/2015 2:31:29 PM	1588 (0x0634)
UserID -HUMAD\JXP4554A	Check-CollectionMemberChange.ps1	9/2/2015 2:31:29 PM	1588 (0x0634)
DeploymentID - TST00041	Check-CollectionMemberChange.ps1	9/2/2015 2:31:29 PM	1588 (0x0634)
DeploymentName - Jim's	Check-CollectionMemberChange.ps1	9/2/2015 2:31:29 PM	1588 (0x0634)
ProgramName - Test	Check-CollectionMemberChange.ps1	9/2/2015 2:31:29 PM	1588 (0x0634)
WorkstationID - machines	Check-CollectionMemberChange.ps1	9/2/2015 2:31:29 PM	1588 (0x0634)
#>

#SCCM Parameters
[CmdletBinding(SupportsShouldProcess=$true)]
Param(
    [Parameter(Mandatory=$true)]
    [String]$SiteCode,
    [Parameter(Mandatory=$true)]
    [String]$SiteServer,
    [Parameter(Mandatory=$false)]
    [String]$UserID,
    [Parameter(Mandatory=$false)]
    [String]$CollectionID,
    [Parameter(Mandatory=$false)]
    [String]$CollectionName,
    [Parameter(Mandatory=$false)]
    [String]$WKID
)

#Begin New-LogEntry Function
Function New-LogEntry
{
    # Writes to the log file
    Param
    (
        [Parameter(Position=0,Mandatory=$true)]
        [String] $Entry,
        [Parameter(Position=1,Mandatory=$false)]
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

#Build variables for New-LogEntry Function

$ScriptName = $MyInvocation.MyCommand.Name
$LogLevel = 1
$LogFile = $ScriptName -replace '(.*)\.ps1', '$1'
$LogFile = "F:\SCCMLogs\$LogFile.log"

$WMIQueryParameters = @{
ComputerName = $SiteServer
NameSpace = "root\sms\site_$SiteCode"
}

New-LogEntry 'Starting'
New-LogEntry "SiteCode - $SiteCode"
New-LogEntry "SiteServer - $SiteServer"
New-LogEntry "UserID -$UserID"
New-LogEntry "CollectionID - $CollectionID"
New-LogEntry "CollectionName - $CollectionName"
New-LogEntry "WorkstationID - $WKID"

New-LogEntry 'Querying for collection'
$Collection = Get-WmiObject @WMIQueryParameters -Class SMS_Collection -Filter "CollectionID = '$CollectionID'"
$Collection.Get()

New-LogEntry $Collection.CollectionID
New-LogEntry $Collection.Name
New-LogEntry $([management.managementDateTimeConverter]::ToDateTime($Collection.LastChangeTime))

foreach($CollectionRule in $Collection.CollectionRules)
{
    New-LogEntry $CollectionRule.QueryExpression
    New-LogEntry $CollectionRule.QueryID
    New-LogEntry $CollectionRule.RuleName
}