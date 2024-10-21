<#
Get folder info from CM.Test.
1st, connect to site, WQ1 in the example below, then use wmi built into ps1
#>
Get-ChildItem WQ1:\ | Select-Object -property Name,ContainerNodeID,ObjectType 

Get-ChildItem WQ1:\package | Select-Object -property Name,ContainerNodeID,ObjectType

Get-ChildItem WQ1:\package\Prod | Select-Object -property Name,ContainerNodeID,ObjectType | Where-Object {$_.Manufacturer -eq $PackageInfo.Manufacturer}

Test-Path -Path "$site $PackageInfo.ObjectPath
$Ppath = $PackageInfo.ObjectPath

$FolderPath = $Site + ":\Package\Prod\" + $PackageInfo.Manufacturer + "\" + $PackageInfo.Name

$folderPathTest = $Site + ":\Package\Prod\ThisIsAFakeFOlder"