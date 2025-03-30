Select
RV.Netbios_Name0 [WKID],
CS.UserName0 [User1],
RV.User_Name0 [User2],
SCUM.TopConsoleUser0 [Top Console User],
SCUM.TotalConsoleTime0 [Top Console Usage Minutes]
from
v_R_System_Valid RV
full join v_GS_COMPUTER_SYSTEM CS on RV.ResourceID=CS.ResourceID
full join dbo.v_GS_SYSTEM_CONSOLE_USAGE_MAXGROUP SCUM on RV.ResourceID=SCUM.ResourceID
where rv.Netbios_Name0 like 'SIMXDWTSTA%'
order by WKID