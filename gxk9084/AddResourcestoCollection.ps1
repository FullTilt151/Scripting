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

#-Determine and set path to this script.
$ScriptLocation = $MyInvocation.Mycommand.Path
$ScriptPath = Split-Path $ScriptLocation
Set-Location $ScriptPath
$hostnames = @()

$inputfile= "$ScriptPath\hosts.txt"

Get-Content $inputfile | Foreach-Object {$hostnames += $_} 

$Line | Out-File $outputfile -Append
$CollectionID="WP1043FD"

Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + '\ConfigurationManager.psd1')
#Setup site and server
New-PSDrive -Name $Site -PSProvider "AdminUI.PS.Provider\CMSite"  -Root $Server -ErrorAction SilentlyContinue
Set-Location $Site":"
foreach ( $Line in $hostnames )
{
Write-Host $Line -Foreground green -Background Black
Add-CMDeviceCollectionDirectMembershipRule -CollectionID $CollectionID -ResourceId $(Get-CMDevice -Name $Line).ResourceID

}
   