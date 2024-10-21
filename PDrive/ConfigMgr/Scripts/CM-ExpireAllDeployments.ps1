$ExpireTime = (Get-Date)
$Header = "CollectionID", "PackageID", "ProgramName"
$AdvertIds = Import-Csv -Path C:\temp\Dave.csv -Delimiter ',' -Header $Header 
 
ForEach ($AdvertId in $AdvertIds) { 

    $CollectionID = $AdvertId.CollectionID
    $PackageId = $AdvertId.PackageID
    $ProgramName = $AdvertId.ProgramName
 
    #Write-host $CollectionID $PackageID $ProgramName $ExpireTime
    Set-CMPackageDeployment -CollectionId "$CollectionID" -PackageId "$PackageID" -StandardProgramName "$ProgramName" -DeploymentExpireDateTime "$ExpireTime" -WhatIf
 }
 