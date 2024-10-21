Import-Module activedirectory
Add-PSSnapin Citrix.*

if ((Get-PSSnapin | where { $_.Name -like "VMWare*"}) -eq $null)
{
	Add-PSSnapin VMware.VimAutomation.Core
}

if ((Get-PSSnapin | where { $_.Name -like "Citrix*"}) -eq $null)
{
   #Get-PSSnapin -Registered "Citrix*" | Add-PSSnapin
   #Add-PSSnapin "PvsPsSnapin"
}

$VMVcenter = 'louvcswps05.rsc.humad.com'
$XD_DDC = 'LOUXDCWPGX1S003.TS.HUMAD.COM'

##Cluster Array to use for VM Builds.
$Site_Cluster_LDC_Array = "HUM-XENDESKTOP-LDC-C06"

##Note - Change this for the target folder the VMs should be built in, must be a unique folder name
$VMFolder = 'TSSA'

##Note - Change this to point to the CSV file that lists the VMs to be built located in the same folder as this script
##Format for CSV file is WKID,Master Template,XDCatalog
$Machine_List = 'Machines.csv'

## Un-Comment one network below.  Chosen network will be used for all VMs built.

#$Site_Network_LDC = 'LDC_Xen_Net1-10.224.0.0'  
#$Site_Network_LDC = 'LDC_Xen_Net2-10.224.2.0'  
#$Site_Network_LDC = 'LDC_Xen_Net3-10.224.4.0'  
#$Site_Network_LDC = 'LDC_Xen_Net4-10.224.6.0'  
#$Site_Network_LDC = 'LDC_Xen_Net5-10.224.8.0'  
#$Site_Network_LDC = 'LDC_Xen_Net6-10.224.10.0' 
#$Site_Network_LDC = 'LDC_Xen_Net7-10.224.12.0' 
#$Site_Network_LDC = 'LDC_Xen_Net8-10.224.14.0' 
#$Site_Network_LDC = 'LDC_Xen_Net9-10.224.16.0' 
#$Site_Network_LDC = 'LDC_Xen_Net10-10.224.18.0'
#$Site_Network_LDC = 'LDC_Xen_Net11-10.224.20.0'
#$Site_Network_LDC = 'LDC_Xen_Net12-10.224.22.0'
$Site_Network_LDC = 'LDC_Xen_Net13-10.224.24.0'
#$Site_Network_LDC = 'LDC_Xen_Net14-10.224.26.0'
#$Site_Network_LDC = 'LDC_Xen_Net15-10.224.28.0'
#$Site_Network_LDC = 'LDC_Xen_Net16-10.224.30.0'
#$Site_Network_LDC = 'LDC_Xen_Net17-10.224.32.0'
#$Site_Network_LDC = 'LDC_Xen_Net18-10.224.34.0'


$VMCustomizationSpec = 'Humana Windows 10 Enterprise - XenDesktop'
$VMADOU = 'OU=Virtual,OU=Workstations,DC=humad,DC=com'


. .\BuildVM_Functions.ps1

$Connect_Vcenter = Connect-VIServer $VMVcenter

$Machines = Import-Csv $Machine_List -Header @("VM","Template","Catalog")

foreach ($line in $Machines) {
    
	$VMName = $line.VM
	$VMTemplate = $line.Template
	$VMCatalog = $line.Catalog

if ($VMName -ne $NULL) {	
	$Site = Determine_Site($VMName)

	
	if ($Site -eq "LDC") 
	{ 

		$VMCluster = $Site_Cluster_LDC_Array
		$Site_Network = $Site_Network_LDC
		
	}
	if ($Site -eq "SDC") 
	{ 

		$VMCluster = $Site_Cluster_SDC_Array
		$Site_Network = $Site_Network_SDC 
	}

	$VMHost = Determine_ESX_Host($VMCluster)

	$VMDataStore = Determine_Datastore($VMHost)

	Write-Host "Summary"
	Write-Host "`tMachine: $VMName"
	Write-Host "`tXenDesktop Catalog: $VMCatalog"
	Write-Host "`tSite: $Site"
	Write-Host "`tNetwork: $Site_Network"
	Write-Host "`tCluster: $VMCluster"
	Write-Host "`tHost: $VMHost"
	Write-Host "`tDatastore: $VMDataStore"
	Write-Host "`tActive Directory: $VMADOU"


		Write-Host "Confirming AD computer account exists"
	$status = $(try {Get-ADComputer $VMName} catch {$null})
	if ($status -ne $null) 
	{
	 	Write-Host "AD computer account exists"
	 	Remove-ADComputer $VMName -Confirm:$false
	 	New-ADComputer $VMName -Path $VMADOU
	} 
	else 
	{
	 	Write-Host "AD computer account does not exist or is invalid"
	 	Write-Host "Creating Computer account"
	  New-ADComputer $VMName -Path $VMADOU
	}
	
	Write-Host "Starting creation of $VMName"
	$New_VM_Task = New-VM -Name $VMName -Template $VMTemplate -Host $VMHost -Datastore $VMDataStore -OSCustomizationSpec $VMCustomizationSpec  -Location $VMFolder -Confirm:$false -RunAsync
	Wait-Task -Task $New_VM_Task -ErrorAction SilentlyContinue
	Get-Task | where {$_.Id -eq $New_VM_Task.Id} | %{
     if($_.State -eq "Error"){
          $event = Get-VIEvent -Start $_.FinishTime | where {$_.DestName -eq $VMName} | select -First 1
          #$emailFrom = <from-email-address>
          #$emailTo = <to-email-address>
          #$subject = "Clone of " + $newVMName + " failed"
          #$body = $event.FullFormattedMessage
          #$smtpServer = <your-smtp-server>
          #$smtp = new-object Net.Mail.SmtpClient($smtpServer)
          #$smtp.Send($emailFrom, $emailTo, $subject, $body)
          Break
     }
}

	Write-Host "Changing network on adapter"
	Get-VM $VMName | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $Site_Network -Confirm:$false
	
	#Write-Host "Modifying Disk Size"
	#Get-VM $VMName | Get-HardDisk | Set-HardDisk -CapacityKB 78643200

	
	Write-Host "Starting VM"
	Start-VM -VM $VMName

    Start-Sleep -s 60	

	$VMHostedID = Get-VM $VMName | %{(Get-View $_.Id).config.uuid}
	$FullVM = "HUMAD\" + $VMName
	$Catalog_UID = Determine_CatalogID($VMCatalog)

	Write-Host "Adding $VM to XenDesktop catalog: $VMCatalog"
	$XD_Machine = New-BrokerMachine -AdminAddress $XD_DDC -MachineName $FullVM -CatalogUid $Catalog_UID -HostedMachineId $VMHostedID -HypervisorConnectionUid 1
}
}