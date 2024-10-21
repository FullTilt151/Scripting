select distinct sys.name0, Vendor0, csp.Version0
from v_r_system SYS FULL JOIN 
	 v_gs_computer_system_product CSP ON SYS.ResourceID = CSP.ResourceID FULL JOIN
	 v_add_remove_programs ARP ON CSP.ResourceID = ARP.ResourceID
where csp.Version0 = 'ThinkPad S1 Yoga' and (displayname0 = 'Lenovo Screen Rotation')


select *
from v_Add_Remove_Programs
where displayname0 = 'On Screen Display'

select *
from v_Add_Remove_Programs
where displayname0 = 'Lenovo System Interface Driver'

select *
from v_Add_Remove_Programs
where displayname0 = 'Lenovo Screen Rotation'