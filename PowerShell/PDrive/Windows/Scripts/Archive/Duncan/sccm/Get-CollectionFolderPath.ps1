# ==============================================================================================
# 
# Microsoft PowerShell Source File -- Created with SAPIEN Technologies PrimalScript 2011
# 
# NAME: Get-CollectionFolderPath
# 
# AUTHOR: Duncan Russell
# DATE  : 8/29/2013
# 
# COMMENT: 
# 
# ==============================================================================================
param ([string]$CollectionId,
[string]$SiteCode,
[string]$CMProvider
)

$PathArray = @()
[int]$SourceFolder = (Get-WmiObject -Class SMS_ObjectContainerItem -Namespace root\sms\site_$SiteCode -Filter "InstanceKey = '$($CollectionId)'" -ComputerName $CMProvider).ContainerNodeId
if ($SourceFolder -ne 0)
{
	while ($SourceFolder -ne 0)
	{
		$ObjectNode = (Get-WmiObject -Class SMS_ObjectContainerNode -Namespace root\sms\site_$SiteCode -Filter "ContainerNodeId = '$($SourceFolder)'" -ComputerName $CMProvider)
		$PathArray += $ObjectNode.Name
		$SourceFolder = $ObjectNode.ParentContainerNodeId
		$ObjectNode = $null
	}
	[array]::Reverse($PathArray)
	$output = [string]::join(" / ", $PathArray)
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
	[System.Windows.Forms.MessageBox]::Show($output , "Folder Path")
}
else
{
	echo 'Could not find collection'
}


