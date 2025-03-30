select *
from vSMS_Scripts

select DeviceName, ScriptExecutionState, ScriptExitCode, ScriptOutput
from vSMS_ScriptsExecutionStatus
where ScriptGuid = '325DF4A7-42E7-4B29-81DD-992303099AEC'

select ScriptOutput, count(*)
from vSMS_ScriptsExecutionStatus
group by ScriptOutput
order by ScriptOutput

select *
from vSMS_ScriptsParameters