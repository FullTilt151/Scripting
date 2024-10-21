select distinct sys.Netbios_Name0 [WKID], cs.Version0 [Model], arp.DisplayName0 [App], arp.Version0 [Version], su.Status
from v_R_System_Valid sys left join
	 v_GS_COMPUTER_SYSTEM_PRODUCT CS on sys.resourceid = cs.ResourceID join
	 v_Add_Remove_Programs arp on sys.ResourceID = arp.ResourceID join
	 v_Update_ComplianceStatusReported su on sys.ResourceID = su.ResourceID
where cs.Version0 in (
'ThinkCentre M700',
'ThinkCentre M800',
'ThinkCentre M900',
'ThinkPad T460s',
'ThinkPad Yoga 260'
) and
arp.DisplayName0 = 'SecureDoc Disk Encryption (x64) 7.1SR1' and
sys.Resource_Domain_OR_Workgr0 != 'HMHSCHAMP' and
CI_ID = '16874714'
order by cs.Version0

select distinct su.Status, count(*)
from v_R_System_Valid sys left join
	 v_GS_COMPUTER_SYSTEM_PRODUCT CS on sys.resourceid = cs.ResourceID join
	 v_Add_Remove_Programs arp on sys.ResourceID = arp.ResourceID join
	 v_Update_ComplianceStatusReported su on sys.ResourceID = su.ResourceID
where cs.Version0 in (
'ThinkCentre M700',
'ThinkCentre M800',
'ThinkCentre M900',
'ThinkPad T460s',
'ThinkPad Yoga 260'
) and
arp.DisplayName0 = 'SecureDoc Disk Encryption (x64) 7.1SR1' and
sys.Resource_Domain_OR_Workgr0 != 'HMHSCHAMP' and
CI_ID = '16874714'
group by status

select distinct DisplayName0, Version0, count(*)
from v_Add_Remove_Programs
where DisplayName0 like 'SecureDoc Disk Encryption (x64)%'
group by DisplayName0, Version0
order by DisplayName0, Version0

select *
from v_Update_ComplianceStatusReported
where CI_ID = '16874714'

select *
from v_UpdateInfo
where ArticleID = '3125574'