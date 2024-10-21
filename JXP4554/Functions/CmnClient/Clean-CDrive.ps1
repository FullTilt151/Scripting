Write-Output "The targeted machine $($env:COMPUTERNAME) will begin to be processed."
Write-Output 'Patch cache and temporary files will be removed.'
Write-Output 'Update installers will be compressed.'
Write-Output 'Deleting Temporary Files'
Get-ChildItem -Path "$env:windir\Temp" | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue | Out-Null
$directories = Get-ChildItem -Path C:\Users -Directory 
foreach ($directory in $directories) {
	if(Test-Path "$($directory.FullName)\AppData\Local\Temp\") {
		Write-Output "Removing $($directory.FullName)\AppData\Local\Temp\"
		Remove-Item -Path "$($directory.FullName)\AppData\Local\Temp\" -Force -Recurse -ErrorAction SilentlyContinue
	}
}

Write-Output 'Clearing Recylce Bin'
Remove-Item -Path 'C:\RECYCLER\' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path 'C:\Windows\Microsoft.NET\Framework\v2.0.50727\Temporary ASP.NET Files\*.*' -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\Temporary ASP.NET Files\*.*' -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path 'C:\Windows\Microsoft.NET\Framework64\v2.0.50727\Temporary ASP.NET Files\*.*' -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files\*.*' -Recurse -ErrorAction SilentlyContinue

Write-Output 'Compressing Installer Directories'

Get-ChildItem -Path $env:windir -Filter '*.log' | compact /c /a /i /f $_.FullName | Out-Null
if(Test-Path 'C:\Program Files\Sqllib\Tools\'){Get-ChildItem -Path 'C:\Program Files\Sqllib\Tools\' -Filter '*.phd' | compact /c /a /i/ f $_.FullName | Out-Null}
$dirs = ('C:\Intervoice\Tomcat\logs','C:\Program Files\Microsoft SQL Server\100\Setup Bootstrap\Log','C:\Windows\Installer')
foreach($dir in $dirs){
	if(Test-Path $dir){
		Write-Output "Compressing $dir"
		Get-ChildItem -Path $dir | compact /c /a /i /f $_.FullName | Out-Null
	}
}