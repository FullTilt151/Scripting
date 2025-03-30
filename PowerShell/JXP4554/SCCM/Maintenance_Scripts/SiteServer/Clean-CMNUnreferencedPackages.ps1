<#
.SYNOPSIS

.DESCRIPTION

.PARAMETER SiteServer

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
	PS C:\> .\Clean-CMNUnreferencedPackages -SiteServer Server01

	This example will redistribute the out of sync packages and make sure they are on Intranet DP's and also keep them on All DP's if they are there.

	PS C:\> .\Clean-CMNUnreferencedPackages -SiteServer Server01 -ClearLog
	PS C:\> .\Clean-CMNUnreferencedPackages -SiteServer Server01 -ClearLog $true

	Both of these are the same as above, except they will clear the logfile as well.
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

    [parameter(Mandatory=$false,HelpMessage="Log File Directory")]
    [string]$LogFile = 'C:\Temp\Error.log',

	[Parameter(Mandatory = $false,
		HelpMessage = 'Max Log size')]
	[Int32]$maxLogSize = 5242880,

	[Parameter(Mandatory = $false,
        HelpMessage = 'Max number of history logs')]
    [Int32]$maxHistory = 5
)

#Build variables
$SCCMConnectionInfo = Get-CMNSCCMConnectionInfo -SiteServer $SiteServer

$NewCMNLogEntry = @{
	LogFile = $LogFile;
	Component = 'Clean-CMNUnreferencedPackages';
	maxLogSize = $maxLogSize;
	maxHistory = $maxHistory;
}

$WMIQueryParameters = $SCCMConnectionInfo.WMIQueryParameters

$dbConString = Get-CMNConnectionString -DatabaseServer $SCCMConnectionInfo.SCCMDBServer -Database $SCCMConnectionInfo.SCCMDB
#This query gets the PackageIDs that are on DP's, but not referenced by a task sequence or have a deployment
$SQLCommand = "SELECT	DISTINCT PackageID`
FROM	v_Package`
WHERE	PackageType = 0`
AND		(PackageID IN`
			(SELECT	DISTINCT PkgID`
			FROM	v_DPGroupPackages`
			WHERE	(PkgID NOT IN`
				(SELECT	DISTINCT PKG.PackageID`
				FROM	v_DeploymentSummary DS`
				JOIN	v_Package PKG on ds.PackageID = PKG.PackageID`
				WHERE	PKG.PackageType = 0`
				UNION`
				select	distinct PKG.PackageID`
				from	v_TaskSequenceReferencesInfo TS`
				JOIN	v_Package PKG on ts.ReferencePackageID = PKG.PackageID`
				WHERE	PKG.PackageType = 0))))"

New-CMNLogEntry -entry 'Getting Package Data' -type 1 @NewCMNLogentry
$PackageIDs = Get-CMNDatabaseData -connectionString $dbConString -query $SQLCommand -isSQLServer
$TotalSpaceSaved = 0
foreach ($PackageID in $($PackageIDs).PackageID)
{
    New-CMNLogEntry -entry "Processing Package $PackageID" -type 1 @NewCMNLogEntry

    #As a precaution, double checking to see that no one has made a change before we remove the package
    if(-not (Test-CMNPKGReferenced -SCCMConnectionInfo $SCCMConnectionInfo -PackageID $PackageID))
    {
        New-CMNLogEntry -entry "Verifying Package $PackageID isn't on the site server" -type 1 @NewCMNLogEntry
        $query = "Select * from SMS_Package where PackageID = '$PackageID'"
        $Package = Get-WmiObject -Query $query @WMIQueryParameters
        if($Package.PkgSourcePath -match $SCCMConnectionInfo.SiteCode)
        {
            New-CMNLogEntry -entry "Package $PackageID has it's source files on the site server, probably required, not removing" -type 2 @NewCMNLogEntry
        }
        else
        {
            New-CMNLogEntry -entry "Removing $PackageID from DP's, freeing $($Package.PackageSize) bytes" -type 1 @NewCMNLogEntry
            Remove-CMNDPContent -SCCMConnectionInfo $SCCMConnectionInfo -PackageID $PackageID
            $TotalSpaceSaved += $Package.PackageSize
        }
    }
}

New-CMNLogEntry -entry "Finished!!! Cleared $TotalSpaceSaved" -type 1 @NewCMNLogEntry