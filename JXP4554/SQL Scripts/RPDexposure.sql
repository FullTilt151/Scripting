select Netbios_Name0, Resource_Domain_OR_Workgr0, Operating_System_Name_and0, scu.TopConsoleUser0, usr.Full_User_Name0, title0, department0
from v_R_System_Valid sys join
	 v_GS_SYSTEM_CONSOLE_USAGE scu on sys.ResourceID = scu.ResourceID left join
	 v_R_User usr on scu.TopConsoleUser0 = usr.Unique_User_Name0
where Netbios_Name0 in (
'WKMJFYVNH',
'WKPF0DMRYE',
'WKMPMP3Y2XV',
'WKMJ06RW3W',
'WKPC0J4RQG',
'WKPC0J25N5',
'WKR90F91NL',
'WKHGBLA0046763'
)