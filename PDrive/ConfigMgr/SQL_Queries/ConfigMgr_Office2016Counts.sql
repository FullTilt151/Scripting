-- Mike's query
select distinct DisplayName0, Version0, count(*)
from v_R_System_Valid sys join
	 v_add_remove_programs arp on sys.ResourceID = arp.ResourceID
where displayname0 = 'Microsoft Office Professional Plus 2016' and
	  ProdID0 = '{90160000-0011-0000-0000-0000000FF1CE}'
group by DisplayName0, Version0

-- Daniel's ARP query
select DisplayName0, Version0, count(*)
from v_R_System_Valid sys join
	 v_Add_Remove_Programs arp on sys.ResourceID = arp.ResourceID
where DisplayName0 in ('Microsoft Office Professional Plus 2016 - en-us', 'Microsoft Office Professional Plus 2016') and
	 ProdID0 in ('Office16.PROPLUS','ProPlusRetail - en-us')
group by DisplayName0, Version0
order by DisplayName0, Version0

-- Daniel's AI query
select ProductName0, ProductVersion0, count(*)
from v_r_system_valid sys join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where ProductName0 in ('Microsoft Office Professional Plus 2016 - en-us', 'Microsoft Office Professional Plus 2016')
group by ProductName0, ProductVersion0
order by ProductName0, ProductVersion0