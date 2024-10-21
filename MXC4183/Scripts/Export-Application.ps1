<#
.SYNOPSIS
	This script will export Applications. 
.DESCRIPTION
	The script will export an application to import into another environment. Will tie into AMM frontend.
.PARAMETER AppName
	This is the Application you want to export.
.PARAMETER Site
	This is the site where the exists.
.EXAMPLE
    Export-Application -Site <site> -AppID <App CI ID>
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('WQ1','SQ1','MT1','WP1')]
    [string]$Site = $Site,
    [Parameter(Mandatory=$true)]
    [string]$AppName = $AppName,
    [Parameter(Mandatory=$false)]
    [string]$Path = '\\lounaswps08\pdrive\workarea\mxc4183\CMApplicationExports',
    [Parameter(Mandatory=$true)]
    [ValidateSet('Export','Import')]
    [string]$Action = $Action
)

#region Connect
$SiteCode = switch ( $Site ) {
    MT1 { 'CMMTPSS.humad.com' }
    WQ1 { 'CMWQPSS.humad.com' }
    SQ1 { 'CMSQPSS.humad.com' }
    WP1 { 'CMWPPSS.humad.com' }
}

# First, let's make sure I didn't already export it and forgot that I did...
if(Test-Path -Path "$location\$AppName.zip"){
    Write-Output "You've already exported $AppName!"
    Exit
}
else {
    # Import Module.
    Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + '\ConfigurationManager.psd1')
    New-PSDrive -Name $Site -PSProvider "AdminUI.PS.Provider\CMSite"  -Root $SiteCode -ErrorAction SilentlyContinue
    Push-Location $Site":"

    # If Export parameter given, get the app and export it to my workarea
    if($Action -eq 'Export'){
        Get-CMApplication -Name "$AppName*" | Export-CMApplication -Path "$Path\$AppName.zip" -IgnoreRelated -OmitContent -Comment "Testing Application Export" -Force
        Write-output "The application was exported to: $Path\$AppName.zip"
    }

# If Import paramater given, import the app to the site defined.
    if($Action -eq 'Import'){
        $Site = Read-Host "What site to you want to import the app to?"
        New-PSDrive -Name $Site -PSProvider "AdminUI.PS.Provider\CMSite"  -Root $SiteCode -ErrorAction SilentlyContinue
        Push-Location $Site":"

        # Now import the app.
        Import-CMApplication -filepath "$Path\$AppName.zip" -ImportActionType Overwrite
    }

}


