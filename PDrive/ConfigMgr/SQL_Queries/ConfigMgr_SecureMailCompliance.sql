-- Addin load state
select case Operating_System_Name_and0
		when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
		when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
		when 'Microsoft Windows NT Workstation 6.3' then 'Windows 8.1'
		when 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' then 'Windows 8.1'
		when 'Microsoft Windows NT Workstation 10.0' then 'Windows 10'
		when 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Windows 10'
		end [OS], FriendlyName0, LoadBehavior0, count(*) [Total]
from v_r_system_valid sys join
	 v_GS_CM_CUST_MSOFFICEADDINS addin on sys.resourceid = addin.ResourceID
where app0 = 'Outlook' and FriendlyName0 in ('Humana Outlook Secure Mail Add-In','Humana.Office.Outlook.SecureMail.AddIn')
group by case Operating_System_Name_and0
		when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
		when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
		when 'Microsoft Windows NT Workstation 6.3' then 'Windows 8.1'
		when 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' then 'Windows 8.1'
		when 'Microsoft Windows NT Workstation 10.0' then 'Windows 10'
		when 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Windows 10' 
		end, FriendlyName0, LoadBehavior0
order by [OS], FriendlyName0, LoadBehavior0

-- Install compliance
select case Operating_System_Name_and0
		when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
		when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
		when 'Microsoft Windows NT Workstation 6.3' then 'Windows 8.1'
		when 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' then 'Windows 8.1'
		when 'Microsoft Windows NT Workstation 10.0' then 'Windows 10'
		when 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Windows 10'
		end [OS], Publisher0, ProductName0, ProductVersion0, count(*) [Total]
from v_R_System_Valid sys left join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where ProductName0 = 'Humana Outlook 2010 Secure Mail Add-In'
group by case Operating_System_Name_and0
		when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
		when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
		when 'Microsoft Windows NT Workstation 6.3' then 'Windows 8.1'
		when 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' then 'Windows 8.1'
		when 'Microsoft Windows NT Workstation 10.0' then 'Windows 10'
		when 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Windows 10' 
		end, Publisher0, ProductName0, ProductVersion0
order by [OS],Publisher0, ProductName0, ProductVersion0