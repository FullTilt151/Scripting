$SCCMConnectionInfo = Get-CMNSCCMConnectionInfo -siteServer LOUAPPWTS1140
$WMIQueryParameters = $SCCMConnectionInfo.WMIQueryParameters
$packages = Get-WmiObject -Query "Select * from SMS_Package" @WMIQueryParameters
foreach($package in $packages)
{
    if($package.PkgSourcePath -imatch '\\\\lounaswps01\\.*')
    {
        $message = "Need to update $($package.PackageID) - $($package.PkgSourcePath) to $($package.PkgSourcePath -ireplace '\\\\LOUNASWPS01\\','\\lounaswps08.rsc.humad.com\')"
        $package.PkgSourcePath = $package.PkgSourcePath -ireplace '\\\\LOUNASWPS01\\','\\lounaswps08.rsc.humad.com\'
        $package.put() | Out-Null
    }
    elseif($package.PkgSourcePath -imatch '\\\\LOUNASWPS01.rsc.humad.com\\.*')
    {
        $message = "Need to update $($package.PackageID) - $($package.PkgSourcePath) to $($package.PkgSourcePath -ireplace '\\\\LOUNASWPS01.rsc.humad.com\\','\\lounaswps08.rsc.humad.com\')"
        $package.PkgSourcePath = $package.PkgSourcePath -ireplace '\\\\LOUNASWPS01.rsc.humad.com\\','\\lounaswps08.rsc.humad.com\'
        $package.put() | Out-Null
    }
    elseif($package.PkgSourcePath -imatch '\\\\LOUNASWPS08\\.*')
    {
        $message = "Need to update $($package.PackageID) - $($package.PkgSourcePath) to $($package.PkgSourcePath -ireplace '\\\\LOUNASWPS08\\','\\lounaswps08.rsc.humad.com\')"
        $package.PkgSourcePath = $package.PkgSourcePath -ireplace '\\\\LOUNASWPS08\\','\\lounaswps08.rsc.humad.com\'
        $package.put() | Out-Null
    }
    if($message)
    {
        Write-output $message
        $message = $null
    }
}

$packages = Get-WmiObject -Query "Select * from SMS_SoftwareUpdatesPackage" @WMIQueryParameters
foreach($package in $packages)
{
    if($package.PkgSourcePath -imatch '\\\\lounaswps01\\.*')
    {
        $message = "Need to update $($package.PackageID) - $($package.PkgSourcePath) to $($package.PkgSourcePath -ireplace '\\\\LOUNASWPS01\\','\\lounaswps08.rsc.humad.com\')"
        $package.PkgSourcePath = $package.PkgSourcePath -ireplace '\\\\LOUNASWPS01\\','\\lounaswps08.rsc.humad.com\'
        $package.put() | Out-Null
    }
    elseif($package.PkgSourcePath -imatch '\\\\LOUNASWPS01.rsc.humad.com\\.*')
    {
        $message = "Need to update $($package.PackageID) - $($package.PkgSourcePath) to $($package.PkgSourcePath -ireplace '\\\\LOUNASWPS01.rsc.humad.com\\','\\lounaswps08.rsc.humad.com\')"
        $package.PkgSourcePath = $package.PkgSourcePath -ireplace '\\\\LOUNASWPS01.rsc.humad.com\\','\\lounaswps08.rsc.humad.com\'
        $package.put() | Out-Null
    }
    elseif($package.PkgSourcePath -imatch '\\\\LOUNASWPS08\\.*')
    {
        $message = "Need to update $($package.PackageID) - $($package.PkgSourcePath) to $($package.PkgSourcePath -ireplace '\\\\LOUNASWPS08\\','\\lounaswps08.rsc.humad.com\')"
        $package.PkgSourcePath = $package.PkgSourcePath -ireplace '\\\\LOUNASWPS08\\','\\lounaswps08.rsc.humad.com\'
        $package.put() | Out-Null
    }
    if($message)
    {
        Write-output $message
        $message = $null
    }
}