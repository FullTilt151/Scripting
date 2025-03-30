<#
SMS_PackageContentServerInfo PackageType
0 - Regular software distribution package.
3 - Driver package.
4 - Task sequence package.
5 - Software update package.
6 - Content package.
8 - Device setting package.
257 - Image package.
258 - Boot image package.
259 - Operating system install package.
512 - Application package.
#>

$SiteServer = 'LOUAPPWPS875'
$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

$WMIQueryParameters = @{
    ComputerName = $SiteServer
    Namespace = "root\sms\site_$SiteCode"
}

$RegularPackage = Get-WmiObject -Class SMS_PackageContentServerInfo -Filter 'PackageType = 0' @WMIQueryParameters
$DriverPackage = Get-WmiObject -Class SMS_PackageContentServerInfo -Filter 'PackageType = 3' @WMIQueryParameters
$TSPackage = Get-WmiObject -Class SMS_PackageContentServerInfo -Filter 'PackageType = 4' @WMIQueryParameters
$SUGPackage = Get-WmiObject -Class SMS_PackageContentServerInfo -Filter 'PackageType = 5' @WMIQueryParameters
$ContentPackage = Get-WmiObject -Class SMS_PackageContentServerInfo -Filter 'PackageType = 6' @WMIQueryParameters
$DevicePackage = Get-WmiObject -Class SMS_PackageContentServerInfo -Filter 'PackageType = 8' @WMIQueryParameters
$ImagePackage = Get-WmiObject -Class SMS_PackageContentServerInfo -Filter 'PackageType = 257' @WMIQueryParameters
$BootImagePackage = Get-WmiObject -Class SMS_PackageContentServerInfo -Filter 'PackageType = 258' @WMIQueryParameters
$OSInstallPackage = Get-WmiObject -Class SMS_PackageContentServerInfo -Filter 'PackageType = 259' @WMIQueryParameters
$AppPackage = Get-WmiObject -Class SMS_PackageContentServerInfo -Filter 'PackageType = 512' @WMIQueryParameters

#Get Package Deployment Types
#First, get the application object
$Application = Get-WmiObject -Class SMS_Application -Filter "CI_ID = '103112'" @WMIQueryParameters
#Strip off the last /??? from the CI_UniqueID
$AppModelName =  $Application.CI_UniqueID -replace '(.*)/.*$','$1'
#Get DeploymentType Information.
$DeploymentType = Get-WmiObject -Class SMS_DeploymentType -Filter "AppModelName = '$AppModelName'" @WMIQueryParameters
#Get DPContent information
$DPContentInfo = Get-WmiObject -Class SMS_DPContentInfo -Filter "ObjectID = '$AppModelName'" @WMIQueryParameters
#Get DPGroup information
$DPGroup = Get-WmiObject -Class SMS_DPGroupPackages -Filter "PkgID ='$($DPContentInfo[$DPContentInfo.Count - 1].PackageID)'" @WMIQueryParameters