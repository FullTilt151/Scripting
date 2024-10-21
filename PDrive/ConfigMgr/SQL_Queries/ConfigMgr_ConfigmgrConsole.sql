-- Count of console installs
select arp.ProductName0, arp.ProductVersion0, count(*)
from v_R_System_Valid sys join
	 v_GS_INSTALLED_SOFTWARE arp on sys.ResourceID = arp.ResourceID
where arp.ProductName0 in ('Microsoft Endpoint Configuration Manager Console')
group by arp.ProductName0, arp.ProductVersion0
order by arp.ProductName0, arp.ProductVersion0

-- List of console installs and usage
select distinct sys.Netbios_Name0 [Name], ProductName0, ProductVersion0, 
		(select max(LastUsedTime0)
		from v_GS_CCM_RECENTLY_USED_APPS 
		where resourceid = sys.ResourceID and ExplorerFileName0 = 'Microsoft.ConfigurationManagement.exe') [Last Used]
from v_R_System_Valid sys join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where ProductName0 in ('Microsoft Endpoint Configuration Manager Console')
order by [Last Used] desc

-- Uninstall keys
select ProductName0, ProductVersion0, UninstallString0, count(*)
from v_R_System_Valid sys inner join
	 v_GS_INSTALLED_SOFTWARE sft on sys.resourceid = sft.resourceid
where sft.ProductName0 in ('Microsoft Endpoint Configuration Manager Console')
group by ProductName0, ProductVersion0, UninstallString0
order by ProductVersion0 desc

/*
Microsoft Endpoint Configuration Manager Console
Microsoft System Center 2012 Configuration Manager Console
Microsoft System Center Configuration Manager 2007 Console
System Center 2012 R2 Configuration Manager Console
System Center Configuration Manager Console
*/

-- Now Micro RCT
select Publisher0, ProductName0, ProductVersion0, count(*)
from v_gs_installed_software
where Publisher0 = 'Now Micro' or Publisher0 in ('Recast Software','Recast Software, Inc.')
group by Publisher0, ProductName0, ProductVersion0
order by ProductVersion0