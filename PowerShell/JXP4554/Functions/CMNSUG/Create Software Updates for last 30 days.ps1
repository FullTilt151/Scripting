Write-Host 'Importing ConfigMGR Module'
$PowerShellPath = "\\LOUAPPWTS872\f$\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1"            
$CMSiteCode = "TST"            
             
#This is what connects you to the Powershell cmdlets                                               
Import-Module $PowerShellPath            
set-location "${CMSiteCode}:"
Write-Host 'Setting Query Limit' 
Set-CMQueryResultMaximum 100000
$Now = Get-Date
Write-Host "Populating Updates $Now"

#$Updates = Get-CMSoftwareUpdate | Where-Object {$_.DatePosted -ge (Get-Date).AddDays(-30)}
$Updates = Get-CMSoftwareUpdate 

Foreach ($Updte in $Updates) {
    #$SUG = $Updte.
    #$Updte.LocalizedDisplayName + ' ' + $Updte.ArticleID + " - " + $Updte.BulletinID
    $Updte.CI_ID.ToString() + ' ' + $Updte.ArticleID + ' ' + $Updte.LocalizedCategoryInstanceNames
}