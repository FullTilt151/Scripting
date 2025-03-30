-- List of laptop batteries
select BT.SystemName0 [WKID], csp.Vendor0 [Mfg], csp.Version0 [Machine Model], BT.BatteryStatus0 [Status #], BT.DeviceId0, BT.Name0 [Battery Model]
from v_gs_battery BT left join
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP ON BT.ResourceID = csp.ResourceID

-- Count of laptop batteries
select csp.Version0 [Machine Model], BT.Name0 [Battery Model], count(*) [Count]
from v_gs_battery BT left join
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP ON BT.ResourceID = csp.ResourceID
group by csp.Version0, BT.Name0
order by Version0, bt.Name0