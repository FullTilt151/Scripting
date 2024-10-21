get-wmiobject -ComputerName louappwps875 -Namespace root\sms\site_cas -Class sms_sci_component -Filter "ComponentName = 'SMS_WSUS_CONFIGURATION_MANAGER'" | 
ForEach-Object{
    $psitem.SiteCode
    ($psitem.Props).where({$_.PropertyName -eq "WSUS Scan Retry Error Codes"}) | Select-Object -ExpandProperty Value2
}