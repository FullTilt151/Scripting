<#
.SYNOPSIS
	This script will export packages. 
.DESCRIPTION
	The script will export a package to import into another environment. 
.PARAMETER PackageID
	This is the package ID you want to export.
.PARAMETER Site
	This is the site where the exists.
.EXAMPLE
    Export-Package -Site <site> -PackageID <package ID>
    Export-Package -Site <site> -Location <new location> -PackageID
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('WQ1','SQ1','MT1','WP1','SP1')]
    [string]$Site = $(Read-Host "What site are we exporting from?"),
    [Parameter(Mandatory=$false)]
    [string]$location = '\\lounaswps08\pdrive\workarea\mxc4183\CMPackageExports',
    [Parameter(Mandatory=$true)]
    [string]$PackageID = $(Read-Host "Input Package ID or enter 0 to quit")
)
#PSS for each env.
$SiteCode = switch ( $Site ) {
    MT1 { 'LOUAPPWTS1140.rsc.humad.com' }
    WQ1 { 'LOUAPPWQS1151.rsc.humad.com' }
    SQ1 { 'LOUAPPWQS1150.rsc.humad.com' }
    WP1 { 'LOUAPPWPS1658.rsc.humad.com' }
    SP1 { 'LOUAPPWPS1825.rsc.humad.com' }
}

#do the things.
#1st, let's make sure I didn't already export it and forgot that I did...
if(Test-Path -Path "$location\$PackageID.zip"){
    Write-Output "You've already exported $PackageID!"
    Exit
}
else {
#Ok, let's connect to CM.
#region Connect 
Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + '\ConfigurationManager.psd1')
New-PSDrive -Name $Site -PSProvider "AdminUI.PS.Provider\CMSite"  -Root $SiteCode -ErrorAction SilentlyContinue
Push-Location $Site":"
#endregion Connect
#Finally, let's export the package.
Export-CMPackage -Id "$packageID" -FileName "$location\$PackageID.zip"
Write-output "Package was exported to: $location\$PackageID.zip"
}