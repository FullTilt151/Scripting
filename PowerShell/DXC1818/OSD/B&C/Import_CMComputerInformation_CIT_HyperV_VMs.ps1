#Requires -RunAsAdministrator
If ($PSVersionTable.PSEdition -ne 'Desktop') {
    Do {
        Write-Host "Switch to Windows Powershell, this script is non-functional in Core." -ForegroundColor Red -BackgroundColor White
        Start-Sleep -Seconds 2
        Write-Host "Switch to Windows Powershell, this script is non-functional in Core." -ForegroundColor White -BackgroundColor Red
    } Until ($PSVersionTable.PSEdition -ne 'Core')
}
##WP1
$SiteCode = 'WP1'
Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" -ErrorAction SilentlyContinue # Import the ConfigurationManager.psd1 module 
Set-Location "WP1:" # Set the current location to be the site code.

Get-CMDevice -Name "CITHPVWTW0010" | Remove-CMDevice -Force
Import-CMComputerInformation -ComputerName "CITHPVWTW0010" -MacAddress "00:15:5D:92:04:07" -CollectionId "WP100131" 
Get-CMDevice -Name "CITHPVWTW0011" | Remove-CMDevice -Force
Import-CMComputerInformation -ComputerName "CITHPVWTW0011" -MacAddress "00:00:00:00:00:15" -CollectionId "WP100131" 
Get-CMDevice -Name "CITHPVWTW0012" | Remove-CMDevice -Force
Import-CMComputerInformation -ComputerName "CITHPVWTW0012" -MacAddress "00:15:5D:92:04:02" -CollectionId "WP100131" 
Invoke-WmiMethod -Path "ROOT\SMS\Site_$($SiteCode):SMS_Collection.CollectionId='WP100131'" -Name RequestRefresh -ComputerName CMWPPSS
Do {
    Start-Sleep -Seconds 60
    $InColl = Get-CMCollectionMember -CollectionId WP100131 | Where-Object -Property Name -EQ 'CITHPVWTW0010'
} Until ($InColl -ne $null)
Get-CMCollectionMember -CollectionId WP100131 | Select-Object Name
Push-Location "C:"

Get-CMDevice -Name "SIMXDWOSD-U-S" | Remove-CMDevice -Force
Import-CMComputerInformation -ComputerName "SIMXDWOSD-U-S" -MacAddress "00:50:56:91:87:f7" -CollectionId "WP100131"
Get-CMDevice -Name "SIMXDWOSD-U-P" | Remove-CMDevice -Force
Import-CMComputerInformation -ComputerName "SIMXDWOSD-U-P" -MacAddress "00:50:56:91:db:25" -CollectionId "WP100131" 
Get-CMDevice -Name "SIMXDWOSD-U-E" | Remove-CMDevice -Force
Import-CMComputerInformation -ComputerName "SIMXDWOSD-U-E" -MacAddress "00:50:56:91:11:34" -CollectionId "WP100131" 
Get-CMDevice -Name "LOUXDWSIC-U-OSD" | Remove-CMDevice -Force
Import-CMComputerInformation -ComputerName "LOUXDWSIC-U-OSD" -MacAddress "00:50:56:91:34:a7" -CollectionId "WP100131"
#Get-CMDevice -Name "LOUXDWOSD-U-A" | Remove-CMDevice -Force
#Import-CMComputerInformation -ComputerName "LOUXDWOSD-U-A" -MacAddress "00:50:56:b7:b6:e1" -CollectionId "WP100131"
#Get-CMDevice -Name "LOUXDWRPA-U-S1" | Remove-CMDevice -Force
#Import-CMComputerInformation -ComputerName "LOUXDWRPA-U-S1" -MacAddress "00:50:56:b7:d0:70" -CollectionId "WP100131"
Get-CMDevice -Name "LOUXDWOSD-U-S" | Remove-CMDevice -Force
Import-CMComputerInformation -ComputerName "LOUXDWOSD-U-S" -MacAddress "00:50:56:b7:c1:49" -CollectionId "WP100131"
Invoke-WmiMethod -Path "ROOT\SMS\Site_$($SiteCode):SMS_Collection.CollectionId='WP100131'" -Name RequestRefresh -ComputerName CMWPPSS
Do {
    Start-Sleep -Seconds 60
    $InColl = Get-CMCollectionMember -CollectionId WP100131 | Where-Object -Property Name -EQ 'LOUXDWOSD-U-S'
} Until ($InColl -ne $null)
Get-CMCollectionMember -CollectionId WP100131 | Select-Object Name



##SP1
$SiteCode = 'SP1'
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" -ErrorAction SilentlyContinue 
}

