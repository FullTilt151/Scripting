$AppTest = Get-CMApplication -name 'Orca 5.0.7693' | Select-Object LocalizedDisplayName,SoftwareVersion,NumberOfDeployments,SourceSite,PackageID,modelname,ModelID,Manufacturer,CI_ID,CI_UniqueID,SmsProviderObjectPath

$zip = $AppTest.LocalizedDisplayName
$path = "\\lounaswps08\pdrive\workarea\mxc4183\CMApplicationExports\Orca.zip"

Export-CMApplication -Name $AppTest.LocalizedDisplayName


$AppTest.packageID

Get-CMApplication -name 'Orca 5.0.7693' | Select-Object LocalizedDisplayName,SoftwareVersion,NumberOfDeployments,SourceSite,PackageID,Modelname,ModelID,Manufacturer,CI_ID,CI_UniqueID,SmsProviderObjectPath | out-file c:\temp\orca.txt

$deployment = Get-CMDeploymentType -DeploymentTypeName "Install Orca 5.0" -ApplicationName "Orca 5.0.7693"
$deployment.ContentId

# This worked 11/22. Going to remove via ps1 and retry
Import-CMApplication -filepath $path

# Remove the app
$Nukeit = Get-CMApplication -name 'Orca 5.0.7693' | Select-Object Modelname
Remove-CMApplication -ModelName $Nukeit

Remove-CMApplication -ModelName "ScopeId_C6945AA2-B8DC-4570-B6EC-4346E5F9E8B1/Application_41a42bb8-d0b9-4c43-b046-faa86b906640"

Get-CMApplication -name 'Orca 5.0.7693' | Select-Object LocalizedDisplayName,SoftwareVersion,NumberOfDeployments,SourceSite,PackageID,ModelName,ModelID,Manufacturer,CI_ID,CI_UniqueID,SmsProviderObjectPath | out-file c:\temp\orcaQA.txt #Export-CSV c:\temp\orca.csv  #out-file c:\temp\orca.txt

Get-CMApplication | Select-Object LocalizedDisplayName,SoftwareVersion,NumberOfDeployments,SourceSite,PackageID,ModelName,ModelID,Manufacturer,CI_ID,CI_UniqueID,SmsProviderObjectPath |  Export-CSV c:\temp\orca.csv  #out-file c:\temp\orca.txt


Get-CMApplication -name 'bginfo' | Select-Object  LocalizedDisplayName,SoftwareVersion,packageID,CI_ID,CI_UniqueID,SmsProviderObjectPath

Get-CMApplication -name 'orca*' | Select-Object  LocalizedDisplayName,SoftwareVersion,packageID,CI_ID,CI_UniqueID,SmsProviderObjectPath

Get-CMApplication -name 'orca*' | out-file c:\temp\orca.txt

Get-CMApplication | Select-Object LocalizedDisplayName,SoftwareVersion,NumberOfDeployments

$deployment = Get-CMDeploymentType -DeploymentTypeName "Install Orca 5.0" -ApplicationName "Orca 5.0.7693"
$deployment.ContentId

# After trying the -import action above:  WARNING: The library object 'SMS_CategoryInstance.CategoryInstance_UniqueID='AppCategories:fdc6015c-421e-46b8-ab00-c43c2f24570c'' cannot be imported because it already exists.



$app = 'groovy'
Get-CMApplication -name 'NomadBranch x64'| out-file c:\temp\nomad.txt

$path = "\\lounaswps08\PDRIVE\workarea\mxc4183\CMApplicationExports\Nomad.zip"
$zip = "$AppName.zip"

$path+'\'$zip

# This worked. 11/22. Going to delete from WQ1 and retry.
Export-CMApplication -name 'NomadBranch x64' -Path $path -IgnoreRelated -OmitContent -Comment "Mike's test export. Added -IgnoreRelated -OmitContent"
Import-CMApplication -filepath "\\lounaswps08\PDRIVE\workarea\mxc4183\CMApplicationExports\node.zip" -ImportActionType Overwrite



Get-CMApplication | Select-Object LocalizedDisplayName | Format-Table -AutoSize | Export-Csv -Path "C:\temp\apps.csv" -Delimiter ';' -NoTypeInformation

Get-CMApplication | Where-Object {$_.IsExpired -eq "$True"}