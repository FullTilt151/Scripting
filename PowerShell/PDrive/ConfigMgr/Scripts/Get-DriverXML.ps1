$drivers = Get-WmiObject -ComputerName LOUAPPWPS875 -Namespace root\sms\site_CAS -Class sms_driver -Property CI_ID, LocalizedDisplayName, DriverClass, DriverVersion, DriverINFFile, LocalizedCategoryInstanceNames -Filter "LocalizedCategoryInstanceNames LIKE '%Lenovo Tx20 Win7x64%'" | select CI_ID, LocalizedDisplayName, DriverClass, DriverVersion, DriverINFFile, LocalizedCategoryInstanceNames -First 5 | ft -AutoSize
foreach ($driver in $drivers) {
    $driver.get()
    $xml = $driver.SDMPackageXML
}