<# 
SELECT distinct csp.Vendor0 [Vendor], csp.Version0 [Model_Name], csp.Name0 [Model_Number]
FROM            v_R_System_valid sys INNER JOIN
                v_GS_COMPUTER_SYSTEM_PRODUCT csp ON sys.ResourceID = csp.ResourceID
Where Vendor0 = 'LENOVO'
and csp.Version0 != 'Lenovo Product'
ORDER BY Model_Name, Model_Number
 #>

$baseFileDir = 'C:\Temp\'
$catalogURL = 'https://download.lenovo.com/luc/LenovoUpdatesCatalog2.cab'
$customCatalogURL = 'https://download.lenovo.com/luc/LenovoCustomPackageData.cab'
$catalogCabFile = "$($baseFileDir)LenovoUpdatesCatalog2.cab"
$customCatalogCabFile = "$($baseFileDir)LenovoCustomPackageData.cab"
$finalCabFile = 'D:\Source\Lenovo\Lenovo.cab'
$catalogXMLFile = "$($baseFileDir)LenovoUpdatesCatalog2.xml"
$customCatalogXMLFile = "$($baseFileDir)LenovoCustomPackageData.xml"
$finalXMLFile = "$($baseFileDir)Lenovo.xml"
Invoke-WebRequest -Uri $catalogURL -OutFile $catalogCabFile
Invoke-WebRequest -Uri $customCatalogURL -OutFile $customCatalogCabFile
$cmd = 'C:\Windows\System32\extrac32.exe'
$args = @("/y",$catalogCabFile,$catalogXMLFile)
& $cmd $args
$args = @("/y",$customCatalogCabFile,$customCatalogXMLFile)
& $cmd $args
Start-Sleep -Seconds 5
[xml]$catalogXML = Get-Content -Path $catalogXMLFile
[xml]$customXML = Get-Content -Path $customCatalogXMLFile
foreach($customNode in $customXML.CustomPackageData.Package)
{
    $node = $catalogXML.SystemsManagementCatalog.SoftwareDistributionPackage | Where-Object {$_.Properties.PackageID -eq "$($customNode.PackageID)"}
    $description = $customNode.Custom.'#text' -replace 'ThinkPad ','TP' -replace 'ThinkCenter','TC' -replace 'ThinkStation','TS' -replace 'Yoga', 'YG' -replace 'Twist','TW' -replace 'Carbon','CBN' -replace ', ',','
    if($description.Length -gt 1500)
    {
        Write-Host -ForegroundColor DarkCyan "`tDescription too long, truncating"
        $description = $description.Substring(0,1500)
    }
    $node.LocalizedProperties.Description = $description
    #$node.Properties.ProductName = $description
    Write-Output "Updating $($node.Properties.PackageID) with Products $description"
}
#Sleep -Seconds 5
$catalogXML.Save($finalXMLFile)
$cmd = 'C:\Windows\System32\makecab.exe'
$args = @($finalXMLFile, $finalCabFile)
& $cmd $args
Remove-Item -Path $catalogCabFile -Force
Remove-Item -Path $catalogXMLFile -Force
Remove-Item -Path $customCatalogCabFile -Force
Remove-Item -Path $customCatalogXMLFile -Force
Remove-Item -Path $finalXMLFile -Force