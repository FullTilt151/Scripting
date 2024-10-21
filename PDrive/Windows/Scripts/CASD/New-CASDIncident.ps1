param(
$CreatorUserID,
$CustomerUserID,
$Summary,
$Group,
$Category,
$Worklog
)

# TEST Web http://louappwts1269.rsc.humad.com/CAisd/pdmweb.exe
# TEST WSDL http://louappwts1269.rsc.humad.com:8080/axis/services/USD_R11_WebService?wsdl
# PROD WSDL http://louappwpl121s03.rsc.humad.com:8080/axis/services/USD_R11_WebService?wsdl

#location of wsdl
$svc = New-WebServiceProxy -Uri 'http://louappwts1269:8080/axis/services/USD_R11_WebService?wsdl'

#login
$UserName = "casdsvcacct"
$Password = "P#6rxD16t6"
$sid = $svc.login($UserName,$Password)

#create incident
$attrVals = {"summary", "A new incident", "description", "new incident", "type", "crt:182", "catagory", "pcat:40002"}
#USPSD.createRequest(SID, creatorHandle, attrVals, template, new String[0], new String[0])
#incident 5415217

#get customer handle
$customerHandle = $svc.getHandleForuserID($sid,$CustomerUserID)

#get creator handle
$creatorHandle = $svc.getHandleForuserID($sid,$CreatorUserID)

#Get variables ready
$prop = ""
$attr = "persistent_id"
$requestHandle = ""
$requestNumber = ""

#get group handle
[xml]$groupHandleReturn = $svc.doSelect($sid,"grp","last_name='$Group'",1,"persistent_id")
$groupHandle=$groupHandleReturn.UDSObjectList.UDSObject.Handle

#get category handle
[xml]$categoryHandleReturn = $svc.doSelect($sid,"pcat","sym='$Category'",1,"persistent_id")
$categoryHandle=$categoryHandleReturn.UDSObjectList.UDSObject.Handle

#Attribute to set (key,value) array
$attrVal = "customer", $customerHandle, "type","I","summary",$summary,"description",$Worklog,"group",$groupHandle,"category",$categoryHandle,"urgency",1,"impact",0,"priority","1"

#Create incident
[xml]$newRequestHandle = $svc.createRequest($sid,$creatorHandle,$attrVal,$prop,"","id",[ref]$requestHandle, [ref]$requestNumber)

$svc.logout($sid)