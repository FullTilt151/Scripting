 param (   
    [switch] $ClearTargetCollection = $false,
    [string] $BaseCollectionName = "",  
    [string] $TargetCollectionID = "",
    [int]    $TargetNumber = 1)

$SiteServer = 'LOUAPPWPS875'
$SiteCode = 'CAS' 

#Retrieve SCCM collection by name 
"Retrieving Base Collection..."
$BaseCollection = get-wmiobject -ComputerName $SiteServer -NameSpace "ROOT\SMS\site_$($SiteCode)" -Query "Select * from SMS_Collection where name ='$BaseCollectionName'"
$BaseCollectionCount = $BaseCollection.LocalMemberCount

if($BaseCollection){
#Retrieve members of collection 
    "Base Collection found, getting base collection members ($BaseCollectionCount)..."
    $SMSMembers = Get-WmiObject -ComputerName $SiteServer -Namespace  "ROOT\SMS\site_$($SiteCode)" -Query "SELECT Name, ResourceID FROM SMS_FullCollectionMembership WHERE CollectionID='$($BaseCollection.CollectionID)' AND IsClient=1 AND IsObsolete=0 AND IsDecommissioned=0"

} else{
    "Could not bind Base Collection!"
}

#Get Target Collection
$global:mc = [wmi]"\\$($SiteServer)\root\sms\site_$($SiteCode):SMS_Collection.CollectionID='$TargetCollectionID'"

if(($BaseCollection) -and ($global:mc)){

    if($ClearTargetCollection){
        #Delete all current direct membership rules
        "Deleting current membership rules"
        foreach($rule in $global:mc.CollectionRules){
            if($rule.__CLASS -eq "SMS_CollectionRuleDirect"){
                $ruleName = $rule.RuleName
                $res = $global:mc.deletemembershiprule($rule)
                if($res.ReturnValue -eq 0){$retVal = "OK" }  
                else   {$retVal = "Error!"}
                "    Attempted to delete direct membership rule for ""$($ruleName)"" --> $($retVal)"
            }
        }
    }
    #Get random machines
    "Retrieving $TargetNumber random machine(s) from the base collection members"
    $NewMachinesToAdd = Get-Random -InputObject $SMSMembers -Count $TargetNumber
    
    #Add them to the target collection
    "Adding those members to target collection via Direct Membership rules"

    foreach($member in $NewMachinesToAdd){
        $found = $false
        if(!$ClearTargetCollection){
            foreach($rule in $global:mc.CollectionRules){  
                if(($rule.RuleName -ieq $member.Name) -and ($rule.__CLASS -eq "SMS_CollectionRuleDirect")){  
                    $found = $true  
                    break  
                }  
            }
        }

        if($found){ "    ""$($member.Name)"" is already in collection!"
        } else {
            $objColRuledirect = [WmiClass]"\\$($SiteServer)\ROOT\SMS\site_$($SiteCode):SMS_CollectionRuleDirect"
            $objColRuleDirect.psbase.properties["ResourceClassName"].value = "SMS_R_System"
            $objColRuleDirect.psbase.properties["ResourceID"].value = $member.ResourceID
            $InParams = $global:mc.psbase.GetMethodParameters('AddMembershipRule')
            $InParams.collectionRule = $objColRuleDirect
            $R = $global:mc.PSBase.InvokeMethod('AddMembershipRule', $inParams, $Null)
            if($r.ReturnValue -eq 0){
                $retVal = "OK"
                $SuccessfulRuleAdd = $true
            }  
            else   {$retVal = "Error"}
                "   Rule for ""$($member.Name)"" --> $($retVal)"
            }
        }
        if($SuccessfulRuleAdd){
            $refresh = $global:mc.PSBase.InvokeMethod('RequestRefresh', $Null, $Null)
            if($refresh.ReturnValue -eq 0){
                $retVal = "OK"}  
            else {$retVal = "Error"}
        "Requesting target collection to update membership --> $retVal"
    }    
}else{
    "Could not bind target collection ID"
}

