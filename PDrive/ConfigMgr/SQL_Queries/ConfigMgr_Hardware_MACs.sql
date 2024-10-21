select sys.Netbios_Name0 [WKID], mac.MAC_Addresses0 [MAC]
from v_r_system_valid sys join 
v_RA_System_MACAddresses mac on sys.resourceid = mac.resourceid
where sys.Netbios_Name0 in (@WKIDs)
order by WKID