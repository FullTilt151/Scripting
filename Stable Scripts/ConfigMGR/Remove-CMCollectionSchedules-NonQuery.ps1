Install-Module sqlserver
Import-Module $env:SMS_ADMIN_UI_PATH\..\configurationmanager.psd1

$Colls = Invoke-Sqlcmd -ServerInstance CMWPDB -Database CM_WP1 -Query `
"select *
from v_Collection
where CollectionID not in (
select CollectionID
from v_CollectionRuleQuery)
and collectiontype = 2 and RefreshType in (2,4,6) and Name not like '%Limiting collection' and Name not like '%Security collection'"

Push-Location WP1:

$Colls.Count

$Colls | ForEach-Object { Set-CMCollection -CollectionID $_.CollectionID -RefreshType Manual }

Pop-Location