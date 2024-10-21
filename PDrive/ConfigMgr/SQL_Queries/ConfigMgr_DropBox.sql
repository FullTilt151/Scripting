select Netbios_name0, sys.User_Name0 , usr.Full_User_Name0, FileName, FileVersion, FilePath
from v_r_system SYS full join
	 v_GS_SoftwareFile sft ON sys.resourceid = sft.ResourceID full join
	 v_R_User usr ON sys.User_Name0 = usr.User_Name0
where FileName = 'dropbox.exe'
order by Netbios_Name0