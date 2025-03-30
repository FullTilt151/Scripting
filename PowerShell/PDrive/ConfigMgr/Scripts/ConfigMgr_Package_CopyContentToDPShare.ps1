Get-WmiObject -Namespace root\sms\site_cas -ComputerName LOUAPPWPS875 -Query "Select * from SMS_Package where packageid like 'CAS004A%'"  | ForEach-Object {
    if ($_.pkgflags -eq ($_.pkgflags -bor 0x80)) {
        "ENABLED on " + $_.Packageid + " - " + $_.Name + " - Flags:" + $_.pkgflags
    } else {
        "NOT ENABLED on " + $_.Packageid + " - " + $_.Name + " - Flags:" + $_.pkgflags
    }
}

#CAS004A1

$pkg = Get-WmiObject -Namespace root\sms\site_cas -ComputerName LOUAPPWPS875 -Query "Select * from SMS_Package where packageid = 'CAS004A1'" 
$pkg.pkgflags
$pkg.pkgflags = "16777344"
$pkg.pkgflags
$pkg.put() 

$ts = Get-WmiObject -Namespace root\sms\site_cas -ComputerName LOUAPPWPS875 -class SMS_tasksequencepackage | select Name,PackageID | sort name

#OSD Pre-Cache  CAS00083
#ZTI            CAS00376

$pkgref = Get-WmiObject -Namespace root\sms\site_cas -ComputerName LOUAPPWPS875 -Query "Select * from SMS_TaskSequencePackageReference where RefPackageID = 'CAS00376'" 