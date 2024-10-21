select Netbios_Name0, client0, csp.vendor0, Version0, osd.builtby0, DeployedBy0, ImageCreationDate0, ImageInstalled0, ImageName0, ImageRelease0, ImageVersion0, TaskSequence0, ss.Install_Date0, ss.OSVersion0
from v_r_system SYS left join
v_gs_osd640 OSD ON sys.Resourceid = osd.ResourceID full join
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP ON sys.ResourceID = csp.ResourceID full join
	 v_GS_SystemSoftware640 SS ON sys.ResourceID = ss.ResourceID
where Netbios_Name0 like 'AEC%' or Resource_Domain_OR_Workgr0 = 'HOMEHEALTH'
order by Vendor0, Version0

select netbios_name0, operating_system_name_and0 , Manufacturer0, Model0, Resource_Domain_OR_Workgr0, cl.LastActiveTime
from v_r_system sys join
	 v_gs_computer_system cs on sys.ResourceID = cs.ResourceID join
	 v_ch_clientsummary cl on sys.resourceid = cl.resourceid
where (Netbios_Name0 like '%aec%' or Resource_Domain_OR_Workgr0 = 'HOMEHEALTH') and Manufacturer0 = 'Dell Inc.'
order by LastActiveTime DESC