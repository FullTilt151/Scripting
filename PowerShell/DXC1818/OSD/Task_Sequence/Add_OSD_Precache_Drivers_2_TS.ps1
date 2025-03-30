Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" # Import the ConfigurationManager.psd1 module 
Set-Location "WP1:" # Set the current location to be the site code.

#$TSPkg = Get-CMTaskSequenceStep -TaskSequencePackageId WP10022E | Where-Object {$_.Name -like "Driver*"} | Select-Object -ExpandProperty PackageID | Sort-Object
#$Pkgs = Compare-Object -DifferenceObject $DrvPkg $TSPkg | Select-Object -ExpandProperty InputObject | Sort-Object
$DrvPkg = Get-CMPackage -Name "Drivers*" |
ForEach-Object {
    $step = New-CMTaskSequenceStepRunCommandLine -CommandLine 'cmd /c' -PackageId $($_.PackageID) -Name $($_.MIFName)
    Write-Host $_.MIFName -ForegroundColor Cyan
    Get-CMTaskSequence -TaskSequencePackageId WP10022E | Set-CMTaskSequenceGroup -StepName "Dynamic Driver Packages Win10" -AddStep $step
}