#ConfigMgr Script Approval
Write-Host "Enter: SP1, SQ1, WP1, WQ1, MT1"
$Action = Read-Host "Select a Site"

Switch ($Action) {
    SP1 {
        $SiteCode = "SP1"
        $ProviderMachineName = "CMSPPSS"              
        }
    SQ1 {
        $SiteCode = "SQ1"
        $ProviderMachineName = "CMSQPSS" 
        }
    WP1 {
        $SiteCode = "WP1"
        $ProviderMachineName = "CMWPPSS" 
        }
    WQ1 {
        $SiteCode = "WQ1"
        $ProviderMachineName = "CMWQPSS" 
        }
    MT1 {
        $SiteCode = "MT1"
        $ProviderMachineName = "CMMTPSS" 
        }
}
$initParams = @{}
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

$SCRPNAME = Read-Host "Enter the Script Name"
$CMNT = Read-Host "Enter a Comment"
$SCRP = Get-CMScript -ScriptName "$SCRPNAME" -Fast
Approve-CMScript -ScriptGuid $SCRP.ScriptGuid -Comment "$CMNT"
Push-Location "C:"