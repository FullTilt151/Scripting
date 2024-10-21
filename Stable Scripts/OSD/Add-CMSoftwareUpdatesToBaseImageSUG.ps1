$siteserver = 'CMWPPSS.humad.com'
$sitecode = 'WP1'

Import-Module "$env:SMS_ADMIN_UI_PATH\..\ConfigurationManager.psd1"
Push-Location "$($sitecode):"

$SiteServerName = Resolve-DnsName -Name $siteserver -Type CName | Select-Object -ExpandProperty Server

$NumPresent = 5000
$Products = "'Windows 10','Windows 10`, version 1903 and later','Silverlight','Microsoft Edge'"

$UpdateInfo = Get-CimInstance -ComputerName $SiteServerName -Namespace root\sms\site_$sitecode -Class sms_softwareupdate -Filter `
"NumPresent > $NumPresent and LocalizedCategoryInstanceNames in ($Products) and NumMissing > 15" -Property ArticleID, LocalizedDisplayName, NumPresent, NumMissing, LocalizedCategoryInstanceNames, IsSuperseded

$UpdateInfo | Where-Object {$_.LocalizedDisplayName -notin $SUGWinOSBase -and $_.LocalizedDisplayName -notin $SUG2XReboots -and $_.LocalizedDisplayName -notin $ExcludedUpdates} |
ForEach-Object {
    Write-Output "Adding $($_.LocalizedDisplayName)"
    Add-CMSoftwareUpdateToGroup -SoftwareUpdateGroupName "Windows 10 - Base Image" -SoftwareUpdateName $_.LocalizedDisplayName
}

$OfficeProducts = "'Office 365 Client','Office 2016','Office 2013'"

$OfficeUpdateInfo = Get-CimInstance -ComputerName $SiteServerName -Namespace root\sms\site_$sitecode -Class sms_softwareupdate -Filter `
"LocalizedCategoryInstanceNames in ($OfficeProducts)" -Property ArticleID, LocalizedDisplayName, NumPresent, NumMissing, LocalizedCategoryInstanceNames, IsSuperseded

$OfficeUpdateInfo | Where-Object {$_.LocalizedDisplayName -notin $SUGWinOSBase -and $_.LocalizedDisplayName -notin $SUG2XReboots -and $_.LocalizedDisplayName -notin $ExcludedUpdates} |
ForEach-Object {
    Write-Output "Adding $($_.LocalizedDisplayName)"
    Add-CMSoftwareUpdateToGroup -SoftwareUpdateGroupName "Windows 10 - Base Image" -SoftwareUpdateName $_.LocalizedDisplayName
}

Pop-Location