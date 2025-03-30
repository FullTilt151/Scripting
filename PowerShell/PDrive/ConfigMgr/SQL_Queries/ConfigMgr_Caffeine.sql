select netbios_name0, sys.User_Name0, usr.Full_User_Name0, usr.title0, usr.department0, FileName, FileVersion, FilePath
from v_R_System_Valid sys join
	 v_gs_softwarefile exe on sys.resourceid = exe.resourceid left join
	 v_R_User usr on sys.User_Name0 = usr.User_Name0
where filename = 'caffeine.exe'
order by Netbios_Name0