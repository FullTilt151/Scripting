<#
.SYNOPSIS
	This script will create collections and deploy the 1E software reclaimer to them.

.DESCRIPTION
	For the optional reclamations, we are creating seperate collections to target machines. This script will automate a lot of the processes.

.LINK
	https://mike-cook.com/

.NOTES
	Author:	Mike Cook
	Email:	Mike@mike-cook.com
	Date:	09/06/2018
	PSVer:	5.1
    Ver:    1.0

    9/6/18: Script creation.

#>

PARAM
    (
        [Parameter(Mandatory=$true)]
        [String]$CollID
    )

#Import CM module.
Import-Module 'C:\Program Files (x86)\ConfigMGR\bin\ConfigurationManager.psd1'

#Connect to WP1 site.
cd WP1:

#New-LogEntry
Function New-LogEntry
{
    Param
    (
        [Parameter(Position=0,Mandatory=$true)]
        [String]$Entry,

        [Parameter(Position=1,Mandatory=$false)]
	    [ValidateSet(1, 2, 3)]
        [INT32]$type = 1,

        [Parameter(Position=2,Mandatory=$false)]
        [String]$component = $ScriptName
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
}#End New-LogEntry




#Get collectionID




#Deploy mandatory and optional programs to collection. Prompt user for collectionID.