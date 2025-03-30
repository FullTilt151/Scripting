-- Count of 32-bit keys
select SchUseStrongCrypto0, SystemDefaultTlsVersions0, count(*)
from v_gs_DotNetTLS0
group by SchUseStrongCrypto0, SystemDefaultTlsVersions0

-- Count of 64-bit keys
select SchUseStrongCrypto0, SystemDefaultTlsVersions0, count(*)
from v_gs_DotNetTLS640
group by SchUseStrongCrypto0, SystemDefaultTlsVersions0

-- Settings for a WKID
select *
from v_gs_DotNetTLS640 where resourceid in (select MachineID from vSMS_CombinedDeviceResources sys where name = 'wkmj059g4b')