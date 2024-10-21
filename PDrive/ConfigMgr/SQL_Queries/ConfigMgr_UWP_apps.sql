-- List of WKIDs with a specific UWP app
select sys.Netbios_Name0, sys.Operating_System_Name_and0, uwp.ApplicationName0, uwp.Architecture0, uwp.FamilyName0, uwp.FullName0, uwp.InstalledLocation0, uwp.Version0
from v_r_system_valid sys join
	 v_GS_WINDOWS8_APPLICATION uwp on sys.ResourceID = uwp.ResourceID
where ApplicationName0 like '%note%'

-- Count of UWP apps
select uwp.ApplicationName0, uwp.Version0, count(*)
from v_r_system_valid sys join
	 v_GS_WINDOWS8_APPLICATION uwp on sys.ResourceID = uwp.ResourceID
group by uwp.ApplicationName0, uwp.Version0
order by uwp.ApplicationName0, uwp.Version0