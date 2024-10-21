###Export DB
Import-Module \\lounaswps08\pdrive\dept907.cit\ConfigMgr\Scripts\MDTDB\MDTDB.psm1
Connect-MDTDatabase -sqlserver SIMMDTWPS01 -instance MDTDB -database MDTDB
Get-MDTMakeModel | Select-Object -Property Make, Model, BIOSPackage, BIOSCommand, DriverPackage, DriverPackageWin7 | Export-Csv -Path C:\Temp\MDTDB.csv -NoTypeInformation

#############################################################################################################################################################


###ImportDB
Import-Module \\lounaswps08\pdrive\dept907.cit\ConfigMgr\Scripts\MDTDB\MDTDB.psm1
Connect-MDTDatabase -sqlserver LOUOSDWPS01 -instance MDTDB -database MDTDB
Import-Csv -LiteralPath C:\temp\MDTDB.csv | 
ForEach-Object {
    $Make = $_.Make
    $Model = $_.Model
    $BIOSPackage = $_.BIOSPackage
    $BIOSCommand = $_.BIOSCommand
    $DriverPackage = $_.Driverpackage
    $DriverPackageWin7 = $_.DriverPackageWin7
    New-MDTMakeModel -make $Make -model $Model -settings @{OSInstall=’YES’; BIOSPackage="$BIOSPackage"; BIOSCommand="$BIOSCommand"; DriverPackage="$DriverPackage"; DriverPackageWin7="$DriverPackageWin7"}
    }