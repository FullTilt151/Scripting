select Name0 as ComputerName, ui.Title, ui.CI_ID, comp.[Status], ui.CI_UniqueID,
comp.LastStatusCheckTime,
comp.LastStatusChangeTime, comp.LastLocalChangeTime
from v_R_System a
left join v_Update_ComplianceStatusAll comp on a.ResourceID=comp.ResourceID
join v_UpdateInfo ui on comp.CI_ID=ui.CI_ID
where a.Name0 = 'WKMJXZHMV'
and ui.BulletinID = 'MS12-036'

--25058

select comp.[Status], count(*)
from v_R_System a
left join v_Update_ComplianceStatusAll comp on a.ResourceID=comp.ResourceID
join v_UpdateInfo ui on comp.CI_ID=ui.CI_ID
where ui.CI_ID = 25058
group by comp.[Status]
