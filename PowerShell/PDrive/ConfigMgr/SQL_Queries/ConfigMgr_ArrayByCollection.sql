select distinct Name
from v_cm_res_coll_cas0263f coll left join
	 v_GS_INSTALLED_SOFTWARE [is] on coll.resourceid = [is].resourceid
where [is].productname0 in (
		'Array Networks SSL VPN Client 8,4,6,14 (Array Networks)',
		'Array Networks SSL VPN Client 8,4,6,68 (Array Networks)',
		'Array Networks VpnApp',
		'Array SSL VPN')

select *
from v_CollectionRuleDirect
where CollectionID = 'CAS0263F'