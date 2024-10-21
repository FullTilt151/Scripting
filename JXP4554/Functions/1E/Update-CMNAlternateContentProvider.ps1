[CmdletBinding(SupportsShouldProcess = $true, 
		ConfirmImpact = 'Low')]
PARAM
(
    [Parameter(Mandatory = $true,
        HelpMessage = 'Site to update')]
    [ValidateSet('CAS','WP1','WQ1','SP1','SQ1','MT1')]
    [String]$site
)

Switch ($site)
{
    'CAS' {
            $sourceCon = Get-CMNSCCMConnectionInfo -SiteServer LOUAPPWPS875
            $connString = Get-CMNConnectionString -DatabaseServer $sourceCon.SCCMDBServer -Database $sourceCon.SCCMDB
        }

    'WP1' {
            $sourceCon = Get-CMNSCCMConnectionInfo -SiteServer LOUAPPWPS1658
            $connString = Get-CMNConnectionString -DatabaseServer $sourceCon.SCCMDBServer -Database $sourceCon.SCCMDB
        }

    'WQ1'  {
            $sourceCon = Get-CMNSCCMConnectionInfo -SiteServer LOUAPPWQS1151
            $connString = Get-CMNConnectionString -DatabaseServer $sourceCon.SCCMDBServer -Database $sourceCon.SCCMDB
        }

    'SP1'  {
            $sourceCon = Get-CMNSCCMConnectionInfo -SiteServer LOUAPPWPS1825
            $connString = Get-CMNConnectionString -DatabaseServer $sourceCon.SCCMDBServer -Database $sourceCon.SCCMDB
        }

    'SQ1' {
            $sourceCon = Get-CMNSCCMConnectionInfo -SiteServer LOUAPPWQS1150
            $connString = Get-CMNConnectionString -DatabaseServer $sourceCon.SCCMDBServer -Database $sourceCon.SCCMDB
        }

    'MT1' {
            $sourceCon = Get-CMNSCCMConnectionInfo -SiteServer LOUAPPWTS1140
            $connString = Get-CMNConnectionString -DatabaseServer $sourceCon.SCCMDBServer -Database $sourceCon.SCCMDB
        }
}

$alterNEtContent = '<AlternateDownloadSettings SchemaVersion="1.0"><Provider Name="NomadBranch"><Data><ProviderSettings /><pc>1</pc></Data></Provider></AlternateDownloadSettings>'
$query = 'SELECT packageid
FROM   v_package
WHERE  packageid NOT IN(SELECT DISTINCT refpackageid
                        FROM   v_tasksequencepackagereferences)
       AND objecttypeid = 2
ORDER  BY packageid'
$packageIDs = Get-CMNDatabaseData -connectionString $connString -query $query -isSQLServer
<#
$query = 'Select PackageID from SMS_Package'
$packageIDs = Get-WmiObject -Query $query -ComputerName $sourceCon.ComputerName -Namespace $sourceCon.NameSpace
#>
$logfile = 'C:\Temp\Update-CMNAltenateContentProvider.log'
$x = 1

$NewLogEntry = @{
			LogFile = $logFile;
			Component = 'Update-CMNAltenateContentProvider'
		}
New-CMNLogEntry -entry '-------------------------------------------------' -type 1 @NewLogEntry
New-CMNLogEntry -entry "Starting update of $site" -type 1 @NewLogEntry

foreach($packageID in $packageIDs.PackageID)
{
    Write-Progress -Activity "Updating Packages" -Status "$packageID" -PercentComplete ($x * 100 / $packageIDs.Count) -CurrentOperation "$x/$($packageIDs.Count)"
    $x++
    $query = "Select * from SMS_Package where PackageID = '$packageID'"
    $package = Get-WmiObject -Query $query -ComputerName $sourceCon.ComputerName -Namespace $sourceCon.NameSpace
    if($package)
    {
        $package.Get()
        if($package.AlternateContentProviders -ne $alterNEtContent -and $package.PackageType -eq 0)
        {
            New-CMNLogEntry -entry "Updating $($package.Name) - $packageID" -type 1 @NewLogEntry
            $package.AlternateContentProviders = $alterNEtContent
            $package.Put() | Out-Null
        }
        else
        {
            New-CMNLogEntry -entry "Package $($package.Name) - $packageID is good!" -type 1 @NewLogEntry
        }
    }
    else
    {
        New-CMNLogEntry -entry "PackageID $packageID doesn't exist" -type 2 @NewLogEntry
    }
}
Write-Progress -Activity "Updating Packages" -Completed
New-CMNLogEntry -entry "Finished update of $site" -type 1 @NewLogEntry
New-CMNLogEntry -entry '-------------------------------------------------' -type 1 @NewLogEntry