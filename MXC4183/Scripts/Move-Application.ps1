<#
.SYNOPSIS
	This script will migrate Applications between environments. 
.DESCRIPTION
	The script will export an application to import into another environment. Will tie into AMM frontend (maybe).
.PARAMETER AppName
	This is the Application you want to export.
.PARAMETER Site
	This is the site where the exists.
.EXAMPLE
    Export-Application -Site <site> -AppID <App CI ID>
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('WQ1','WP1','SQ1','SP1','MT1')]
    [string]$Site = $Site,
    [Parameter(Mandatory=$true)]
    [string]$AppName = $AppName,
	[Parameter(Mandatory=$true)]
    [string]$CR = $CR,
    [Parameter(Mandatory=$false)]
    [string]$Path = '\\lounaswps08\pdrive\workarea\mxc4183\CMApplicationExports',
    [Parameter(Mandatory=$false)]
    [ValidateSet('Export','Import')]
    [string]$Action = $Action
)

#region Connect
$SiteCode = switch ( $Site ) {
    MT1 { 'CMMTPSS.humad.com' }
    WQ1 { 'CMWQPSS.humad.com' }
    SQ1 { 'CMSQPSS.humad.com' }
	SP1 { 'CMSPPSS.humad.com' }
    WP1 { 'CMWPPSS.humad.com' }
}

# Import CM Module, connect to CM site provided by user.
 Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + '\ConfigurationManager.psd1')
 New-PSDrive -Name $Site -PSProvider "AdminUI.PS.Provider\CMSite"  -Root $SiteCode -ErrorAction SilentlyContinue
 Push-Location $Site":"
 
 # Get app from initial site using wildcard. Throw the deets into another variable so we can increment later if needed.
 if(Get-CMApplication -Name "$AppName*" -Fast){
    $App = Get-CMApplication -Name "$AppName*" -Fast
        # Get WKID. Create temp CR folder to hold exported files. Delete with script is finished.
        $WKID = "\\$env:COMPUTERNAME"
        Write-Host "Checking for $WKID\C$\temp\$CR directory" -ForegroundColor Blue
        if(Test-Path -Path "$WKID\c$\temp\$CR"){
            Write-host "$WKID\c$\temp\$CR found! No need to create." -ForegroundColor Blue
            $AppDrop = "$WKID\c$\temp\$CR"
        }else{
            Write-host "Creating C:\temp\$CR" -ForegroundColor Blue
            New-Item -Path "$WKID\c$\temp\" -Name "$CR" -ItemType "directory"
            $AppDrop = "$WKID\c$\temp\$CR"
        }
 }else{
     Write-host "$AppName application not found! Please ensure your application exists in $Site and you've entered part of the application name. Exiting" -ForegroundColor Red
     Exit
     
 }
 # Whatever the initial site given will tell us what site we should import to but first we need to bounce over to import env and check if it already exists. (Change this to reflect QA > PROD after testing is done.)
 if($Site -eq "MT1"){
     Write-Host "Workstation Test site given. Checking if application already exists..." -ForegroundColor Blue
     Set-Location -Path "WQ1:"
     if(Get-CMApplication -Name "$AppName*" -Fast){
         Write-host "App exists. Need to bump the CI version, then export, THEN import." -ForegroundColor Blue
         $AppExists = $true
     }else{
         Write-host "App doesn't exist. Import withOUT the overwrite switch." -ForegroundColor Blue
         $AppExists = $false
     }

     #Jump back site given by tech. Export app depending on if app exists in other env.
     Set-Location -Path ($Site + ":")
     if($AppExists){
         Write-Host "App exists in WQ1. Bumping the version before importing." -ForegroundColor Blue
         # Bump the CIversion by setting English at the language. (Will this always work?)
         Set-CMApplication -InputObject $app -ApplyToLanguageById 1033
         #Now export it.
         Write-Host "Ok, exporting after bumping the CIversion." -ForegroundColor Blue
         Get-CMApplication -Name "$AppName*" -Fast | Export-CMApplication -Path "$AppDrop\$CR.zip" -IgnoreRelated -OmitContent -Comment "Application version incremented and exported from $Site." -Force         
     }
     else{
         Write-host "App doesn't exist." -ForegroundColor Blue
         #Export it without the overwrite.
         Get-CMApplication -Name "$AppName*" | Export-CMApplication -Path "$AppDrop\$CR.zip" -IgnoreRelated -OmitContent -Comment "Application exported from $Site." -Force
     }

    #Ok, finally we can import. Situation will determine the switches.
    if($site -eq "MT1"){
        If($AppExists -eq $true){
            Write-host "Importing app from $Site with overwrite switch." -ForegroundColor Blue
            Set-Location -Path "WQ1:"
            Import-CMApplication -filepath "$Appdrop\$CR.zip" -ImportActionType Overwrite
        }
        If($AppExists -eq $false){
            Write-host "Importing app from $site without switch." -ForegroundColor Blue
            Set-Location -Path "WQ1:"
            Import-CMApplication -filepath "$Appdrop\$CR.zip"
        }

    }
}



 
