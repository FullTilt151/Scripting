select sys.Operating_System_Name_and0, FileName, FileVersion, Count(*)
from v_r_system SYS inner join 
	 v_GS_SoftwareFile SF ON sys.resourceid = sf.resourceid
where FilePath = 'c:\program files\internet explorer\' and
	  FileName = 'iexplore.exe' and
	  sys.Operating_System_Name_and0 like '%workstation%'
group by Operating_System_Name_and0, FileName, FileVersion
order by operating_system_name_and0, FileVersion