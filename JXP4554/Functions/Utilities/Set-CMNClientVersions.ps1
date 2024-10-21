PARAM
(
    [Parameter(Mandatory = $true,
        HelpMessage = 'Site Server')]
    [String]$siteServer
)

$SCCMConn = Get-CMNSCCMConnectionInfo -SiteServer $siteServer
$SQLConn = Get-CMNConnectionString -DatabaseServer $SCCMConn.SCCMDBServer -Database $SCCMConn.SCCMDB
$SQLConn
$query = "IF EXISTS (SELECT *
           FROM   sys.objects
           WHERE  object_id = Object_id(N'[dbo].[Humana_Client_Versions]'
                              )
                  AND type IN ( N'U' ))
  DROP TABLE [dbo].[Humana_Client_Versions]" 

Invoke-CMNDatabaseQuery -connectionString $SQLConn -query $query -isSQLServer

$query = "IF NOT EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id =
                      Object_id(N'[dbo].[Humana_Client_Versions]')
                      AND type IN ( N'U' ))
  BEGIN
      CREATE TABLE [dbo].[Humana_Client_Versions]
        (
           [Caption]     [NVARCHAR](100) NOT NULL,
           [DisplayName] [NVARCHAR](500) NOT NULL
        )
      ON [PRIMARY]
  END"

Invoke-CMNDatabaseQuery -connectionString $SQLConn -query $query -isSQLServer

$ClientVersions = @{
'5.00.8239.1000' = 'SCCM Technical Preview'
'5.00.8271.1000' = 'SCCM Technical Preview 2'
'5.00.8287.1000' = 'SCCM Technical Preview 3'
'5.00.8299.1000' = 'SCCM Technical Preview (Version 1509)'
'5.00.8315.1000' = 'SCCM Technical Preview (Version 1510)'
'5.00.8325.1000' = 'SCCM (Version 1511)'
'5.00.8325.1005' = 'SCCM (Version 1511)'
'5.00.8325.1010' = 'SCCM (Version 1511)'
'5.00.8325.1126' = 'SCCM (Version 1511)'
'5.00.8336.1000' = 'SCCM Technical Preview (Version 1512)'
'5.00.8347.1000' = 'SCCM Technical Preview (Version 1601)'
'5.00.8355.1000' = 'SCCM (Version 1602)'
'5.00.8355.1306' = 'SCCM (Version 1602)'
'5.00.8355.1307' = 'SCCM (Version 1602)'
'5.00.8360.1000' = 'SCCM Technical Preview (Version 1602)'
'5.00.8372.1000' = 'SCCM Technical Preview 5 (Version 1603)'
'5.00.8385.1000' = 'SCCM Technical Preview (Version 1604)'
'5.00.8396.1000' = 'SCCM Technical Preview (Version 1605)'
'5.00.8410.1000' = 'SCCM Technical Preview (Version 1606)'
'5.00.8412.1000' = 'SCCM (Version 1606)'
'5.00.8412.1003' = 'SCCM (Version 1606)'
'5.00.8412.1006' = 'SCCM (Version 1606)'
'5.00.8412.1204' = 'SCCM (Version 1606)'
'5.00.8412.1205' = 'SCCM (Version 1606)'
'5.00.8412.1207' = 'SCCM (Version 1606)'
'5.00.8412.1307' = 'SCCM (Version 1606)'
'5.00.8412.1309' = 'SCCM (Version 1606)'
'5.00.8426.1000' = 'SCCM Technical Preview (Version 1607)'
'5.00.8433.1000' = 'SCCM Technical Preview (Version 1608)'
'5.00.8455.1000' = 'SCCM Technical Preview (Version 1610)'
'5.00.8458.1000' = 'SCCM (Version 1610)'
'5.00.8458.1005' = 'SCCM (Version 1610)'
'5.00.8458.1007' = 'SCCM (Version 1610)'
'5.00.8458.1500' = 'SCCM (Version 1610)'
'5.00.8465.1000' = 'SCCM Technical Preview (Version 1611)'
'5.00.8471.1000' = 'SCCM Technical Preview (Version 1612)'
}

foreach($ClientVersion in $ClientVersions.GetEnumerator())
{
    $query = "Insert Humana_Client_Versions (DisplayName, Caption)
        Values ('$($ClientVersion.Name)','$($ClientVersion.Value)')"
    Invoke-CMNDatabaseQuery -connectionString $SQLConn -query $query -isSQLServer
}
