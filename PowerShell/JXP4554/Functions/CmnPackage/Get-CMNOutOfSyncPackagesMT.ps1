<#
.SYNOPSIS
	Cleans up the content locations for various package types

.DESCRIPTION
	This script will go out to the package types selected and remove any unwanted assignments
	and ensure you have just the assignments you need. It will also deploy content for any
	packages that have deployments and remove packages from DP's that do not have any deployments

.PARAMETER SiteServer
	Site server that you are working with.

.PARAMETER DPTargets
	This is an array of the DP Groups you want to put the packages on.

.PARAMETER DPKeep
	This is an array of DP Groups that you want to keep if the package is already on there.

.PARAMETER SleepSeconds
	This is a delay between each package to help not overload the site server. Default is 10 seconds.

.PARAMETER LogLevel
	Minimum logging level:
	1 - Informational
	2 - Warning (default)
	3 - Error

.PARAMETER LogFileDir
	Directory where log file will be created. Default C:\Temp.

.PARAMETER ClearLog
    Clears exisiting log file.

.EXAMPLE
	PS C:\> .\Get-CMNOutOfSyncPackages.ps1 -Server Server01 -LogLevel 2 -DPTargets 'Intranet DP''s' -DPKeep 'All DP''s'

	This example will redistribute the out of sync packages and make sure they are on Intranet DP's and also keep them on All DP's if they are there.

.LINK
	Blog
	http://configman-notes.com

.NOTES
 	Case
        when v_Package.PackageType = 0 Then 'Software Distribution Package'
        when v_Package.PackageType = 3 Then 'Driver Package'
        when v_Package.PackageType = 4 Then 'Task Sequence Package'
        when v_Package.PackageType = 5 Then 'Software Update Package'
        when v_Package.PackageType = 6 Then 'Device Setting Package'
        when v_Package.PackageType = 7 Then 'Virtual Package'
        when v_Package.PackageType = 8 Then 'Application'
        when v_Package.PackageType = 257 Then 'Image Package'
        when v_Package.PackageType = 258 Then 'Boot Image Package'
        when v_Package.PackageType = 259 Then 'Operating System Install Package'
	Else
		'Unknown'
	End
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [parameter(Mandatory=$true,HelpMessage="Site server where the SMS Provider is installed")]
    [ValidateScript({Test-Connection -ComputerName $_ -Count 1 -Quiet})]
    [string]$SiteServer,
    [parameter(Mandatory=$false,HelpMessage="DP Group to put packages on")]
    [string[]]$DPTargets='Workstation DP''s',
    [parameter(Mandatory=$false,HelpMessage="DP Group to leave if present")]
    [string[]]$DPKeep = @(),
    [parameter(Mandatory=$false,HelpMessage="Number of seconds to sleep between packages")]
    [int]$SleepSeconds=10,
    [parameter(Mandatory=$false,HelpMessage="Logging Level")]
    [ValidateSet(1, 2, 3)]
    [Int32]$LogLevel = 1,
    [parameter(Mandatory=$false,HelpMessage="Log File Directory")]
    [string]$LogFileDir = 'C:\Temp\',
    [parameter(Mandatory=$true,HelpMessage="Clear any existing log file")]
    [switch]$ClearLog
)

Function get-SQLQuery
{
    PARAM
    (
		[Parameter(Mandatory=$true)]
		[String]$DataSource,
		[Parameter(Mandatory=$true)]
		[String]$Database,
		[Parameter(Mandatory=$true)]
		[String]$SQLCommand
    )
    $ConnectionString = "Data Source=$DataSource;" +
    "Integrated Security=SSPI; " +
    "Initial Catalog=$Database"

    $Connection = new-object system.data.SqlClient.SQLConnection($ConnectionString)
    $Command = new-object system.data.sqlclient.sqlcommand($SQLCommand,$Connection)
    $Connection.Open()

    $Adapter = New-Object System.Data.sqlclient.sqlDataAdapter $Command
    $DataSet = New-Object System.Data.DataSet
    $Adapter.Fill($DataSet) | Out-Null

    $Connection.Close()

    Return $DataSet.Tables
}
#End get-SQLQuery

