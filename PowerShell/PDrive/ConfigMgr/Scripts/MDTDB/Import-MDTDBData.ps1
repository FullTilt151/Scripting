Import-Module \\lounaswps08\pdrive\dept907.cit\ConfigMgr\Scripts\MDTDB\MDTDB.psm1
Connect-MDTDatabase -sqlserver SIMMDTWPS01 -instance MDTDB -database MDTDB

Get-Content C:\temp\wkids.txt | 
ForEach-Object {
    #$Make = 'LENOVO'
    #$Model = $_.Model
    #$DriverPackage = $_.driverpackage
    #$DriverPackageWin7 = $_.driverpackagewin7
    #$BIOSPackage = $_.PackageID
    #$BIOSCommand = $_.Command
    $Serial = $_.Serial
    $SMSTSRole = 'W10EIPAM'
    #New-MDTMakeModel -make $Make -model $Model -settings @{OSInstall=’YES’; BIOSPackage="$BIOSPackage"; BIOSCommand="$BIOSCommand"}
    #New-MDTMakeModel -make $Make -model $Model -settings @{OSInstall=’YES’; DriverPackage="$DriverPackage"; DriverPackageWin7="$DriverPackageWin7"}
    New-MDTComputer -serialNumber $Serial -settings @{OSInstall=’YES’; SMSTSRole="$SMSTSRole"}
}