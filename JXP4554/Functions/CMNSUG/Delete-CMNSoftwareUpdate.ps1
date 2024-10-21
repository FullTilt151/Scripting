$CI_ID = '17015996'
$CI_ID = '17015995'
$cimSession = New-CimSession -ComputerName LOUAPPWPS1658
$update = Get-CimInstance -CimSession $cimSession -ClassName SMS_SoftwareUpdate -Namespace root/sms/site_wp1 -Filter "CI_ID = $CI_ID"
$smsCItoContent = Get-CimInstance -CimSession $cimSession -ClassName SMS_CIToContent -Namespace root/sms/site_wp1 -Filter "CI_ID = $($update.CI_ID)"
$smsCItoContent
$smsPackageToContent = Get-CimInstance -CimSession $cimSession -ClassName SMS_PackageToContent -Namespace root/sms/site_WP1 -Filter "ContentID=$($smsCItoContent.ContentID)"
$smsPackageToContent
