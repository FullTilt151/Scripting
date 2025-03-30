﻿# Site Configuration
$SiteCode = "SQ1" # Site code 
$ProviderMachineName = "LOUAPPWQS1150" # SMS Provider machine name

# Customizations
$initParams = @{}
#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors


# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams

$LimitingCollectionID = "SQ100022"
$Collections = Get-CMDeviceCollection -Name "EST*" | where-object {$_.LimitToCollectionID -eq "SMS00001"}
ForEach ($Collection in $Collections)
{
Set-CMDeviceCollection -CollectionId $Collection.CollectionID -LimitingCollectionId $LimitingCollectionID
}