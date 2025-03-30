<#
.Synopsis
   Resends all failed or retrying packages to a specified Distribution Point.
.EXAMPLE
   ResendDPPackages.ps1 -SiteCode "S01" -DistPoint "SERVER01" -Verbose
#>
[cmdletbinding()]
Param(
    [Parameter(Mandatory)]
    [String]
    [ValidateNotNullOrEmpty()]
    $SiteServer,
    [Parameter(Mandatory)]
    [String]
    [ValidateNotNullOrEmpty()]
    $DistPoint
)

$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace root\SMS -Class SMS_ProviderLocation).SiteCode
$Query = "Select NALPath,Name From SMS_DistributionPointInfo Where ServerName Like '%$DistPoint%'"
$DistributionPoint = @(Get-WmiObject -Computername $SiteServer -Namespace "root\SMS\Site_$SiteCode" -Query $Query)
$ServerNalPath = $DistributionPoint.NALPath -replace "([\[])",'[$1]' -replace "(\\)",'\$1'

if($DistributionPoint.Count -ne 1)
{
    Foreach($DistributionPoint in $DistributionPoint)
    {
        Write-Host -Message $DistributionPoint.Name
    }
    Write-Error -Message "Found $($DistributionPoint.Count) matching Distribution Points. Please redefine query."
}
else
{
    $Query = "Select * From SMS_PackageStatusDistPointsSummarizer Where ServerNALPath Like '$ServerNALPath' AND (State = 2 OR state = 3 or State = 7 or State = 8)"
    $FailedPackages = Get-WmiObject -Computername $SiteServer -Namespace "root\SMS\Site_$SiteCode" -Query $Query
    Foreach($Package in $FailedPackages)
    {
        $Query = "Select * From SMS_DistributionPoint WHERE ServerNALPath Like '$ServerNALPath' AND PackageID = '$($Package.PackageID)'"
        $DistPointPkg = Get-WmiObject -Computername $SiteServer -Namespace "root\SMS\Site_$($SiteCode)" -Query $Query
        $Status = switch($Package.State)
            {
                0 {"INSTALLED"}
                1 {"INSTALL_PENDING"}
                2 {"INSTALL_RETRYING"}
                3 {"INSTALL_FAILED"}
                4 {"REMOVAL_PENDING"}
                5 {"REMOVAL_RETRYING"}
                6 {"REMOVAL_FAILED"}
                default {"UnKnown - $($pkg.State)"}
            }
        Write-Host "Refreshing package $($DistPointPkg.PackageID) on $($DistributionPoint.Name) with a status of $($Status)"
        $DistPointPkg.RefreshNow = $true
        [Void]$DistPointPkg.Put()
    }
}
