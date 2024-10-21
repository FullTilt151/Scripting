<#
.Synopsis
    This script will be the deployment form for SCCM in Humana. It will be for deploying:
        Applications
        Packages
        Software Updates
        Task Sequences
        Compliance Scripts

.DESCRIPTION
    

.PARAMETER SiteServer
    This specifies the SiteServer the deployment is target against

.PARAMETER LogLevel
    This specifies the level of logging
        1 - Informational
        2 - Warning (Default)
        3 - Error
.PARAMETER LogFileDir
    Specifies the directory where the log will be written to, default is C:\Temp

.EXAMPLE

.LINK

.NOTES

#>

         
[CmdletBinding(SupportsShouldProcess=$true)]
Param(
    [Parameter(Mandatory=$true,HelpMessage="Site SiteServer where the SMS Provider is installed")]
    [ValidateScript({Test-Connection -ComputerName $_ -Count 1 -Quiet})]
    [String]$SiteServer,
    [Parameter(Mandatory=$false,HelpMessage="Sets the Log Level, 1 - Informational, 2 - Warning, 3 - Error")]
    [Int32]$LogLevel = 2,
    [Parameter(Mandatory=$false,HelpMessage="Log File Directory")]
    [String]$LogFileDir = 'C:\Temp\'
)

#Begin Funtions

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

#Begin Function New-Deployment
Function New-Deployment
{
    #1 Determine Deployment Type
        #Application
            #General Tab
                #Software 
                #TargetCollection
                #Automatically Distribute content for dependencies
                #Comments 
            #Content Tab
                #List of DPs/DPGroups
            #Deployment Settings
                #Action
                #Purpose
                #Require administrator approval if users request this application
            #Scheduling
                #TimeBasedOn
                #Schedule the application to be available at
            #User Experience
                #User Notifications
                #When the dealine is reached
                    #Software Install
                    #System Restart
                #Embedded devices - Commit changes at deadline checkbox
            #Alerts
                #Threshold for succesfull deployment
                    #Create alert
                    #Percent Success
                    #After date
                #Threshold for failed deployment
                    #Create alert checkbox
                    #Percent falure
                #Enalbe SCOM
                    #Enable maintenance mode checkbox
                    #Generate alert when software install fails checkbox
        
        #Package
            #General Tab
                #Software 
                #Collection
                #Automatically distribute content for dependencies checkbox
                #Comments
            #Content
                #List of DPs/DPGroups
            #Deployment Settings
                #Action
                #Purpose
                #Require administrator approval if users request this application
            #Scheduling
                #Schedule when available checkbox
                    #Date
                    #Time
                    #UTC Checkbox
                #Schedule when expire checkbox
                    #Date
                    #Time
                    #UTC Checkbox
                #Assignment schedule (Collection of schedules)
                #Rerun Behavior
            #User Experience
                #Allow users to run independent of assignments checkbox
                #Software install outside of maintenance window checkbox
                #Restart outside of maintenance window checkbox
                #Commint changes during maintenance window for embedded devices checkbox
            #Distribution Points
                #Deployment options for slow network
                #Deployment options for fast network
                #Allow clients to share checkbox
                #Allow clients to fallback checkbox

        #Software Update
}
#End Function New-Deployment

#End Functions

#Build variables for New-LogEntry Function
         
$ScriptName = $MyInvocation.MyCommand.Name
if(-not ($LogFileDir -match '\\$')){$LogFileDir = "$LogFileDir\"}
$LogFile = $ScriptName -replace '(.*)\.ps1', '$1'
$LogFile = $LogFileDir + $LogFile + '.log'

#SCCM Import Module
import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')

$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

Push-Location
Set-Location "$($SiteCode):"

New-LogEntry 'Starting Script'
New-LogEntry "SiteServer - $SiteServer"
New-LogEntry "SiteCode - $SiteCode" 
