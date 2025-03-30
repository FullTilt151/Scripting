select Size0
from dbo.v_GS_SMS_ADVANCED_CLIENT_CACHE inner join
dbo.v_R_System on dbo.v_r_system.ResourceID = dbo.v_GS_SMS_ADVANCED_CLIENT_CACHE.ResourceID
where dbo.v_r_system.Name0 = @WKID

select ResourceID, KeyName0,Persistent0
from dbo.v_GS_XEN_DESKTOP_PERSISTENT