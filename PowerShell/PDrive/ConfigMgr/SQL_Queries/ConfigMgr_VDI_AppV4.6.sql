select Name0, ARPDisplayName0, ProductVersion0, InstallDate0
from v_GS_INSTALLED_SOFTWARE inner join
v_R_System on v_GS_INSTALLED_SOFTWARE.ResourceID = v_r_system.ResourceID
where Name0 like '%xdw%' and ARPDisplayName0 like '%virtualization%' and
	ProductVersion0 like '4.6%'
	order by Name0, ARPDisplayName0, InstallDate0
	
select distinct sys.Name0 --, appv.Name0 
from v_R_System sys inner join
v_GS_VIRTUAL_APPLICATION_PACKAGES appv on appv.ResourceID = sys.ResourceID
where sys.Name0 like '%xdw%'
order by sys.Name0