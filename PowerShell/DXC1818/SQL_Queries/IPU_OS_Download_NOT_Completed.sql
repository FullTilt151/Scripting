select sys.Netbios_Name0, sys.Build01, pkg.OptInfo0, Percent0, ReturnStatus0, Version0
from v_R_System sys left join
     v_GS_PkgStatus640 pkg on sys.ResourceID = pkg.ResourceID
where pkg.KeyName0 = 'WP1007CE' and OptInfo0 != 'Completed' and Version0 = 2 and sys.Build01 != '10.0.18363'