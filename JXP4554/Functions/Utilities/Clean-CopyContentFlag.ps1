<#
.SYNOPSIS
    Sets or clears the "Copy the content in this package to a package share on distribution points:".

.DESCRIPTION
    This script queries for all packages referenced by a task sequence, and all packages that have
    deployments with the "Run from distribution point" set. It will then log (and optionally
    remediate) whether the checkbox should be checked or not. It determines this by the fact if it
    is referenced by a task sequence and/or run from DP, the checkbox should be checked, otherwise
    cleared.

.PARAMETER Server
    Site server that you are working with.

.PARAMETER LogLevel
    Minimum logging level:
    1 - Informational
    2 - Warning (default)
    3 - Error

.PARAMETER LogFileDir
    Directory where log file will be created. Default C:\Temp.

.PARAMETER CheckContentBox
    If selected, any package that is referenced by a task sequence and/or has a deployment that is
    set to run from DP will have the checkbox checked, if it isn't as long as it is no larger than
    the MaxPackageSize

.PARAMETER ClearContentBox
    If selected, any package that is not referenced by a task sequence and does not have a deployment
    that is set to run form dp will have the checkbox cleared, if it isn't smaller than the
    MinPackageSize.

.PARAMETER WriteCSV
    If selected, will write a CSV file in the LogFileDir containing the PackageID, Package Name,
    Description, Package Size, whether or not it was remediated, if it was referenced by a task
    sequence, if it had a deployment with the "Run From DP" set, and if the Content box was checked.

.PARAMETER MinPackageSize
    Sets minimum package size (KB) that a package must be before clearing the checkbox. Default 0.

.PARAMETER MaxPackageSize
    Sets maximum package size (KB) that a package must be before setting the checkbox. Default MaxInt.

.EXAMPLE
    PS C:\> Clean-CopyContentFlag -Server Server01

    This example will log all packages that need to have the check box cleared or set but will make
    no changes based on the Site Server Sever01.

.EXAMPLE
    PS C:\> Clean-CopyContentFlag -Server Server01 -LogLevel 1 -LogFileDir C:\Logs -WriteCSV -CheckContentBox -ClearContentBox -MinPackageSize 10000 -MaxPackageSize -5000

    This example will work with Site Server Server 01, log all details in the C:\Logs directory where
    it will also create a .csv file in that directory. It will check the box for any package smaller
    than or equal to 5,000KB and clear the checkbox for any package larger than or equal to 10,000kb.

.LINK
    Blog
    http://parrisfamily.com

.NOTES
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [parameter(Mandatory=$true,HelpMessage="Site server where the SMS Provider is installed")]
    [ValidateScript({Test-Connection -ComputerName $_ -Count 1 -Quiet})]
    [string]$Server,
    [parameter(Mandatory=$false,HelpMessage="Sets the Log Level, 1 - Informational, 2 - Warning, 3 - Error")]
    [Int32]$LogLevel=2,
    [parameter(Mandatory=$false,HelpMessage="Log File Directory")]
    [string]$LogFileDir='C:\Temp\',
    [parameter(Mandatory=$false,HelpMessage="Write results to CSV File")]
    [switch]$WriteCSV,
    [parameter(Mandatory=$false,HelpMessage="Check the box where needed")]
    [switch]$CheckContentBox,
    [parameter(Mandatory=$false,HelpMessage="Clear the box where needed")]
    [switch]$ClearContentBox,
    [parameter(Mandatory=$false,HelpMessage="Minimum Package Size to clear check box")]
    [int32]$MinPackageSize=0,
    [parameter(Mandatory=$false,HelpMessage="Maximum Package Size to check box")]
    [int32]$MaxPackageSize=[int32]::MaxValue
)

import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')

Function New-LogEntry {
    # Writes to the log file
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [STRING] $Entry,

        [Parameter(Position=1,Mandatory=$false)]
        [INT32] $type = 1,

        [Parameter(Position=2,Mandatory=$false)]
        [STRING] $component = $ScriptName)
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

