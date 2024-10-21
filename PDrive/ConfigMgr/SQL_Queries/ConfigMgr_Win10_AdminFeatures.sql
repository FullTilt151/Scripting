-- Developer features
select allowalltrustedapps0, allowdevelopmentwithoutdevli0, 
		case 
		when AllowAllTrustedApps0 = 1 and AllowDevelopmentWithoutDevLi0 = 0 then 'Sideload'
		when AllowAllTrustedApps0 = 1 and AllowDevelopmentWithoutDevLi0 = 1 then 'Dev Features'
		else 'Store Apps only'
		end [Feature], count(*)
from v_gs_appmodelunlock640
group by allowalltrustedapps0, allowdevelopmentwithoutdevli0
order by allowalltrustedapps0, allowdevelopmentwithoutdevli0

-- Machines with Hyper-V enabled
select sys.Netbios_Name0, sys.Operating_System_Name_and0 [OS], sys.Build01, sys.User_Name0
from v_R_System sys join
	 v_GS_SERVICE svc on sys.ResourceID = svc.ResourceID
where DisplayName0 = 'Hyper-V Virtual Machine Management'