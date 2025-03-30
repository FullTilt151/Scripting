http://www.techlimbo.com/software/sccm-1702-osd-imaging-issue-there-are-no-task-sequences-available-for-this-computer/

-- Verify you have dup unknown computers
select * 
from UnknownSystem_DISC inner join 
System_DISC on UnknownSystem_DISC.SMS_Unique_Identifier0 = System_DISC.SMS_Unique_Identifier0

-- Note current item keys and GUIDs
select * from UnknownSystem_DISC
select * from v_R_UnknownSystem

/*
ItemKey	DiscArchKey	SMS_Unique_Identifier0	Name0	Description0	CPUType0	Creation_Date0	SiteCode0	Decommissioned0
2046820366	2	cdb96053-6386-40f9-8539-a7f61ca27e75	x86 Unknown Computer (x86 Unknown Computer)	x86 Unknown Computer	x86	2017-07-28 03:27:42.000	WP1	0
2046820367	2	cf7d22a2-ec32-4ba9-b77d-7fee52933a22	x64 Unknown Computer (x64 Unknown Computer)	x64 Unknown Computer	x64	2017-07-28 03:27:42.000	WP1	0
*/

/*
-- Delete old unknown devices
delete from UnknownSystem_DISC where ItemKey in (
'2046820366',
'2046820367')
/*