# Connect to the site's drive if it is not already present
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName 
}
Set-Location "SP1:" # Set the current location to be the site code.
#Get-CMDevice -Name "W2012R2-BC" | Remove-CMDevice -Force
#Import-CMComputerInformation -ComputerName "W2012R2-BC" -MacAddress "00:50:56:81:d5:f2" -CollectionId "SP1014C8"
Get-CMDevice -Name "WIN2016G-BC" | Remove-CMDevice -Force
Import-CMComputerInformation -ComputerName "WIN2016G-BC" -MacAddress "00:50:56:b7:e1:30" -CollectionId "SP1014C8"
Get-CMDevice -Name "WIN2019G-BC" | Remove-CMDevice -Force
Import-CMComputerInformation -ComputerName "WIN2019G-BC" -MacAddress "00:50:56:b7:1d:cd" -CollectionId "SP1014C8"
Get-CMDevice -Name "WIN2019C-BC" | Remove-CMDevice -Force
Import-CMComputerInformation -ComputerName "WIN2019C-BC" -MacAddress "00:50:56:b7:11:e5" -CollectionId "SP1014C8"
Get-CMDevice -Name "WIN2016C-BC" | Remove-CMDevice -Force
Import-CMComputerInformation -ComputerName "WIN2016C-BC" -MacAddress "00:50:56:b7:17:93" -CollectionId "SP1014C8"
Get-CMDevice -Name "WIN2022G-BC" | Remove-CMDevice -Force
Import-CMComputerInformation -ComputerName "WIN2022G-BC" -MacAddress "00:50:56:b7:b3:c6" -CollectionId "SP1014C8"
Invoke-WmiMethod -Path "ROOT\SMS\Site_$($SiteCode):SMS_Collection.CollectionId='SP1014C8'" -Name RequestRefresh -ComputerName CMSPPSS
Do {
    Start-Sleep -Seconds 60
    $InColl = Get-CMCollectionMember -CollectionId SP1014C8 | Where-Object -Property Name -EQ 'WIN2022G-BC'
} Until ($InColl -ne $null)
Get-CMCollectionMember -CollectionId SP1014C8 | Select-Object Name

Get-CMDevice -Name "W2016G-BC-T" | Remove-CMDevice -Force
Import-CMComputerInformation -ComputerName "W2016G-BC-T" -MacAddress "00:50:56:b7:a2:4c" -CollectionId "SP1014C8"
Get-CMDevice -Name "W2016C-BC-T" | Remove-CMDevice -Force
Import-CMComputerInformation -ComputerName "W2016C-BC-T" -MacAddress "00:50:56:b7:8a:46" -CollectionId "SP1014C8"
Get-CMDevice -Name "W2019G-BC-T" | Remove-CMDevice -Force
Import-CMComputerInformation -ComputerName "W2019G-BC-T" -MacAddress "00:50:56:b7:f1:3b" -CollectionId "SP1014C8"
Get-CMDevice -Name "W2019C-BC-T" | Remove-CMDevice -Force
Import-CMComputerInformation -ComputerName "W2019C-BC-T" -MacAddress "00:50:56:b7:23:40" -CollectionId "SP1014C8"
Invoke-WmiMethod -Path "ROOT\SMS\Site_$($SiteCode):SMS_Collection.CollectionId='SP1014C8'" -Name RequestRefresh -ComputerName CMSPPSS
Do {
    Start-Sleep -Seconds 60
    $InColl = Get-CMCollectionMember -CollectionId SP1014C8 | Where-Object -Property Name -EQ 'W2016G-BC-T'
} Until ($InColl -ne $null)
Get-CMCollectionMember -CollectionId SP1014C8 | Select-Object Name



##WP1 HGB
$SiteCode = 'WP1'
Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" # Import the ConfigurationManager.psd1 module 
Set-Location "WP1:" # Set the current location to be the site code.
Get-CMDevice -Name "HGBHPVWTW0001" | Remove-CMDevice -Force
Import-CMComputerInformation -ComputerName "HGBHPVWTW0001" -MacAddress "00:15:5D:94:8A:3B" -CollectionId "WP100131" 
Get-CMDevice -Name "HGBHPVWTW0002" | Remove-CMDevice -Force
Import-CMComputerInformation -ComputerName "HGBHPVWTW0002" -MacAddress "00:15:5D:94:8A:58" -CollectionId "WP100131"
Get-CMDevice -Name "HGBHPVWTW0004" | Remove-CMDevice -Force
Import-CMComputerInformation -ComputerName "HGBHPVWTW0004" -MacAddress "00:15:5D:94:8A:82" -CollectionId "WP100131" 
Get-CMDevice -Name "HGBHPVWTW0005" | Remove-CMDevice -Force
Import-CMComputerInformation -ComputerName "HGBHPVWTW0005" -MacAddress "00:15:5D:94:8A:86" -CollectionId "WP100131"
Invoke-WmiMethod -Path "ROOT\SMS\Site_$($SiteCode):SMS_Collection.CollectionId='WP100131'" -Name RequestRefresh -ComputerName CMWPPSS
Do {
    Start-Sleep -Seconds 60
    $InColl = Get-CMCollectionMember -CollectionId WP100131 | Where-Object -Property Name -EQ 'HGBHPVWTW0001'
} Until ($InColl -ne $null)
Get-CMCollectionMember -CollectionId WP100131 | Select-Object Name