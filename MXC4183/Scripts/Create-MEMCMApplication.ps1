param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('WQ1','SQ1','MT1','WP1')]
    [string]$Site = $Site
)
#region Connect
#PSS for each env.
$SiteCode = switch ( $Site ) {
    MT1 { 'CMMTPSS.humad.com' }
    WQ1 { 'CMWQPSS.humad.com' }
    SQ1 { 'CMSQPSS.humad.com' }
    WP1 { 'CMWPPSS.humad.com' }
}

# Import Module.
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to site.
New-PSDrive -Name $Site -PSProvider "AdminUI.PS.Provider\CMSite"  -Root $SiteCode -ErrorAction SilentlyContinue
Push-Location $Site":"
Write-Output "Connected to $Site..."
#endregion Connect

Invoke-RestMethod -Method 'Get' -Uri "https://cmmtpss.humad.com/AdminService/wmi/sms_application" -UseDefaultCredentials

((Invoke-RestMethod -Method 'Get' -Uri "https://SMSProviderFQDN/AdminService/wmi/SMS_Site" -UseDefaultCredentials).value).Version