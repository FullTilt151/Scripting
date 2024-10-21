$logFile = 'C:\Temp\Seal-Image.log'
'Stop CcmExec Service'  | Out-File -FilePath $logFile -Encoding ascii -Append
While ((Get-Service -Name CcmExec).Status -ne 'Stopped') {
    Stop-Service -Name CcmExec -Force
    Start-Sleep -Seconds 10
}

"Clean CcmTempDir"  | Out-File -FilePath $logFile -Encoding ascii -Append
$ccmTempDir = (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\CCM -ErrorAction Continue).TempDir
if ((Test-Path $ccmTempDir) -and $ccmTempDir -ne $null -and $ccmTempDir -ne '') {Get-ChildItem -Path $ccmTempDir | Where-Object {!$_.PSisContainer} | Remove-Item -Force -ErrorAction Continue}

"Clean CcmLogDir"  | Out-File -FilePath $logFile -Encoding ascii -Append
$ccmLogDir = (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\CCM\Logging\@Global -ErrorAction Continue).LogDirectory
if ((Test-Path $ccmLogDir) -and $ccmLogDir -ne $null -and $ccmLogDir -ne '') {Get-ChildItem -Path $ccmLogDir | Where-Object {!$_.PSisContainer} | Remove-Item -Force -ErrorAction Continue}

"Clear any queued messages"  | Out-File -FilePath $logFile -Encoding ascii -Append
Get-ChildItem "c:\windows\ccm\ServiceData\Messaging\*.*" -Recurse | Where-Object { ! $_.PSIsContainer } | Remove-Item -Force

"Clear GPO data"  | Out-File -FilePath $logFile -Encoding ascii -Append
if (Test-Path "$env:windir\System32\GroupPolicy\Machine\Registry.pol") {Remove-Item -Path "$env:windir\System32\GroupPolicy\Machine\Registry.pol" -Force}

"Clear SMS Guid"  | Out-File -FilePath $logFile -Encoding ascii -Append
if (Test-Path -Path 'C:\Windows\SMSCFG.INI') {Remove-Item -Path 'C:\Windows\SMSCFG.INI' -Force }

"Clear Citrix backup info"  | Out-File -FilePath $logFile -Encoding ascii -Append
if (Test-Path -Path 'C:\ProgramData\Citrix\pvsagent\LocallyPersistedData\CCMData\CCMCFG.bak') {
    <# 
    Cd /d "c:\ProgramData\Citrix\PvsAgent"
    takeown /f .\LocallyPersistedData /a
    icacls .\LocallyPersistedData /reset /t /c
    if exist .\LocallyPersistedData\CCMData\CCMCFG.BAK del .\LocallyPersistedData\CCMData\CCMCFG.BAK 
    #>
    Remove-item 'C:\ProgramData\Citrix\pvsagent\LocallyPersistedData\CCMData\CCMCFG.bak' -Force 
}

"Clear Certs"  | Out-File -FilePath $logFile -Encoding ascii -Append
Get-ChildItem Cert:\LocalMachine\My | ForEach-Object {foreach ($dmn in $_.DnsNameList) {if ($dmn.Unicode -Match 'humad.com') {Remove-Item -InputObject $_}}}
# Get-ChildItem Cert:\LocalMachine\SMS | Where-Object {$_.Subject -match "^CN=SMS, CN=($env:COMPUTERNAME)"} | Remove-Item -ErrorAction Continue 
Get-ChildItem Cert:\LocalMachine\SMS | Remove-Item -ErrorAction Continue 

"Clear any inventory history"  | Out-File -FilePath $logFile -Encoding ascii -Append
Get-CimInstance -Namespace root\CCM\InvAgt -ClassName InventoryActionStatus -ErrorAction Continue | Remove-CimInstance

'Clear WSUS Store' | Out-File $logFile -Encoding ascii -Append
while ((Get-Service -Name wuauserv).Status -ne 'Stopped') {
    Stop-Service -Name wuauserv -Force
    Start-Sleep -Seconds 10
}
Get-ChildItem C:\Windows\SoftwareDistribution\DataStore | Where-Object {!$_.PSIsContainer} | Remove-Item -Force -ErrorAction Continue
Get-ChildItem C:\Windows\SoftwareDistribution\Download -Recurse | Remove-Item -Force -ErrorAction Continue