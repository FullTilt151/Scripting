select distinct sft.ProductName0, sft.ProductVersion0, count(*)
from v_r_system_valid sys join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where ProductName0 = 'Recast RCT' or ProductName0 = 'Right click Tools'
group by sft.ProductName0, sft.ProductVersion0
order by sft.ProductName0, sft.ProductVersion0

select distinct sft.ProductName0, sft.ProductVersion0, sft.UninstallString0
from v_r_system_valid sys join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where ProductName0 = 'Recast RCT' or ProductName0 = 'Right click Tools'
order by sft.ProductName0, sft.ProductVersion0