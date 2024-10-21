import-Module webadministration

$FullFileName = (Get-WebConfigFile 'IIS:\Sites\WSUS Administration\ClientWebService').fullname
$acl = get-acl $FullFileName
takeown /F $FullFileName /A
$adminRule = New-Object System.Security.AccessControl.FileSystemAccessRule('BuiltIn\Administrators', 'FullControl', 'Allow')
$acl.SetAccessRule($adminRule)
$Ar = New-Object system.security.accesscontrol.filesystemaccessrule("NT AUTHORITY\SYSTEM", "FullControl", "Allow")
$acl.SetAccessRule($Ar)
Set-ACL $FullFileName $acl
[XML]$xml = Get-Content $FullFileName
$ChangeThis = ((($xml.configuration).'system.web').httpRunTime)
$ChangeThis.SetAttribute('executionTimeout', '7200')
$xml.Save($FullFileName)

Set-ItemProperty -Path IIS:\Sites\'WSUS Administration' -Name limits.maxConnections -Value 4294967295
Set-ItemProperty -Path IIS:\Sites\'WSUS Administration' -Name limits.maxBandwidth -Value 4294967295
Set-ItemProperty -Path IIS:\Sites\'WSUS Administration' -Name limits.connectionTimeout -Value 00:05:20
Set-ItemProperty -Path IIS:\AppPools\Wsuspool -Name cpu -Value @{action = 'Throttle'}
Set-ItemProperty -Path IIS:\AppPools\Wsuspool -Name cpu -Value @{limit = 70000}
Set-ItemProperty -Path IIS:\AppPools\Wsuspool -Name cpu -Value @{resetInterval = "00:15:00"}
Set-ItemProperty -Path IIS:\AppPools\Wsuspool -Name processmodel.pingingEnabled -Value False
Set-ItemProperty -Path IIS:\AppPools\Wsuspool -name queueLength -Value 30000
Set-ItemProperty -Path IIS:\AppPools\Wsuspool -name failure.rapidFailProtection -Value False
Set-ItemProperty -Path IIS:\AppPools\WsusPool -Name failure.rapidFailProtectionInterval -Value '00:30:00'
Set-ItemProperty -Path IIS:\AppPools\WsusPool -Name failure.rapidFailProtectionMaxCrashes -value 60
Set-ItemProperty -Path IIS:\AppPools\WsusPool -Name Failure.loadBalancerCapabilities -Value 'TcpLevel'
Set-ItemProperty -Path IIS:\AppPools\Wsuspool -Name recycling.periodicRestart.time -Value '00:00:00'
Set-ItemProperty -Path IIS:\AppPools\Wsuspool -Name recycling.periodicRestart.requests -Value 0
Set-ItemProperty -Path IIS:\AppPools\Wsuspool -Name recycling.periodicRestart.privateMemory -Value 0