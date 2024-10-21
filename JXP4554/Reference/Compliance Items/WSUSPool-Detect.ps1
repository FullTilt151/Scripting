import-module webadministration

$applicationPoolsPath = "/system.applicationHost/applicationPools"
$applicationPools = Get-WebConfiguration $applicationPoolsPath

$appPoolPath = "$applicationPoolsPath/add[@name='WsusPool']"
$a =  Get-WebConfiguration "$appPoolPath/recycling/periodicRestart/@privateMemory" 
write-host $a.Value