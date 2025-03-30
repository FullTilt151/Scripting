-- Count of LAPS versions
select ProductName0 [Product], ProductVersion0 [Version], count(*) [Count]
from v_gs_installed_software
where productname0 = 'Local Administrator Password Solution'
group by ProductName0, ProductVersion0
order by ProductName0, ProductVersion0

-- List of missing LAPS clients
select Netbios_Name0 [Name], Resource_Domain_OR_Workgr0 [Domain], 
		case Operating_System_Name_and0
		when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
		when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
		when 'Microsoft Windows NT Workstation 6.3' then 'Windows 8.1'
		when 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' then 'Windows 8.1'
		when 'Microsoft Windows NT Workstation 10.0' then 'Windows 10'
		when 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Windows 10'
		when 'Microsoft Windows NT Advanced Server 10.0' then 'Windows Server 2016'
		when 'Microsoft Windows NT Advanced Server 5.2' then 'Windows Server 2003'
		when 'Microsoft Windows NT Advanced Server 6.0' then 'Windows Server 2008'
		when 'Microsoft Windows NT Advanced Server 6.1' then 'Windows Server 2008 R2'
		when 'Microsoft Windows NT Advanced Server 6.3' then 'Windows Server 2012 R2'
		when 'Microsoft Windows NT Server 6.0' then 'Windows Server 2008'
		when 'Microsoft Windows NT Server 6.1' then 'Windows Server 2008 R2'
		when 'Microsoft Windows NT Server 6.2' then 'Windows Server 2012'
		when 'Microsoft Windows NT Server 6.3' then 'Windows Server 2016'
		end [OS], os.InstallDate0
from v_R_System_Valid sys left join
	 v_GS_OPERATING_SYSTEM OS on sys.ResourceID = os.ResourceID
where sys.ResourceID in (
select resourceid from v_CM_RES_COLL_WP10001B
) and sys.ResourceID not in (
select ResourceID
from v_gs_installed_software
where productname0 = 'Local Administrator Password Solution')
order by Netbios_Name0

-- Expiration time compliance
select Netbios_Name0, Resource_Domain_OR_Workgr0, DATEADD(S, CONVERT(int,LEFT(ms_Mcs_AdmPwdExpirationTi0, 10)), '1970-01-01') [AdmPwdExpiration], ms_Mcs_AdmPwdExpirationTi0
from v_r_system
where client0 = 1
order by Netbios_Name0