Function Start-CMDPPackage
{
    <#
    .Synopsis
        This function will put a package on the DP Group's.

    .DESCRIPTION
        This function will put a package on the DP Group's.

    .PARAMETER Package
        This is a PSObjectthat needs the following info:
            PackageID
            IsDPRemoved
            PackageType

    .PARAMETER
        DPTargets

    .EXAMPLE

    .LINK
        http://configman-notes.com

    .NOTES

    #>
	 Param
	(
		[Parameter(Mandatory=$true)]
		[PSObject]$Package,
		[Parameter(Mandatory=$true)]
		[array]$DPTargets,
		[Parameter(Mandatory=$true)]
		[Array]$DPKeeps,
		[Parameter(Mandatory=$true)]
		[string]$LogFile,
		[Parameter(Mandatory=$true)]
		[string]$ScriptName,
		[Parameter(Mandatory=$true)]
		[hash]$WMIQueryParameters
	)

	Function IsPKGReferenced
	{
		<#
		.Synopsis
			This function will put a package on the DP Group's.

		.DESCRIPTION
			This function will put a package on the DP Group's.

		.PARAMETER Package
			This is a PSObjectthat needs the following info:
				PackageID
				IsDPRemoved
				PackageType

		.PARAMETER
			DPTargets

		.EXAMPLE

		.LINK
			http://configman-notes.com

		.NOTES

		#>
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

	Function Remove-CMDPPackage
	{
		<#
		.Synopsis
			This function will remove the package from the DP's and DP Group's.

		.DESCRIPTION
			This function will remove the package from the DP's and DP Group's.

		.PARAMETER Package
			This is a PSObjectthat needs the following info:
				PackageID
				IsDPRemoved set to $false
				PackageType

		.EXAMPLE

		.LINK
			http://configman-notes.com

		.NOTES

		#>

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
		$Package.IsDPRemoved = $false

		#Go through and remove each DP/DPGroup
		if ($DPStatus)
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
				else
				{
					$Assignment='DP Group'
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
		else
		{
			New-LogEntry "Package $PackageID is not currently distributed" 1 'Remove-CMDPPackage'
		}

		New-LogEntry 'End Function Remove-CMDPPackage' 1 'Remove-CMDPPackage'
		return ,$DPTargets
	}
	#End Remove-CMDPPackage

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
			$Entry | Out-File $LogFile -Append -Encoding ascii
		}
	}

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

#End Functions

import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')

#Build variables for New-LogEntry Function

$ScriptName = $MyInvocation.MyCommand.Name
if(-not ($LogFileDir -match '\\$')){$LogFileDir = "$LogFileDir\"}
$LogFile = $ScriptName -replace '(.*)\.ps1', '$1'
$LogFile = $LogFileDir + $LogFile + '.log'
if($ClearLog)
{
    if(Test-Path $Logfile) {Remove-Item $LogFile}
}

#Figure out what site we're connecting to.

$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

#Put log here to confirm we connected.................................................

New-LogEntry "Connected to site $SiteCode."

#Save our current location before changing
Push-Location
Set-Location "$($SiteCode):" | Out-Null

$WMIQueryParameters = @{
    ComputerName = $SiteServer
    Namespace = "root\sms\site_$SiteCode"
}
#Get DB Server from SCCM
$DataSource = $(Get-CMSiteRole -RoleName 'SMS SQL Server' -SiteCode "$SiteCode").NetworkOSPath -replace "\\*(.*)", '$1'
$Database = $(Get-CimInstance -ClassName SMS_SiteSystemSummarizer -Namespace root\sms\site_$SiteCode -ComputerName $SiteServer -Filter "Role = 'SMS SQL SERVER' and SiteCode = '$SiteCode' and ObjectType = 1").SiteObject -replace ".*\\([A-Z_]*?)\\$", '$+'
#$SQLCommand = "SELECT DPG.Name AS [DP Group], DPOS.PkgID, DPOS.PkgServer, DPOS.PkgVersion, DPOS.DPPkgVersion, DPOS.DPPkgStatus, PackageType`
#	FROM vSMS_DPGroupOutOfSyncPackages DPOS INNER JOIN`
#	v_SMS_DistributionPointGroup DPG ON DPOS.GroupID = DPG.GroupID INNER JOIN`
#	v_Package PKG on PKG.PackageID = DPOS.PkgID"
$SQLCommand = "SELECT Distinct DPOS.PkgID, pkg.PackageType FROM vSMS_DPGroupOutOfSyncPackages DPOS INNER JOIN v_Package PkG ON pkg.PackageID = DPOS.PkgID ORDER BY DPOS.PkgID"
New-LogEntry 'Getting list of out of sync packages'
$PackageIDs = get-SQLQuery $DataSource $Database $SQLCommand

foreach($PackageID in $PackageIDs)
{
    Switch ($PackageID.PackageType)
    {
        0
        {
            $objPackage = Get-CMPackage -Id "$($PackageID.PkgID)"
            $Package = New-Object PSObject
            $Package | Add-Member -MemberType NoteProperty -Name Description -Value $($objPackage.Description)
            $Package | Add-Member -MemberType NoteProperty -Name Name -Value $($objPackage.Name)
            $Package | Add-Member -MemberType NoteProperty -Name PackageID -Value $($objPackage.PackageID)
            $Package | Add-Member -MemberType NoteProperty -Name PackageType -Value $($objPackage.PackageType)
            $Package | Add-Member -MemberType NoteProperty -Name IsDPRemoved -Value $false
            $DPs = Remove-CMDPPackage $Package $DPTargets $DPKeep $LogFile $WMIQueryParameters
            if(IsPKGReferenced $Package)
            {
                Start-job ${Function:Start-CMDPPackage} -ArgumentList -Package $Package -DPTargets $DPs
            }
            else
            {
                New-LogEntry "$($Package.Name) is not referenced by a task sequence or deployment"
            }
        }
    }
}

New-LogEntry 'Finished Script!'
Pop-Location