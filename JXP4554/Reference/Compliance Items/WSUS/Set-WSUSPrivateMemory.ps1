#Set this variable to true for the remediation script, false for the detection script
#Requires -Modules webadministration
$remediate = $false
$compliant = $false
$memoryPoolLimit = 15728640 #15 GB - =(15*2^30)/2^10

import-module webadministration
$applicationPoolsPath = "/system.applicationHost/applicationPools"
$appPoolPath = "$applicationPoolsPath/add[@name='WsusPool']"
if ((Get-WebConfiguration "$appPoolPath/recycling/periodicRestart/@privateMemory").Value -eq $memoryPoolLimit){
	$compliant = $true
}
else{
	#if the item is not compliant, be sure to run the lines below
	Write-Output $false
	if ($remediate) {
		Set-WebConfiguration "$appPoolPath/recycling/periodicRestart/@privateMemory" -Value 0
	} 
}

Write-Output $compliant