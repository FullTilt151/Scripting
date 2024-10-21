$siteCode = (Get-CimInstance -Namespace root\SMS -ClassName SMS_ProviderLocation).SiteCode
$cimNameSpace = "Root\SMS\Site_$siteCode"
# Get currently deployed updates
Write-Output 'Getting list of currently deployed updates'
$deployedUpdates = Get-CimInstance -Namespace $cimNameSpace -ClassName SMS_SoftwareUpdate | Where-Object {$_.IsDeployed -eq $true}

Write-Output 'Loading WSUS assemply'
Try {
    [reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | out-null
}
Catch { 
    Add-TextToCMLog $LogFile "Failed to load the UpdateServices module." $component 3
    Add-TextToCMLog $LogFile "Please make sure that WSUS Admin Console is installed on this machine" $component 3
    Add-TextToCMLog $LogFile "Error: $($_.Exception.Message)" $component 3
    Add-TextToCMLog $LogFile "$($_.InvocationInfo.PositionMessage)" $component 3
}

$useSSL = $false
$Port = 8530
Write-Output 'Determining WSUS server'
$wsusServer = (Get-CimInstance -Namespace $cimNameSpace -query "SELECT * FROM SMS_SUPSyncStatus WHERE WSUSSourceServer = 'Microsoft Update'").WSUSServerName

Write-Output "WSUS Server is $wsusServer, now getting list of updates"
$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer($wsusServer, $useSSL, $Port);
$allUpdates = $wsus.GetUpdates()
$allUpdates