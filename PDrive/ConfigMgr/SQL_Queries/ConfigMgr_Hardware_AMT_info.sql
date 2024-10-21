select sys.Netbios_Name0 WKID, SYS.AMTFullVersion0, SYS.AMTStatus0, SYS.IsClientAMT30Compatible0 , AMT0, AMTApps0, ProvisionState0, BiosVersion0, BuildNumber0, Flash0, LegacyMode0, Netstack0, ProvisionMode0, RecoveryBuildNum0, RecoveryVersion0, Sku0, TLSMode0, ZTCEnabled0
from v_r_system SYS INNER JOIN
	v_GS_AMT_AGENT AMT ON SYS.ResourceID = AMT.ResourceID
order by WKID

select AMT0, count(*)
from v_GS_AMT_AGENT
group by amt0
order by AMT0