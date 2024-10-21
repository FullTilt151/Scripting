Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" # Import the ConfigurationManager.psd1 module 
Set-Location "WP1:" # Set the current location to be the site code.

Get-CMPackage -Name "Lenovo*Win10x64" |
ForEach-Object {
    $step = New-CMTaskSequenceStepRunCommandLine -CommandLine 'cmd /c' -PackageId $($_.PackageID) -Name $($_.Name)
    Get-CMTaskSequence -TaskSequencePackageId WP10023A | Add-CMTaskSequenceStep -Step $step
}