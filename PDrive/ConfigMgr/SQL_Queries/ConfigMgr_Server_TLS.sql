--from v_GS_TLSClient0
--from v_GS_TLSClient640
--from v_GS_TLSServer0
--from v_GS_TLSServer640

select sys.Netbios_Name0 [Name], 
	   case sys.Operating_System_Name_and0 
	   when 'Microsoft Windows NT Advanced Server 5.2' then 'Server 2003'
       when 'Microsoft Windows NT Advanced Server 6.0' then 'Server 2008'
	   when 'Microsoft Windows NT Advanced Server 6.1' then  'Server 2008 R2'
	   when 'Microsoft Windows NT Advanced Server 6.3' then  'Server 2012 R2'
	   when 'Microsoft Windows NT Server 6.1' then 'Server 2008 R2'
	   when 'Microsoft Windows NT Server 6.2' then 'Server 2012' 
	   when 'Microsoft Windows NT Server 6.3' then 'Server 2012 R2'
	   end [OS], 
	   sys.Resource_Domain_OR_Workgr0 [Domain],
	   (select Enabled0 from v_GS_TLSClient0 clt32 where sys.ResourceID = clt32.ResourceID) [TLSClient32 Enabled], 
	   (select Disabledbydefault0 from v_GS_TLSClient0 clt32 where sys.ResourceID = clt32.ResourceID) [TLSClient32 DisabledByDefault],
	   (select Enabled0 from v_GS_TLSClient640 clt64 where sys.ResourceID = clt64.ResourceID) [TLSClient64 Enabled],
	   (select Disabledbydefault0 from v_GS_TLSClient640 clt64 where sys.ResourceID = clt64.ResourceID) [TLSClient64 DisabledByDefault],
	   (select Enabled0 from v_GS_TLSServer0 svr32 where sys.ResourceID = svr32.ResourceID) [TLSServer32 Enabled],
	   (select Disabledbydefault0 from v_GS_TLSServer0 svr32 where sys.ResourceID = svr32.ResourceID) [TLSServer32 DisabledByDefault],
	   (select Enabled0 from v_GS_TLSServer640 svr64 where sys.ResourceID = svr64.ResourceID) [TLSServer64 Enabled],
	   (select Disabledbydefault0 from v_GS_TLSServer640 svr64 where sys.ResourceID = svr64.ResourceID) [TLSServer64 DisabledByDefault]
from v_r_system_valid sys
order by Netbios_Name0