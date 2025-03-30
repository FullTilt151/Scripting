$updateServer = 'LOUAPPWPS1742.rsc.humad.com'
$useSSL = $true
$port = 8531
[reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | out-null
$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer($updateServer, $useSSL, $port);
$categories = $wsus.GetUpdateCategories()
$classifications = $wsus.GetUpdateClassifications()
Export-Clixml -InputObject $categories -Path c:\temp\WSUSCategories.xml
Export-Clixml -InputObject $classifications -Path c:\temp\WSUSClassifications.xml
