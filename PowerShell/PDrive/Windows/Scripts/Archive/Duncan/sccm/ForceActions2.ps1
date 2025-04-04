# ==============================================================================================
# 
# Microsoft PowerShell Source File -- Created with SAPIEN Technologies PrimalScript 2011
# 
# NAME: ForceActions2.ps1
# 
# AUTHOR: Duncan Russell, Humana Inc.
# DATE  : 2/10/2014
# 
# COMMENT: Reference http://tompaps.blogspot.com/2013/01/invoke-inventory-sccm.html
#			-Added alternative GUI
#			-Added ability to call multiple scans
# 
# ==============================================================================================
 

param (
	[Parameter(HelpMessage="Computer")] [string]$computer,
	[Parameter(HelpMessage="Hardware Inventory Collection Cycle")] [switch]$HW,
	[Parameter(HelpMessage="Software Inventory Collection Cycle")] [switch]$SW,
	[Parameter(HelpMessage="Discovery Data Collection Cycle")] [switch]$DD,
	[Parameter(HelpMessage="Software Updates Scan Cycle")] [switch]$UpdateScan,
	[Parameter(HelpMessage="Software Updates Deployment Evaluation Cycle")] [switch]$UpdateDeploymentScan,
	[Parameter(HelpMessage="File Collection Cycle")] [switch]$FileCollection,
	[Parameter(HelpMessage="Compliance Evaluations")] [switch]$ComplianceEval,
	[Parameter(HelpMessage="Run full scans instead of delta")] [switch]$Full,
	[Parameter(HelpMessage="Use GUI")] [switch]$GUI

	) 
	#[Parameter(HelpMessage="Refresh Compliance State Info")] [switch]$ComplianceState,

function executeSCCMAction {

	param (
		[string]$srv,
		[string]$action,
		$fscheduleID
	)

   #Binding SMS_Client wmi class remotely.... 
   $SMSCli = [wmiclass] "\\$srv\root\ccm:SMS_Client"

   if($SMSCli){
      #if($action -imatch "full"){
      if($script:Full -and ($action -imatch "inventory")){
         #Clearing HW or SW inventory delta flag...
         $wmiQuery = "\\$srv\root\ccm\invagt:InventoryActionStatus.InventoryActionID='$fscheduleID'"
         $checkdelete = ([wmi]$wmiQuery).Delete()
         $action += " (Full)"
      }   
      #Invoking $action ...
      Write-Host "$srv, Invoking action $action"
      $check = $SMSCli.TriggerSchedule($fscheduleID)
   }
   else{
      # could not get SCCM WMI Class
      Write-Host "$srv, could not get SCCM WMI Class"
   }
}

function Invoke-SCCMDCMEvaluation ([string]$srv){
	Write-Host "$srv, Invoking action Compliance Evaluations"
	$Baselines = Get-WmiObject -ComputerName "$srv" -Namespace "root\ccm\dcm" -Class "SMS_DesiredConfiguration"
	
	$Baselines | % { ([wmiclass]"\\$srv\root\ccm\dcm:SMS_DesiredConfiguration").TriggerEvaluation($_.Name, $_.Version) | Out-Null }

}

function doActions ([string]$srv){
	if($script:HW){
		executeSCCMAction $srv "Hardware Inventory Collection Cycle" "{00000000-0000-0000-0000-000000000001}"
	}
	if($script:SW){
		executeSCCMAction $srv "Software Inventory Collection Cycle" "{00000000-0000-0000-0000-000000000002}"		
	}
	if($script:DD){
		executeSCCMAction $srv "Discovery Data Collection Cycle" "{00000000-0000-0000-0000-000000000003}"		
	}
	if($script:UpdateScan){
		executeSCCMAction $srv "Software Updates Scan Cycle" "{00000000-0000-0000-0000-000000000113}"		
	}
	if($script:UpdateDeploymentScan){
		executeSCCMAction $srv "Software Updates Assignment Evaluation Cycle" "{00000000-0000-0000-0000-000000000108}"		
	}
	if($script:FileCollection){
		executeSCCMAction $srv "File Collection Cycle" "{00000000-0000-0000-0000-000000000104}"		
	}
	if($script:ComplianceEval){
		Invoke-SCCMDCMEvaluation $srv
	}
}

if(($computer -ne $null) -and ($computer.trim() -ne "")){
	Write-Host "Single computer specified, $computer"
	doActions $computer
}
else{
	# No hostname or hostlist is specified, use localhost
	$computer = gc env:computername
	Write-Host "No computer specified, using $computer"
	#Binding SMS_Client wmi class remotely.... 
	$SMSCli = [wmiclass] "\\$computer\root\ccm:SMS_Client"
	if($SMSCli){
		doActions $computer
	} else {
		# could not get SCCM WMI Class
		Write-Host "$srv, could not get SCCM WMI Class"
	}
}
