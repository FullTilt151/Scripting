Get-ChildItem 'c:\windows\ccm' -Recurse -Include mof,mfl

Get-ChildItem C:\windows\CCM\* -Include *.mof,*.mlf -Recurse |
ForEach-Object {
    & mofcomp $_.FullName
}

Invoke-WmiMethod -Path ROOT\ccm:SMS_Client -Name RepairClient
Restart-Service CcmExec