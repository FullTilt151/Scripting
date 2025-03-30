New-Item -Path C:\ -Name "Array_Conn" -ItemType Directory -Force
Remove-Item -Path "C:\Array_Conn\*" -Force -Recurse -Erroraction SilentlyContinue
Copy-Item Array_NLA.* -Destination C:\Array_Conn -Force
Unregister-ScheduledTask -TaskName "Array_NLA" -Confirm:$False
Register-ScheduledTask -Xml (Get-content 'C:\Array_Conn\Array_NLA.xml' | Out-string) -TaskName "Array_NLA"
