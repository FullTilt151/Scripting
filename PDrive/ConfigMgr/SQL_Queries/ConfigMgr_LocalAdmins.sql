-- List of workstations, local admins, and OUs
select distinct Netbios_Name0 WKID, System_OU_Name0 [OU] ,Category0 [Account Category],Account0 Account, Full_User_Name0 [Friendly Name] , Type0 [Account Type],Domain0 Domain,v_gs_custom_localgroupmembers0.Name0 [Group]
from v_GS_CUSTOM_LocalGroupMembers0 FULL join
	v_R_System on v_R_System.ResourceID=v_GS_CUSTOM_LocalGroupMembers0.ResourceID FULL JOIN
	v_r_user on v_GS_CUSTOM_LocalGroupMembers0.Account0 = v_r_user.user_name0 FULL JOIN
	v_ra_system_systemouname ON v_r_system.resourceid = v_ra_system_systemouname.resourceid
where v_GS_CUSTOM_LocalGroupMembers0.Name0 = 'Administrators' and
	  v_GS_CUSTOM_LocalGroupMembers0.Account0 != 'Administrator' and
	  v_GS_CUSTOM_LocalGroupMembers0.Account0 != 'Domain Admins' and
	  v_GS_CUSTOM_LocalGroupMembers0.Account0 != 'G_WKS_ADMIN' and
	  System_OU_Name0 = @OU
order by OU, WKID,Account

-- List of OUs
select distinct System_OU_Name0 [OU]
from v_RA_System_SystemOUName
WHERE System_OU_Name0 like '%ADMINACCESS%'
ORDER BY OU

-- List of workstations, local admins, and OUs
select distinct sys1.Netbios_Name0 WKID, sys1.Resource_Domain_OR_Workgr0 [WKID Domain], max(v_ra_system_systemouname.System_OU_Name0) [OU] , Category0 [Account Category],Account0 Account, Full_User_Name0 [Friendly Name] , Type0 [Account Type],Domain0 [User Domain],LGM.Name0 [Group]
from v_GS_CUSTOM_LocalGroupMembers0 LGM FULL join
	v_R_System_Valid sys1 on sys1.ResourceID=LGM.ResourceID FULL JOIN
	v_r_user on LGM.Account0 = v_r_user.user_name0 FULL JOIN
	v_ra_system_systemouname ON sys1.resourceid = v_ra_system_systemouname.resourceid
where LGM.Name0 = 'Administrators' and
	  LGM.Account0 not in ('Administrator','Domain Admins','G_WKS_ADMIN','CtxAppVCOMAdmin')  and
	  sys1.Resource_Domain_OR_Workgr0 in (@Domain)
group by sys1.Netbios_Name0 , sys1.Resource_Domain_OR_Workgr0, Category0, Account0, Full_User_Name0, Type0,Domain0 , LGM.Name0
order by OU, WKID, Account

-- Count of account with local admin
select Account0, count(*) [Total]
from v_R_System_Valid sys join
	 v_GS_LocalGroupMembers0 lgm on sys.ResourceID = lgm.ResourceID
where Name0 = 'Administrators' and Account0 not in ('Administrator','CtxAppVCOMAdmin')
group by Account0
having count(*) > 10
order by count(*) desc