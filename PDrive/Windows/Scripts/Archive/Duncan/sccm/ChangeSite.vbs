Dim oSMSClient
Dim oUIResManager
Dim oUIResource
 

set oSMSClient = CreateObject ("Microsoft.SMS.Client")
set oUIResManager = createobject("UIResource.UIResourceMgr")
Set oUIResource = CreateObject("UIResource.UIResourceMgr")
Set objCacheInfo = oUIResource.GetCacheInfo
Set oCache=oUIResManager.GetCacheInfo()
 
if Err.Number <>0 then
wscript.echo "Could not create SMS Client Object - quitting"
end if
 
'Assign client to Servername
oSMSClient.SetAssignedSite "HUM",0
 
set oSMSClient=nothing
