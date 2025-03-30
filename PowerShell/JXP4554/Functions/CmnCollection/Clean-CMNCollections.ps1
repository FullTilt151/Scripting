#Get Collections
$start = Get-Date -Format g
$start
$updateDays = 365
$csvFile = "C:\Temp\OldCollections_$updateDays.csv"
$src = Get-CMNSCCMConnectionInfo -siteServer LOUAPPWPS1658
$CIMQueryParameters = $src.WMIQueryParameters
Write-Host 'Getting Collections'
$collections = Get-CimInstance -ClassName SMS_Collection @CIMQueryParameters | Where-Object {(New-TimeSpan -Start $_.LastMemberChangeTime -End (Get-Date)).Days -gt $updateDays}
Write-Host 'Done! Now to check for deployments...'
#$deployments = Get-CimInstance -ClassName SMS_Advertisement @CIMQueryParameters | Where-Object {(New-TimeSpan -Start $_.PresentTime -End (Get-Date)).Days -le $updateDays}
$returnHashTable = @()

#Cycle through the collections
$collectionCount = 0
foreach ($collection in $collections) {
    Write-Progress -Activity 'Parsing Collections' -PercentComplete ($collectionCount / $collections.Count * 100) -Status "Processing $collectionCount of $($collections.Count)"
    $collectionCount++
    $isOld = $true
    if ($collection.Name -match '^All.*Limiting Collection' -or $collection.Name -match '^All.*Security Collection') {
        Write-Output "Skipping $($collection.Name)"
    }
    else {
        $query = "Select * from SMS_Advertisement where CollectionID='$($collection.CollectionID)'"
        try {
            $deployments = Get-CimInstance -Query $query @CIMQueryParameters -ErrorAction SilentlyContinue
        }
        catch {
            $deployments = New-Object -TypeName PSObject -Property @{
                'AdvertisementID'       = 'None';
                'AdvertisementName'     = 'None';
                'PresentTime'           = 'N/A';
                'ExpirationTime'        = 'N/A';
                'ExpirationTimeEnabled' = 'N/A';
            }
        }
        foreach ($deployment in $deployments) {
            if ((New-TimeSpan -start $deployment.PresentTime -End (Get-Date)).Days -le $updateDays) {
                $isOld = $false
            }
        
        }
        if ($isOld) {
            foreach ($deployment in $deployments) {
                $package = Get-CimInstance -ClassName SMS_Package -Filter "PackageID = '$($deployment.PackageID)'" @CIMQueryParameters
                $results = New-Object -TypeName PSObject -Property @{
                    'CollectionID'          = $collection.CollectionID;
                    'CollectionName'        = $collection.Name;
                    'CollectionType'        = $(
                        if ($collection.CollectionType -eq 1) {'User'} 
                        elseif ($collection.CollectionType -eq 2) {'Device'}
                        else {'UnKnown'});
                    'CollectionPath'        = $collection.ObjectPath;
                    'LastChangeTime'        = $collection.LastChangeTime;
                    'DeploymentID'          = $deployment.AdvertisementID;
                    'DeploymentName'        = $deployment.AdvertisementName;
                    'PresentTime'           = $deployment.PresentTime;
                    'ExpirationTime'        = $deployment.ExpirationTime;
                    'ExpirationTimeEnabled' = $deployment.ExpirationTimeEnabled;
                    'PackageID'             = $package.PackageID;
                    'PackageName'           = $package.Name;
                    'LastRefreshTime'       = $package.LastRefreshTime;
                    'PackagePath'           = $package.ObjectPath;
                }
                $returnHashTable += [Array]$results
            }
        }
    }
}
Write-Progress -Activity 'Parsing Collections' -Completed
$returnHashTable | Export-Csv -Path $csvFile -NoClobber -NoTypeInformation -Force
$returnHashTable.Count
$finish = Get-Date -Format g
Write-Output "Started $start and finished $finish"