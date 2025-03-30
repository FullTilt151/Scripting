-- Firefox files
select sys.Netbios_Name0, sys.User_Name0, usr.Full_User_Name0, usr.title0, usr.department0, sft.FilePath, sft.FileName
from v_r_system_valid sys join
	 v_GS_SoftwareFile sft on sys.ResourceID = sft.ResourceID join
	 v_R_User usr on sys.User_Name0 = usr.User_Name0
where FileName = 'firefox.exe' and operating_system_name_and0 like '%10.0%' and 
filepath not in (
'C:\RPAExpress\Applications\FirefoxPortable\App\Firefox\',
'C:\RPAExpress\Applications\FirefoxPortable\App\Firefox64\',
'C:\Program Files (x86)\HP\LoadRunner\bin\firefox\',
'C:\Program Files (x86)\HP\Virtual User Generator\bin\firefox\',
'C:\Program Files (x86)\HPE\Virtual User Generator\bin\firefox\'
)
order by FilePath

-- Firefox system installs
select sys.Name, 
	   case DeviceOS
	   when 'Microsoft Windows NT Workstation 6.1' then 'Win7'
	   when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Win7'
	   when 'Microsoft Windows NT Workstation 10.0' then 'Win10'
	   when 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Win10'
	   else DeviceOS
	   end [OS], 
	   sys.Domain, sys.UserName, usr.Full_User_Name0, usr.title0, usr.department0, sft.ProductName0
from v_CombinedDeviceResources sys inner join
	 v_gs_installed_software sft on sys.MachineID = sft.ResourceID left join
	 v_R_User usr on sys.UserName = usr.User_Name0
where productname0 like 'Mozilla Firefox%' and DeviceOS in ('Microsoft Windows NT Workstation 10.0','Microsoft Windows NT Workstation 10.0 (Tablet Edition)') 
	  and Name not like 'LOUXDWMIBA%'
	  and Domain != 'HMHSCHAMP'
order by department0, title0, Name