$ScriptName = $MyInvocation.MyCommand.Name
if(-not ($LogFileDir -match '\\$')){$LogFileDir = "$LogFileDir\"}
$LogFile = $ScriptName -replace '(.*)\.ps1', '$1'
$CSVFile = $LogFileDir + $LogFile + '.csv'
$LogFile = $LogFileDir + $LogFile + '.log'
if($WriteCSV){'"PackageID","Package Name","Description","Package Size (KB)","Remediated","Task Sequence","Run From DP","Content Checked"' | Out-File $CSVFile -Encoding ascii}
$Site = $(Get-WmiObject -ComputerName $Server -Namespace root/SMS -Class SMS_ProviderLocation).SiteCode

Push-Location
Set-Location "$($site):"

New-LogEntry '-------------------------------------------------' 2
New-LogEntry "Starting" 2
New-LogEntry "Options:" 2
New-LogEntry "Server - $Server" 2
New-LogEntry "LogLevel - $LogLevel" 2
New-LogEntry "LogFileDir - $LogFileDir" 2
New-LogEntry "LogFile - $LogFile" 2
New-LogEntry "ClearContentBox - $ClearContentBox" 2
New-LogEntry "CheckContentBox - $CheckContentBox" 2
New-LogEntry "WriteCSV - $WriteCSV" 2
New-LogEntry "MinPackageSize - $MinPackageSize" 2
New-LogEntry "MaxPackageSize - $MaxPackageSize" 2
New-LogEntry "Site - $Site" 2

#Get a list of packages associated with all task sequences
New-LogEntry 'Getting Task Sequences'
$TaskSequences = $(Get-CMTaskSequence).References | Select-Object -Property Package

#Get Deployments where they are run from DP
New-LogEntry 'Getting Deployments'
$Deployments = (Get-WmiObject -ComputerName $Server -Namespace root/sms/site_$($Site) -Class SMS_Advertisement | ForEach-Object {if ($_.RemoteClientFlags -bxor 0x80) {$_.PackageID}})

#Get list of packages
New-LogEntry 'Getting Packages'
$Packages = Get-CMPackage

New-LogEntry 'Starting processing of packages'

foreach ($Package in $Packages)
{
    New-LogEntry "Checking $($Package.PackageID)"
    $TSSMatch = $false
    $PkgMatch = $false
    $Entry = $Package.PackageID.ToString()
    $Package.Get()

    foreach ($TaskSequence in $TaskSequences)
    {
        if ($TaskSequence.Package -eq $Package.PackageID)
        {
            New-LogEntry "Referenced by task sequence"
            $Entry = "$Entry is referenced by a task sequence"
            $TSSMatch = $true
            break
        }
    }

    foreach($Deployment in $Deployments) #Check to see if the package has a deployment with "Run from distribution point"
    {
        if ($Package.PackageID -eq $Deployment)
        {
            New-LogEntry "$Deployment Deployment Match"
            if ($Entry.Length -gt 8) {$Entry = "$Entry, and "}
            $Entry = "$Entry has a deployment that run's from DP"
            $PkgMatch =$true
            break
        }
    }

    $CopyContentChecked = $Package.PkgFlags -band 0x80

    if ($PkgMatch -or $TSSMatch) #Should have box checked
    {
        if (-not ($CopyContentChecked))
        {
            $IsFixed = $false
            $ContentChecked = $false
            New-LogEntry "$Entry. It should have 'Copy content' checked. Package Size - $($Package.PackageSize)KB" 2
            if(($CheckContentBox) -and ($Package.PackageSize -le $MaxPackageSize))
            {
                New-LogEntry "Setting Checkbox..." 2
                $IsFixed = $true
                $Package.PkgFlags = $Package.PkgFlags -bor 0x80
                $Package.RefreshPkgSourceFlag = $true
                $package.put()
            }
            if($WriteCSV)
            {
                "`"" + $Package.PackageID + "`",`"" + $Package.Name + "`",`"" + $Package.Description + "`",`"" + $Package.PackageSize + "`",`"" + $IsFixed + "`",`"" + $TSSMatch + "`",`"" + $PkgMatch + "`",`"" + $ContentChecked + "`"" | Out-File $CSVFile -Append ascii
            }
        }
    }
    if (-not ($PkgMatch -or $TSSMatch)) #Should not have box checked
    {
         if($CopyContentChecked)
         {
            $IsFixed = $false
            $ContentChecked = $true
            if ($Entry.Length -le 8)
            {
                $Entry = "$Entry has no Run from DP deployments and is not referenced by a TS. "
            }
            New-LogEntry "$Entry. It should NOT have 'Copy content' checked. Package Size - $($Package.PackageSize)KB" 2
            if (($ClearContentBox) -and ($Package.PackageSize -ge $MinPackageSize))
            {
                New-LogEntry "Clearing Checkbox..." 2
                $IsFixed = $true
                $Package.PkgFlags = $Package.PkgFlags -band 0xff7f
                $Package.RefreshPkgSourceFlag = $true
                $Package.put()
            }
            if($WriteCSV)
            {
                "`"" + $Package.PackageID + "`",`"" + $Package.Name + "`",`"" + $Package.Description + "`",`"" + $Package.PackageSize + "`",`"" + $IsFixed + "`",`"" + $TSSMatch + "`",`"" + $PkgMatch + "`",`"" + $ContentChecked + "`"" | Out-File $CSVFile -Append ascii
            }
        }
    }
}
Pop-Location
New-LogEntry 'Finished script' 2
New-LogEntry '-------------------------------------------------' 2