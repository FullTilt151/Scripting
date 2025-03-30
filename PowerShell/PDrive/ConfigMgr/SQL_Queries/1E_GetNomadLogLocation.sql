select Netbios_Name0, LogFileName0
from v_GS_NomadBranch640 NB
join v_R_System_Valid sys on sys.ResourceID = nb.ResourceID
where Netbios_Name0 like '%pxe%'
order by LogFileName0
