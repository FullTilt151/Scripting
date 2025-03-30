DECLARE @WKIDs table (Value varchar(1000))
insert into @WKIDs values ('wkmj059g4b'),('WKMJ064ACH'),('WKPC0G666M'),('WKMP04XBRV')

-- List of WKIDs - ZTI
select distinct sys.Netbios_Name0 [WKID], 
	   case sys.Operating_System_Name_and0
	   WHEN 'Microsoft Windows NT Workstation 10.0' THEN 'Windows 10'
	   WHEN 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' THEN 'Windows 10'
	   WHEN 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' THEN 'Windows 8.1'
	   WHEN 'Microsoft Windows NT Workstation 6.3' THEN 'Windows 8.1'
	   WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7'
	   WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
	   WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
	   end [OS], sys.Resource_Domain_OR_Workgr0 [Domain], sys.Is_Virtual_Machine0 [VM], csp.Vendor0 [Make], csp.Version0 [Model], 
	   case 
	   WHEN UEFI.UEFI0 = 0 THEN 'Off'
	   WHEN UEFI.UEFI0 = 1 and UEFI.SecureBoot0 = 0 THEN 'On'
	   WHEN UEFI.UEFI0 = 1 and UEFI.SecureBoot0 IS NULL THEN 'On'
	   WHEN UEFI.UEFI0 = 1 and UEFI.SecureBoot0 = 1 THEN 'On + SecureBoot'
	   else 'Unknown'
	   end [UEFI],
	   (select top 1 'UEFI' from v_GS_PARTITION PT where sys.ResourceID = pt.ResourceID and pt.Description0 like 'GPT%') [UEFI2],
	   bios.SMBIOSBIOSVersion0 [BIOS], bios.ReleaseDate0,
	   PhysicalPresenceVersionInfo0 [TPM], cpu.IsVitualizationCapable0 [Virt], os.DataExecutionPrevention_Avai0 [NXbit], disk.FreeSpace0 [GB Freespace],
	   (select sum(capacity0) from v_GS_PHYSICAL_MEMORY where v_GS_PHYSICAL_MEMORY.ResourceID = sys.ResourceID) [MB RAM], 
	   (select count(*) from v_gs_disk dsk where sys.resourceid = dsk.resourceid group by resourceid) [Disks],
	   (select top 1 SizeEstimate0 from v_GS_USMT_ESTIMATE USMT where sys.resourceid = USMT.resourceid order by DateTime0 desc) [USMT],
	   (select 'X' from v_CM_RES_COLL_WP100669 coll where sys.resourceid = coll.resourceid) [VPN],
	   (select 'X' from v_CM_RES_COLL_WP10318B coll where sys.resourceid = coll.resourceid) [HW Enc],
	   (select 'X' from v_GS_CUSTOM_MAPPEDDRIVES map where sys.resourceid = map.resourceid and (map.DrivePath0 like '\\xerxes%' or map.DrivePath0 like '\\thor%')) [AS400]
from v_R_System_Valid sys left join
	 v_GS_TPM tpm on sys.ResourceID = tpm.ResourceID left join
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP on sys.ResourceID = csp.ResourceID left join
	 v_GS_OPERATING_SYSTEM OS on sys.resourceid = os.resourceid left join
	 v_GS_LOGICAL_DISK DISK on sys.ResourceID = disk.ResourceID and disk.DeviceID0 = 'c:' left join
	 v_GS_PHYSICAL_MEMORY RAM on sys.ResourceID = ram.ResourceID left join
	 v_GS_FIRMWARE UEFI on sys.ResourceID = uefi.ResourceID left join
	 v_GS_PROCESSOR CPU on sys.ResourceID = cpu.ResourceID left join
	 v_GS_PC_BIOS BIOS on sys.ResourceID = bios.ResourceID
where   sys.Resource_Domain_OR_Workgr0 != 'HMHSCHAMP' and 
		sys.netbios_name0 in (select value from @WKIDs)
order by Domain, WKID

-- List of WKIDs - IPU
DECLARE @WKIDs table (Value varchar(1000))
insert into @WKIDs values ('WKPF23BEJK'),('WKPF24CA6D'),('WKPF2JT9S1')

