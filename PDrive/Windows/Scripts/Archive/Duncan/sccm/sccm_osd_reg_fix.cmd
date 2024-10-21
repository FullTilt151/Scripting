REG ADD HKLM\SOFTWARE\Wow6432Node\Microsoft\CCM\CcmExec /v ProvisioningMode /t REG_SZ /d false /f
REG ADD HKLM\SOFTWARE\Wow6432Node\Microsoft\CCM\CcmExec /v SystemTaskExcludes /t REG_SZ /d "" /f
shutdown /r /f /t 00
