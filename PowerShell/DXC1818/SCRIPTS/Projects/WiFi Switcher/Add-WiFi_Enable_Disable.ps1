Unregister-ScheduledTask -TaskName "WiFiDisable*" -Confirm:$false -ErrorAction SilentlyContinue
Unregister-ScheduledTask -TaskName "WiFiEnable*" -Confirm:$false -ErrorAction SilentlyContinue
$EvtSrc = Get-CimInstance Win32_NetworkAdapter | Where-Object Name -Like "Intel(R) Ethernet*" | Select-Object -ExpandProperty ServiceName

Add-Content -Path C:\temp\WifiDisable.xml -Encoding Default -Value '
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>2018-02-26T11:21:49.7662712</Date>
    <Author>Client Innovation Solutions</Author>
    <URI>\WiFiDisable</URI>
  </RegistrationInfo>
  <Triggers>
    <EventTrigger>
      <Enabled>true</Enabled>
      <Subscription>&lt;QueryList&gt;&lt;Query Id="0" Path="System"&gt;&lt;Select Path="System"&gt;*[System[Provider[@Name=e1express] and EventID=32]]&lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;</Subscription>
    </EventTrigger>
    <EventTrigger>
      <Enabled>true</Enabled>
      <Subscription>&lt;QueryList&gt;&lt;Query Id="0" Path="System"&gt;&lt;Select Path="System"&gt;*[System[Provider[@Name=e1express] and EventID=33]]&lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;</Subscription>
    </EventTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-18</UserId>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>false</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
    <Priority>7</Priority>
    <RestartOnFailure>
      <Interval>PT1M</Interval>
      <Count>3</Count>
    </RestartOnFailure>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>C:\Windows\System32\netsh.exe</Command>
      <Arguments>interface set interface "Wi-Fi" disable</Arguments>
    </Exec>
  </Actions>
</Task>'

Add-Content -Path C:\temp\WiFiEnable.xml -Encoding Default -Value '
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>2018-02-26T11:20:24.486224</Date>
    <Author>Client Innovation Solutions</Author>
    <URI>\WiFiEnable</URI>
  </RegistrationInfo>
  <Triggers>
    <EventTrigger>
      <Enabled>true</Enabled>
      <Subscription>&lt;QueryList&gt;&lt;Query Id="0" Path="System"&gt;&lt;Select Path="System"&gt;*[System[Provider[@Name=e1express] and EventID=27]]&lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;</Subscription>
    </EventTrigger>
    <BootTrigger>
      <Enabled>true</Enabled>
    </BootTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-18</UserId>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>false</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
    <Priority>7</Priority>
    <RestartOnFailure>
      <Interval>PT1M</Interval>
      <Count>3</Count>
    </RestartOnFailure>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>C:\Windows\System32\netsh.exe</Command>
      <Arguments>interface set interface "Wi-Fi" enable</Arguments>
    </Exec>
  </Actions>
</Task>'

(Get-Content -Path C:\temp\WifiDisable.xml | Select-Object -Skip 1) -replace 'e1express',"'$EvtSrc'" | Set-Content -Path C:\temp\WifiDisable.xml
(Get-Content -Path C:\temp\WifiEnable.xml | Select-Object -Skip 1) -replace 'e1express',"'$EvtSrc'" | Set-Content -Path C:\temp\WifiEnable.xml

Register-ScheduledTask -Xml (Get-content 'C:\temp\WifiDisable.xml' | Out-string) -TaskName "WiFiDisable"
Register-ScheduledTask -Xml (Get-content 'C:\temp\WifiEnable.xml' | Out-string) -TaskName "WiFiEnable"

Remove-Item -Path C:\temp\Wifi*.xml -Confirm:$false