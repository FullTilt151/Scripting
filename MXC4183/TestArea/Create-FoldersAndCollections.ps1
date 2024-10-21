#What site are we connecting to?
param(
    [parameter(Mandatory = $true, HelpMessage = "Which site are we running this on. WP1, MT1, SP1, WQ1, SQ1")]
    [string]$Site
)
#Prompt for site, MT1, WQ1, SQ1, WP1
if ($Site -eq $null) {$Site = Read-Host 'Enter site (MT1, WQ1, SQ1, WP1)'}
$Server = switch ( $Site ) {
    WP1 {'LOUAPPWPS1658.rsc.humad.com'}
    MT1 {'LOUAPPWTS1140.rsc.humad.com'}
    SP1 {'LOUAPPWPS1825.rsc.humad.com'}
    WQ1 {'LOUAPPWQS1151.rsc.humad.com'}
    SQ1 {'LOUAPPWQS1150.rsc.humad.com'}
}
#Location stuff.
$Location = Get-Location
#Connect to CM
Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + '\ConfigurationManager.psd1')
#Setup site and server
New-PSDrive -Name $Site -PSProvider "AdminUI.PS.Provider\CMSite"  -Root $Server -ErrorAction SilentlyContinue
Set-Location $Site":"
#End Connect to CM


#Prompt user for packageID.
$PackageID = Read-Host -Prompt 'What is the packageID?'

#Get info about package.
$PackageInfo = Get-CMPackage -Id $PackageID -Fast

if ($PackageInfo -eq $null){
    #Package not found or typo.
    Write-Host "$packageID could not be found. Try again." -ForegroundColor Red
    }
else {
    #Legit package. Do some stuff.
    Write-Host "$PackageID found in $site." -ForegroundColor Green
    $PCollection = $PackageInfo.Manufacturer + " " + $PackageInfo.Name + " " + $PackageInfo.Version
    $VCollection = $PCollection + "_VM"
    $Ppath = $PackageInfo.ObjectPath
    Write-Host "Package Path:" $PPath
    Write-Host "Physical Collection: " $PCollection
    Write-Host "Virtual Collection: " $VCollection
}