select sys.netbios_name0, ucs.ci_id, ucs.status
from v_r_system_valid sys join
	 v_updatecompliancestatus ucs on sys.resourceid = ucs.resourceid
where ci_id in (
select ci_id
from V_updateinfo
where title = '2017-10 Security Monthly Quality Rollup for Windows 7 for x64-based Systems (KB4041681)')
order by netbios_name0

-- Package
-- c:\windows\sysnative\wusa.exe /uninstall /kb:4041681 /quiet /norestart