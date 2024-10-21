# ***************************************************************************
# 
# File:      Disable-IncrementalCollectionUpdates.ps1
#
# Version:   1.0
# 
# Author:    Brandon Linton
# 
# Purpose:   Disables Incremental Collection Updates on Collections in ConfigMgr
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

Function Disable-IncrementalCollectionUpdates
{
$ServerName = "."
$SiteCode = @(Get-WmiObject -Namespace root\sms -Class SMS_ProviderLocation -ComputerName $ServerName)[0].SiteCode
$Count = 0
gwmi sms_collection -computer $ServerName `
  -namespace root\sms\site_$SiteCode | foreach {
  $Coll = [wmi] $_.__Path
  if ($Coll.RefreshType -eq 6 -And $Coll.CollectionID -notlike "SMS*") {
        write-host "Disabling Incremental Updates on: " $Coll.CollectionID "`t" $Coll.Name -ForegroundColor Yellow
        $Coll.RefreshType = 2
        $Coll.Put() | Out-Null
        $Count ++
      }
   }
Write-Host $Count "Collections were updated."
}

Disable-IncrementalCollectionUpdates

 