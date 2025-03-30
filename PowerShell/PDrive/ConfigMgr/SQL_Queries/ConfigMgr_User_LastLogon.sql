select netbios_name0, Operating_System_Name_and0, usr.LocalPath0, usr.LastUseTime0, nlp.name0, nlp.LastLogon0
from v_r_system_valid sys left join
	 v_GS_USER_PROFILE usr on sys.resourceid = usr.ResourceID left join
	 v_GS_NETWORK_LOGIN_PROFILE NLP on sys.ResourceID = nlp.ResourceID
where (Netbios_Name0 like 'SIMDEVWDS%' or Netbios_Name0 like 'LOUDEVWDS%') and
		sys.resourceid in (
		select resourceid
		from v_gs_installed_software
		where productname0 like 'Microsoft Biztalk%') and
		usr.LocalPath0 not like '%a' and usr.LocalPath0 not like '%s' and usr.LocalPath0 not in (
		'C:\Users\Administrator','C:\Users\BTServerAcct','C:\Users\SQL_Server_Service','C:\Windows\ServiceProfiles\NetworkService','C:\Windows\ServiceProfiles\LocalService','C:\Windows\system32\config\systemprofile',
		'C:\Users\ecmadmin','C:\Users\btservice.humad','C:\Users\k2srvact') and
		nlp.Name0 like 'HUMAD\%' and nlp.Name0 not like '%s' and nlp.Name0 not like '%a' and nlp.Name0 not in (
		'HUMAD\SQL_Server_Service','HUMAD\ECMADMIN','HUMAD\BTService')
order by Netbios_Name0