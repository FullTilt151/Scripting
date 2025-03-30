<#
.Synopsis
   Stops never ending task sequences

.DESCRIPTION
   Used for PXE Boxes that have task sequences stuck in an "Installing" state

.PARAMETER ComputerName
    Computername to be worked on - Defaults to local workstations name

.EXAMPLE Fix-NeverEndingTS
    This will fix the local machine

.EXAMPLE Fix-NeverEndingTS -ComputerName CITPXEWPW01
    This will fix CITPXEWPW01

.LINK
    Blog
    http://parrisfamily.com

.NOTES

#>

         
[CmdletBinding(SupportsShouldProcess=$true)]
Param(
    [Parameter(Mandatory=$false,HelpMessage="Computer to be worked on, local name is used by default")]
    [String]$ComputerName=$env:COMPUTERNAME,
    [Parameter(Mandatory=$false,HelpMessage="Sets the Log Level, 1 - Informational, 2 - Warning, 3 - Error")]
    [Int32]$LogLevel = 2,
    [Parameter(Mandatory=$false,HelpMessage="Log File Directory")]
    [String]$LogFileDir = 'C:\Temp\'
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
if(-not ($LogFileDir -match '\\$')){$LogFileDir = "$LogFileDir\"}
$LogFile = $ScriptName -replace '(.*)\.ps1', '$1'
$LogFile = $LogFileDir + $LogFile + '.log'

New-LogEntry 'Starting Script'
New-LogEntry "ComputerName - $ComputerName"

$Query = 'SELECT * FROM CCM_TSExecutionRequest'
New-LogEntry 'Getting list of Task Sequences'
$TSRequests = get-wmiobject -ComputerName $ComputerName -NameSpace root\ccm\SoftMgmtAgent -Query $Query

foreach($TSRequest in $TSRequests)
{
    $TSRequest | Remove-WmiObject
}

New-LogEntry 'Finished Script!'