# Configuration
$SiteCode = "MT1" # Site code 
$ProviderMachineName = "LOUAPPWTS1442" # SMS Provider machine name
$NewUser = "HUMAD\T_MEMCM_ScriptTest2_WT"
$ExistingUser = "HUMAD\T_MEMCM_ScriptTest_WT"

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

$ExistingUserProperties = Get-CMAdministrativeUser -Name $ExistingUser
$Permissions = $ExistingUserProperties.Permissions
New-CMAdministrativeUser -Name $NewUser -Permission $Permissions