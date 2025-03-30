<#
.SYNOPSIS
	This script will import packages. 
.DESCRIPTION
	The script will import a package to import into another environment. 
.PARAMETER PackageID
	This is the package ID you want to import.
.PARAMETER Site
	This is the site where the exists.
.EXAMPLE
    Import-Package - -PackageID <package ID>
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('WQ1','SQ1','MT1')]
    [string]$Site = $(Read-Host "What site are we importing to?"),
    [Parameter(Mandatory=$false)]
    [string]$folder = 'package\SWS Packages\mxc4183',
    [Parameter(Mandatory=$true)]
    [string]$PackageID = $(Read-Host "Input Package ID or enter 0 to quit"),
    [Parameter(Mandatory=$true)]
    [string]$name = $(Read-Host "Package name?")
)

#PSS for each env.
$SiteCode = switch ( $Site ) {
    MT1 { 'LOUAPPWTS1140.rsc.humad.com' }
    WQ1 { 'LOUAPPWQS1151.rsc.humad.com' }
    SQ1 { 'LOUAPPWQS1150.rsc.humad.com' }
}

#region Connect 
Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + '\ConfigurationManager.psd1')
New-PSDrive -Name $Site -PSProvider "AdminUI.PS.Provider\CMSite"  -Root $SiteCode -ErrorAction SilentlyContinue
Push-Location $Site":"
#endregion Connect

#do the thing.
#import the package.
Import-CMPackage -ImportFilePath "$location\$PackageID.zip"

#get the new packageID (hopefully there's just the one we imported)
Get-CMPackage
Move-CMObject -FolderPath "$folder" -ObjectId $PackageID