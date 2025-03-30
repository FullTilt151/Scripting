select Netbios_Name0, adp.IPAddress0
from v_R_System_Valid SYS
join v_GS_NETWORK_ADAPTER_CONFIGUR adp on sys.ResourceID = adp.ResourceID
where IPAddress0 IS NOT NULL and IPAddress0 like '%105'
