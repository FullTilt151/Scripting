$SiteCode = "MEM"
if((Get-Module ConfigurationManager) -eq $null) {
Try{
Import-Module "C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin\ConfigurationManager.psd1" -ErrorAction Stop -Verbose
}
catch{Write-host "Unable to Load SCCM PS Module"
}
}
else{}
Try{
Set-Location "$($SiteCode):\" -Verbose
}
Catch{write-host "Could not connect to MEMCM Drive"}
#Get Active Deployments

$Deployments= Get-CMDeployment |? CollectionID -notlike 'SMS*' | Select -Unique -ExpandProperty CollectionID

#Get Collections with No Active Deployment and No Member Count
$Rule1 = Get-CMCollection | ? CollectionID -NotIn $Deployments | ? membercount -eq 0 | select name,collectionid,membercount

#Get Collections with No Active Deployment and No Memebership change in Past 6 months
##LastMemberChangeTime
##LastChangeTime
$6MonthsAgo= (Get-date).AddMonths(-6)
$Rule2 = Get-CMCollection | ? CollectionID -NotIn $Deployments | ? LastMemberChangeTime -LT ( get-date $6MonthsAgo -Format g) | select name,Collectionid,membercount

foreach($CollectionID in $Rule1 )
{

Write-Host $CollectionID.name "-----Rule1" $CollectionID.Collectionid -ForegroundColor red

}

foreach($CollectionID in $Rule2 )
{

Write-Host $CollectionID.name + "---- rule two" $CollectionID.Collectionid -ForegroundColor Green

}