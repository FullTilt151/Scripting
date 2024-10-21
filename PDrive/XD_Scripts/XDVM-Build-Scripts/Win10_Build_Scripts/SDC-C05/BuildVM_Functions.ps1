
Function Determine_ESX_Host{
param($ESX_Cluster)
$min = 9999
Write-Host "Determining Host"
Get-Cluster -Name $ESX_Cluster | Get-VMHost |where { $_.ConnectionState -eq "Connected" -and $_.connectionstate -ne "Maintenance"} | %{
      if($_.Extensiondata.Vm.Count -lt $min)
            {
            $ESX_Host = $_.Name
            $min = $_.Extensiondata.Vm.Count
            }     
}
$ESX_Host
}

Function Determine_Datastore{
param($ESX_Host)
$freeGBTgt = 100
$maxDsFree = 0
Write-Host "Determining Datastore"
Get-VMHost -Name $ESX_Host | Get-Datastore | %{
      if($_.FreeSpaceMB -gt ($freeGBTgt * 1KB) -and $_.Name -like "HUM-SDC-INTR-PROD-XEN-C05*" -and $_.Name -notlike "MGMT*" -and $_.Name -notlike "*storage-1" -and $_.Name -notlike "*250*" -and $_.FreeSpaceMB -gt $maxDsFree){
            $DataStoreName = $_.Name
            $maxDsFree = $_.FreeSpaceMb
      }
      if($_.FreeSpaceMB -gt ($freeGBTgt * 1KB) -and $_.Name -like "HUM-SDC-INTR-PROD-XEN-C05*" -and $_.Name -notlike "MGMT*" -and $_.Name -notlike "*storage-1" -and $_.Name -notlike "*250*" -and $_.FreeSpaceMB -gt $maxDsFree){
            $DataStoreName = $_.Name
            $maxDsFree = $_.FreeSpaceMb
      }
}
$Datastore = $DataStoreName
if($maxDsFree -ne 0)
      {
      Write-Host "$DataStore has " ($maxDsFree/1KB) " GB free space"
      }
else {
      Write-Host "There is no datastore with more than" $freeGBTgt "GB free space"
      }
$Datastore
}

Function Determine_CatalogID{
param($Catalog_Name)
Write-Host "Determining XenDesktop Catalog"
$CatalogUID = (Get-BrokerCatalog -AdminAddress $XD_DDC -Name $Catalog_Name).Uid

$CatalogUID
}

Function Determine_Site{
param($VMName)
Write-Host "Determining Site"
if ($VMName -like "LOU*") 
	{ 
		$Site = "LDC" 
	}
	elseif ($VMName -like "SIM*") 
	{ 
		$Site = "SDC" 
	}

$Site
}
