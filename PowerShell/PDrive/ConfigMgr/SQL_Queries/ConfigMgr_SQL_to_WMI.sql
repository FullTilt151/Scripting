-- SQL to WMI
SELECT map.InvClassName AS [ViewName],  cls.Namespace AS [WMI_Namespace],  cls.ClassName AS [WMI_Class]
FROM dbo.v_InventoryClass cls INNER JOIN 
	 dbo.DataItem itm ON cls.ClassID = itm.ClassID INNER JOIN 
	 dbo.v_GroupMap map ON cls.SMSClassID = map.MIFClass
WHERE map.InvClassName = N'v_GS_Battery';
