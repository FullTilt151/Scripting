declare @Build nvarchar(256) set @Build = '10.0.14393'
declare @Domain nvarchar(256) set @Domain = 'HUMAD'

-- Count of an OS build
select count(*) from v_R_System where Build01 = @Build

-- Chassis type for an OS build
select CASE 
	When ChassisTypes0 = 1 Then 'VM'
	When ChassisTypes0 in (2,5,8,9,10,12,16,31) Then 'Laptop'
	When ChassisTypes0 in (3,4,6,7,15,17,21) Then 'Desktop'
	When ChassisTypes0 = 11 Then 'Tablet'
	When ChassisTypes0 = 13 Then 'All-In-One'
	When ChassisTypes0 = 14 Then 'Sub-Notebook'
	When ChassisTypes0 = 18 Then 'Expansion Chassis'
	When ChassisTypes0 = 19 Then 'Sub-Chassis'
	When ChassisTypes0 = 20 Then 'Bus Expansion Chassis'
	When ChassisTypes0 = 22 Then 'Storage Chassis'
	When ChassisTypes0 = 23 Then 'Rack-Mount Chassis'
	When ChassisTypes0 = 24 Then 'Sealed PC'
	When ChassisTypes0 = 32 Then 'Tablet'
	Else ChassisTypes0
	End [Chassis Type], count(*) [Total]
from v_r_system sys left join
	 v_GS_SYSTEM_ENCLOSURE se on sys.ResourceID = se.ResourceID
where Build01 in (@Build) and Resource_Domain_OR_Workgr0 in (@Domain)
group by CASE 
	When ChassisTypes0 = 1 Then 'VM'
	When ChassisTypes0 in (2,5,8,9,10,12,16,31) Then 'Laptop'
	When ChassisTypes0 in (3,4,6,7,15,17,21) Then 'Desktop'
	When ChassisTypes0 = 11 Then 'Tablet'
	When ChassisTypes0 = 13 Then 'All-In-One'
	When ChassisTypes0 = 14 Then 'Sub-Notebook'
	When ChassisTypes0 = 18 Then 'Expansion Chassis'
	When ChassisTypes0 = 19 Then 'Sub-Chassis'
	When ChassisTypes0 = 20 Then 'Bus Expansion Chassis'
	When ChassisTypes0 = 22 Then 'Storage Chassis'
	When ChassisTypes0 = 23 Then 'Rack-Mount Chassis'
	When ChassisTypes0 = 24 Then 'Sealed PC'
	When ChassisTypes0 = 32 Then 'Tablet'
	Else ChassisTypes0
	End
order by [Chassis Type]

-- Chassis types with user info and role
select distinct netbios_name0, sys.Build01, CASE 
	When ChassisTypes0 = 1 Then 'VM'
	When ChassisTypes0 in (2,5,8,9,10,12,16,31) Then 'Laptop'
	When ChassisTypes0 in (3,4,6,7,15,17,21) Then 'Desktop'
	When ChassisTypes0 = 11 Then 'Tablet'
	When ChassisTypes0 = 13 Then 'All-In-One'
	When ChassisTypes0 = 14 Then 'Sub-Notebook'
	When ChassisTypes0 = 18 Then 'Expansion Chassis'
	When ChassisTypes0 = 19 Then 'Sub-Chassis'
	When ChassisTypes0 = 20 Then 'Bus Expansion Chassis'
	When ChassisTypes0 = 22 Then 'Storage Chassis'
	When ChassisTypes0 = 23 Then 'Rack-Mount Chassis'
	When ChassisTypes0 = 24 Then 'Sealed PC'
	When ChassisTypes0 = 32 Then 'Tablet'
	Else 'Unknown'
	End [Chassis Type], csp.version0 [Model], os.InstallDate0,
	AD_Site_Name0, scu.TopConsoleUser0, usr.Full_User_Name0, usr.Mail0, usr.title0, usr.department0, usr.manager0,
	(select 'X' from v_GS_INSTALLED_SOFTWARE sft where sft.ResourceID = sys.resourceid and ProductName0 = 'Medicare Advantage Paperless Application') [MKPT],
	(select 'X' from v_GS_OSD640 osd where osd.ResourceID = sys.ResourceID and osd.SMSTSRole0 = 'W10YHA') [YHA]
