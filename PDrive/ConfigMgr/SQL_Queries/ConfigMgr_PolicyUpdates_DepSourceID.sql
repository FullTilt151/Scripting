Declare @PolicyID  varchar(255)
-- Failing Policy
set @PolicyID = 'SMS10000-cas00F21-49E164A1'

select *
from SettingsPolicy
where PolicyID = (select PolicyAssignmentID
from SoftwarePolicy
where PolicyID = @PolicyID)

select *
from SoftwarePolicy
where PolicyID = @PolicyID

select * 
from SoftwarePolicy
where PkgID = (select PkgID
from SoftwarePolicy
where PolicyID = @PolicyID)
