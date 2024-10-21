<#
.SYNOPSIS
	Cleans up the content locations for various package types

.DESCRIPTION
	This script will go out to the package types selected and remove any unwanted assignments
	and ensure you have just the assignments you need. It will also deploy content for any
	packages that have deployments and remove packages from DP's that do not have any deployments

.PARAMETER Server
	Site server that you are working with.

.PARAMETER LogLevel
	Minimum logging level:
	1 - Informational
	2 - Warning (default)
	3 - Error

.PARAMETER LogFileDir
	Directory where log file will be created. Default C:\Temp.

.PARAMETER StartFolder
	This parameter is not currently used.

.PARAMETER DPTargets
	This is an array of the DP Groups you want to put the packages on.

.PARAMETER DPKeep
	This is an array of DP Groups that you want to keep if the package is already on there.

.PARAMETER SleepSeconds
	This is a delay between each package to help not overload the site server. Default is 10 seconds.

.PARAMETER RemoveExistingDPGroups
	This will cause the script to remove it from the DP Groups.

.PARAMETER RemoveExistingDPs
	This will cause the script to remove it from the DP's

.PARAMETER PkgStatus
	This will cause the script to only make changes to packages whos status match this. You can supply
	multiple statuses. They can be:
	ALL
	INSTALLED
	INSTALL_PENDING
	INSTALL_RETRYING -Default
	INSTALL_FAILED   -Default
	REMOVAL_PENDING  -Default
	REMOVAL_RETRYING -Default
	REMOVAL_FAILED   -Default

.PARAMETER CleanPackages
	This will cause the script to clean standard packages.

.PARAMETER CleanDriverPackages
	This will cause the script to clean driver packages.

.PARAMETER CleanSoftwareUpdatePackages
	This will cause the script to clean software update packages.

.PARAMETER CleanImagePackages
	This will cause the script to clean image packages.

.PARAMETER CleanBootImagePackages
	This will cause the script to clean boot image packages.

.PARAMETER CleanApplicationPackages
	This will cause the script to clean application packages.

.EXAMPLE
	PS C:\> Repair-CMNDPGroups.ps1 -Server Server01 -RemoveExistingDPGroups -RemoveExistingDPs `
	-DPTargets 'Intranet DP''s' -DPKeep 'All DP''s' -CleanSoftwareUpdatePackages -CleanPackages `
	-CleanDriverPackages -CleanImagePackages -CleanBootImagePackages -CleanApplicationPackages

	This example will clean software update, standard, driver, task sequence, content, image,
	boot image, and application packages, putting them on Intranet DP's DP Group and keeping any
	on All DP's, while removing it from existing DP's and DP Groups.

.LINK
	Blog
	http://configman-notes.com

.NOTES
	State Values
		0 = INSTALLED
		1 = INSTALL_PENDING
		2 = INSTALL_RETRYING
		3 = INSTALL_FAILED
		4 = REMOVAL_PENDING
		5 = REMOVAL_RETRYING
		6 = REMOVAL_FAILED
		8 = FAILED_VALIDATION

Rewriting - Use status instead of packages

