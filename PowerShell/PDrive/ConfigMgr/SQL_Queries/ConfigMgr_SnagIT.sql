-- Snagit installs count
select distinct displayname0 [Product], count(*) [Total]
from v_r_system_valid sys join
	 v_add_remove_programs arp on sys.resourceid = arp.resourceid
where displayname0 like 'Snagit%' and sys.resourceid not in (select resourceid from v_Add_Remove_Programs where displayname0 like 'Snagit Stamps%')
group by Displayname0
order by displayname0

-- Snagit installs list
select distinct sys.Netbios_Name0 [WKID], displayname0 [Product], version0 [Version]
from v_r_system_valid sys join
	 v_add_remove_programs arp on sys.resourceid = arp.resourceid
where displayname0 like 'Snagit%' and sys.resourceid not in (select resourceid from v_Add_Remove_Programs where displayname0 like 'Snagit Stamps')

-- Snagit unused installs
select distinct sys.Netbios_Name0 [WKID], sys.User_Name0 [User], displayname0 [Product], version0 [Version],
		(select max(rua.LastUsedTime0)
		from v_GS_CCM_RECENTLY_USED_APPS rua
		where (FileDescription0 like '%snag%' or productname0 like '%snag%') and sys.resourceid = rua.resourceid) [LastUsed]
from v_r_system_valid sys join
	 v_add_remove_programs arp on sys.resourceid = arp.resourceid
where displayname0 like 'Snagit%' and sys.ResourceID not in (
select resourceid
from v_GS_CCM_RECENTLY_USED_APPS
where (FileDescription0 like '%snag%' or productname0 like '%snag%') and DATEDIFF(dd,getdate(),lastusedtime0) > -7)

-- Snagit raw usage by date
select ExplorerFileName0, FileDescription0, FolderPath0, LastUsedTime0, LastUserName0, ProductName0, ProductVersion0
from v_GS_CCM_RECENTLY_USED_APPS
where (FileDescription0 like '%snag%' or productname0 like '%snag%') and DATEDIFF(dd,getdate(),lastusedtime0) > -7
order by LastUsedTime0 desc

-- Snagit usage counts
select ExplorerFileName0, FileDescription0, FolderPath0, ProductName0, ProductVersion0, count(*) [Total]
from v_GS_CCM_RECENTLY_USED_APPS
where FileDescription0 like '%snag%' or productname0 like '%snag%'
group by ExplorerFileName0, FileDescription0, FolderPath0, ProductName0, ProductVersion0
having count(*) >2
order by explorerfilename0, folderpath0