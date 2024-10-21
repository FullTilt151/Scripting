#https://devblogs.microsoft.com/scripting/use-powershell-to-create-zip-archive-of-folder/
$source = (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\CCM\Logging\@Global).LogDirectory
$source = "C:\temp\Software_Install_Logs"
$destination = "C:\Temp\Logs.zip"
If (Test-path $destination) { Remove-item $destination }
Add-Type -assembly "system.io.compression.filesystem"
# Add-Type -assembly "system.IO.Compression"
[io.compression.zipfile]::CreateFromDirectory($Source, $destination)
$mode = [io.Compression.ZipArchiveMode]::Update
$file = [IO.compression]::Open