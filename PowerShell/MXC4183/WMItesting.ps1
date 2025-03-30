$Site = Invoke-WmiMethod -Namespace Root\SMS\Site_MTL -ComputerName CM2012 -Path SMS_Identification -name GetSiteID
$Site.SiteID



$App = get-wmiobject -Namespace root\sms\site_wp1 -Class SMS_Application -Filter "localizeddisplayname = 'client'" -ComputerName louappwps1658
$DT = Get-WmiObject -Namespace root\sms\site_wp1 -Class sms_Deploymenttype -Filter "appmodelname = '$($App.modelname)'" -ComputerName louappwps1658

$DT

sms_deploymenttype appmodelname