$ValidationFailedQuery = @"
SELECT DISTINCT
	DPSD.DPName
	, DPSD.PackageID
	, SP.PackageType
	, DPSD.MessageCategory
	, CAST(CASE
		WHEN (SP.Source IS NULL OR SP.Source = '') THEN 0
		ELSE 1
	END AS Bit) AS [HasSourceFiles] 
FROM vSMS_DPStatusDetails DPSD 
	JOIN SMSPackages_All SP ON DPSD.PackageID = SP.PkgID
--WHERE MessageState = 2 AND MessageCategory = 11
--Failed to validate package
WHERE MessageState = 4 --AND MessageCategory = 13
--User update package on distribution point - usually just need to perform RemovePackages method on SMS_DistributionPointGroup WMI class
--WHERE MessageState = 2 AND MessageCategory = 72
"@

$sccmConnectionInfo = Get-CMNSCCMConnectionInfo -siteServer $env:COMPUTERNAME
$dbCon = Get-CMNConnectionString -DatabaseServer $sccmConnectionInfo.SCCMDBServer -Database $sccmConnectionInfo.SCCMDB
$SiteCode = $sccmConnectionInfo.SiteCode

$NeedsWork = Get-CMNDatabaseData -connectionString $dbCon -query $ValidationFailedQuery -isSQLServer:$true

foreach ($Package in $NeedsWork) {
    $PackageType = $Package.PackageType
    $PackageID = $Package.PackageID
    $HasSourceFiles = [bool]$Package.HasSourceFiles
    $InputObject = switch ($PackageType) {
        0 {
            Get-CMPackage -Id $PackageID -Fast
        }
        3 {
            Get-CMDriverPackage -Id $PackageID
        }
        4 {
            Get-CMTaskSequence -TaskSequencePackageId $PackageID
        }
        5 {
            Get-CMSoftwareUpdateDeploymentPackage -Id $PackageID
        }
        8 {
            Get-CMApplication -Id $PackageID -Fast
        }
        257 {
            Get-CMOperatingSystemImage -Id $PackageID
        }
        258 {
            Get-CMBootImage -Id $PackageID
        }
        259 {
            Get-CMOperatingSystemInstaller -Id $PackageID
        }
    }
    $ContentRedistributionParams = @{
        DistributionPoint = (Get-CMDistributionPoint -SiteSystemServerName $Package.DPName)
        InputObject       = $InputObject
        ErrorAction       = 'Continue'
    }
    if (-not $HasSourceFiles) {
        "Removing $PackageID from All DP's Group"
        Invoke-WmiMethod -InputObject (Get-WmiObject -ComputerName $env:COMPUTERNAME -Query "SELECT * FROM SMS_DistributionPointGroup WHERE GroupID='{4DE0F6D3-3D74-405C-AEF3-25D40C3F9BFD}'" -Namespace ROOT\SMS\SITE_WP1) -Name RemovePackages -ArgumentList @(, $PackageID), $true
    }
    else {
        "Redistributing $PackageID to $($Package.DPName)"
        Invoke-CMContentRedistribution @ContentRedistributionParams
    }
}