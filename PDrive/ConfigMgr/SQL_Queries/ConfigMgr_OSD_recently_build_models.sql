select os.InstallDate0, cs.Manufacturer0, Model0, csp.Version0
from v_gs_operating_system OS join
	 v_GS_COMPUTER_SYSTEM CS on os.ResourceID = cs.ResourceID join
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP on cs.ResourceID = csp.ResourceID
where Model0 in (
		'Optiplex 170L',
		'Optiplex GX280',
		'Optiplex GX520',
		'Latitude D620',
		'Optiplex 320',
		'Latitude D630',
		'Optiplex 745',
		'Optiplex 330',
		'Latitude E4300',
		'Latitude E6400',
		'7522J5U',
		'OptiPlex 360',
		'7303',
		'Optiplex 755',
		'2522AP6',
		'2522WTA',
		'2522WVJ',
		'2522WZ5',
		'7303BN8',
		'7303BN9')
order by InstallDate0 DESC