Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" # Import the ConfigurationManager.psd1 module 
Set-Location "WP1:" # Set the current location to be the site code.
CLS
$Manf = Read-Host "Please enter the Manufacturer name:"
$ProgramName = read-host "Please enter the Program Name:"

Get-CMPackage -Name "*$ProgramName*" -Fast | Select-Object -Property Manufacturer,Name,Version,PackageID,ObjectPath | Where-Object {$_.Manufacturer -like "*$Manf*"} | Where-Object {$_.PackageID -like "W*"} | Where-Object {$_.ObjectPath -notlike "*HGB*"}