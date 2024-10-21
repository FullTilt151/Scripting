DECLARE @UserID table (Value varchar(1000))
insert into @UserID values ('mxc4370'),('dxr5354'),(''),('')

-- User to WKID
select distinct sys.LastLogonUser [Last User], sys.CurrentLogonUser, sys.PrimaryUser, scum.TopConsoleUser0 [Top User],
		(select top 1 usr0.mail0
		from v_r_user USR0
		where usr0.User_Name0 = SUBSTRING(cs.UserName0, CHARINDEX('\', cs.UserName0)+1, 8) or 
		usr0.User_Name0 = sys.UserName or
		USR0.User_Name0 = SUBSTRING(scum.TopConsoleUser0, CHARINDEX('\', scum.TopConsoleUser0)+1, 8)) [Email], 
		sys.Name [WKID],
		case  sys.DeviceOS
		WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
		WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
		WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7'
		WHEN 'Microsoft Windows NT Workstation 10.0' THEN 'Windows 10'
		WHEN 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' THEN 'Windows 10'
		end as [OS],
		ch.LastActiveTime
from vSMS_CombinedDeviceResources SYS full join
	 v_GS_COMPUTER_SYSTEM CS ON sys.MachineID = cs.resourceid FULL JOIN
	 v_GS_SYSTEM_CONSOLE_USAGE_MAXGROUP SCUM ON SCUM.ResourceID = SYS.MachineID LEFT JOIN
	 v_CH_ClientSummary CH on sys.MachineID = ch.ResourceID
where (sys.UserName in (select value from @UserID) or
	  SUBSTRING(cs.UserName0, CHARINDEX('\', cs.UserName0)+1, 8) in (select value from @UserID) or
	  SUBSTRING(scum.TopConsoleUser0, CHARINDEX('\', scum.TopConsoleUser0)+1, 8) in (select value from @UserID)) and 
	  (sys.Name IS NOT NULL)
	  and sys.DeviceOS in (
	  'Microsoft Windows NT Workstation 5.1',
	  'Microsoft Windows NT Workstation 6.1',
	  'Microsoft Windows NT Workstation 6.1 (Tablet Edition)',
	  'Microsoft Windows NT Workstation 10.0',
	  'Microsoft Windows NT Workstation 10.0 (Tablet Edition)')
order by sys.Name

-- WKID to user
SELECT  RV.Netbios_Name0 AS WKID, SCUM.TopConsoleUser0 AS [Top User], usr2.Full_User_Name0 [Top User Friendly], usr2.Mail0 [Top User Email], CS.UserName0 AS [Last User 1], RV.User_Name0 AS [Last User 2], RV.User_Domain0 AS [Last User Domain], usr1.Full_User_Name0 [Last User Friendly], usr1.Mail0 [Last User Email], 
		csp.Vendor0 [Mfg], csp.Name0 [Model Number], csp.Version0 [Model Name], ip.IP_Addresses0 [IP],
		(select sum(capacity0) from v_GS_PHYSICAL_MEMORY where v_GS_PHYSICAL_MEMORY.ResourceID = RV.ResourceID) [MB RAM], 
        (select count(capacity0) from v_GS_PHYSICAL_MEMORY where v_GS_PHYSICAL_MEMORY.ResourceID = RV.ResourceID) [DIMM Count]
FROM            v_R_System_Valid AS RV LEFT JOIN
                v_GS_COMPUTER_SYSTEM_Product AS CSP ON RV.ResourceID = CSP.ResourceID LEFT JOIN
				v_GS_COMPUTER_SYSTEM CS on rv.ResourceID = cs.ResourceID left join
                v_GS_SYSTEM_CONSOLE_USAGE_MAXGROUP AS SCUM ON RV.ResourceID = SCUM.ResourceID LEFT JOIN
				v_RA_System_IPAddresses IP on rv.ResourceID = ip.ResourceID left join
				v_r_user USR1 on rv.User_Name0 = usr1.User_Name0 LEFT JOIN
				v_r_user USR2 on SUBSTRING(scum.TopConsoleUser0, CHARINDEX('\', CS.UserName0)+1, 8) = usr2.User_Name0
--WHERE        (RV.Netbios_Name0 in (@WKID))
WHERE        (RV.Netbios_Name0 = ('WKPC0LAST8'))
ORDER BY WKID