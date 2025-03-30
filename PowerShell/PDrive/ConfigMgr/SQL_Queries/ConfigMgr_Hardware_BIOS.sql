-- Count of versions and models
select bios.SMBIOSBIOSVersion0, bios.ReleaseDate0, csp.Version0, count(*)
from vSMS_CombinedDeviceResources sys inner join
	 v_GS_COMPUTER_SYSTEM_PRODUCT csp on sys.MachineID = csp.ResourceID inner join
	 v_GS_PC_BIOS bios on sys.MachineID = bios.ResourceID
where sys.IsVirtualMachine = 0
group by bios.SMBIOSBIOSVersion0, bios.ReleaseDate0, csp.Version0
order by bios.SMBIOSBIOSVersion0, bios.ReleaseDate0, csp.Version0

-- Count of versions grouped
select LEFT(bios.SMBIOSBIOSVersion0,4) [Family], bios.SMBIOSBIOSVersion0, bios.ReleaseDate0, count(*)
from vSMS_CombinedDeviceResources sys inner join
	 v_GS_PC_BIOS bios on sys.MachineID = bios.ResourceID
where sys.IsVirtualMachine = 0
group by LEFT(bios.SMBIOSBIOSVersion0,4), bios.SMBIOSBIOSVersion0, bios.ReleaseDate0
order by [Family], bios.ReleaseDate0, bios.SMBIOSBIOSVersion0

-- Versions and models list
select distinct LEFT(bios.SMBIOSBIOSVersion0,4) [Family], csp.Version0
from vSMS_CombinedDeviceResources sys inner join
	 v_GS_PC_BIOS bios on sys.MachineID = bios.ResourceID inner join
	 v_GS_COMPUTER_SYSTEM_PRODUCT csp on sys.MachineID = csp.ResourceID
where sys.IsVirtualMachine = 0 and csp.Version0 not in ('Lenovo Product','ThinkPad')
order by [Family], csp.Version0

-- BIOS collections
select coll.CollectionId, Name, RuleName, QueryExpression
from v_Collection coll inner join
	 v_CollectionRuleQuery crq on coll.CollectionID = crq.CollectionID
where Name like 'BIOS%'