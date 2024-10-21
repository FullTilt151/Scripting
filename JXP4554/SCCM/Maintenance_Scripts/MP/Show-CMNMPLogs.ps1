$mpControlLog = (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\SMS\Tracing\SMS_MP_CONTROL_MANAGER -Name TraceFilename).TraceFilename
$mpFDMLog = (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\SMS\Tracing\SMS_MP_FILE_DISPATCH_MANAGER -Name TraceFilename).TraceFilename
$CcmLogDir = (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\CCM\Logging\@Global -Name LogDirectory).LogDirectory
$cmd = 'CMTrace.exe'
$params = ($mpControlLog, $mpFDMLog, "$CcmLogDir\MP_Relay.log", "C:\Windows\CCMSetup\Logs\CcmSetup.log", "$CcmLogDir\CcmRepair.log", "$CcmLogDir\CcmMessaging.log", "$CcmLogDir\CertificateMaintenance.log", "$CcmLogDir\PolicyAgent.log", "$CcmLogDir\CcmExec.log")
& $cmd $params