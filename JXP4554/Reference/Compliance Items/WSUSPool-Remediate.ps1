import-module webadministration

$applicationPoolsPath = "/system.applicationHost/applicationPools"
$applicationPools = Get-WebConfiguration $applicationPoolsPath

$appPoolPath = "$applicationPoolsPath/add[@name='WsusPool']"
$a =  Get-WebConfiguration "$appPoolPath/recycling/periodicRestart/@privateMemory" 
Set-WebConfiguration "$appPoolPath/recycling/periodicRestart/@privateMemory" -Value 8388608