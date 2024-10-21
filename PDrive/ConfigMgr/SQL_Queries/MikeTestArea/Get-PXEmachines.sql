Select *
from v_R_System_Valid 
where Netbios_Name0 like '%pxe%'
order by AD_Site_Name0 --= 'Louisville'

select *
from v_GS_ADD_REMOVE_PROGRAMS_64
where DisplayName0 = '1E Nomadbranch x64'
order by version0 desc