$reportserver = "LOUSRSWPS18:8081";
$newDataSourcePath = "/Data Sources/SCCM"
$newDataSourceName = "SCCM";
$reportFolderPath = "/ConfigMgr_WP1/CIS Reports"

$url = "http://$($reportserver)/reportserver/reportservice2005.asmx?WSDL"
#------------------------------------------------------------------------

$ssrs = New-WebServiceProxy -uri $url -UseDefaultCredential

$reports = $ssrs.ListChildren($reportFolderPath, $false)

$reports |
ForEach-Object {
    $reportPath = $_.path
    Write-Host "Report: " $reportPath
    $dataSources = $ssrs.GetItemDataSources($reportPath)
    $dataSources | ForEach-Object {
                    $proxyNamespace = $_.GetType().Namespace
                    $myDataSource = New-Object ("$proxyNamespace.DataSource")
                    $myDataSource.Name = $newDataSourceName
                    $myDataSource.Item = New-Object ("$proxyNamespace.DataSourceReference")
                    $myDataSource.Item.Reference = $newDataSourcePath

                    $_.item = $myDataSource.Item

                    $ssrs.SetItemDataSources($reportPath, $_)

                    Write-Host "Report's DataSource Reference ($($_.Name)): $($_.Item.Reference)"
                    }

    Write-Output "------------------------" 
}