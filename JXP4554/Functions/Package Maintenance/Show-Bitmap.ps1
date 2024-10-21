$TestDeployment = Get-WmiObject -ComputerName LOUAPPWPS875 -Namespace root/sms/site_cas -Class SMS_Advertisement -Filter "AdvertisementID = 'CAS233AA'"
$TestPackage = Get-WmiObject -ComputerName LOUAPPWPS875 -Namespace root/sms/site_cas -Class SMS_Package -Filter "PackageID = 'CAS00B62'"
$BitMap = ''
for ($i=31;$i -ge 0;$i--)
{
    if($TestDeployment.RemoteClientFlags -band ([math]::pow(2,$i)))
    {$BitMap = $BitMap +'1'}
    else
    {$BitMap =$BitMap +'0'}

}
Write-Host $BitMap

$BitMap = ''
for ($i=31;$i -ge 0;$i--)
{
    if($TestPackage.PkgFlags -band ([math]::pow(2,$i)))
    {$BitMap = $BitMap +'1'}
    else
    {$BitMap =$BitMap +'0'}

}
Write-Host $BitMap