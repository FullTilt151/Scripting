-- List of all local user accounts
select sys.Netbios_Name0 [WKID], sys.Resource_Domain_OR_Workgr0 [Domain], lua.Name0 [Username], lua.Description0 [Description], lua.Disabled0 [Disabled]
from v_r_system SYS join
	 v_gs_localuseraccounts0 LUA on sys.resourceid = lua.resourceid
where sys.Operating_System_Name_and0 like '%workstation%' and
	  sys.Client0 = '1' and
	  sys.Resource_Domain_OR_Workgr0 = 'HUMAD' and
	  lua.Name0 != 'Administrator' and
	  lua.Name0 != 'humguest' and
	  lua.Name0 != 'SMSNomadP2P&' and
	  lua.Name0 not like 'NomadNMDS%'
order by sys.Netbios_Name0

-- Count of all local user accounts
select lua.Name0 [Username], lua.Description0 [Description], lua.Disabled0 [Disabled], count(*) [Total]
from v_r_system SYS join
	 v_gs_localuseraccounts0 LUA on sys.resourceid = lua.resourceid
where sys.Operating_System_Name_and0 like '%workstation%' and
	  sys.Client0 = '1' and
	  sys.Resource_Domain_OR_Workgr0 = 'HUMAD' and
	  lua.Name0 != 'Administrator' and
	  lua.Name0 != 'humguest' and
	  lua.Name0 != 'SMSNomadP2P&' and
	  lua.Name0 not like 'NomadNMDS%'
group by lua.Name0, lua.Description0, lua.Disabled0
order by count(*) desc