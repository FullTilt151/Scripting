<#
.DESCRIPTION
   Deletes the deployment if currently set to a restricted target collection and is a Required advertisement
.EXAMPLE
   ProtectRestrictedCollectionsFromNewDeployments.ps1 %msgis01 %msgis02 %sc %sitesvr
#>
$UserID = $args[0]
$AdvertID = $args[1]
$SiteCode = $args[2]
$SiteServer = $args[3]

$arrRestrictedCollections = @("SMS00001", "CAS0000B", "CAS0000A")
$logpath = "F:\scripts" #added $logpath or static script location and log path location
$log = $true

#Create the Log file for writting later.
if ($log -eq $true) { $Logfile = "$logpath\ProtectRestrictedCollectionsFromNewDeployments.log"}

$advert = Get-WmiObject -ComputerName $SiteServer -Namespace "root\sms\site_$SiteCode" -class sms_advertisement -Filter "advertisementid = '$AdvertID'"
if (($advert.OfferType -eq 0) -and ($arrRestrictedCollections -contains $advert.CollectionID))
{
	$advertName = $advert.AdvertisementName
	if($log -eq $true)
	{
		WriteLog "*****************************************************************"
		WriteLog "Deployment Name:" $myname
		WriteLog "User ID:" $UserID
		WriteLog "*****************************************************************"
	}
	$advert.delete() | Out-Null
}


Function WriteLog{
   Param ([string]$string)
   Add-content $Logfile -value "$(Get-date -format G)  $string"
   [System.Threading.Thread]::Sleep(250)
}