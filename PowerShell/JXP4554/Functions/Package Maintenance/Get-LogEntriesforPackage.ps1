<#
.SYNOPSIS
    Scans log file and follows log to log to get the execution of a package

.DESCRIPTION
    This file will scan the log file for a packageID or some other identifiable 
    information. It will follow the log entries in the related logs to show the
    complete execution of the package 

.PARAMETER LogFilePath
    Path to the log files, defaults to C:\Windows\CCM\Logs

.PARAMETER SearchString
    What we are looking for

.EXAMPLE
    PS C:\> Get-LogEntriesforPackage -LogFilePath \\SomeMachine\C$\Windows\CCM\Logs -SearchString PackageName1,PackageID2

.LINK
    http://parrisfamily.com

.NOTES
    Author:  James Parris
    Email:   Jim@ParrisFamily.com
    Date:    02/18/2014
    PSVer:   3.0
#>


Param(
    [Parameter(Mandatory=$false)][string]$LogFilePath,
    [Parameter(Mandatory=$true)][array]$SearchString
)

Function ParseLog {
    Param(
            [String]$LogFileName,
            [array]$ParseString)

    $Log = @{}
    $Lines = @{}
    $Log = Get-Content $LogFileName
    ForEach($Line in $Log) {
        ForEach($ParseItem in $ParseString) {
            if ($Line.ToLower().Contains($ParseItem.ToString().ToLower())) {
                if ($line.Contains("corresponding DTS job")) {
                    $JobID = $line.Substring($line.IndexOf("{") + 2, $line.IndexOf("}") - $Line.IndexOf("{") - 2)
                    $Script:SearchString += $JobID
                }
                $Line | Out-File 'search.log' -Append
            }
        }
    }
    if ($Lines.Count -gt 0) {
        $Lines | Out-File 'search.log' -Append
    }
}

if ($LogFilePath.Length -eq 0) {
    $LogFilePath="C:\Windows\CCM\Logs"
    }

if (-not (Test-Path $LogFilePath)) {
    Write-Host "Invalid Path"
    exit
    }

$Files = @{}

$Files = Get-ChildItem $LogFilePath
if (Test-Path 'search.log') {
    Remove-Item 'search.log'
}

foreach ($File in $Files){
    if (($File.ToString().EndsWith("log")) -or ($File.ToString().EndsWith("lo_"))) {
        "Searching $File" 
        ParseLog "$LogFilePath\$File" $SearchString
    }
}