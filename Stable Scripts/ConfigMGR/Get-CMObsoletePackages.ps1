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

$TSPackages = Get-CimInstance -ComputerName $Server -Namespace root\sms\site_$SiteCode -ClassName sms_tasksequencepackagereference | Select-Object -ExpandProperty RefPackageId

Get-CMPackage -Fast | Where-Object {$_.PackageType -eq 0 -and $_.pkgsourcepath -ne '' -and $_.pkgsourcepath -like '\\lounaswps*' -and $_.PackageID -notin $TSPackages} |
ForEach-Object {
    Pop-Location
    if (-not (Test-Path ($_.Pkgsourcepath).replace('lounaswps01','lounaswps08'))) {
        "$($_.PackageID),$($_.Name),$($_.Pkgsourcepath),$($_.LastRefreshTime)" | Out-File -Path c:\temp\ObsoletePackages.csv -Append
    }
    Push-Location "$($SiteCode):\"
}
Pop-Location