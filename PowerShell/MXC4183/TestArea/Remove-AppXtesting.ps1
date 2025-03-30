invoke-command -ComputerName WKMJ029CZB  -ScriptBlock {Get-AppxPackage -Name *hevc* -AllUsers | Remove-AppxPackage -AllUsers}

Invoke-Command -ComputerName WKPC0MTDFM -ScriptBlock{Get-AppxPackage -Name *hevc* -AllUsers | Remove-AppxPackage -AllUsers}

Get-Content C:\Temp\Servers.txt | ForEach-Object {Invoke-Command -ComputerName $_ -ScriptBlock{get-appxpackage -name Microsoft.HEVCVideoExtension -AllUsers | remove-appxpackage -AllUsers}	}  

Get-Content C:\Temp\Servers.txt | ForEach-Object {
	If (Test-Connection $_ -Quiet -Count 1){
	    Write-Host "$_" -ForegroundColor Green
	} Else {
	    Write-Host "$_" -ForegroundColor Red
	}
}  

Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStoreDeprovisioned\Microsoft.HEVCVideoExtension_8wekyb3d8bbwe'

get-appxpackage -allusers Microsoft.HEVCVideoExtension_1.0.31053.0_x64__8wekyb3d8bbwe | remove-appxpackage

get-appxpackage -name Microsoft.HEVCVideoExtension_1.0.31053.0_x64__8wekyb3d8bbwe

Get-AppxPackage -Publisher 8wekyb3d8bbwe

Get-AppxPackage -Name *hevc* -AllUsers

Get-AppxPackage -AllUsers -name '*hevc*'
Get-AppxProvisionedPackage -Online

get-appxpackage -name Microsoft.HEVCVideoExtension -AllUsers
get-appxpackage -name Microsoft.HEVCVideoExtension -AllUsers | remove-appxpackage -AllUsers

Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.BingWeather_8wekyb3d8bbwe'

HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\A ppxAllUserStore\Deprovisioned\Microsoft.BingWeather_8wekyb3d8bbwe

HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.BingWeather_8wekyb3d8bbwe


WKPC0Q7KEA
WKMJ05A3DC
WKMJ05H500
WKR90NSTW1