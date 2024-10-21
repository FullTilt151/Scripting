param(
[Parameter(Mandatory = $true)]
[string]$BrowserExtensionName
)

# Site configuration
$SiteCode = "WP1" # Site code 
$ProviderMachineName = "CMWPPSS.humad.com" # SMS Provider machine name

# Import the ConfigurationManager.psd1 module 
if($null -eq (Get-Module ConfigurationManager)) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"
}

# Connect to the site's drive if it is not already present
if($null -eq (Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName
}

# Set the current location to be the site code.
Push-Location "$($SiteCode):\"

$Name = "Script - Browser Extension - $BrowserExtensionName"
$ChromeName = "Script - Browser Extension - Chrome - $BrowserExtensionName"
$EdgeName = "Script - Browser Extension - Edge - $BrowserExtensionName"
$BaselineName = "Browser Extension - $BrowserExtensionName"

#TODO Pull in Extension and Store to modify file
#TODO Add supported platforms

$ChromeSettings = @{
    DataType = 'Boolean'
    DiscoveryScriptFile = "$env:userprofile\VSCode-Repo\SCCM-PowerShell_Scripts\Stable Scripts\ConfigMGR\Add-CMCI-BrowserExtension-Chrome.ps1"
    DiscoveryScriptLanguage = 'PowerShell'
    RemediationScriptFile = "$env:userprofile\VSCode-Repo\SCCM-PowerShell_Scripts\Stable Scripts\ConfigMGR\Add-CMCI-BrowserExtension-Chrome.ps1"
    RemediationScriptLanguage = 'PowerShell'
    Name = $ChromeName
    Is64Bit = $true
    IsPerUser = $false
    NoRule = $true
}

$EdgeSettings = @{
    DataType = 'Boolean'
    DiscoveryScriptFile = "$env:userprofile\VSCode-Repo\SCCM-PowerShell_Scripts\Stable Scripts\ConfigMGR\Add-CMCI-BrowserExtension-Edge.ps1"
    DiscoveryScriptLanguage = 'PowerShell'
    RemediationScriptFile = "$env:userprofile\VSCode-Repo\SCCM-PowerShell_Scripts\Stable Scripts\ConfigMGR\Add-CMCI-BrowserExtension-Edge.ps1"
    RemediationScriptLanguage = 'PowerShell'
    Name = $EdgeName
    Is64Bit = $true
    IsPerUser = $false
    NoRule = $true
}

$CI = New-CMConfigurationItem -CreationType WindowsOS -Name $Name
$CI | Add-CMComplianceSettingScript @ChromeSettings
$CI | Add-CMComplianceSettingScript @EdgeSettings
$CISettingChrome = $CI | Get-CMComplianceSetting -SettingName $ChromeName
$CISettingEdge = $CI | Get-CMComplianceSetting -SettingName $EdgeName
$CIRuleChrome = $CISettingChrome | New-CMComplianceRuleValue -Remediate -ExpectedValue $true -ExpressionOperator IsEquals -RuleName 'Compliant = True'
$CIRuleEdge = $CISettingEdge | New-CMComplianceRuleValue -Remediate -ExpectedValue $true -ExpressionOperator IsEquals -RuleName 'Compliant = True'
$CI | Add-CMComplianceSettingRule -Rule $CIRuleChrome
$CI | Add-CMComplianceSettingRule -Rule $CIRuleEdge

$Baseline = New-CMBaseline -Name $BaselineName -AllowComanagedClients
Set-CMBaseline -Id $($Baseline.CI_ID) -AddOSConfigurationItem $CI.CI_ID

Move-CMObject -InputObject $CI -FolderPath 'WP1:\ConfigurationItem\CIS\Applications'
Move-CMObject -InputObject $Baseline -FolderPath 'WP1:\ConfigurationBaseline\CIS\Applications'