Get-Service SMS* | Stop-Service
Stop-Service CcmExec
Get-WmiObject win32_service | Where-Object {$_.StartMode -eq 'Auto' -and $_.State -ne 'Running'} | Start-Service