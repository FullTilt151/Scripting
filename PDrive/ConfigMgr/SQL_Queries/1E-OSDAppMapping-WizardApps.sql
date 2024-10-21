-- Identify App ID
select *
from tb_Application
where DisplayName like '%tiff%'

-- View app record
select *
from tb_OsdRecommendedItem
where ApplicationId = 39 and MachineAccount = 'WKMJ029CW9'

-- Rename app to prevent an empty record
update tb_OsdRecommendedItem 
SET ApplicationNameOverride = 'TIFF'
where ApplicationId = 39 and MachineAccount = 'WKMJ029CW9'

-- Set to NULL to remove from list
update tb_OsdRecommendedItem 
SET ApplicationID = NULL
where ApplicationId = 39 and MachineAccount = 'WKMJ029CW9'

-- 172 - Office 2016
-- 39 - Tiff editor