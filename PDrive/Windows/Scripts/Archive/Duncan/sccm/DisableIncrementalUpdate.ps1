# ***************************************************************************
# 
# File:      Disable-IncrementalCollectionUpdate.ps1
#
# Version:   1.0
# 
# Author:    Brandon Linton
# 
# Purpose:   Disables Incremental Collection Updates on New Collections in ConfigMgr
# 
#
# Usage:     Run this script elevated on a system where PowerShell scripts
#            are enabled ("set-executionpolicy bypass").
#
# Possible Refresh Type Values:
#
# 6 = Incremental and Periodic Updates
# 4 = Incremental Updates Only
# 2 = Periodic Updates only
# 1 = Manual Update only
#
#
# ------------- DISCLAIMER -------------------------------------------------
# This script code is provided as is with no guarantee or waranty concerning
# the usability or impact on systems and may be used, distributed, and
# modified in any way provided the parties agree and acknowledge the 
# Microsoft or Microsoft Partners have neither accountabilty or 
# responsibility for results produced by use of this script.
#
# Microsoft will not provide any support through any means.
# ------------- DISCLAIMER -------------------------------------------------
#
# ***************************************************************************

$CollID = $args[0]
$SiteCode = $args[1]
$SiteServer = $args[2]

$collection = Get-WmiObject -ComputerName $SiteServer -Namespace "root\sms\site_$SiteCode" -class sms_collection -Filter "collectionid = '$CollID'"
# $collection
write-host $collection.name " was found."

# query WMI for the object, to see if it is in the SMS_ObjectContainerItem class (meaning it is in a folder)
$SourceFolder = (Get-WmiObject -Class SMS_ObjectContainerItem -Namespace root\sms\site_$SiteCode -Filter "InstanceKey = '$($CollID)' AND ObjectTypeName = 'sms_collection_device'" -ComputerName $SiteServer).ContainerNodeId

#check if it is...
# $collection.RefreshType -eq 6 -> incremental updates turned on (2 PERIODIC + 4 CONSTANT_UPDATE)
# $collection.CollectionID -notlike "SMS*" -> not a system folder
# $collection.name -notlike "*ZTI*" -> not a ZTI collection where we allow incremental updates
# $SourceFolder -ne 1 -> not in our Limiting Collections collection folder, where we allow incremental updates

if ($collection.RefreshType -eq 6 -And $collection.CollectionID -notlike "SMS*" -And $collection.name -notlike "*ZTI*" -And $SourceFolder -ne 1) {
	$collection.RefreshType = 2
	$collection.put()  | Out-Null
	write-host $collection.name " was updated."
}


 
