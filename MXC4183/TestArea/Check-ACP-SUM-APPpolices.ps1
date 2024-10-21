$computer = $env:COMPUTERNAME
$namespace = "ROOT\ccm\Policy\Machine\ActualConfig"
$classname = "CCM_ComponentClientConfig"
$ACPQuery = "SELECT * FROM CCM_DownloadProvider WHERE LogicalName='NomadBranch'"
$SUMquery = "SELECT * FROM CCM_SoftwareUpdatesClientConfig WHERE SiteSettingsKey=1"
$Appquery = "SELECT * FROM CCM_ApplicationManagementClientConfig WHERE SiteSettingsKey=1"


write-host "ACP Policy: " -NoNewline

if( (Get-WmiObject -ComputerName $computer -Namespace $namespace -Query $ACPQuery | Measure-Object).Count -eq 1 ){
    Write-Host "Nomad Enabled" -ForegroundColor Green
} else {
    Write-Host "Nomad not found!" -ForegroundColor Red
}

write-host "SUM Policy: " -NoNewline
if( ([string](Get-WmiObject -ComputerName $computer -Namespace $namespace -Query $SUMquery).Reserved1) -match "NomadBranch" ){
    Write-Host "Nomad Enabled" -ForegroundColor Green
} else {
    Write-Host "Nomad not found!" -ForegroundColor Red
}

Write-Host "APP Policy: " -NoNewline
if([string]((Get-WmiObject -ComputerName $computer -Namespace $namespace -Query $Appquery).Reserved1) -match "nomadBranch" ){
    Write-Host "Nomad Enabled" -ForegroundColor Green
} else {
    Write-Host "Nomad not found!" -ForegroundColor Red
}
