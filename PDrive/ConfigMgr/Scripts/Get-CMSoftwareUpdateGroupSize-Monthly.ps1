$SiteServer = 'LOUAPPWPS1658'
$SiteCode = 'WP1'

Import-Module "$env:SMS_ADMIN_UI_PATH\..\ConfigurationManager.psd1"
Set-Location "$($Sitecode):"

$UpdateInfo = @()
$Categories = 'Silverlight','Office 2010','Office 2013','Office 2007','Office 2016','Windows 7'

$StartDay = (Get-Date -Month 9 -day 1 -Hour 0 -Minute 0 -Second 0)
$EndDay = (Get-Date -Month 9 -day 1 -Hour 0 -Minute 0 -Second 0).AddMonths(1).addseconds(-1)
Get-CMSoftwareUpdate -IsDeployed $true -IsContentProvisioned $true -Fast -DatePostedMin $StartDay -DatePostedMax $EndDay -CategoryName $Categories |
ForEach-Object {

    $CIToContent = Get-WmiObject -ComputerName $SiteServer -Namespace root\sms\site_$($SiteCode) -Query "Select * from SMS_CItoContent where CI_ID = '$($_.CI_ID)'"
        
    $TotalUpdateSize = 0
    $TotalContentRefs = 0
    $TotalFiles = 0
    foreach ($ContentRef in $CIToContent)  {
        $CIContentFiles = @(Get-WmiObject -ComputerName $SiteServer -Namespace root\sms\site_$($SiteCode) -Query "select * from SMS_CIContentFiles where ContentID = '$($ContentRef.ContentID)'")
        $UpdateSize = 0
        foreach ($file in $CIContentFiles) {
            $UpdateSize += $file.filesize
            $TotalFiles += 1
        }
        $TotalUpdateSize += $UpdateSize
        $TotalContentRefs += 1
    }
    $obj = New-Object pscustomobject -Property @{
            DatePosted = $_.DatePosted
            DateRevised = $_.DateRevised
            Name = $_.LocalizedDisplayName
            Size = "{0:N2}" -f ($TotalUpdateSize / 1MB)
            TotalContentRefs = $TotalContentRefs
            TotalFiles = $TotalFiles
    }
    $UpdateInfo += $obj
    $cnt += 1
}

Write-Output "Total size: $(($UpdateInfo.Size | Measure-Object -Sum).Sum)"
$UpdateInfo | Format-Table -AutoSize