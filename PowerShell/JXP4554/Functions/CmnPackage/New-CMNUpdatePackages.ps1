<#
https://support.microsoft.com/en-us/help/934307
.exe switches /q /norestart /uninstall /log
WUSA switches /quiet /uninstall /norestart /log

#>

$siteServer = 'LOUAPPWTS1140'
$SiteServerConnectionInfo = Get-CMNSCCMConnectionInfo -siteServer $siteServer
$KBPath = '\\lounaswps01\pdrive\NWS_Patch-Management\EST - Specialty'
$KBPath = '\\lounaswps01\pdrive\NWS_Patch-Management\EST - Specialty\April SUVP\Rel 17-05 .Net Monthly Rollup'
$basePackageURL = 'C:\Temp\UpdatePackages'
$files = Get-ChildItem -Path $KBPath
#Create Package Folders below $basePackageURL. Give it the name of the file
foreach($file in $files)
{
    $folderName = "$basePackageURL\$($file.BaseName)"
    if(-not(Test-Path $folderName)){New-Item -Path $basePackageURL -Name $file.BaseName -ItemType Directory | Out-Null}
    Copy-Item -Path $file.FullName -Destination $folderName
    #Create Package
    #Create Install Program
}