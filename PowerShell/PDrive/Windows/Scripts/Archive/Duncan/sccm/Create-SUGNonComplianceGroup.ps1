# ==============================================================================================
# 
# Microsoft PowerShell Source File -- Created with SAPIEN Technologies PrimalScript 2011
# 
# NAME: 
# 
# AUTHOR: Duncan Russell , SysAdminTechNotes.com
# DATE  : 2/20/2014
# 
# COMMENT: 
# 
# ==============================================================================================

#On SUG creation:
# 1. pass CI_ID of SUG, use to look up SUG NAME (LocalizedDisplayName)
# 2. Create Basic Collection  Name= "[CI_ID] Non-Compliant workstations for SUG NAME", Limiting Collection="CAS0000B" (All Workstations Limiting Collection)
# 3. Move it to desired folder (for us, TargetContainerID = 2377)
# 4: Create a basic query and assign it to the collection
# 5. Update SQL and change it to the desired SQL query
# 6. Create Basic Collection Name= "[CI_ID] Non-Compliant servers for SUG NAME", Limiting Collection="CAS0000A" (All Servers)
# 7. Move it to desired folder (for us, TargetContainerID = 2377)
# 8: Create a basic query and assign it to the collection
# 9. Update SQL and change it to the desired SQL query

# Get-WmiObject -namespace root\sms\site_$siteCode -class sms_authorizationlist -computername $siteServer -filter "CI_ID=$CI_ID"

# 	%sc 
# 	site code of the current site 
# 	
# 	%sitesvr 
# 	name of the site server for the current site 
# 	
# 	%sqlsvr 
# 	name of the SQL server for the current site 


#$siteCode, $siteServer, $CI_ID, $SMS_Database, $SMS_SQLServer

#Status Message ID's
#Create 30219

$CMModule = 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
if ($CMModule) {
	Import-Module $CMModule
}

$TargetContainerID = 2377

$CI_ID = $args[0]
$siteCode = $args[1]
$siteServer = $args[2]
$SMS_SQLServer = $args[3]
$SMS_Database = $args[4]


function Create-Collection($CollectionName, $CollectionType, $LimitToCollectionID)

{
	$siteCode = $script:siteCode
	$siteServer = $script:siteServer

	$collInstance = ([wmiclass]"\\$siteServer\root\sms\site_$($siteCode):sms_collection").CreateInstance()
	$collInstance.Name = $CollectionName
	$collInstance.LimitToCollectionID = $LimitToCollectionID
	$collInstance.CollectionType = 2
	if(gwmi -ComputerName $siteServer -Namespace root\sms\site_$siteCode -Class sms_collection -Filter "Name='$CollectionName'"){
		"Collection '$CollectionName' already exists"
	}else{
		$collInstance.Put() | Out-Null
		
		#$collInstance.Get()
	}	
	#$results = Set-WmiInstance -Class SMS_Collection -Computer $siteServer -arguments $CollectionArgs -namespace "root\SMS\Site_$siteCode" | Out-Null
	Get-WmiObject -ComputerName $siteServer -Namespace root\sms\site_$siteCode -Class sms_collection -Filter "Name='$CollectionName'" | ForEach-Object {$CollID = $_.CollectionID} | Out-Null
	Write-Host ("CollectionID: {0}" -f $CollID)

	return $CollID
}

function Move-Collection($SourceContainerNodeID,$CollectionID,$TargetContainerNodeID) { 
	$siteCode = $script:siteCode
	$siteServer = $script:siteServer
	$Class = "SMS_ObjectContainerItem" 
	$Method = "MoveMembers"
	$MC = [WmiClass]"\\$siteServer\ROOT\SMS\site_$($siteCode):$Class" 
	
	$InParams = $mc.psbase.GetMethodParameters($Method)
	$InParams.ContainerNodeID = $SourceContainerNodeID #usually 0 when newly created Collection
	$InParams.InstanceKeys = $CollectionID
	$InParams.ObjectType = "5000" #5000 for Collection_Device, 5001 for Collection_User
	$InParams.TargetContainerNodeID = $TargetContainerNodeID
	
	$R = $mc.PSBase.InvokeMethod($Method, $inParams, $Null)
	Write-Host "Collection moved to target location"
}

