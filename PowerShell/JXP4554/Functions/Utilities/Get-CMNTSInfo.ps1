<#
.SYNOPSIS

.DESCRIPTION

.PARAMETER

.EXAMPLE

.LINK
	Blog
	http://configman-notes.com

.NOTES

#>
PARAM
(
	[Parameter(Mandatory=$true,HelpMessage='Name of SCCM Client')]
	[String]$ComputerName,
	[Parameter(Mandatory=$false,HelpMessage='Start Date/Time')]
	[DateTime]$StartTime = '1/1/1990 12:00:00 am',
	[Parameter(Mandatory=$false,HelpMessage='End Date/Time')]
	[DateTime]$EndTime = "$(Get-Date)",
    #Parameters in script for New-LogEntry
    [Parameter(Mandatory=$false,HelpMessage="Sets the Log Level, 1 - Informational, 2 - Warning, 3 - Error")]
    [Int32]$LogLevel = 1,
    [Parameter(Mandatory=$false,HelpMessage="Log File Directory")]
    [String]$LogFileDir = 'C:\Temp\',
    [Parameter(Mandatory=$false,HelpMessage="Clear any existing log file")]
    [Switch]$ClearLog
)

Function Get-EventLogEntry
{
    PARAM
    (
        [Parameter(Mandatory=$true,Position=1,HelpMessage='Computer name')]
        [String]$ComputerName,
        [Parameter(Mandatory=$true,Position=2,HelpMessage='Log to retrieve')]
        [String]$Log,
        [Parameter(Mandatory=$true,Position=3,HelpMessage='Start Time')]
        [DateTime]$StartTime,
        [Parameter(Mandatory=$true,Position=4,HelpMessage='Finish Time')]
        [DateTime]$EndTime
    )
    Get-EventLog -ComputerName $ComputerName -LogName $Log -After $StartTime -Before $EndTime
}

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

Function Convert-NormaltoWMIDateTime
{
	PARAM
	(
		[Parameter(Mandatory=$true)]
		[string]$DateTime
	)
	return [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime($DateTime)
}

#Build variables for New-LogEntry Function

$ScriptName = $MyInvocation.MyCommand.Name
if(-not ($LogFileDir -match '\\$')){$LogFileDir = "$LogFileDir\"}
$LogFile = $ScriptName -replace '(.*)\.ps1', '$1'
$LogFile = $LogFileDir + $LogFile + '.log'
if($ClearLog)
{
    if(Test-Path $Logfile) {Remove-Item $LogFile}
}

New-LogEntry 'Creating Excel SpreadSheet'

$objExcel = New-Object -ComObject Excel.Application
$objExcel.Visible = $true
$objWorkBook = $objExcel.Workbooks.Add()
$objAppLogWorkSheet = $objWorkBook.Worksheets.Item(1)

<#
$objExcel.cells.item(1,1) = 'Server Name' #Text
$objExcel.cells.item(1,2) = 'Site Code' #Text

$objExcel.cells.item(1,$i).Font.Size = 14
$objExcel.cells.item(1,$i).Font.Bold = $true
if ($i -gt 1) {$objExcel.cells.item(1,$i).Orientation = 90}
$objExcel.cells.item(1,$i).Interior.Color=$BackGroundColor

$Computername = 'LOUAPPWQS909'
$StartTime = '12/13/2015 12:13:00 pm'
$EndTime = '12/13/2015 12:30:00 pm'
#>

#Gather Events
New-LogEntry 'Gathering Application Log'
$AppJob = Start-Job -Name 'AppJob' -ScriptBlock ${Function:Get-EventLogEntry} -ArgumentList $ComputerName, 'Application', $StartTime, $EndTime
New-LogEntry 'Gathering System Log'
$SysJob = Start-Job -Name 'SysJob' -ScriptBlock ${Function:Get-EventLogEntry} -ArgumentList $ComputerName, 'System', $StartTime, $EndTime
New-LogEntry 'Gathering Security Log'
$SecJob = Start-Job -Name 'SecJob' -ScriptBlock ${Function:Get-EventLogEntry} -ArgumentList $ComputerName, 'Security', $StartTime, $EndTime

New-LogEntry 'Waiting for jobs to complete'
while((Get-Job | Where-Object {$_.State -eq 'Running'} | Measure-Object).Count -ne 0)
{
    sleep 10
    New-LogEntry 'Still Waiting'
}

$AppEvents = Receive-Job -Id ($AppJob.ID)
Remove-Job -Id ($AppJob.ID)
$SysEvents = Receive-Job -Id ($SysJob.ID)
Remove-Job -id ($SysJob.ID)
$SecEvents = Receive-Job -Id ($SecJob.ID)
Remove-Job -Id ($SecJob.ID)

#Gather WMI Info
#StateMsg
#Get-CimInstance -ClassName CCM_StateMsg -ComputerName $Computername -Namespace root\ccm\StateMsg -Filter "MessageTime > '$(Convert-NormaltoWMIDateTime $StartTime)'"
New-LogEntry 'Gathering CCMMessages'
$CCMMessages = Get-WmiObject -Namespace root\ccm\StateMsg -Class CCM_StateMsg -ComputerName $Computername -Filter "MessageTime > '$(Convert-NormaltoWMIDateTime $StartTime)'"
# CCM_ExecutionRequestEx
New-LogEntry 'Gathering CCMExectionHistory'
$CCMExectionHistory = Get-WmiObject -Namespace root\ccm\SoftMgmtAgent -Class CCM_ExecutionRequestEx -ComputerName $ComputerName

#Gather Registery
#HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SMS\Mobile Client\Software Distribution\Execution History
#HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SMS\Task Sequence

#Gather Logs

$objAppLogWorkSheet.Name = 'Application Log'
$AppArray = @{}
$AppArray = $AppEvents
Foreach($Appevent in $AppArray.GetEnumerator())
{
    write-host "$($Appevent.Key) = $($Appevent.Value) | $($Appevent)"
}