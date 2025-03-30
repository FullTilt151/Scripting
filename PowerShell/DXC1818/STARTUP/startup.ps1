Get-Credential -UserName 
$username = 'humad\DXC1818a'
$password = Read-Host "Enter your password:"
cls
$Credential = New-Object System.Management.Automation.PSCredential -ArgumentList @($username,(ConvertTo-SecureString -String $password -AsPlainText -Force))

Start-Process powershell.exe -Credential $Credential -ArgumentList “Start-Process cmd.exe -Verb runAs" 
Start-Process powershell.exe -Credential $Credential -ArgumentList “Start-Process explorer.exe /separate"
Start-Process powershell.exe -Credential $Credential -ArgumentList “Start-Process 'C:\Program Files\Microsoft VS Code\Code.exe' -Verb runAs"
Start-Process powershell.exe -Credential $Credential -ArgumentList “Start-Process powershell_ise.exe -Verb runAs”