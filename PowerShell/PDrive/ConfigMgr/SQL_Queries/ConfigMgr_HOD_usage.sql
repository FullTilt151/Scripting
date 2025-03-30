-- List of workstations and last time HOD was used
select distinct sys.Netbios_Name0, sys.Resource_Domain_OR_Workgr0 [Domain],
	   case sys.Operating_System_Name_and0
	   when 'Microsoft Windows NT Workstation 5.1' then 'Windows XP'
	   when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.1' then 'Windows 8.1'
	   when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 8.1'
	   else 'Other'
	   end [OS],
		(select distinct MAX(cast(LastModified0 as datetime2))
		from v_GS_HOD HOD1
		where sys.resourceid = hod1.ResourceID) [HOD Last Used], 
		(select top 1 DisplayName0
		from v_Add_Remove_Programs arp1
		where (DisplayName0 like 'Java 7 Update%' or
			  DisplayName0 like 'Java 8 Update%' or
			  DisplayName0 like 'Java(TM) 6 Update%' or
			  DisplayName0 like 'Java(TM) 7%') and
			  sys.resourceid = arp1.ResourceID ) [JRE]
from v_GS_HOD HOD left join
	 v_r_system SYS on HOD.ResourceID = sys.ResourceID join
	 v_Add_Remove_Programs ARP on sys.ResourceID = arp.ResourceID 
where sys.Client0 = '1' and
	  hod.LastModified0 IS NOT NULL
order by Netbios_Name0

-- Workstations that have not used HOD in last X days
select distinct sys.Netbios_Name0 [WKID], sys.Resource_Domain_OR_Workgr0 [Domain] ,
		case sys.Operating_System_Name_and0
	   when 'Microsoft Windows NT Workstation 5.1' then 'Windows XP'
	   when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.1' then 'Windows 8.1'
	   when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 8.1'
	   else 'Other'
	   end [OS],
		(select distinct MAX(cast(LastModified0 as datetime2))
		from v_GS_HOD HOD1
		where sys.resourceid = hod1.ResourceID) [Last Used HOD date], 
		(select distinct DATEDIFF(dd,max(cast(lastmodified0 as datetime2)),getdate())
		from v_GS_HOD HOD2
		where sys.resourceid = hod2.ResourceID)  [Last Used HOD days], 
		(select top 1 DisplayName0
		from v_Add_Remove_Programs arp1
		where (DisplayName0 like 'Java 7 Update%' or
			  DisplayName0 like 'Java 8 Update%' or
			  DisplayName0 like 'Java(TM) 6 Update%' or
			  DisplayName0 like 'Java(TM) 7%') and
			  sys.resourceid = arp1.ResourceID ) [JRE]
from v_r_system SYS left join
	v_gs_hod HOD on sys.ResourceID = hod.ResourceID left join
	v_Add_Remove_Programs ARP on sys.ResourceID = arp.ResourceID
where sys.Client0 = '1' and
	  sys.Operating_System_Name_and0 like '%workstation%' and
	  sys.Resource_Domain_OR_Workgr0 != 'HMHSCHAMP' and
	  (DATEDIFF(dd,cast(lastmodified0 as datetime2),getdate()) > 7 or
	  hod.LastModified0 is null)
order by sys.Netbios_Name0