select sft.ARPDisplayName0, Count(*) [Totals], 
	   CASE 
	   WHEN TaskSequence0 = '1E ZTI Win7x64E-OSDDeploy-Master-Rel3-0830-Image' THEN 'ZTI'
	   WHEN TaskSequence0 = '1E ZTI Win7x64E-OSDDeploy-Master-Rel3-083-WinMagic' THEN 'ZTI'
	   WHEN TaskSequence0 = '1E ZTI Win7x64E-OSDDeploy-Master-No-OU' THEN 'ZTI'
	   WHEN TaskSequence0 = '1E ZTI Win7x64E-OSDDeploy-Master' THEN 'ZTI'
	   WHEN TaskSequence0 = 'Win7x64E-OSDDeploy-Nomad-AppMapping' THEN 'HTI'
	   WHEN TaskSequence0 LIKE 'Windows 7 -%' THEN 'OSD'
	   WHEN ImageVersion0 = '08302013' THEN 'OSD'
	   WHEN ImageVersion0 = '10092013' THEN 'OSD'
	   ELSE 'Ghost'
	   END as [Method]
from v_r_system SYS INNER JOIN
	 v_gs_installed_software SFT ON SYS.ResourceID = SFT.ResourceID INNER JOIN
	 v_GS_OSD640 OSD ON sys.resourceid = osd.ResourceID
where ARPDisplayName0 = 'Humana CCP'
group by ARPDisplayName0, CASE 
	   WHEN TaskSequence0 = '1E ZTI Win7x64E-OSDDeploy-Master-Rel3-0830-Image' THEN 'ZTI'
	   WHEN TaskSequence0 = '1E ZTI Win7x64E-OSDDeploy-Master-Rel3-083-WinMagic' THEN 'ZTI'
	   WHEN TaskSequence0 = '1E ZTI Win7x64E-OSDDeploy-Master-No-OU' THEN 'ZTI'
	   WHEN TaskSequence0 = '1E ZTI Win7x64E-OSDDeploy-Master' THEN 'ZTI'
	   WHEN TaskSequence0 = 'Win7x64E-OSDDeploy-Nomad-AppMapping' THEN 'HTI'
	   WHEN TaskSequence0 LIKE 'Windows 7 -%' THEN 'OSD'
	   WHEN ImageVersion0 = '08302013' THEN 'OSD'
	   WHEN ImageVersion0 = '10092013' THEN 'OSD'
	   ELSE 'Ghost'
	   END