from v_r_system sys left join
	 v_GS_SYSTEM_ENCLOSURE se on sys.ResourceID = se.ResourceID left join
	 v_GS_SYSTEM_CONSOLE_USAGE SCU on sys.ResourceID = scu.ResourceID left join
	 v_R_User usr on SUBSTRING(scu.TopConsoleUser0, CHARINDEX('\', scu.TopConsoleUser0)+1, 8) = usr.User_Name0 left join
	 v_GS_OPERATING_SYSTEM os on sys.ResourceID = os.ResourceID left join
	 v_GS_COMPUTER_SYSTEM_PRODUCT csp on sys.ResourceID = csp.ResourceID
where client0 = 1 and Build01 = @build and sys.Resource_Domain_OR_Workgr0 in (@Domain)
order by department0, title0, [Chassis Type], Netbios_Name0

-- Count of MKPT
select count(distinct sys.Netbios_Name0)
from v_r_system sys left join
	 v_GS_SYSTEM_ENCLOSURE se on sys.ResourceID = se.ResourceID left join
	 v_GS_SYSTEM_CONSOLE_USAGE SCU on sys.ResourceID = scu.ResourceID left join
	 v_R_User usr on SUBSTRING(scu.TopConsoleUser0, CHARINDEX('\', scu.TopConsoleUser0)+1, 8) = usr.User_Name0 left join
	 v_GS_OPERATING_SYSTEM os on sys.ResourceID = os.ResourceID left join
	 v_GS_COMPUTER_SYSTEM_PRODUCT csp on sys.ResourceID = csp.ResourceID inner join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where client0 = 1 and Build01 in (@Build) and sys.Resource_Domain_OR_Workgr0 in (@Domain) and ProductName0 = 'Medicare Advantage Paperless Application'

-- Chassis type by model and AD site
select CASE 
	When ChassisTypes0 = 1 Then 'VM'
	When ChassisTypes0 in (2,5,8,9,10,12,16,31) Then 'Laptop'
	When ChassisTypes0 in (3,4,6,7,15,17,21) Then 'Desktop'
	When ChassisTypes0 = 11 Then 'Tablet'
	When ChassisTypes0 = 13 Then 'All-In-One'
	When ChassisTypes0 = 14 Then 'Sub-Notebook'
	When ChassisTypes0 = 18 Then 'Expansion Chassis'
	When ChassisTypes0 = 19 Then 'Sub-Chassis'
	When ChassisTypes0 = 20 Then 'Bus Expansion Chassis'
	When ChassisTypes0 = 22 Then 'Storage Chassis'
	When ChassisTypes0 = 23 Then 'Rack-Mount Chassis'
	When ChassisTypes0 = 24 Then 'Sealed PC'
	When ChassisTypes0 = 32 Then 'Tablet'
	Else 'Unknown'
	End [Chassis Type], csp.Version0, sys.AD_Site_Name0, count(*) [Total]
from v_r_system sys join
	 v_GS_SYSTEM_ENCLOSURE se on sys.ResourceID = se.ResourceID left join
	 v_GS_COMPUTER_SYSTEM_PRODUCT csp on sys.ResourceID = csp.ResourceID
where Build01 = @build
group by CASE 
	When ChassisTypes0 = 1 Then 'VM'
	When ChassisTypes0 in (2,5,8,9,10,12,16,31) Then 'Laptop'
	When ChassisTypes0 in (3,4,6,7,15,17,21) Then 'Desktop'
	When ChassisTypes0 = 11 Then 'Tablet'
	When ChassisTypes0 = 13 Then 'All-In-One'
	When ChassisTypes0 = 14 Then 'Sub-Notebook'
	When ChassisTypes0 = 18 Then 'Expansion Chassis'
	When ChassisTypes0 = 19 Then 'Sub-Chassis'
	When ChassisTypes0 = 20 Then 'Bus Expansion Chassis'
	When ChassisTypes0 = 22 Then 'Storage Chassis'
	When ChassisTypes0 = 23 Then 'Rack-Mount Chassis'
	When ChassisTypes0 = 24 Then 'Sealed PC'
	When ChassisTypes0 = 32 Then 'Tablet'
	Else 'Unknown'
	End, csp.Version0, sys.AD_Site_Name0
order by [Chassis Type], csp.Version0

-- List of WKIDs that ran upgrade
select distinct Netbios_Name0 [WKID], Version0 [Model], 
		case sys.build01
		when '10.0.14393' then '1607'
		when '10.0.16299' then '1709'
		when '10.0.17134' then '1803'
		when '10.0.17763' then '1809'
		when '10.0.18362' then '1903'
		end [Build], max(ts.ExecutionTime) [ExecutionTime]
from v_taskexecutionstatus TS full join
     v_r_system SYS ON TS.ResourceID = sys.ResourceID full join
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP ON sys.ResourceID = csp.ResourceID full join
	 v_AdvertisementInfo ADV ON TS.AdvertisementID = adv.AdvertisementID full join
	 v_TaskSequencePackage TSP ON adv.PackageID = tsp.PackageID full join
	 v_GS_OSD640 OSD on sys.ResourceID = osd.ResourceID
where tsp.name = 'Windows 10 - In-Place Upgrade 1709' and sys.ResourceID in (select sys.ResourceID from v_R_System_Valid sys join v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID where ProductName0 = 'Medicare Advantage Paperless Application')
group by Netbios_Name0, Version0, Build01
order by max(ts.ExecutionTime) desc

-- Count of models that ran upgrade
select distinct Version0 [Model], count(sys.Netbios_Name0)
from v_taskexecutionstatus TS full join
     v_r_system SYS ON TS.ResourceID = sys.ResourceID full join
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP ON sys.ResourceID = csp.ResourceID full join
	 v_AdvertisementInfo ADV ON TS.AdvertisementID = adv.AdvertisementID full join
	 v_TaskSequencePackage TSP ON adv.PackageID = tsp.PackageID full join
	 v_GS_OSD640 OSD on sys.ResourceID = osd.ResourceID
where tsp.name = 'Windows 10 - In-Place Upgrade 1909' and sys.ResourceID in (select sys.ResourceID from v_R_System_Valid sys join v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID where ProductName0 = 'Medicare Advantage Paperless Application')
group by Version0

-- WinMagic and BIOS upgrades
select Netbios_Name0, Build01, csp.Version0, bios.SMBIOSBIOSVersion0, bios.ReleaseDate0, ip.IP_Subnets0--, sft.ProductName0
from v_r_system sys inner join
	 v_GS_COMPUTER_SYSTEM_PRODUCT csp on sys.ResourceID = csp.ResourceID left join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID left join
	 v_GS_PC_BIOS bios on sys.ResourceID = bios.ResourceID left join
	 v_RA_System_IPSubnets ip on sys.ResourceID = ip.ResourceID
where Build01 in ('10.0.14393','10.0.15063','10.0.16299','10.0.17134','10.0.17763','10.0.18362') and Is_Virtual_Machine0 = 0 and sft.ProductName0 in (
'SecureDoc Disk Encryption (x64) 7.5',
'SecureDoc Disk Encryption (x64) 7.1SR4',
'SecureDoc Disk Encryption (x64) 7.1SR1',
'SecureDoc Disk Encryption (x64) 6.5 SR3',
'SecureDoc Disk Encryption (x64) 6.2 SR2'
)

-- IPU WKID list with details
select distinct sys1.Netbios_Name0, ts.ActionName
from v_r_system SYS1 left join
	 v_taskexecutionstatus TS on sys1.resourceid = ts.resourceid
where ts.AdvertisementID in (select AdvertisementID from v_advertisement adv where adv.packageid = 'WP10062C') and 
	  ts.ActionName = 'Set Nomad as Download Program' and sys1.ResourceID in (select resourceid from v_cm_res_coll_WP107118)

-- IPU WKID list
select distinct Netbios_Name0 [WKID], sys.Build01 [Build], case (
	 select distinct top 1 ts.ActionName 
	 from v_r_system SYS1 left join
	 v_taskexecutionstatus TS on sys1.resourceid = ts.resourceid
	 where ts.AdvertisementID in (select AdvertisementID from v_advertisement adv where adv.packageid = 'WP10062C') and 
		   ts.ActionName = 'Set Nomad as Download Program' and sys1.ResourceID = sys.resourceid)
	 when 'Set Nomad as Download Program' then 'X' end [IPU Ran]
from v_r_system SYS
where sys.ResourceID in (select resourceid from v_cm_res_coll_WP107118)
order by Netbios_Name0

-- List of IPU TSs
select Right(Name,4) [Build], PackageID
from v_TaskSequencePackage tsp
where tsp.Name like 'Windows 10 - In-Place Upgrade ____'

(select CollectionID from v_Collection where name = 'Win10 ' + @Build + ' Targets w/Agents current')