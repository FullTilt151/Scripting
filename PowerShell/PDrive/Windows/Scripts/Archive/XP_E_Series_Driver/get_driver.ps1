$comps = get-content D:\scripts\XP_E_Series_Driver\computers.txt

foreach ($comp in $comps) {
    $ping = Test-Connection $comp -Count 1
    if ($ping) {
        $drivers = Get-WmiObject win32_pnpsigneddriver -ComputerName $comp -filter "DeviceClass = 'NET'"| where {$_.devicename -notlike "WAN Miniport*" -and $_.devicename -notlike "RAS Async*" -and $_.devicename -ne "Packet Scheduler Miniport" -and $_.devicename -notlike "*Array*" -and $_.devicename -ne "Direct Parallel"}
        foreach ($driver in $drivers) {
            $date = $driver.converttodatetime($driver.driverdate)
            $driverdate = @{DriverDateFriendly=$date}
            $wkid = @{Label="WKID";Expression={$_.pscomputername}}
            $driver | Add-Member -TypeName NoteProperty $driverdate
            $driver | Format-Table $wkid,DeviceName,DeviceClass,DriverProviderName,DriverVersion,DriverDateFriendly -AutoSize
            #$driver | ConvertTo-Csv -NoTypeInformation | Add-Content D:\scripts\XP_E_Series_Driver\NetDrivers.csv
        }
    } else {
        write-error "$comp is offline!"
    }
}