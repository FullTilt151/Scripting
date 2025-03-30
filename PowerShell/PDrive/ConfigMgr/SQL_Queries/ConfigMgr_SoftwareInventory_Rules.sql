-- CAS - View the Site Control File information for Software Inventory Rules in table format
 SELECT MAX(CASE WHEN pvt.[Option] = 'Inventoriable Types' THEN pvt.Value END) AS [FileName]
 ,MAX(CASE WHEN pvt.[Option] = 'Path' THEN pvt.Value END) AS [Path]
 ,MAX(CASE WHEN pvt.[Option] = 'Subdirectories' THEN pvt.Value END) AS [Search Subfolers]
 ,MAX(CASE WHEN pvt.[Option] = 'Exclude' THEN pvt.Value END) AS [Exclude Encrypted and Compressed files]
 ,MAX(CASE WHEN pvt.[Option] = 'Exclude Windir and Subfolders' THEN pvt.Value END) AS [Exclude files in the Windows folder]
 FROM (
 SELECT swi.SiteCode, nds.col.value('@Name[1]','nvarchar(2000)') AS [Option], row.val.value('.', 'nvarchar(2000)') AS [Value]
 ,ROW_NUMBER() OVER (PARTITION BY swi.SiteCode, nds.col.value('@Name[1]','nvarchar(2000)') ORDER BY (SELECT 0)) AS [RowNum]
 FROM dbo.vSMS_SC_ClientComponent_SDK swi INNER JOIN -- Only get the CAS info as the Primaries do not matter!
	dbo.ServerData srv ON swi.SiteCode = srv.SiteCode AND srv.ID = 0
 CROSS APPLY swi.RegMultiStringList.nodes('//RegMultiStringLists/RegMultiStringList') nds(col)
 CROSS APPLY nds.col.nodes('Value') row(val)
 WHERE swi.ClientComponentName = 'Software Inventory Agent') pvt
 GROUP BY pvt.RowNum
 ORDER BY FileName

 select *
 from vSMS_SoftwareInventoryAgentConfig