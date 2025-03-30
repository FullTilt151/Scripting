$LOC = Get-Location

Write-Host "Enter: WP1 or WQ1"
$Action = Read-Host "Select an enviroment"
Switch ($Action)
{
    WP1 {
        If ($LOC.Path -ne "WP1:\") {
            $Drives = Get-PSDrive
            If ($Drives.Name -ne "WP1") {
                Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" -ErrorAction SilentlyContinue
                Set-Location "WP1:"
            }
            $SiteCode = 'WP1'
            Set-Location "WP1:"
        } 
    }
    WQ1 {
        If ($LOC.Path -ne "WQ1:\") {
            $Drives = Get-PSDrive
            If ($Drives.Name -ne "WQ1") {
                Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" -ErrorAction SilentlyContinue
                Set-Location "WQ1:"
            }
            $SiteCode = 'WQ1'
            Set-Location "WQ1:"
        } 
    }
    default {
    'No Action'
    }
} 

$BLD = Read-Host "Enter the Build: Ex:2009"
$BLD2 = "_$BLD"
$IMGRLS = Read-Host "Enter the Image Release: Ex:0121"
$IMGRLS2 = "_$IMGRLS"
$IMGPTH = "\\lounaswps08\pdrive\Dept907.CIT\OSD\images\OS\"


#.NET Ent
$IMGNME = "Win10NetDevEnt"
$IMGFILE = "$IMGPTH$IMGNME$BLD2$IMGRLS2.wim"
$SYSIMGNME = "Humana Windows 10 Ent $BLD .Net Dev Ent 2019"
$NewImg = New-CMOperatingSystemImage -Name $SYSIMGNME -Path "$IMGFILE" -Version $IMGRLS
Switch ($SiteCode) {
    'WP1' { Start-CMContentDistribution -InputObject $NewImg -DistributionPointGroupName "All DP's" }
    'WQ1' { Start-CMContentDistribution -InputObject $NewImg -DistributionPointGroupName "OSD Only" }
}
#$GetImg = Get-CMOperatingSystemImage -Name $SYSIMGNME | Where-Object -Property Version -EQ "$IMGRLS"
#Move-CMObject -InputObject $GetImg -FolderPath 'WP1:\Operating Systems\Operating System Images\Win10'

#.NET Pro
$IMGNME = "Win10NetDevPro"
$IMGFILE = "$IMGPTH$IMGNME$BLD2$IMGRLS2.wim"
$SYSIMGNME = "Humana Windows 10 Ent $BLD .Net Dev Pro 2019"
$NewImg = New-CMOperatingSystemImage -Name $SYSIMGNME -Path "$IMGFILE" -Version $IMGRLS
Switch ($SiteCode) {
    'WP1' { Start-CMContentDistribution -InputObject $NewImg -DistributionPointGroupName "All DP's" }
    'WQ1' { Start-CMContentDistribution -InputObject $NewImg -DistributionPointGroupName "OSD Only" }
}
#$GetImg = Get-CMOperatingSystemImage -Name $SYSIMGNME | Where-Object -Property Version -EQ "$IMGRLS"
#Move-CMObject -InputObject $GetImg -FolderPath 'WP1:\Operating Systems\Operating System Images\Win10'

#Base
$IMGNME = "Win10Base"
$IMGFILE = "$IMGPTH$IMGNME$BLD2$IMGRLS2.wim"
$SYSIMGNME = "Humana Windows 10 Enterprise $BLD"
$NewImg = New-CMOperatingSystemImage -Name $SYSIMGNME -Path "$IMGFILE" -Version $IMGRLS
Switch ($SiteCode) {
    'WP1' { Start-CMContentDistribution -InputObject $NewImg -DistributionPointGroupName "All DP's" }
    'WQ1' { Start-CMContentDistribution -InputObject $NewImg -DistributionPointGroupName "OSD Only" }
}
#$GetImg = Get-CMOperatingSystemImage -Name $SYSIMGNME | Where-Object -Property Version -EQ "$IMGRLS"
#Move-CMObject -InputObject $GetImg -FolderPath 'WP1:\Operating Systems\Operating System Images\Win10'

#Java
$IMGNME = "Win10Java"
$IMGFILE = "$IMGPTH$IMGNME$BLD2$IMGRLS2.wim"
$SYSIMGNME = "Humana Windows 10 Enterprise $BLD Java"
$NewImg = New-CMOperatingSystemImage -Name $SYSIMGNME -Path "$IMGFILE" -Version $IMGRLS
Switch ($SiteCode) {
    'WP1' { Start-CMContentDistribution -InputObject $NewImg -DistributionPointGroupName "All DP's" }
    'WQ1' { Start-CMContentDistribution -InputObject $NewImg -DistributionPointGroupName "OSD Only" }
}
#$GetImg = Get-CMOperatingSystemImage -Name $SYSIMGNME | Where-Object -Property Version -EQ "$IMGRLS"
#Move-CMObject -InputObject $GetImg -FolderPath 'WP1:\Operating Systems\Operating System Images\Win10'

#Rx Dispensing
$IMGNME = "Win10Rx"
$IMGFILE = "$IMGPTH$IMGNME$BLD2$IMGRLS2.wim"
$SYSIMGNME = "Humana Windows 10 Enterprise $BLD Rx Dispensing"
$NewImg = New-CMOperatingSystemImage -Name $SYSIMGNME -Path "$IMGFILE" -Version $IMGRLS
Switch ($SiteCode) {
    'WP1' { Start-CMContentDistribution -InputObject $NewImg -DistributionPointGroupName "All DP's" }
    'WQ1' { Start-CMContentDistribution -InputObject $NewImg -DistributionPointGroupName "OSD Only" }
}
#$GetImg = Get-CMOperatingSystemImage -Name $SYSIMGNME | Where-Object -Property Version -EQ "$IMGRLS"
#Move-CMObject -InputObject $GetImg -FolderPath 'WP1:\Operating Systems\Operating System Images\Win10'

#SiteCore
$IMGNME = "Win10SiteCore"
$IMGFILE = "$IMGPTH$IMGNME$BLD2$IMGRLS2.wim"
$SYSIMGNME = "Humana Windows 10 Enterprise $BLD SiteCore"
$NewImg = New-CMOperatingSystemImage -Name $SYSIMGNME -Path "$IMGFILE" -Version $IMGRLS
Switch ($SiteCode) {
    'WP1' { Start-CMContentDistribution -InputObject $NewImg -DistributionPointGroupName "All DP's" }
    'WQ1' { Start-CMContentDistribution -InputObject $NewImg -DistributionPointGroupName "OSD Only" }
}
#$GetImg = Get-CMOperatingSystemImage -Name $SYSIMGNME | Where-Object -Property Version -EQ "$IMGRLS"
#Move-CMObject -InputObject $GetImg -FolderPath 'WP1:\Operating Systems\Operating System Images\Win10'

Push-Location "C:"