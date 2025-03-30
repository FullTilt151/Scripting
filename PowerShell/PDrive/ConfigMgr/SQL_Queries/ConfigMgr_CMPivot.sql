-- Get the CMPivot GUID
select *
from vSMS_Scripts
where ScriptName = 'CMPivot'

-- CMPivot results of open query window
select sys.Name, cmp.ScriptExecutionState, cmp.ScriptExitCode, cmp.ScriptOutput, cmp.ReturnCode, cmp.ErrorMessage
from vSMS_CombinedDeviceResources sys inner join
	 vSMS_CMPivotResult cmp on sys.MachineID = cmp.ResourceID
where ScriptGuid = '7DC6B6F1-E7F6-43C1-96E0-E1D16BC25C14'

-- Script result of an open query window
select sys.Name, cmp.ScriptExecutionState, cmp.ScriptExitCode, cmp.ScriptOutput
from vSMS_CombinedDeviceResources sys inner join
	 vSMS_ScriptsExecutionStatus cmp on sys.MachineID = cmp.ResourceID
where ScriptGuid = '4F84F5CC-7F60-48FE-8BED-44CCBB39DFA1'