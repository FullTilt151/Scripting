-- McAfee ePO
select sft.Publisher0, sft.ProductName0, sft.ProductVersion0, count(*)
from v_r_system sys join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where Client0 = 1 and Build01 = '10.0.14393' and ProductName0 = 'McAfee Agent'
group by sft.Publisher0, sft.ProductName0, sft.ProductVersion0
order by sft.Publisher0, sft.ProductName0, sft.ProductVersion0

-- McAfee ENS
select sft.Publisher0, sft.ProductName0, sft.ProductVersion0, count(*)
from v_r_system sys join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where Client0 = 1 and Build01 = '10.0.14393' and ProductName0 like 'McAfee Endpoint Security Platform'
group by sft.Publisher0, sft.ProductName0, sft.ProductVersion0
order by sft.Publisher0, sft.ProductName0, sft.ProductVersion0

-- McAfee MOVE
select sft.Publisher0, sft.ProductName0, sft.ProductVersion0, count(*)
from v_r_system sys join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where Client0 = 1 and Build01 = '10.0.14393' and ProductName0 like 'move av%'
group by sft.Publisher0, sft.ProductName0, sft.ProductVersion0
order by sft.Publisher0, sft.ProductName0, sft.ProductVersion0

-- WinMagic
select sft.Publisher0, sft.ProductName0, sft.ProductVersion0, count(*)
from v_r_system sys join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where Client0 = 1 and Build01 = '10.0.14393' and ProductName0 like 'SecureDoc Disk Encryption (x64)%'
group by sft.Publisher0, sft.ProductName0, sft.ProductVersion0
order by sft.Publisher0, sft.ProductName0, sft.ProductVersion0

-- BeyondTrust
select sft.Publisher0, sft.ProductName0, sft.ProductVersion0, count(*)
from v_r_system sys join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where Client0 = 1 and Build01 = '10.0.14393' and ProductName0 = 'BeyondTrust PowerBroker Desktops Client for Windows'
group by sft.Publisher0, sft.ProductName0, sft.ProductVersion0
order by sft.Publisher0, sft.ProductName0, sft.ProductVersion0

-- Digital Guardian 1
select sft.Publisher0, sft.ProductName0, sft.ProductVersion0, count(*)
from v_r_system sys left join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where Client0 = 1 and Build01 = '10.0.14393' and ProductName0 = 'Digital Guardian Agent'
group by sft.Publisher0, sft.ProductName0, sft.ProductVersion0
order by sft.Publisher0, sft.ProductName0, sft.ProductVersion0

-- Digital Guardian 2
select Agentversion0, count(*)
from v_r_system sys left join
	 v_GS_VDG640 dg on sys.ResourceID = dg.ResourceID
where Client0 = 1 and Build01 = '10.0.14393'
group by Agentversion0
order by Agentversion0

-- FireEye
select sft.Publisher0, sft.ProductName0, sft.ProductVersion0, count(*)
from v_r_system sys join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where Client0 = 1 and Build01 = '10.0.14393' and ProductName0 = 'FireEye Endpoint Agent'
group by sft.Publisher0, sft.ProductName0, sft.ProductVersion0
order by sft.Publisher0, sft.ProductName0, sft.ProductVersion0

-- VDA
select sft.Publisher0, sft.ProductName0, sft.ProductVersion0, count(*)
from v_r_system sys join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where Client0 = 1 and Build01 = '10.0.14393' and ProductName0 like '%delivery agent%'
group by sft.Publisher0, sft.ProductName0, sft.ProductVersion0
order by sft.Publisher0, sft.ProductName0, sft.ProductVersion0