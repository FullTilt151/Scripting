-- By version
select DisplayName0, Version0, count(*)
from v_Add_Remove_Programs
where DisplayName0 like 'SecureDoc Disk Encryption (x64)%'
group by DisplayName0, Version0
order by DisplayName0, Version0

-- By model
select csp.vendor0 [Make], csp.Version0 [Model], ProductName0, ProductVersion0, count(*) [Total]
from v_r_system_valid sys join
	 v_gs_installed_software sft on sys.resourceid = sft.resourceid join
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP on sys.ResourceID = csp.ResourceID
where Publisher0 = 'WinMagic Inc.' and csp.Vendor0 in ('LENOVO','Dell Inc.')
group by csp.vendor0, csp.Version0, ProductName0, ProductVersion0
order by csp.vendor0, csp.version0, ProductVersion0, ProductName0