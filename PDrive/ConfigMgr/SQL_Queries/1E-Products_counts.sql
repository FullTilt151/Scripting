--ActiveEfficiency
select distinct SW.ProductName0 as Product, SW.ProductVersion0 as Version, count(*) as Total
from v_R_System_Valid SYS
inner join v_gs_installed_software SW
on SYS.ResourceID = SW.ResourceID
where SW.ProductName0 = '1E ActiveEfficiency Agent x64'
group by SW.ProductName0, SW.ProductVersion0
order by SW.ProductName0, SW.ProductVersion0

--1E Agent
select distinct SW.ProductName0 as Product, SW.ProductVersion0 as Version, count(*) as Total
from v_R_System_Valid SYS
inner join v_gs_installed_software SW
on SYS.ResourceID = SW.ResourceID
where SW.ProductName0 = '1E Agent'
group by SW.ProductName0, SW.ProductVersion0
order by SW.ProductName0, SW.ProductVersion0

--NomadBranch/x64
select distinct SW.ProductName0 as Product, SW.ProductVersion0 as Version, count(*) as Total
from v_R_System_Valid SYS
inner join v_gs_installed_software SW
on SYS.ResourceID = SW.ResourceID
where SW.ProductName0 in ('1E NomadBranch', '1E NomadBranch x64')
group by SW.ProductName0, SW.ProductVersion0
order by SW.ProductName0, SW.ProductVersion0

--PXE Lite
select distinct SW.ProductName0 as Product, SW.ProductVersion0 as Version, count(*) as Total
from v_R_System_Valid SYS
inner join v_gs_installed_software SW
on SYS.ResourceID = SW.ResourceID
where SW.ProductName0 = '1E PXE Lite Local'
group by SW.ProductName0, SW.ProductVersion0
order by SW.ProductName0, SW.ProductVersion0

select distinct SW.ProductName0 as Product, SW.ProductVersion0 as Version, count(*) as Total
from v_R_System_Valid SYS
inner join v_gs_installed_software SW
on SYS.ResourceID = SW.ResourceID
where SW.ProductName0 in ('1E Shopping Agent', '1E Shopping Client Identity')
group by SW.ProductName0, SW.ProductVersion0
order by SW.ProductName0, SW.ProductVersion0