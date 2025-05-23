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
# 1. pass CI_ID of SUG, use to look up SUG NAME (LocalizedDisplayName), and collect associated Updates
# 2. Create Collection  Name= "[CI_ID] Non-Compliant workstations for SUG NAME", Limiting Collection="CAS0000B" (All Workstations Limiting Collection)
# 3. Move it to desired folder (for us, TargetContainerID = 2377)
# 4: Create a query for each Update in the SUG and assign it to the collection

#HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SMS\Setup\UI Installation Directory + "bin"

$CMModule = 'F:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
if ($CMModule) {
	Import-Module $CMModule
}

#region Script Functions

function Create-Collection($CollectionName, $CollectionType, $LimitToCollectionID, $CI_ID)

{
	$siteCode = $script:siteCode
	$siteServer = $script:siteServer

	$Providerlocation = $siteCode + ":"
	$StartLocation = (get-location).Path
	$CollectionExists = $false

	$collInstance = ([wmiclass]"\\$siteServer\root\sms\site_$($siteCode):sms_collection").CreateInstance()
	$collInstance.Name = $CollectionName
	$collInstance.LimitToCollectionID = $LimitToCollectionID
	$collInstance.CollectionType = 2
	$Collections = Get-WmiObject -ComputerName $siteServer -Namespace root\sms\site_$siteCode -Class sms_collection -Filter "Name='$CollectionName'"
	foreach($Collection in $Collections){
		Set-Location $Providerlocation
		$CI_ID_VAR = Get-CMDeviceCollectionVariable -CollectionId $Collection.CollectionID -VariableName "CI_ID"
		Set-Location $StartLocation

		if($CI_ID_VAR.Value -ne $CI_ID){
			#TODO:	Don't Delete it! Grab array of rules, add new ones needed and delete old ones not needed.
			#		Then, set the collection variable to match.
			Write-Host("Collection '{0}' already exists but does not match CI_ID, deleting..." -f $CollectionName)
			$Collections = Get-WmiObject -ComputerName $siteServer -Namespace root\sms\site_$siteCode -Class sms_collection -Filter "Name='$CollectionName'"
			Set-Location $Providerlocation
			Remove-CMDeviceCollection -CollectionID $Collection.CollectionID -Force
			Set-Location $StartLocation
		}else{
			$CollectionExists = $true
			Write-Host("Collection '{0}' already exists and matches CI_ID {1}" -f $CollectionName, $CI_ID)
			return 0
		}

	}
	if($CollectionExists -eq $false){
			#create a new collection
			$collInstance.Put() | Out-Null
			#$results = Set-WmiInstance -Class SMS_Collection -Computer $siteServer -arguments $CollectionArgs -namespace "root\SMS\Site_$siteCode" | Out-Null
			create-ScheduleToken
			$scheduletoken = $script:scheduletoken	
			$Collections = Get-WmiObject -ComputerName $siteServer -Namespace root\sms\site_$siteCode -Class sms_collection -Filter "Name='$CollectionName'"
			foreach($Collection in $Collections){
				$CollID = $Collection.CollectionID
				Set-Location $Providerlocation
				New-CMDeviceCollectionVariable -CollectionId $CollID -VariableName "CI_ID" -VariableValue $CI_ID | Out-Null
				Set-Location $StartLocation
				$Coll = [wmi]$Collection.__PATH
				$Coll.RefreshSchedule = $scheduletoken
				$Coll.RefreshType=2
				$Coll.put() | Out-Null
			}
			Write-Host ("Created collection '{0}', " -f $CollectionName) -NoNewline
			Write-Host ("CollectionID: {0}" -f $CollID)
	}
	
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

function Add-QueryRule($CollectionID, $CI_ID, $UpdateID){
	$siteCode = $script:siteCode
	$siteServer = $script:siteServer
	
	$QueryExpression = 'select * from SMS_R_SMSTEM'
	#$Collection = [wmi]$CollectionID
	$Collections = Get-WmiObject -ComputerName $siteServer -Namespace root\sms\site_$siteCode -Class SMS_Collection -Filter "CollectionID='$CollectionID'"
	foreach($Collection in $Collections){
		$QueryExpressionName = "Non-compliant for update CI_ID $UpdateID"
		$QueryExpression = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from sms_r_system AS sms_r_system inner join SMS_UpdateComplianceStatus as c on c.machineid=sms_r_system.resourceid where c.CI_ID = $UpdateID and c.status = 2"
		$location = $siteCode + ":"
		$oldLocation = (get-location).Path
		Set-Location $location
		Add-CMDeviceCollectionQueryMembershipRule -RuleName $QueryExpressionName -CollectionID $CollectionID -QueryExpression $QueryExpression
		Set-Location $oldLocation
		Write-Host("Added rule for Update {0} on collection {1}" -f $UpdateID, $CollectionID)
		
	}

}

function Convert-NormalDateToConfigMgrDate {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$starttime
    )
    return [System.Management.ManagementDateTimeconverter]::ToDMTFDateTime($starttime)
}

function create-ScheduleToken {
	$siteCode = $script:siteCode
	$siteServer = $script:siteServer
	$SMS_ST_RecurInterval = "SMS_ST_RecurInterval"
	[datetime]$startTime = [datetime]::Now.AddMinutes(30) 
	$class_SMS_ST_RecurInterval = [wmiclass]""
	 
	$class_SMS_ST_RecurInterval.psbase.Path ="\\$($siteServer)\ROOT\SMS\Site_$($siteCode):$($SMS_ST_RecurInterval)"
	 
	$script:scheduleToken = $class_SMS_ST_RecurInterval.CreateInstance()
	    if($scheduleToken){
	        $scheduleToken.DayDuration = 0
	        $scheduleToken.DaySpan = 1
	        $scheduleToken.HourDuration = 0
	        $scheduleToken.HourSpan = 0
	        $scheduleToken.IsGMT = $false
	        $scheduleToken.MinuteDuration = 0
	        $scheduleToken.MinuteSpan = 0
	        $scheduleToken.StartTime = (Convert-NormalDateToConfigMgrDate $startTime)
	    }
}

#endregion Script Functions

$siteCode = "CAS"
$siteServer = "LOUAPPWPS875"
$LimitingCollection = "CAS0000B"
$TargetContainerID = 2377


# Create new collections for each SUG, if it does not already exist
$arrSugCI_ID = @()
$sugs = Get-WmiObject -namespace root\sms\site_$siteCode -class sms_authorizationlist -computername $siteServer
foreach($sug in $sugs){
	$CI_ID = $sug.CI_ID
	$arrSugCI_ID += $CI_ID
	$SugName = $sug.LocalizedDisplayName
	#Get the list of Updates
	$Updates = @()
	$sug = [wmi]"$($sug.__PATH)"
	foreach ($Update in $sug.Updates){
		$Updates += $Update
	}
	
	$CollectionName = "Non-Compliant Workstations for $SugName"
	
	$CollectionID = Create-Collection $CollectionName 2 $LimitingCollection $CI_ID
	if($CollectionID) {
		Move-Collection 0 $CollectionID $TargetContainerID
		foreach($Update in $Updates){
			Add-QueryRule $CollectionID $CI_ID $Update
		}
	}
}

#Delete any collections that do not have a matching SUG CI_ID variable

