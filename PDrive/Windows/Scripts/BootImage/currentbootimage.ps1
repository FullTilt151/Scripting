# Set Bootimage Version
$bootimage = "LCD0000D"
$date = "10/16/2014"

# Test the directory
Test-Path C:\ProgramData\1e\PXELite\TftpRoot\Images\$bootimage
(Get-ItemProperty "C:\ProgramData\1e\PXELite\TftpRoot\Images\$bootimage\boot.$bootimage.wim").lastwritetime -match $date


# Test the registry
(Get-ItemProperty -path HKLM:\SOFTWARE\Wow6432Node\1e\PXELiteServer).AlwaysBootImageID -match $bootimage