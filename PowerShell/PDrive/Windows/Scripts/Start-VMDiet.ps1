# Remove temp files
Remove-Item C:\windows\Temp -Recurse -Force -ErrorAction SilentlyContinue

# Remove recycled files
#$Shell = New-Object -ComObject Shell.Application
#$RecycleBin = $Shell.Namespace(0xA)
#$RecycleBin.items() | ForEach-Object { Remove-Item $_.path -Recurse -Force }

# Remove .NET temp files
Remove-Item "C:\Windows\Microsoft.NET\Framework\v2.0.50727\Temporary ASP.NET Files" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\Microsoft.NET\Framework\v4.0.30319\Temporary ASP.NET Files" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\Microsoft.NET\Framework64\v2.0.50727\Temporary ASP.NET Files" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files" -Force -Recurse -ErrorAction SilentlyContinue

<# Compress directories
$CompressDirectories = 
"C:\Program Files\Sqllib\Tools\*.phd",
"C:\Windows\*.log",
"C:\Intervoice\Tomcat\logs",
"C:\Program Files\Microsoft SQL Server\100\Setup Bootstrap\Log",
"C:\Windows\Installer"

$CompressDirectories | 
ForEach-Object {
    c:\windows\system32\compact.exe /C /S:$_ /a /i /f
}

#>

Write-Output 'Complete'