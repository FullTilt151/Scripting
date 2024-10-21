Import-Module (Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1)
#$SiteCode = Get-PSDrive -PSProvider CMSITE
#$SiteCode = "WP1"
Set-Location -Path "WP1:\"
$tsname = "Windows 10 - Standard Build-WP100820"
Export-CMTaskSequence -Name $tsname -WithDependence $false  -withContent $false -ExportFilePath ("\\lounaswps08\pdrive\Dept907.CIT\OSD\Export\"+$tsname+ ".zip") -Force