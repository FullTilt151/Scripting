
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('WQ1','SQ1','MT1')]
    [string]$Site = 'WQ1',
    [Parameter(Mandatory=$true)]
    [string]$PackageID = $(Read-Host -Prompt "What is the PackageID?"),
    [Parameter(Mandatory=$false)]
    [string]$DistributionPointGroup

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
$DistributionPointGroup = "All DP's"

# Distribution point name won't change. Prompt for the packageID and just send 'er bud.
Start-CMContentDistribution -PackageId $PackageID -DistributionPointGroupName $DistributionPointGroup


