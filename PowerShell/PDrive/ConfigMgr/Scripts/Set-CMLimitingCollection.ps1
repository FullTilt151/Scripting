param(
[ValidateScript({$_.Length -eq 8})] 
[Parameter(Mandatory=$True)]
[string]$OldLimitToCollectionID,
[ValidateScript({$_.Length -eq 8})] 
[Parameter(Mandatory=$True)]
[string]$NewLimitToCollectionID,
[Parameter(Mandatory=$True)]
[string]$SiteServer,
[Parameter(Mandatory=$True)]
[string]$SiteCode
)

Write-Verbose 'Gathering collection information...'
$oldcoll = Get-WmiObject -ComputerName $SiteServer -Namespace "root\sms\site_$SiteCode" -Class sms_collection -Filter "CollectionID = '$OldLimitToCollectionID'" -ErrorAction SilentlyContinue
$oldcollname = $oldcoll.Name
Write-Output "Old Collection: $OldLimitToCollectionID - $oldcollname"
$newcoll = Get-WmiObject -ComputerName $SiteServer -Namespace "root\sms\site_$SiteCode" -Class sms_collection -Filter "CollectionID = '$NewLimitToCollectionID'" -ErrorAction SilentlyContinue
$newcollname = $newcoll.Name
Write-Output "New Collection: $newLimitToCollectionID - $newcollname"

if ($oldcoll -eq $null -or $newcoll -eq $null) {
    Write-Error 'Collection does not exist!'
    exit
}

Write-Verbose 'Gathering list of collections...'
$colls = Get-WmiObject -ComputerName $SiteServer -Namespace "root\sms\site_$SiteCode" -Class sms_collection -Filter "LimitToCollectionID = '$OldLimitToCollectionID'" -ErrorAction SilentlyContinue
$collcount = $colls.Count

if ($colls -ne $null) {
    write-verbose "There are $collcount collections..."
    $colls | ft CollectionID, Name, LimitToCollectionID, LimittoCollectionName -AutoSize

    Write-Verbose 'Gathering current location...'
    Push-Location

    write-Verbose 'Importing ConfigMgr module and setting location...'
    Import-Module ($env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')
    Set-Location "$($SiteCode):"

    Write-Verbose "Setting new Limiting Collection to $NewLimitToCollectionID - $newcollname..."
    $colls | % {Set-CMDeviceCollection -Name $_.Name -LimitingCollectionId $NewLimitToCollectionID}

    Write-Verbose 'Resetting original location...'
    Pop-Location
} elseif ($colls -eq $null) {
    Write-Verbose "There are no collections limited to $OldLimitToCollectionID - $oldcollname!"
}