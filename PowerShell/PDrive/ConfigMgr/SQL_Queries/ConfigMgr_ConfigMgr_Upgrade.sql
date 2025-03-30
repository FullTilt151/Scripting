-- 1E Shopping agents
select arp.DisplayName0, arp.Version0, count(*)
from v_R_System_Valid sys join
	 v_Add_Remove_Programs arp on sys.ResourceID = arp.ResourceID
where arp.DisplayName0 in ('1E Shopping Client Identity','1E Shopping Agent')
group by arp.DisplayName0, arp.Version0

-- 1E Nomad agents
select arp.DisplayName0, arp.Version0, count(*)
from v_R_System_Valid sys join
	 v_Add_Remove_Programs arp on sys.ResourceID = arp.ResourceID
where arp.DisplayName0 in ('1E NomadBranch x64','1E Nomad Branch Admin Extensions 2012')
group by arp.DisplayName0, arp.Version0
order by DisplayName0, Version0

-- Most recent active clients
select Netbios_Name0, cs.LastActiveTime
from v_r_system_valid sys join
	 v_ch_clientsummary cs on sys.resourceid = cs.resourceid
where Resource_Domain_OR_Workgr0 != 'HMHSCHAMP' and Operating_System_Name_and0 in ('Microsoft Windows NT Workstation 6.1','Microsoft Windows NT Workstation 6.1 (Tablet Edition)')
	  and Netbios_Name0 not like 'GRBAPPWPW%' and cs.LastActiveTime > dateadd(hh,1,getdate())
order by LastActiveTime desc

-- Total clients
select count(*)
from v_r_system_valid

-- Clients missing Hardware inventory
select case 
	   when cs.LastHW is null then ' '
	   when cs.LastHW is not null then 'X'
	   end HW, count(*)
from v_r_system_valid sys join
	 v_CH_ClientSummary cs on sys.ResourceID = cs.ResourceID
	   group by case 
	   when cs.LastHW is null then ' '
	   when cs.LastHW is not null then 'X'
	   end

-- Client push stats
select status, Description, count(*)
from v_CP_Machine
group by status, Description
order by Status

select *
from v_CP_Machine 
order by InitialRequestDate desc

-- Content distribution
SELECT DISTINCT CDR.DPNALPath AS DPNalPath, UPPER(SUBSTRING(CDR.DPNALPath,13,CHARINDEX('.', CDR.DPNALPath) -13)) AS ServerName,
				CDR.PkgCount AS Targeted, CDR.NumberInstalled AS Installed, CDR.PkgCount-CDR.NumberInstalled AS NotInstalled,
				PSd.SiteCode AS ReportingSite, ROUND((100 * CDR.NumberInstalled/CDR.pkgcount), 2) AS Compliance
 FROM v_ContentDistributionReport_DP CDR LEFT JOIN 
	  v_PackageStatusDistPointsSumm PSd ON CDR.DPNALPath=PSD.ServerNALPath