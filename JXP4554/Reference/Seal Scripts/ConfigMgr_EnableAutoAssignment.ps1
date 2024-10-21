write-host "----------------------------------------------"
write-host "This script checks the ConfigMgr client WMI settings to see if EnableAutoAssignment is false and if so enables it."
write-host "----------------------------------------------"
write-host ""

$SMSClient = Get-Wmiobject -class SMS_Client -namespace 'ROOT\CCM'
$AutoAssignment = (Get-Wmiobject -class SMS_Client -namespace 'ROOT\CCM').EnableAutoAssignment

if ($AutoAssignment -eq "True"){
    write-host "AutoAssignment already enabled!" -ForegroundColor Green
} else {
    write-host "Enabling AutoAssignment..." -ForegroundColor Yellow
    $SMSClient.EnableAutoAssignment = $true
    $SMSClient.Put() | Out-Null
    start-sleep -seconds 5
    write-host "EnableAutoAssignment is now"(Get-Wmiobject -class SMS_Client -namespace 'ROOT\CCM').EnableAutoAssignment
}