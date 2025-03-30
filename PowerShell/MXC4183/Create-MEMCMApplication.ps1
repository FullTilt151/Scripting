#region params
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('WQ1','SQ1','MT1')]
    [string]$Site = 'WQ1',
    [Parameter(Mandatory=$true)]
    [string]$Name,
    [Parameter(Mandatory=$true)]
    [string]$Publisher,
    [Parameter(Mandatory=$true)]
    [string]$Version,
    [Parameter(Mandatory=$true)]
    [string]$LocalizedName,
    [Parameter(Mandatory=$true)]
    [string]$DocumentationLink,
    [Parameter(Mandatory=$true)]
    [string]$ContentLocation
    
)
#endregion params

#PSS for each env.
$SiteCode = switch ( $Site ) {
    MT1 { 'LOUAPPWTS1140.rsc.humad.com' }
    WQ1 { 'LOUAPPWQS1151.rsc.humad.com' }
    SQ1 { 'LOUAPPWQS1150.rsc.humad.com' }
}

# Connect to MEMCM 
Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + '\ConfigurationManager.psd1')
New-PSDrive -Name $Site -PSProvider "AdminUI.PS.Provider\CMSite"  -Root $SiteCode -ErrorAction SilentlyContinue
Push-Location $Site":"

# Create application.
New-CMApplication -Name $Name -Publisher $Publisher -SoftwareVersion $Version -LocalizedName $LocalizedName -UserDocumentation $DocumentationLink -LinkText "Click here for more information about$Name" 

# Now create deployment type.
$SilentInstallCommand = "Deploy-Application.ps1 -DeployMode Silent"
$SilentUninstallCommand = "Deploy-Application.ps1 -DeploymentType Uninstall"

Add-CMScriptDeploymentType -DeploymentTypeName "Install $Name" -InstallCommand $SilentInstallCommand -ApplicationName $Name -ScriptLanguage PowerShell -ContentLocation $ContentLocation  
Add-CMScriptDeploymentType -ApplicationName $Name -DeploymentTypeName "Uninstall $Name" -ContentLocation $ContentLocation -UninstallCommand $SilentUninstallCommand -ScriptLanguage 'PowerShell'