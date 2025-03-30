 SELECT SYS.Netbios_Name0, ADV.AdvertisementID, ADV.AdvertisementName, 
      COL.Name AS TargetedCollection, CAS.LastStatusMessageIDName 
    FROM v_ClientAdvertisementStatus CAS INNER JOIN v_R_System SYS 
      ON CAS.ResourceID = SYS.ResourceID INNER JOIN v_Advertisement ADV 
      ON CAS.AdvertisementID = ADV.AdvertisementID INNER JOIN 
      v_Collection COL ON ADV.CollectionID = COL.CollectionID 
	  where LastStatusMessageIDName != 'Program completed with success' and col.Name like 'EUX_jxg2181a_CHG00415%' or col.Name like 'EUX_jxg2181a_CHG004223%' or col.Name like 'EUX_jxg2181a_CHG0044505%' 
    ORDER BY SYS.Netbios_Name0, ADV.AdvertisementID