select distinct sys.Netbios_Name0 [WKID], 
	   case sys.Operating_System_Name_and0
	   WHEN 'Microsoft Windows NT Workstation 10.0' THEN 'Windows 10'
	   WHEN 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' THEN 'Windows 10'
	   WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7'
	   WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
	   end [OS], 
	   case sys.build01
	   when '6.1.7601' then 'Win7'
	   when '10.0.14393' then '1607'
	   when '10.0.15063' then '1703'
	   when '10.0.16299' then '1709'
	   when '10.0.17134' then '1803'
	   when '10.0.17763' then '1809'
	   when '10.0.18362' then '1903'
	   when '10.0.18363' then '1909'
	   when '10.0.19041' then '2004'
	   when '10.0.19042' then '20H2'
	   else 'Other'
	   end [Build], sys.Resource_Domain_OR_Workgr0 [Domain], cs.LastHW [Hardware Inv], sys.Is_Virtual_Machine0 [VM], csp.Vendor0 [Make], csp.Version0 [Model], 
	   disk.FreeSpace0 [GB Freespace], (select top 1'X' from v_CM_RES_COLL_WP100669 coll where sys.resourceid = coll.resourceid) [VPN], 
	   sys.client_version0 [MEMCM],
	   (select distinct top 1 productversion0 from v_GS_INSTALLED_SOFTWARE sft where sft.ProductName0 = 'McAfee Agent' and sft.ResourceID = sys.resourceid order by ProductVersion0 Desc) [McAfee ePO],
	   (select distinct top 1 productversion0 from v_GS_INSTALLED_SOFTWARE sft where sft.ProductName0 = 'McAfee Endpoint Security Platform' and sft.ResourceID = sys.resourceid order by ProductVersion0 Desc) [McAfee ENS],
	   (select distinct top 1 productversion0 from v_GS_INSTALLED_SOFTWARE sft where sft.ProductName0 like 'Move AV%' and sft.ResourceID = sys.resourceid order by ProductVersion0 Desc) [McAfee MOVE],
	   (select distinct top 1 productversion0 from v_GS_INSTALLED_SOFTWARE sft where sft.ProductName0 like 'SecureDoc Disk Encryption%' and sft.ResourceID = sys.resourceid order by ProductVersion0 Desc) [WinMagic],
	   (select distinct top 1 ProtectionStatus0 from v_GS_BITLOCKER_DETAILS bl where bl.ResourceID = sys.resourceid) [Bitlocker],
	   (select distinct top 1 productversion0 from v_GS_INSTALLED_SOFTWARE sft where sft.ProductName0 = 'BeyondTrust PowerBroker Desktops Client for Windows' and sft.ResourceID = sys.resourceid order by ProductVersion0 Desc) [BeyondTrust],
	   (select distinct top 1 productversion0 from v_GS_INSTALLED_SOFTWARE sft where sft.ProductName0 = 'FireEye Endpoint Agent' and sft.ResourceID = sys.resourceid order by ProductVersion0 Desc) [FireEye],
	   (select distinct agentversion0 from v_GS_vdg640 sft where sft.ResourceID = sys.resourceid) [DG],
	   (select distinct top 1 productversion0 from v_GS_INSTALLED_SOFTWARE sft where sft.ProductName0 = 'Qualys CLoud Security Agent' and sft.ResourceID = sys.resourceid order by ProductVersion0 Desc) [Qualys],
	   (select distinct top 1 productversion0 from v_GS_INSTALLED_SOFTWARE sft where sft.ProductName0 like 'Citrix%Virtual Delivery Agent%' and sft.ResourceID = sys.resourceid order by ProductVersion0 Desc) [VDA],
	   (select distinct top 1 Version0 from v_Add_Remove_Programs sft where sft.ProdID0 = 'Zscaler' and sft.ResourceID = sys.resourceid order by Version0 Desc) [zScaler]
from v_R_System sys left join
	 v_GS_TPM tpm on sys.ResourceID = tpm.ResourceID left join
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP on sys.ResourceID = csp.ResourceID left join
	 v_GS_OPERATING_SYSTEM OS on sys.resourceid = os.resourceid left join
	 v_GS_LOGICAL_DISK DISK on sys.ResourceID = disk.ResourceID and disk.DeviceID0 = 'c:' left join
	 v_GS_PHYSICAL_MEMORY RAM on sys.ResourceID = ram.ResourceID left join
	 v_GS_FIRMWARE UEFI on sys.ResourceID = uefi.ResourceID left join
	 v_GS_PROCESSOR CPU on sys.ResourceID = cpu.ResourceID left join
	 v_CH_ClientSummary cs on sys.ResourceID = cs.ResourceID
where   sys.Resource_Domain_OR_Workgr0 != 'HMHSCHAMP' and 
		sys.netbios_name0 in (select value from @WKIDs)
order by Domain, WKID

-- Precache data
DECLARE @WKIDs table (Value varchar(1000))
insert into @WKIDs values ('wkmj059g4b'),('citpxewpw02'),('WKMJ064ACH'),('simxdwtssa1074'),('DSIPXEWPW40'),('CISPXEWQW02'),('WKR90NMUWG'),('WKR90NMUWG'),('WKR90P2RG5'),('WKR90RJ20H'),('WKR90RNERG'),('WKR90SZM2G'),
						  ('WKMJ05ZYYZ'),('WKMJ060C8V'),('WKMJ060CAC'),('WKMJ060CAM'),('WKMJ060CAP'),('WKMJ060CAW')
