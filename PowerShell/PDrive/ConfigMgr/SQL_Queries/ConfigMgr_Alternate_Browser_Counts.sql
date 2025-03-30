-- Google Chrome Counts
select DisplayName0 [Product], Version0 [Version], count(*) [Total]
from v_add_remove_programs ARP join
	 v_r_system SYS ON ARP.ResourceID = sys.ResourceID
where displayname0 = 'Google Chrome' and Operating_System_Name_and0 like '%workstation%'
group by DisplayName0, Version0
order by Version0

-- Google Chrome version conversion
select displayname0, version0, sf.filename, FileVersion, count(*)
from v_add_remove_programs ARP join
	 v_gs_softwarefile SF ON arp.ResourceID = sf.ResourceID
	 where DisplayName0 = 'Google Chrome' and sf.FileName = 'chrome.exe' and sf.FilePath = 'C:\Program Files (x86)\Google\Chrome\Application\' and version0 like '6%'
	 group by displayname0, version0, sf.filename, FileVersion
	 order by FileVersion

--66.40.49217 and that is really chrome 39.0.2171.65

--Mozilla Firefox counts
select DisplayName0 [Product], Version0 [Version], count(*) [Total]
from v_Add_Remove_Programs ARP join
	 v_r_system SYS ON arp.ResourceID = sys.ResourceID
where DisplayName0 like 'Mozilla Firefox%' and Publisher0 = 'Mozilla' and Operating_System_Name_and0 like '%workstation%'
group by Publisher0, DisplayName0, Version0
order by cast('/' + replace(replace(Version0,' (en-US)','') , '.', '/') + '/' as hierarchyid)

-- Opera counts
select DisplayName0 [Product], Version0 [Version], count(*) [Total]
from v_Add_Remove_Programs ARP join
	 v_r_system SYS ON ARP.ResourceID = SYS.ResourceID
where Publisher0 = 'Opera Software ASA' and Operating_System_Name_and0 like '%workstation%'
group by DisplayName0, Version0
order by cast('/' + replace(Version0 , '.', '/') + '/' as hierarchyid)