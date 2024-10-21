$Text = '
#SCCM Parameters
[CmdletBinding(SupportsShouldProcess=$true)]
Param(
    [Parameter(Mandatory=$true,HelpMessage="Site server where the SMS Provider is installed")]
    [ValidateScript({Test-Connection -ComputerName $_ -Count 1 -Quiet})]
    [String]$Server,
    [Parameter(Mandatory=$false,HelpMessage="Sets the Log Level, 1 - Informational, 2 - Warning, 3 - Error")]
    [Int32]$LogLevel = 2,
    [Parameter(Mandatory=$false,HelpMessage="Log File Directory")]
    [String]$LogFileDir = ''C:\Temp\''
)'

New-IseSnippet -Title 'SCCM Module - Paramemters' -Description 'These are the parameters for the begining of your script for the SCCM Module' -Text $Text -Author 'Jim Parris'

$Text = '
#SCCM Import Module
import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + ''\ConfigurationManager.psd1'')

$Site = $(Get-WmiObject -ComputerName $Server -Namespace ''root\SMS'' -Class SMS_ProviderLocation).SiteCode

Push-Location
Set-Location "$($site):"'

New-IseSnippet -Title 'SCCM Module' -Description 'This is used to import the SCCM Module' -Text $Text -Author 'Jim Parris'

$Text = '
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
            $Entry = ''N/A''
        }
        $TZOffset = ([TimeZoneInfo]::Local).BaseUTcOffset.TotalMinutes
        $TZOffset = "$(Get-Date -Format "HH:mm:ss.fff")+$(-$TZOffset)"
        $Entry = "<![LOG[{0}]LOG]!><time=""{2}"" date=""{1}"" component=""{5}"" context="""" type=""{4}"" thread=""{3}"">" -f $Entry, (Get-Date -Format "MM-dd-yyyy"), $TZOffset, $pid, $type, $component
        $Entry | Out-File $Script:LogFile -Append -Encoding ascii
    }
}
#End New-LogEntry'

New-IseSnippet -Title 'New-LogEntry - Function' -Description 'This is the New-LogEntry Function' -Text $Text -Author 'Jim Parris'

$Text = '
#Parameters in script for New-LogEntry
         
[CmdletBinding(SupportsShouldProcess=$true)]
Param(
    [Parameter(Mandatory=$false,HelpMessage="Sets the Log Level, 1 - Informational, 2 - Warning, 3 - Error")]
    [Int32]$LogLevel = 2,
    [Parameter(Mandatory=$false,HelpMessage="Log File Directory")]
    [String]$LogFileDir = ''C:\Temp\''
)'

New-IseSnippet -Title 'New-LogEntry - Parameters' -Description 'This is the parameters for the New-LogEntry Function' -Text $Text -Author 'Jim Parris'

$Text = '
#Build variables for New-LogEntry Function
         
$ScriptName = $MyInvocation.MyCommand.Name
if(-not ($LogFileDir -match ''\\$'')){$LogFileDir = "$LogFileDir\"}
$LogFile = $ScriptName -replace ''(.*)\.ps1'', ''$1''
$LogFile = $LogFileDir + $LogFile + ''.log'''

New-IseSnippet -Title 'New-LogEntry - Variables' -Description 'This is the parameters for the New-LogEntry Function' -Text $Text -Author 'Jim Parris'
