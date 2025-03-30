$Baselines = Get-WmiObject -Namespace root\ccm\dcm -Class SMS_DesiredConfiguration -Filter 'DisplayName = "Root CA Certificates"'
$Baselines | ForEach-Object { 
    $Result = ([wmiclass]"\\$env:computername\root\ccm\dcm:SMS_DesiredConfiguration").GetUserReport($_.Name, $_.Version)
    $xml = [xml]$Result.ComplianceDetails
} 
