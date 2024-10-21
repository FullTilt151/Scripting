-- List of Ctera WKIDs via add/remove
select sys.netbios_name0, sft.Publisher0, sft.ProductName0, sft.ProductVersion0
from v_r_system_valid sys join
	 v_gs_installed_software sft on sys.resourceid = sft.ResourceID
where ProductName0 = 'Humana Agent'
order by Netbios_Name0

-- List of Ctera WKIDs via file name
select sys.Netbios_Name0, sf.FilePath, sf.FileName
from v_R_System_Valid sys join
	 v_GS_SoftwareFile sf on sys.ResourceID = sf.ResourceID
where FileName = 'CTERAAgent.exe'
order by Netbios_Name0