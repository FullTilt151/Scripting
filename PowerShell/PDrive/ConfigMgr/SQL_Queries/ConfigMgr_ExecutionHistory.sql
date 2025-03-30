SELECT  sys.netbios_name0 WKID, adv.AdvertisementID,adv.AdvertisementName, 
	stat.LastStateName, stat.lastexecutionresult, stat.laststatustime, 
	adv.PackageID,
	pkg.Name AS Package, 
	adv.ProgramName AS Program, 
	adv.Comment AS Description,  
	adv.CollectionID
FROM v_advertisement adv 
JOIN v_Package  pkg ON adv.PackageID = pkg.PackageID 
JOIN v_ClientAdvertisementStatus  stat ON stat.AdvertisementID = adv.AdvertisementID 
JOIN v_R_System sys ON stat.ResourceID=sys.ResourceID 
WHERE sys.Netbios_Name0='WKMP04WC1G' and 
	  LastStateName != 'Accepted - No Further Status' and 
	  LastStateName != 'No Status'
order by LastStatusTime desc

select sys.Netbios_Name0 [WKID], Publisher0 [Mfg], DisplayName0 [Product], Version0 [Version], InstallDate0 [Install Date]
from v_r_system SYS join
	 v_add_remove_programs ARP ON SYS.ResourceID = ARP.ResourceID
where Netbios_Name0 = 'WKMP04WC1G'
order by arp.InstallDate0 DESC