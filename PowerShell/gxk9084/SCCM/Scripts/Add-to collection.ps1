param(
    [parameter(Mandatory = $true, HelpMessage = "Which site are we running this on?")]
    [ValidateSet('MT1', 'SP1', 'SQ1', 'WP1', 'WQ1')]
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

#-Setup Logfile
$APPN = "Pilot1"
$Logfile = "$Env:SystemDrive\Temp\$APPN.log"
$CurrDate = (Get-Date)
if (!(Test-Path -Path "$Env:SystemDrive\Temp")) {
    new-item $Env:SystemDrive\Temp -itemtype directory
}
#-Start Logfile
"" | Out-File $Logfile -Force
"$APPN initiated" | Out-File $Logfile -Append
"$Currdate" | Out-File $Logfile -Append
"" | Out-File $Logfile -Append
#End Setup logfile
Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + '\ConfigurationManager.psd1')
#Setup site and server
New-PSDrive -Name $Site -PSProvider "AdminUI.PS.Provider\CMSite"  -Root $Server -ErrorAction SilentlyContinue
Set-Location $Site":"
$InputFile = 'C:\Users\gxk9084a\Repos\SCCM-PowerShell_Scripts\GXK9084\SCCM\Scripts\Pilot1.txt'
$CollectionID = 'WP1046EA'
$WKIDList = Get-Content $InputFile

foreach($WKID in $WKIDList){
    Write-Host $WKID -ForegroundColor Blue -BackgroundColor Black
    Add-CMDeviceCollectionDirectMembershipRule -CollectionID $CollectionID -ResourceID (Get-CMDevice -Name $WKID).ResourceID 
}
Write-Host "Complete" -ForegroundColor Magenta -BackgroundColor black