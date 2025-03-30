-- Inventory of choco.exe
select *
from v_gs_softwarefile
where filename = 'choco.exe'

-- Inventory of Chocolatey environmental variables
select sys.Netbios_Name0, sys.User_Name0, UserName0, Name0, VariableValue0
from v_r_system_valid sys join
	 v_GS_ENVIRONMENT env on sys.resourceid = env.ResourceID
where Name0 like '%Chocolatey%'