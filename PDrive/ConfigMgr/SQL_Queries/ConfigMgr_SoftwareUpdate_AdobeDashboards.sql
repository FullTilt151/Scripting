/*
###### ADOBE READER #####
*/

-- List of workstations and Reader version
select netbios_name0, FileName, FilePath, FileVersion
from v_r_system SYS join
	 v_GS_SoftwareFile SF on sys.ResourceID = sf.ResourceID
where netbios_name0 like 'AEC%' and Operating_System_Name_and0 like '%workstation%' and
	  FileName = 'AcroRd32.exe' and FilePath like 'C:\Program Files%Adobe%Reader%'
order by FileVersion

-- Count of workstations and Reader version
select FileName, FilePath, FileVersion,count(*)
from v_r_system SYS join
	 v_GS_SoftwareFile SF on sys.ResourceID = sf.ResourceID
where netbios_name0 like 'AEC%' and Operating_System_Name_and0 like '%workstation%' and
	  FileName = 'AcroRd32.exe' and FilePath like 'C:\Program Files%Adobe%Reader%'
group by FileName, FilePath, FileVersion

/*
###### ADOBE FLASH PLAYER #####
*/

-- List of workstations and x64 and x86 Flash version
select distinct Netbios_Name0 [WKID], Resource_Domain_OR_Workgr0 [Domain], FileVersion, FilePath
from v_r_system SYS join
	 v_GS_SoftwareFile SF ON sys.ResourceID = sf.ResourceID
where operating_system_name_and0 like '%workstation%' and
	  (FilePath = 'C:\Windows\SysWOW64\Macromed\Flash\' or FilePath = 'C:\WINDOWS\system32\Macromed\Flash\') and
	  SYS.ResourceID IN (
	  select ResourceID
	  from v_FullCollectionMembership
	  where CollectionID = @Collection)
order by FileVersion, Netbios_Name0

-- Count of workstations and x64 Flash version
select distinct FilePath, FileVersion, count(distinct Netbios_Name0) [Total]
from v_r_system SYS join
	 v_GS_SoftwareFile SF ON sys.ResourceID = sf.ResourceID
where operating_system_name_and0 like '%workstation%' and
	  (FilePath = 'C:\WINDOWS\system32\Macromed\Flash\') and
	  SYS.ResourceID IN (
	  select ResourceID
	  from v_FullCollectionMembership
	  where CollectionID = @Collection)
group by FileVersion, FilePath
order by FileVersion, FilePath

-- Count of workstations and x86 Flash version
select distinct FilePath, FileVersion, count(distinct Netbios_Name0) [Total]
from v_r_system SYS join
	 v_GS_SoftwareFile SF ON sys.ResourceID = sf.ResourceID
where operating_system_name_and0 like '%workstation%' and
	  (FilePath = 'C:\WINDOWS\syswow64\Macromed\Flash\') and
	  SYS.ResourceID IN (
	  select ResourceID
	  from v_FullCollectionMembership
	  where CollectionID = @Collection)
group by FileVersion, FilePath
order by FileVersion, FilePath

/*
###### Collections #####
*/

-- Collection List with count of members
select CollectionID, Name + ' (' + CAST(MemberCount as nvarchar) + ')' [Name & Count]
from v_Collection
where MemberCount > 1
order by [Name & Count]