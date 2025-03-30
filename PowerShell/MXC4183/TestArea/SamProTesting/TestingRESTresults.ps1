Param(
   [parameter(Mandatory=$True)][validateset('QA','PROD')]
   [string]$site
)

#pretty obvious what's going on here.

switch ($site) {
    'QA' { $uri = 'https://louappwqs1151.rsc.humad.com/AdminService/wmi/SMS_Collection?$filter=startswith(Name,''Reclaim |'') eq true'}
    'PROD' { $uri = 'https://louappwps1658.rsc.humad.com/AdminService/wmi/SMS_Collection?$filter=startswith(Name,''Reclaim |'') eq true'}   
 }

$resultArray = @();
$Collections = ((Invoke-RestMethod -Method 'Get' -Uri $uri -UseDefaultCredentials).value) #where({$_.ObjectPath -eq '/Software Reclamation'})
$Collections | ForEach-Object {
    $collectionInfo = @{};
    $collection = $_;
    $collection | Get-Member -MemberType Properties | Where-Object {$_.name -in ('CollectionID','Name','CollectionType')} | ForEach-Object {
        $key = $_.name;
        $collectionInfo.Add($key, $collection.$key);
    }
    $resultArray += $collectionInfo;
}
ConvertTo-Json $resultArray;

(Invoke-RestMethod -Method 'Get' -Uri $uri -UseDefaultCredentials).all