$Query = "SELECT * FROM SMS_PackageStatusDistPointsSummarizer WHERE state in ('2','3','8')"
$DistStatuss = Get-WmiObject -Query $Query @WMIQueryParameters
foreach($DistStatus in $DistStatuss)
{
    $Server = $DistStatus.ServerNALPath -replace '.*\\\\([A-Z0-9_.]+)\\.*', '$+'
    Write-Output "$($DistStatus.PackageID) - $($DistStatus.State) - $Server"
}#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [parameter(Mandatory=$true,HelpMessage="Site server where the SMS Provider is installed")]
    [ValidateScript({Test-Connection -ComputerName $_ -Count 1 -Quiet})]
    [string]$Server,
    [parameter(Mandatory=$false,HelpMessage="Starting Folder")]
    [string]$StartFolder='\',
    [parameter(Mandatory=$false,HelpMessage="DP Group to put packages on")]
    [string[]]$DPTargets='All DP''s',
    [parameter(Mandatory=$false,HelpMessage="DP Group to leave if present")]
    [string[]]$DPKeep = @(),
    [parameter(Mandatory=$false,HelpMessage="Number of seconds to sleep between packages")]
    [int]$SleepSeconds=10,
    [parameter(Mandatory=$false,HelpMessage="Remove Existing DP Groups")]
    [switch]$RemoveExistingDPGroups,
    [parameter(Mandatory=$false,HelpMessage="Remove Individual DP's")]
    [switch]$RemoveExistingDPs,
    [parameter(Mandatory=$false,HelpMessage="This will cause the script to only make changes to packages whos status match this. You can supply multiple statuses")]
    [ValidateSet('ALL','INSTALLED','INSTALL_RETRYING','INSTALL_FAILED','REMOVAL_PENDING','REMOVAL_RETRYING','REMOVAL_FAILED',ignorecase = $true)]
    [array]$PkgStatus = @('INSTALL_RETRYING','INSTALL_FAILED','REMOVAL_PENDING','REMOVAL_RETRYING','REMOVAL_FAILED'),
    [parameter(Mandatory=$false,HelpMessage="Clean Standard Packages")]
    [switch]$CleanPackages,
    [parameter(Mandatory=$false,HelpMessage="Clean Driver Packages")]
    [switch]$CleanDriverPackages,
    [parameter(Mandatory=$false,HelpMessage="Clean Software Update Packages")]
    [switch]$CleanSoftwareUpdatePackages,
    [parameter(Mandatory=$false,HelpMessage="Clean Image Packages")]
    [switch]$CleanImagePackages,
    [parameter(Mandatory=$false,HelpMessage="Clean Boot Image Packages")]
    [switch]$CleanBootImagePackages,
    [parameter(Mandatory=$false,HelpMessage="Clean Application Packages")]
    [switch]$CleanApplicationPackages,
    [parameter(Mandatory=$false,HelpMessage="Sets the Log Level, 1 - Informational, 2 - Warning, 3 - Error")]
    [Int32]$LogLevel = 1,
    [parameter(Mandatory=$false,HelpMessage="Log File Directory")]
    [string]$LogFileDir = 'C:\Temp\'
)

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
        Write-Verbose $Entry
        $Entry = "<![LOG[{0}]LOG]!><time=""{2}"" date=""{1}"" component=""{5}"" context="""" type=""{4}"" thread=""{3}"">" -f $Entry, (Get-Date -Format "MM-dd-yyyy"), $TZOffset, $pid, $type, $component
        $Entry | Out-File $Script:LogFile -Append -Encoding ascii
    }
}
#End New-LogEntry

Function Remove-CMDPPackage
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [PSObject]$Package,
        [Parameter(Mandatory=$true)]
        [array]$DPTargets,
        [Parameter(Mandatory=$false)]
        [array]$DPKeeps
    )

    #First, get a list of DP/DPGroup's the package is on
    New-LogEntry 'Starting Function Remove-CMDPPackage' 1 'Remove-CMDPPackage'
    New-LogEntry "Package -  $Package" 1 'Remove-CMDPPackage'
    New-LogEntry "DPTargets - $DPTargets" 1 'Remove-CMDPPackage'
    New-LogEntry "DPKeeps - $DPKeeps" 1 'Remove-CMDPPackage'

    $Query = "SELECT * FROM SMS_PackageContentServerInfo where ObjectID = '$($Package.PackageID)'"
    $DPStatus = Get-WmiObject -Query $Query @WMIQueryParameters
    $IsDPRemoved = $false

    #Go through and remove each DP/DPGroup
    if (($DPStatus) -and ($RemoveExistingDPGroups -or $RemoveExistingDPs))
    {
        foreach($DP in $DPStatus)
        {
            if ($DP.Name -match '\\')
            {
                $DPName = $DP.Name -replace "([\[])”,'[$1]’ -replace “(\\)”,'$1' -replace '\\\\(.*)', '$1'
            }
            else
            {
                $DPName = $DP.Name
            }
            foreach($DPK in $DPKeeps)
            {
                if ($DPName -match $DPK)
                {
                    New-LogEntry "Package $($Package.PackageID) exists on a $DPName so we'll need to add that back." 1 'Remove-CMDPPackage'

                    #See if it's in the list
                    $DPKeepExists = $false
                    foreach($x in $DPTargets)
                    {
                        if ($DPName -match $x) {$DPKeepExists = $true}
                    }

                    if (-not ($DPKeepExists))
                    {
                        $DPTargets = $DPTargets + $DPName
                    }
                }
            }

            if ($DP.ContentServerType -eq 1)
            {
                $Assignment='DP'
                if ($RemoveExistingDPs)
                {
                    New-LogEntry "Removing Package $($Package.PackageID) from $DPName" 1 'Remove-CMDPPackage'
                    $Package.IsDPRemoved = $true
                    Switch ($Package.PackageType)
                    {
                        0 {Remove-CMContentDistribution -PackageId $Package.PackageID -DistributionPointName $DPName -ErrorAction SilentlyContinue -Force}
                        3 {Remove-CMContentDistribution -DriverPackageId $Package.PackageID -DistributionPointName $DPName -ErrorAction SilentlyContinue -Force}
                        5 {Remove-CMContentDistribution -DeploymentPackageID $Package.PackageID -DistributionPointName $DPName -ErrorAction SilentlyContinue -Force}
                        257 {Remove-CMContentDistribution -OperatingSystemImageId $Package.PackageID -DistributionPointName $DPName -ErrorAction SilentlyContinue -Force}
                        258 {Remove-CMContentDistribution -BootImageId $Package.PackageID -DistributionPointName $DPName -ErrorAction SilentlyContinue -Force}
                        512 {Remove-CMContentDistribution -ApplicationId $Package.CI_ID -DistributionPointName $DPName -ErrorAction SilentlyContinue -Force}
                        default {New-LogEntry "Distribute to DP $DPName - Unknown Package Type $($DP.PackageType)" 2 'Remove-CMDPPackage'}
                    }
                }
            }
            else
            {
                $Assignment='DP Group'
                if ($RemoveExistingDPGroups)
                {
                    New-LogEntry "Removing Package $PackageID from $DPName" 1 'Remove-CMDPPackage'
                    $Package.IsDPRemoved = $true
                    Switch  ($Package.PackageType)
                    {
                        0 {Remove-CMContentDistribution -PackageId $Package.PackageID -DistributionPointGroupName $DPName -ErrorAction SilentlyContinue -Force}
                        3 {Remove-CMContentDistribution -DriverPackageId $Package.PackageID -DistributionPointGroupName $DPName -ErrorAction SilentlyContinue -Force}
                        5 {Remove-CMContentDistribution -DeploymentPackageID $Package.PackageID -DistributionPointGroupName $DPName -ErrorAction SilentlyContinue -Force}
                        257 {Remove-CMContentDistribution -OperatingSystemImageId $Package.PackageID -DistributionPointGroupName $DPName -ErrorAction SilentlyContinue -Force}
                        258 {Remove-CMContentDistribution -BootImageId $Package.PackageID -DistributionPointGroupName $DPName -ErrorAction SilentlyContinue -Force}
                        512 {Remove-CMContentDistribution -ApplicationId $Package.CI_ID -DistributionPointGroupName $DPName -ErrorAction SilentlyContinue -Force}
                        default {New-LogEntry "Distribute to DP Group $DPName - Unknown Package Type $($DP.PackageType)" 2 'Remove-CMDPPackage'}
                    }
                }
            }
        }
    }
    else
    {
        New-LogEntry "Package $PackageID is not currently distributed" 1 'Remove-CMDPPackage'
    }

    New-LogEntry 'End Function Remove-CMDPPackage' 1 'Remove-CMDPPackage'
    return ,$DPTargets
}
#End Remove-CMDPPackage

Function Start-CMDPPackage
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [PSObject]$Package,
        [Parameter(Mandatory=$true)]
        [array]$DPTargets
    )

    #Deploy package to DPTargets, if there is anything to deploy
    New-LogEntry 'Starting Function Start-CMDPPackage' 1 'Start-CMDPPackage'
    New-LogEntry "Package - $Package" 1 'Start-CMDPPackage'
    New-LogEntry "DPTargets - $DPTargets" 1 'Start-CMDPPackage'

    #Sleep here if requested.
    if (($SleepSeconds -gt 0) -and ($Package.IsDPRemoved))
    {
        New-LogEntry "Sleeping for $SleepSeconds." 1 'Start-CMDPPackage'
        Start-Sleep -Seconds $SleepSeconds
    }
    else
    {
        New-LogEntry 'No need to sleep!' 1 'Start-CMDPPackage'
    }
    foreach($DPTarget in $DPTargets)
    {
        New-LogEntry "Distributing package $($Package.Name) to $DPTarget" 1 'Start-CMDPPackage'
        Switch ($Package.PackageType)
        {
            0 {Start-CMContentDistribution -PackageId $Package.PackageID -DistributionPointGroupName $DPTarget -ErrorAction SilentlyContinue}
            3 {Start-CMContentDistribution -DriverPackageId $Package.PackageID -DistributionPointGroupName $DPTarget -ErrorAction SilentlyContinue}
            5 {Start-CMContentDistribution -DeploymentPackageID $Package.PackageID -DistributionPointGroupName $DPTarget -ErrorAction SilentlyContinue}
            257 {Start-CMContentDistribution -OperatingSystemImageId $Package.PackageID -DistributionPointGroupName $DPTarget -ErrorAction SilentlyContinue}
            258 {Start-CMContentDistribution -BootImageId $Package.PackageID -DistributionPointGroupName $DPTarget -ErrorAction SilentlyContinue}
            512 {Start-CMContentDistribution -ApplicationId $Package.CI_ID -DistributionPointGroupName $DPTarget -ErrorAction SilentlyContinue}
            default {New-LogEntry 'Unknown Package Type' 2 'Start-CMDPPackage'}
        }
    }
    New-LogEntry 'End Function' 1 'Start-CMDPPackage'
}
#End Start-CMDPPackage

Function IsPKGReferenced
{
    Param
    (
        [parameter(Mandatory=$True)]
        [PSObject]$Package
    )

    New-LogEntry 'Starting Function IsPKGReferenced' 1 'IsPKGReferenced'
    New-LogEntry "Package - $Package" 1 'IsPKGReferenced'
    $IsPKGReferenced = $false

    if (($Package.PackageType -eq 3) -or ($Package.PackageType -eq 5) -or ($Package.PackageType -eq 257) -or ($Package.PackageType -eq 258))
    {
        Switch ($Package.PackageType)
        {
            3 {$Message = 'Driver '}
            5 {$Message = 'Software Update '}
            257 {$Message = 'Image '}
            258 {$Message = 'Boot image '}
        }
        $Message += 'package, returning true'
        New-LogEntry $Message 1 'IsPKGReferenced'
        $IsPKGReferenced = $True
    }
    else
    {
        New-LogEntry "Checking if Package $($Package.Name) is referenced by a task sequence" 1 'IsPKGReferenced'
        if ($Package.PackageType -eq 512)
        {
            $Query = "SELECT * FROM SMS_TaskSequenceAppReferencesInfo  WHERE RefAppPackageID = '$($Package.PackageID)'"
        }
        else
        {
            $Query = "SELECT * FROM SMS_TaskSequenceReferencesInfo WHERE ReferencePackageID = '$($Package.PackageID)'"
        }
        $TaskSequence = Get-WmiObject -Query $Query @WMIQueryParameters
        if ($TaskSequence)
        {
            $IsPKGReferenced = $True
            New-LogEntry 'It is referenced by a task sequence' 1 'IsPKGReferenced'
        }
        else
        {
            New-LogEntry 'It is not referenced by a task sequence' 1 'IsPKGReferenced'
        }

        $Query = "SELECT * FROM SMS_DeploymentSummary WHERE PackageID = '$($Package.PackageID)'"
        $DistributionStatus = Get-WmiObject -Query $Query @WMIQueryParameters
        if ($DistributionStatus)
        {
            $IsPKGReferenced = $True
            New-LogEntry 'It is referenced by a distribution' 1 'IsPKGReferenced'
        }
        else
        {
            New-LogEntry 'It is not referenced by a distribution' 1 'IsPKGReferenced'
        }
    }
    New-LogEntry "End Function - Returning $IsPKGReferenced" 1 'IsPKGReferenced'
    return $IsPKGReferenced
}
#End IsPKGReferenced

Function Clean-Package
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [PSObject]$Package
    )

    New-LogEntry 'Starting Clean-Package' 1 'Clean-Package'
    New-LogEntry "Package - $Package" 1 'Clean-Package'
    #First, is this a package we are supposed to work with?
    New-LogEntry "Checking status of package $($Package.Name) - $($Package.PackageID)" 1 'Clean-Package'
    if ($AllPkgStaes) #We picked all, so no use going nuts
    {
        New-LogEntry "All Packages are being checked" 1 'Clean-Package'
        $IsPkgStatusMatch = $true
    }
    else
    {
        #We need to query and see the status.
        $Query = "SELECT * FROM SMS_PackageStatusDistPointsSummarizer WHERE PackageID = '$($Package.PackageID)'"
        $DistStatuss = Get-WmiObject -Query $Query @WMIQueryParameters

        if ($DistStatuss)
        {
            New-LogEntry "$($Package.Name) appears to be distributed, checking if it's state is one we're looking for" 1 'Clean-Package'
            $IsPkgStatusMatch = $false
            foreach($DistStatus in $DistStatuss)
            {
                foreach($PkgState in $Pkgstates)
                {
                    New-LogEntry "Checking if the package state of $($PkgStateNames[$DistStatus.State]) matches $($PkgStateNames[$PkgState])" 1 'Clean-Package'
                    if ($PkgState -eq $DistStatus.State)
                    {
                        $IsPkgStatusMatch = $true
                        New-LogEntry "Package $($Package.Name) has a status of $($PkgStateNames[$PkgState])" 1 'Clean-Package'
                        break
                    }
                }
            }
            New-LogEntry "Finished Checking, result is $IsPkgStatusMatch" 1 'Clean-Package'
        }
        else
        {
            $IsPkgStatusMatch = $false
            New-LogEntry "Package $($Package.Name) is not currently distributed" 1 'Clean-Package'
        }
    }
    #If we're supposed to, remove the package from the DP/DP Groups
    if ($IsPkgStatusMatch)
    {
        if ($RemoveExistingDPGroups -or $RemoveExistingDPs) #Need to remove package
        {
            $DPs = Remove-CMDPPackage -Package $Package -DPTargets $DPTargets -DPKeeps $DPKeep
        }
        else
        {
            $DPs = $DPTargets
        }

        #Check to see if the package is referenced by a task sequence or deployment
        if ((IsPKGReferenced $Package) -and $IsPkgStatusMatch)
        {
            if (($Package.PackageSize -gt 0) -or $Package.HasContent)
            {
                Start-CMDPPackage -Package $Package -DPTargets $DPs
            }
        }
        else
        {
            New-LogEntry "$($Package.Name) is not referenced by a task sequence or deployment" 1 'Clean-Package'
        }
    }
    New-LogEntry 'End function' 1 'Clean-Package'
}
#End Clean-Package

#End of Functions

#Import ConfigurationManager Module

import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')

#Build variables for New-LogEntry Function

$ScriptName = $MyInvocation.MyCommand.Name
if(-not ($LogFileDir -match '\\$')){$LogFileDir = "$LogFileDir\"}
$LogFile = $ScriptName -replace '(.*)\.ps1', '$1'
$LogFile = $LogFileDir + $LogFile + '.log'

#Figure out what site we're connecting to.

$Site = $(Get-WmiObject -ComputerName $Server -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

#Put log here to confirm we connected.................................................

New-LogEntry "Connected to site $Site."

#Log the switch settings
New-LogEntry 'Starting script with the following options:'
New-LogEntry "Server - $Server"
New-LogEntry "StartingFolder - $StartFolder"
New-LogEntry "DPTargets - $DPTargets"
New-LogEntry "DPKeep - $DPKeep"
New-LogEntry "RemoveExistingDPGroups - $RemoveExistingDPGroups"
New-LogEntry "RemoveExistingDPs - $RemoveExistingDPs"
New-LogEntry "PkgStatus - $PkgStatus"
New-LogEntry "SleepSeconds - $SleepSeconds"
New-LogEntry "CleanPackages - $CleanPackages"
New-LogEntry "CleanDriverPackages - $CleanDriverPackages"
New-LogEntry "CleanSoftwareUpdatePackages - $CleanSoftwareUpdatePackages"
New-LogEntry "CleanImagePackages - $CleanImagePackages"
New-LogEntry "CleanBootImagePackages - $CleanBootImagePackages"
New-LogEntry "CleanApplicationPackages - $CleanApplicationPackages"
New-LogEntry "LogLevel - $LogLevel"
New-LogEntry "LogFileDir- $LogFileDir"

#Build array of states from PkgStatus
$PkgStates = @()
$PkgStateNames = @('Installed', 'Install Pending', 'Install Retrying', 'Install Failed', 'Removal Pending', 'Removal Retrying', 'Removal Failed')
$AllPkgStaes = $false
foreach($State in $PkgStatus)
{
    switch($State)
    {
        "ALL" {$AllPkgStaes = $true}
        "INSTALLED" {$PkgStates += 0}
        "INSTALL_PENDING" {$PkgStates += 1}
        "INSTALL_RETRYING" {$PkgStates += 2}
        "INSTALL_FAILED" {$PkgStates += 3}
        "REMOVAL_PENDING" {$PkgStates += 4}
        "REMOVAL_RETRYING" {$PkgStates += 5}
        "REMOVAL_FAILED" {$PkgStates += 6}
    }
}

#Save our current location before changing
Push-Location
Set-Location "$($site):"

$WMIQueryParameters = @{
    ComputerName = $Server
    Namespace = "root\sms\site_$Site"
}

#0 - Regular software distribution package.
if ($CleanPackages)
{
    New-LogEntry 'Getting Regular software distribution package.'
    $Packages = Get-CMPackage

    if ($Packages)
    {
        New-LogEntry 'Cleaning packages'
        foreach($PKG in $Packages)
        {
            #Start by creating Package object for reference
            $Package = New-Object PSObject
            $Package | Add-Member -MemberType NoteProperty -Name 'PackageID' -Value $Pkg.PackageID
            $Package | Add-Member -MemberType NoteProperty -Name 'Name' -Value $PKG.Name
            $Package | Add-Member -MemberType NoteProperty -Name 'PackageSize' -Value $PKG.PackageSize
            $Package | Add-Member -MemberType NoteProperty -Name 'PackageType' -Value '0'
            $Package | Add-Member -MemberType NoteProperty -Name 'IsDPRemoved' -Value $false
            Clean-Package $Package
        }
    }
}

#3 - Driver package.
if ($CleanDriverPackages)
{
    New-LogEntry 'Getting driver packages.'
    $Packages = Get-CMDriverPackage

    if ($Packages)
    {
        New-LogEntry 'Cleaning driver packages'
        foreach($PKG in $Packages)
        {
            #Start by creating Package object for reference
            $Package = New-Object PSObject
            $Package | Add-Member -MemberType NoteProperty -Name 'PackageID' -Value $Pkg.PackageID
            $Package | Add-Member -MemberType NoteProperty -Name 'Name' -Value $PKG.Name
            $Package | Add-Member -MemberType NoteProperty -Name 'PackageSize' -Value $PKG.PackageSize
            $Package | Add-Member -MemberType NoteProperty -Name 'PackageType' -Value '3'
            $Package | Add-Member -MemberType NoteProperty -Name 'IsDPRemoved' -Value $false
            Clean-Package $Package
        }
    }
}

#5 - Software update package.
if ($CleanSoftwareUpdatePackages)
{
    New-LogEntry 'Getting Software Update Packages'
    $Packages = Get-CMSoftwareUpdateDeploymentPackage

    if ($Packages)
    {
        New-LogEntry 'Cleaning software update packages'
        foreach($PKG in $Packages)
        {
            #Start by creating Package object for reference
            $Package = New-Object PSObject
            $Package | Add-Member -MemberType NoteProperty -Name 'PackageID' -Value $Pkg.PackageID
            $Package | Add-Member -MemberType NoteProperty -Name 'Name' -Value $PKG.Name
            $Package | Add-Member -MemberType NoteProperty -Name 'PackageSize' -Value $PKG.PackageSize
            $Package | Add-Member -MemberType NoteProperty -Name 'PackageType' -Value '5'
            $Package | Add-Member -MemberType NoteProperty -Name 'IsDPRemoved' -Value $false
            Clean-Package $Package
        }
    }
}

#257 - Image package.
if ($CleanImagePackages)
{
    New-LogEntry 'Getting Image package.'
    $Packages = Get-CMOperatingSystemImage

    if ($Packages)
    {
        New-LogEntry 'Cleaning image packages'
        foreach($PKG in $Packages)
        {
            #Start by creating Package object for reference
            $Package = New-Object PSObject
            $Package | Add-Member -MemberType NoteProperty -Name 'PackageID' -Value $Pkg.PackageID
            $Package | Add-Member -MemberType NoteProperty -Name 'Name' -Value $PKG.Name
            $Package | Add-Member -MemberType NoteProperty -Name 'PackageSize' -Value $PKG.PackageSize
            $Package | Add-Member -MemberType NoteProperty -Name 'PackageType' -Value '257'
            $Package | Add-Member -MemberType NoteProperty -Name 'IsDPRemoved' -Value $false
            Clean-Package $Package
        }
    }
}

#258 - Boot image package.
if ($CleanBootImagePackages)
{
    New-LogEntry 'Getting Boot Image package.'
    $Packages = Get-CMBootImage

    if ($Packages)
    {
        New-LogEntry 'Cleaning boot image ackages'
        foreach($PKG in $Packages)
        {
            #Start by creating Package object for reference
            $Package = New-Object PSObject
            $Package | Add-Member -MemberType NoteProperty -Name 'PackageID' -Value $Pkg.PackageID
            $Package | Add-Member -MemberType NoteProperty -Name 'Name' -Value $PKG.Name
            $Package | Add-Member -MemberType NoteProperty -Name 'PackageSize' -Value $PKG.PackageSize
            $Package | Add-Member -MemberType NoteProperty -Name 'PackageType' -Value '258'
            $Package | Add-Member -MemberType NoteProperty -Name 'IsDPRemoved' -Value $false
            Clean-Package $Package
        }
    }
}

#512 - Application package.
if ($CleanApplicationPackages)
{
    New-LogEntry 'Getting Application packages.'
    $Packages = Get-CMApplication

    if ($Packages)
    {
        New-LogEntry 'Cleaning applications'
        foreach($PKG in $Packages)
        {
            #Start by creating Package object for reference
            $Package = New-Object PSObject
            $Package | Add-Member -MemberType NoteProperty -Name 'PackageID' -Value $Pkg.PackageID
            $Package | Add-Member -MemberType NoteProperty -Name 'Name' -Value $PKG.Name
            $Package | Add-Member -MemberType NoteProperty -Name 'PackageSize' -Value $PKG.PackageSize
            $Package | Add-Member -MemberType NoteProperty -Name 'PackageType' -Value '512'
            $Package | Add-Member -MemberType NoteProperty -Name 'CI_ID' -Value $PKG.CI_ID
            $Package | Add-Member -MemberType NoteProperty -Name 'HasContent' -Value $PKG.HasContent
            $Package | Add-Member -MemberType NoteProperty -Name 'IsDPRemoved' -Value $false
            Clean-Package $Package
        }
    }
}

Pop-Location
New-LogEntry 'Finished Script'