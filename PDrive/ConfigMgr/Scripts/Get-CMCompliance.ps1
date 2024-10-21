#Check for state message in the last 24 hours
$query = 'SELECT * FROM CCM_StateMsg'
$lastStateMessage = (Get-WmiObject -Namespace root\ccm\StateMsg -Query $query | Where-Object {$_.MessageSent -eq $true} | Sort-Object -Property MessageTime -Descending)[0]
$lastStateTime = $lastStateMessage.ConvertToDateTime($lastStateMessage.MessageTime)
$lastMessageDelta = New-TimeSpan -Start $(get-date) -End $lastStateTime
if($lastMessageDelta.Hours -gt 24){$stateMessage = $false}else{$stateMessage = $true}

#Get Service Info
$services = ((Get-WmiObject -Query "select startmode from win32_service where Name = 'ccmexec'").StartMode -eq 'Auto') -and ((Get-WmiObject -Query "select State from win32_service where Name = 'ccmexec'").State -eq 'Running')

#Check CCMEval ran within the last 24 hours
$lastEval = (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\CCM\CcmEval -Name LastEvalTime).LastEvalTime
$lastEvalDateTime = $lastEval -replace '(.*)T(.*)Z', '$1 $2'
$currentTimeZone = ([TimeZoneInfo]::Local.BaseUtcOffset).Hours
if(-not ($currentTimeZone -match '^[+-]')){$currentTimeZone = "+$currentTimeZone"}
$lastEvalTime = Get-Date("$lastEvalDateTime $currentTimeZone")
$lastMessageDelta = New-TimeSpan -Start $lastEvalTime -End $(Get-Date)
if($lastMessageDelta.Hours -lt 168){$ccmEval = $true}else{$ccmEval = $false}

Write-Output ($stateMessage -and $ccmEval -and $services)