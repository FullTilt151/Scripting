<#
.SYNOPSIS
	This script will create deployments for your CR testing. 
.DESCRIPTION
	The script will create an install and uninstall, optional deployment for the CR you're testing. 
.PARAMETER Site
	This is the site you're in. Default is WQ1.
.PARAMETER Collection
	This should be the testing collection you want to deploy your package to. Default is mine collection. 
.PARAMETER PackageID
	This should be the package you want to test your deployment with.
.EXAMPLE
    If you don't pass any parameters, the site will be WQ1 and the Collection will be WQ100500. These are the author's.   
    Passing parameters: 
    C:\Users\MXC4183A\Repos\SCCM-PowerShell_Scripts\MXC4183\Scripts\Create-CRDeployments.ps1 -site SQ1 -Collection SQ100757 -PackageID SQ1007C2
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('WQ1','SQ1','MT1')]
    [string]$Site = 'WQ1',
    [Parameter(Mandatory=$false)]
    [string]$Collection = 'WQ100500', #WQ1 collection. SQ100757 is mine in SQ1
    [Parameter(Mandatory=$true)]
    [string]$PackageID = $(Read-Host "Input Package ID or enter 0 to quit")
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

#region CheckColl
if(Get-CMCollection -Id $Collection){
    $CollectionID = $Collection
}
else{
    Write-Output "$Collection collection doesn't exist! Please try again."
    EXIT
}
#endregion CheckColl
#Check if the package exists, if so, create the deployments, otherwise bail out.
If($PackageID -eq 0){
    "Input is 0, Exiting"
    EXIT
}
if(Get-CMPackage -packageID $packageID -fast){
    $Actions = (Get-CMProgram -PackageId $PackageID).programname
    foreach ($Action in $Actions) {
        New-CMPackageDeployment -PackageId $PackageID -CollectionID $Collection -ProgramName $Action -StandardProgram -FastNetworkOption DownloadContentFromDistributionPointAndRunLocally -SlowNetworkOption DownloadContentFromDistributionPointAndLocall -Comment "This deployment was created by Mike's Create-CRdeployment.ps1 script." -DeployPurpose Available
    }
}
Else {
    Write-output "$packageID package not found! Please try again."
    EXIT
    }