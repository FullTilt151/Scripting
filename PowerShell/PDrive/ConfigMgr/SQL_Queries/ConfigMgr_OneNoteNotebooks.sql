-- List of OneNote notebooks by WKID
select sys.Netbios_Name0 [WKID], one.User0 [User], one.Notebook0, one.ScriptLastRan0
from v_R_System_Valid sys left join
	 v_GS_ONE_NOTE_NETWORK_NOTEBOOKS one on sys.ResourceID = one.ResourceID
where sys.Netbios_Name0 in (@WKID)
order by Netbios_Name0, one.User0, one.Notebook0

-- List of users and notebooks
select netbios_name0, one.User0, notebook0, scriptlastran0
from v_r_system_valid sys join
	 v_gs_one_note_network_notebooks one on sys.ResourceID = one.ResourceID
order by Netbios_Name0, User0, Notebook0