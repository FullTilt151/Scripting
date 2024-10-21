$tspack = Get-WmiObject -ComputerName LOUAPPWPS875 -Namespace root\sms\site_cas -Class sms_tasksequencepackagereference -Property RefPackageID, ObjectName, ObjectType

$pkgs = Get-WmiObject -ComputerName LOUAPPWPS875 -Namespace root\sms\site_cas -Class sms_package -Property PackageID, Manufacturer, Name, Version, Pkgflags
$ospkgs = Get-WmiObject -ComputerName LOUAPPWPS875 -Namespace root\sms\site_cas -Class sms_imagepackage -Property PackageID, Manufacturer, Name, Version, Pkgflags
$driverpkgs = Get-WmiObject -ComputerName LOUAPPWPS875 -Namespace root\sms\site_cas -Class sms_driverpackage -Property PackageID, Manufacturer, Name, Version, Pkgflags
$bootpkgs = Get-WmiObject -ComputerName LOUAPPWPS875 -Namespace root\sms\site_cas -Class sms_bootimagepackage -Property PackageID, Manufacturer, Name, Version, Pkgflags

#$tspack | Select-Object RefPackageID, ObjectName,ObjectType -Unique | Sort-Object ObjectType, ObjectName | Format-Table -AutoSize

foreach ($pkg in $tspack) {
    
     
     switch ($_.ObjectType) {
        0 {; break}
        3 {; break}
        257 {; break}
        258 {; break}
        default {write-error "Package type unknown"; break}
     }
}

#"PackageID = '$_.refpackageid'"