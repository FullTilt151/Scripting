select sys.Netbios_Name0, chs.HealthType, chs.HealthState, chs.HealthStateName, chs.ErrorCode, chs.ExtendedErrorCode, chs.LastHealthReportDate, er.EvalTime, er.HealthCheckGUID, er.Result, er.HealthCheckDescription, er.ResultDetail, er.ResultCode, er.ResultType
from v_R_System_Valid sys join
	 v_ClientHealthState chs on sys.Netbios_Name0 = chs.NetBiosName join
	 v_CH_EvalResults ER on sys.ResourceID = er.ResourceID
where sys.Netbios_Name0 like 'LOUWEBWPL293s%' or sys.Netbios_Name0 like 'LOUWEBWQL317S0%'
order by sys.Netbios_Name0