DECLARE @VM table (Value int)
insert into @VM values (0),(1)

SELECT distinct Hostname, 
(SELECT top 1 cd0.[Percent] FROM [ActiveEfficiency].[dbo].[contents] c0 INNER JOIN [ActiveEfficiency].[dbo].[contentdeliveries] cd0 ON cd.ContentId = c0.id LEFT JOIN
		[ActiveEfficiency].[dbo].[devices] d0 ON d0.Id = cd0.DeviceId LEFT JOIN	[ConfigMGRLink].[CM_WP1].[DBO].v_Package PKG0 ON C0.ContentName COLLATE database_default = PKG0.packageid COLLATE database_default
where d0.HostName = d.hostname and c0.Version = 2 and c0.ContentName = 'WP10045D' 
order by cd0.[Percent] desc) [1803 Image], 
(SELECT top 1 cd1.[Percent] [IPU notif] FROM [ActiveEfficiency].[dbo].[contents] c1 INNER JOIN [ActiveEfficiency].[dbo].[contentdeliveries] cd1 ON cd1.ContentId = c1.id LEFT JOIN
		[ActiveEfficiency].[dbo].[devices] d1 ON d1.Id = cd1.DeviceId LEFT JOIN [ConfigMGRLink].[CM_WP1].[DBO].v_Package PKG1 ON C1.ContentName COLLATE database_default = PKG1.packageid COLLATE database_default
where d1.HostName = d.hostname and c1.Version = 7 and c1.ContentName = 'WP1005C7'
order by cd.[Percent] desc) [IPU Notif],
(SELECT top 1 cd2.[Percent] FROM [ActiveEfficiency].[dbo].[contents] c2 INNER JOIN [ActiveEfficiency].[dbo].[contentdeliveries] cd2 ON cd.ContentId = c2.id LEFT JOIN
		[ActiveEfficiency].[dbo].[devices] d2 ON d2.Id = cd2.DeviceId LEFT JOIN [ConfigMGRLink].[CM_WP1].[DBO].v_Package PKG2 ON C2.ContentName COLLATE database_default = PKG2.packageid COLLATE database_default
where d2.HostName = d.hostname and c2.Version = 3 and c2.ContentName = 'WP100417' 
order by cd.[Percent] desc) [Setupdiag]
FROM    [ActiveEfficiency].[dbo].[contents] c LEFT JOIN
		[ActiveEfficiency].[dbo].[contentdeliveries] cd ON cd.ContentId = c.id FULL JOIN
		[ActiveEfficiency].[dbo].[devices] d ON d.Id = cd.DeviceId FULL JOIN
		[ConfigMGRLink].[CM_WP1].[DBO].v_Package PKG ON C.ContentName COLLATE database_default = PKG.packageid COLLATE database_default
where d.HostName in (select value from @WKIDs)
order by d.HostName

-- Precache - Lenovo drivers
DECLARE @WKIDs table (Value varchar(1000))
insert into @WKIDs values ('wkmj059g4b'),('citpxewpw02'),('WKMJ064ACH'),('simxdwtssa1074'),('DSIPXEWPW40'),('CISPXEWQW02'),('WKR90NMUWG'),('WKR90NMUWG'),('WKR90P2RG5'),('WKR90RJ20H'),('WKR90RNERG'),('WKR90SZM2G'),
						('WKMJ05ZYYZ'),('WKMJ060C8V'),('WKMJ060CAC'),('WKMJ060CAM'),('WKMJ060CAP'),('WKMJ060CAW')

DECLARE @VM table (Value int)
insert into @VM values (0),(1)

SELECT distinct HostName, ContentName [PKG_ID], PKG.NAME + ' ' + PKG.version [Package_Name], MAX(cd.[Percent]) [Percent], MAX(c.[Version]) [Version]
FROM    [ActiveEfficiency].[dbo].[contents] c INNER JOIN
		[ActiveEfficiency].[dbo].[contentdeliveries] cd ON cd.ContentId = c.id FULL JOIN
		[ActiveEfficiency].[dbo].[devices] d ON d.Id = cd.DeviceId FULL JOIN
		[ConfigMGRLink].[CM_WP1].[DBO].v_Package PKG ON C.ContentName COLLATE database_default = PKG.packageid COLLATE database_default LEFT JOIN
		[ConfigMGRLink].[CM_WP1].[DBO].vSMS_CombinedDeviceResources CDR ON d.HostName COLLATE database_default = CDR.Name COLLATE database_default LEFT JOIN
		[ConfigMGRLink].[CM_WP1].[DBO].v_gs_computer_system_product CSP ON CDR.MachineID = CSP.ResourceID
where d.HostName in (select value from @WKIDs) and pkg.Name like 'Drivers - %' + csp.version0 + '%'
group by HostName, ContentName, PKG.NAME + ' ' + PKG.version
order by hostname, PKG_ID, [Version] desc, [Percent] desc