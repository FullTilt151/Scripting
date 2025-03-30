select Publisher0 [Vendor], ProductName0 [Product], ProductVersion0 [Version], count(*) As Count
from v_r_system SYS join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where (ProductName0 like '%Systems Management Agent%')
group by ProductName0, ProductVersion0, Publisher0
order by Count DESC

select ProdID0 [Product], Version0 [Version], count(*) As Count
from v_r_system SYS join
	 v_Add_Remove_Programs sft on sys.ResourceID = sft.ResourceID
where sft.ProdID0 like '%SysTrack%'
group by ProdID0, Version0
order by Count Desc