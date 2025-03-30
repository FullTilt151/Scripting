select netbios_name0, Operating_System_Name_and0, Resource_Domain_OR_Workgr0, Is_Virtual_Machine0, Is_MachineChanges_Persisted0
from v_r_system SYS
where (operating_system_name_and0 = 'Microsoft Windows NT Workstation 6.1' or 
	  operating_system_name_and0 = 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)') and
	  Resource_Domain_OR_Workgr0 != 'HMHSCHAMP' and
	  Client0 = 1 and
	  sys.ResourceID not in (
	    select ResourceID
		from v_GS_QUICK_FIX_ENGINEERING
		where HotFixID0 = 'KB2775511') and
		Is_Virtual_Machine0 = '1' and is_MachineChanges_Persisted0 = '1'
order by Netbios_Name0