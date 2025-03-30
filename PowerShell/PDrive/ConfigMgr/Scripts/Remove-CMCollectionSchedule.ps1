#Import-Module $env:SMS_ADMIN_UI_PATH\..\configurationmanager.psd1
#Set-Location WP1:
Get-CMCollection | Select-Object CollectionID, Name, CollectionRules, RefreshType |
ForEach-Object {
    $CollRules = $_ | Select-Object -ExpandProperty CollectionRules
    if ($_.RefreshType -ne 1 -and $CollRules.SmsProviderObjectPath -notcontains 'SMS_CollectionRuleQuery') {
        $_
        $CollRules.SMSProviderObjectPath
        # exclude limiting or Security
    }
}