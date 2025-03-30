-- Count of devices not HAADJ/Comanaged
select HybridAADJoined, MDMProvisioned, count(*)
from v_R_System_Valid sys inner join
	 v_ClientCoManagementState comgmt on sys.ResourceID = comgmt.ResourceID
where Resource_Domain_OR_Workgr0 = 'HUMAD' and Operating_System_Name_and0 in ('Microsoft Windows NT Workstation 10.0','Microsoft Windows NT Workstation 10.0 (Tablet Edition)')
group by HybridAADJoined, MDMProvisioned

-- List of devices not HAADJ/Comanaged
select Netbios_Name0, HybridAADJoined, MDMProvisioned, EnrollmentStatusCode, EnrollmentErrorDetail,
		(select top 1 System_OU_Name0 from v_RA_System_SystemOUName ou where ou.resourceid = sys.resourceid order by System_OU_Name0 desc) [OU]
	   --(select ProductName0 from v_GS_INSTALLED_SOFTWARE sft where sft.ResourceID = sys.resourceid and ProductName0 = 'Cisco AnyConnect Secure Mobility Client') [AnyConnect]
from v_R_System_Valid sys inner join
	 v_ClientCoManagementState comgmt on sys.ResourceID = comgmt.ResourceID
where Resource_Domain_OR_Workgr0 = 'HUMAD' and Operating_System_Name_and0 in ('Microsoft Windows NT Workstation 10.0','Microsoft Windows NT Workstation 10.0 (Tablet Edition)')
	  and MDMProvisioned != 1
	  --and Netbios_Name0 in ('WKPC0VT6X8')
order by name

-- List of devices not HAADJ/Comanaged - AnyConnect
select Netbios_Name0, cdr.PrimaryUser, HybridAADJoined, MDMProvisioned, EnrollmentStatusCode, EnrollmentErrorDetail,
	   (select ProductName0 from v_GS_INSTALLED_SOFTWARE sft where sft.ResourceID = sys.resourceid and ProductName0 = 'Cisco AnyConnect Secure Mobility Client') [AnyConnect],
	   ip.IP_Subnets0, case
	   when ip_subnets0 like '10.94.%' then 'Array'
	   when IP_Subnets0 like '10.52.%' then 'Aruba'
	   when IP_Subnets0 like '10.53.%' then 'Aruba'
	   when IP_Subnets0 like '10.54.%' then 'Aruba'
	   when IP_Subnets0 like '10.55.%' then 'Aruba'
	   when IP_Subnets0 like '10.56.%' then 'Aruba'
	   when IP_Subnets0 like '10.57.%' then 'Aruba'
	   when IP_Subnets0 like '10.58.%' then 'Aruba'
	   when IP_Subnets0 like '10.59.%' then 'Aruba'
	   when IP_Subnets0 like '10.60.%' then 'Aruba'
	   when IP_Subnets0 like '10.61.%' then 'Aruba'
	   when IP_Subnets0 like '10.62.%' then 'Aruba'
	   when IP_Subnets0 like '10.63.%' then 'Aruba'
	   when IP_Subnets0 like '10.188.%' then 'AnyConnect'
	   when IP_Subnets0 like '10.189.%' then 'AnyConnect'
	   when IP_Subnets0 like '10.%' then 'In office'
	   when IP_Subnets0 like '193.%' then 'In office'
	   when IP_Subnets0 like '32.%' then 'In office'
	   else 'Local IP'
	   end [Location]
from v_R_System_Valid sys inner join
	 v_CombinedDeviceResources cdr on sys.ResourceID = cdr.MachineID left join
	 v_ClientCoManagementState comgmt on sys.ResourceID = comgmt.ResourceID inner join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID inner join
	 v_RA_System_IPSubnets ip on sys.ResourceID = ip.ResourceID
where Resource_Domain_OR_Workgr0 = 'HUMAD' and Operating_System_Name_and0 in ('Microsoft Windows NT Workstation 10.0','Microsoft Windows NT Workstation 10.0 (Tablet Edition)')
	  and MDMProvisioned != 1
	  and ProductName0 = 'Cisco AnyConnect Secure Mobility Client'
	  and PrimaryUser like '%humad%' and PrimaryUser not like '%s' and PrimaryUser not like '%a'
	  and PrimaryUser not in ('humad\avayaotvservice','humad\cpqismxe','humad\videoarch')
order by Netbios_Name0

/*
1. Missing HAADJ
2. Missing co-managed
3. Missing Intune Compliant
*/