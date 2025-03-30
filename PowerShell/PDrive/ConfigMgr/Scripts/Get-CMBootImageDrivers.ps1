param(
$SiteServer = 'LOUAPPWPS1825',
$SiteCode = 'SP1',
$BootImage = 'SP1001CF'
)

$CurrentDrivers = @()

$BootImageDrivers = Get-WmiObject -ComputerName $SiteServer -Namespace root\sms\site_$sitecode -Class sms_bootimagepackage_driverref -Filter "PkgID='$BootImage'" -Property CI_ID
$BootImageDrivers.CI_ID |
ForEach-Object { 
    $DriverInfo = Get-WmiObject -ComputerName $SiteServer -Namespace root\sms\site_$SiteCode -Class sms_driver -Filter "CI_ID='$_'" `
    -Property CI_ID, LocalizedDisplayName, ContentSourcePath, DriverInfFile, DriverVersion, LocalizedCategoryInstanceNames
    $Properties = @{
        CI_ID = $DriverInfo.CI_ID; 
        Name = $DriverInfo.LocalizedDisplayName
        Source = $DriverInfo.ContentSourcePath
        InfFile = $DriverInfo.DriverInfFile
        Version = $DriverInfo.DriverVersion
        Category = $DriverInfo.LocalizedCategoryInstanceNames
    }
    $CurrentDrivers += New-Object -TypeName psobject -Property $Properties
}

$CurrentDrivers #| Export-Csv c:\temp\drivers.csv -NoTypeInformation