#Add a reg key to a remove system.
Get-Content C:\Temp\Servers.txt | ForEach-Object {
$regFile = @"
 Windows Registry Editor Version 5.00

 [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.HEVCVideoExtension_8wekyb3d8bbwe]
"@

Invoke-Command -ComputerName $_ -ScriptBlock {param($regFile) $regFile | out-file $env:temp\a.reg; 
    reg.exe import $env:temp\a.reg } -ArgumentList $regFile
}