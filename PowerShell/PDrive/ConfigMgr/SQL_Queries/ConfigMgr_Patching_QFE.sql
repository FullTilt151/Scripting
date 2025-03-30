select netbios_name0, osd.imagecreationdate0, imageinstalled0, imagename0, ImageRelease0
from v_r_system SYS full join
	 v_GS_OSD_Keys640 OSD ON sys.resourceid = osd.resourceid
	 where imagerelease0 = '0214' --and netbios_name0 = 'WKMJ1423B'
	 and imagename0 != 'Win7base' and ImageName0 != 'win7base-sql'
	 order by ImageInstalled0

select sys.netbios_name0, qfe.hotfixid0, InstalledOn0, qfe.Description0, qfe.InstalledBy0
from v_r_system SYS FULL JOIN
	v_GS_QUICK_FIX_ENGINEERING QFE ON SYS.resourceid = QFE.resourceid
	where netbios_name0 = 'WKMJXKAWA'
	order by qfe.InstalledOn0