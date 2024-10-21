Import-Module  "$env:SMS_ADMIN_UI_PATH\..\ConfigurationManager.psd1" # Import the ConfigurationManager.psd1 module 
Set-Location 'SP1:' # Set the current location to be the site code.

$Schedule = New-CMSchedule –RecurInterval Days –RecurCount 1 -Start "3/24/2016 7:00 am"

"PROD Migration 4/3",
"PROD Migration 4/4",
"PROD Migration 4/5 a",
"PROD Migration 4/5 b",
"PROD Migration 4/6 a",
"PROD Migration 4/6 b",
"PROD Migration 4/7" |
ForEach-Object {
    #$coll = New-CMDeviceCollection -LimitingCollectionId SMS00001 -Name $_
    #Move-CMObject -FolderPath "SP1:\DeviceCollection\CIS\Migration" -InputObject $coll
    #Set-CMDeviceCollection -Name $_ -RefreshSchedule $Schedule -RefreshType Periodic
    #$coll08 = New-CMDeviceCollection -Name "$_ 2008" -LimitingCollectionName $_
    #Move-CMObject -FolderPath "SP1:\DeviceCollection\CIS\Migration\PowerShell" -InputObject $coll08
    #$coll08r2 = New-CMDeviceCollection -Name "$_ 2008R2" -LimitingCollectionName $_
    #Move-CMObject -FolderPath "SP1:\DeviceCollection\CIS\Migration\PowerShell" -InputObject $coll08r2
    #Add-CMDeviceCollectionIncludeMembershipRule -CollectionName "$_ 2008" -IncludeCollectionId SP10018A
    Add-CMDeviceCollectionExcludeMembershipRule -CollectionName "SP1 Migration - June 16th" -ExcludeCollectionId SP100412
    Add-CMDeviceCollectionExcludeMembershipRule -CollectionName "SP1 Migration - June 17th" -ExcludeCollectionId SP100412
    Add-CMDeviceCollectionExcludeMembershipRule -CollectionName "SP1 Migration - June 18th" -ExcludeCollectionId SP100412
}

$query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where 
SMS_R_System.NetbiosName = 'LOUWEBWPL255S02' or
SMS_R_System.NetbiosName = 'LOUWEBWPL255S03' or
SMS_R_System.NetbiosName = 'LOUWEBWPL255S04' or
SMS_R_System.NetbiosName = 'LOUWEBWPL256S01' or
SMS_R_System.NetbiosName = 'LOUWEBWPL256S02' or
SMS_R_System.NetbiosName = 'LOUWEBWPL256S03' or
SMS_R_System.NetbiosName = 'LOUWEBWPL256S04' or
SMS_R_System.NetbiosName = 'louwebwpl260s02' or
SMS_R_System.NetbiosName = 'louwebwpl260s03' or
SMS_R_System.NetbiosName = 'louwebwpl260s04'
"

Add-CMDeviceCollectionQueryMembershipRule -CollectionName "SP1 Migration - June 18th" -RuleName "ServerQuery 2" -QueryExpression $query