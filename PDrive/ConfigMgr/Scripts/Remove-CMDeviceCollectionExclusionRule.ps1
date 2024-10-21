param(
[ValidateScript({$_.Length -eq 8})] 
[Parameter(Mandatory=$True)]
$ExcludeCollectionID
)

$colls = Get-Content C:\temp\colls.txt
$collscount = $colls.Count
Write-Output "Found [$collscount] collections"

$colls | % {
    $coll = Get-CMDeviceCollection -CollectionId $psitem
    $collname = $coll.Name
    Write-Output "Removing exclusion from [$collname]..."
    Remove-CMDeviceCollectionExcludeMembershipRule -CollectionId $coll.CollectionID -ExcludeCollectionId $ExcludeCollectionID -Force
}