select sys.netbios_name0 [WKID], sys.Resource_Domain_OR_Workgr0 [Domain],
(select Subject0
from v_gs_root_ca
where subject0 = 'CN=Humana General Purpose Issuing CA 3, O=Humana Inc.' and
	  ResourceID = sys.resourceid) [CA3 General],
(select Subject0
from v_gs_root_ca
where subject0 = 'CN=Humana Enterprise Root CA 3, O=Humana Inc.' and
	  resourceid = sys.resourceid) [CA3 Root CA]
from v_R_System_Valid sys
where sys.Operating_System_Name_and0 like 'Microsoft Windows NT Workstation%' and
	  (sys.ResourceID not in 
	  	(select resourceid
		from v_gs_root_ca
		where subject0 = 'CN=Humana Enterprise Root CA 3, O=Humana Inc.'))
		or (sys.ResourceID not in 
		(select resourceid
		from v_gs_root_ca
		where subject0 = 'CN=Humana General Purpose Issuing CA 3, O=Humana Inc.'))
order by sys.Netbios_Name0

select count(*)
from v_R_System_Valid sys
where sys.Operating_System_Name_and0 like 'Microsoft Windows NT Workstation%' and
	  (sys.ResourceID not in 
	  (select resourceid 
		from v_gs_root_ca
		where subject0 = 'CN=Humana Auto Enrollment Issuing CA 3, O=Humana Inc.'))
		or (sys.ResourceID not in 
		(select resourceid
		from v_gs_root_ca
		where subject0 = 'CN=Humana Multi-Factor Issuing CA 3, O=Humana Inc.'))
		or (sys.ResourceID not in 
		(select resourceid
		from v_gs_root_ca
		where subject0 = 'CN=Humana Enterprise Root CA 3, O=Humana Inc.'))
		or (sys.ResourceID not in 
		(select resourceid
		from v_gs_root_ca
		where subject0 = 'CN=Humana General Purpose Issuing CA 3, O=Humana Inc.'))

select subject0 [Subject], thumbprint0 [Thumbprint], count(*) [Total]
from v_gs_root_ca
where subject0 in ('CN=Humana General Purpose Issuing CA 3, O=Humana Inc.','CN=Humana Enterprise Root CA 3, O=Humana Inc.','CN=Humana Multi-Factor Issuing CA 3, O=Humana Inc.','CN=Humana Auto Enrollment Issuing CA 3, O=Humana Inc.')
group by subject0, thumbprint0

/*
'CN=Humana General Purpose Issuing CA 3, O=Humana Inc.'
'CN=Humana Enterprise Root CA 3, O=Humana Inc.'
'CN=Humana Multi-Factor Issuing CA 3, O=Humana Inc.'
'CN=Humana Auto Enrollment Issuing CA 3, O=Humana Inc.'

'9BCAFA2240006108B32E984C862215C095E19E62'
'6FC128B467F1106B6AF35ADDC22AA1F59F60F4DE'
'0A358A0823CDB202E3B4693A121266C39D7DBA24'
'D93FEF7DC6AF997F75755C10D534566816A6F3AA'
*/