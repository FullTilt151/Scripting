Get-CMDriverPackage | 
foreach { 
    Start-CMContentDistribution -DriverPackageId $_.PackageID -DistributionPointGroupName "OSD DP's" -ErrorAction SilentlyContinue
    Remove-CMContentDistribution -DriverPackageId $_.PackageID -DistributionPointGroupName "All DPs"
    Remove-CMContentDistribution -DriverPackageId $_.PackageID -DistributionPointGroupName "Workstation DP's"
    Remove-CMContentDistribution -DriverPackageId $_.PackageID -DistributionPointName "LOUAPPWPS442.DMZAD.HUM"
    Remove-CMContentDistribution -DriverPackageId $_.PackageID -DistributionPointName "LOUAPPWPS443.DMZAD.HUM"
}