function Add-QueryRule($CollectionID, $CI_ID){
	$siteCode = $script:siteCode
	$siteServer = $script:siteServer
	
	$QueryExpression = 'select * from SMS_R_SMSTEM'
	#$Collection = [wmi]$CollectionID
	$Collections = Get-WmiObject -ComputerName $siteServer -Namespace root\sms\site_$siteCode -Class SMS_Collection -Filter "CollectionID='$CollectionID'"
	foreach($Collection in $Collections){
		Write-Host("Collection is : {0}" -f $Collection.Name)
		$QueryExpressionName = "Non-compliant for CI_ID $CI_ID [DO NOT MODIFY]"
		$ruleClass = [wmiclass] "\\$siteServer\root\sms\site_$($siteCode):SMS_CollectionRuleQuery" 
		$newRule = $ruleClass.CreateInstance() 
		$newRule.RuleName = $QueryExpressionName 
		$newRule.QueryExpression = $QueryExpression 
		$null = $Collection.AddMembershipRule($newRule)
		 	
		#Commit changes and initiate the collection evaluator                   
		$Collection.AddMemberShipRule($NewRule)
	}
	#Change SQL for rule
	$sqlQuery = "UPDATE v_CollectionRuleQuery set QueryExpression='declare @CI_ID int;set @CI_ID = $($CI_ID);select  all SMS_R_SYSTEM.ItemKey,SMS_R_SYSTEM.DiscArchKey,SMS_R_SYSTEM.Name0,SMS_R_SYSTEM.SMS_Unique_Identifier0,SMS_R_SYSTEM.Resource_Domain_OR_Workgr0,SMS_R_SYSTEM.Client0 from vSMS_R_System AS SMS_R_System INNER JOIN v_Update_ComplianceStatusAll cs on cs.CI_ID=@CI_ID and cs.ResourceID=SMS_R_System.ItemKey where cs.Status = 2' where CollectionID = '$($CollectionID)'"
	$SMS_SQLServer = $script:SMS_SQLServer
	$SMS_Database = $script:SMS_Database
	$data = invoke-sqlcmd -ServerInstance $SMS_SQLServer -Database $SMS_Database -Query $sqlQuery
	
	$Collection.RequestRefresh()

}

function Add-SCCMCollectionRule($collectionID,$CI_ID) { 

	$siteCode = $script:siteCode
	$siteServer = $script:siteServer
	$queryExpression = "SELECT * from SMS_R_SMSTEM"
	$queryRuleName = "Non-compliant for CI_ID $CI_ID [DO NOT MODIFY]"
        # Get the specified collection (to make sure we have the lazy properties) 
        $coll = [wmi]"\\$siteServer\root\sms\site_$($siteCode):SMS_Collection.CollectionID='$collectionID'" 
	Write-Host("Hello, {0} {1}" -f $collectionID, $CI_ID) 

        # Build the new rule 
        if ($queryExpression -ne $null) 
        { 
            # Create a query rule 
            $ruleClass = [wmiclass]"\\$siteServer\root\sms\site_$($siteCode):SMS_CollectionRuleQuery" 
            $newRule = $ruleClass.CreateInstance() 
            $newRule.RuleName = $queryRuleName 
            $newRule.QueryExpression = $queryExpression 

            $null = $coll.AddMembershipRule($newRule) 
        } 

        
# 	    #Change SQL for rule
# 		$sqlQuery = "UPDATE v_CollectionRuleQuery set QueryExpression='declare @CI_ID int;set @CI_ID = $($CI_ID);select  all SMS_R_SYSTEM.ItemKey,SMS_R_SYSTEM.DiscArchKey,SMS_R_SYSTEM.Name0,SMS_R_SYSTEM.SMS_Unique_Identifier0,SMS_R_SYSTEM.Resource_Domain_OR_Workgr0,SMS_R_SYSTEM.Client0 from vSMS_R_System AS SMS_R_System INNER JOIN v_Update_ComplianceStatusAll cs on cs.CI_ID=@CI_ID and cs.ResourceID=SMS_R_System.ItemKey where cs.Status = 2' where CollectionID = '$($CollectionID)'"
# 		$SMS_SQLServer = $script:SMS_SQLServer
# 		$SMS_Database = $script:SMS_Database
# 		$data = Invoke-Sqlcmd -ServerInstance $SMS_SQLServer -Database $SMS_Database -Query $sqlQuery
# 		
# 		$coll.RequestRefresh() 
 
}

#Get the Software Update Group name
$sug = Get-WmiObject -namespace root\sms\site_$siteCode -class sms_authorizationlist -computername $siteServer -filter "CI_ID=$CI_ID"
$SugName = $sug.LocalizedDisplayName

$CollectionName = "Non-Compliant Workstations for $SugName"
$CollectionID = Create-Collection $CollectionName 2 "CAS0000B"
if($CollectionID) {
	Move-Collection 0 $CollectionID $TargetContainerID
	#Add-QueryRule $CollectionID $CI_ID
	#Add-SCCMCollectionRule $CollectionID $CI_ID
	Add-CMDeviceCollectionQueryMembershipRule -RuleName $_.Title -CollectionID $CollectionID -QueryExpression "select * from SMS_R_System"
}

# $CollectionName = "Non-Compliant Servers for $SugName"
# $CollectionID = Create-Collection $CollectionName 2 "CAS0000A"
# if($CollectionID) {
# 	Move-Collection 0 $CollectionID $TargetContainerID
# 	Add-QueryRule $CollectionID $CI_ID
# }
