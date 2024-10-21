$CMPkg = Get-CimInstance -Namespace root\sms\site_WQ1 -Class SMS_PackageBaseClass -ComputerName LOUAPPWQS1151.rsc.humad.com | Where-Object {$_.PackageID -eq 'WQ1000CE' }
$CMPkg | Get-CimInstance | Select-Object AlternateContentProviders


# Get instance of a class
$p = Get-CimInstance -ClassName Win32_PerfFormattedData_PerfOS_Processor

# Perform get again by passing the instance received earlier, and get the updated properties. The value of $p remains unchanged.
$p | Get-CimInstance | select PercentProcessorTime

$UpdateLists = Get-CimInstance -Namespace root\sms\site_TST -Class SMS_AuthorizationList

foreach ($UpdateList in $UpdateLists) {
    $UpdateList = $UpdateList | Get-CimInstance
    
    $Updates = $UpdateList.Updates
    ...
}