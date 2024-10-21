select smio_MachineName [WKID], smio_TopUser [User], smio_OperatingSystem [OS],
CASE mpch_status
	when 0 then 'User chose to remove.'
	when 1 then 'Uninstalled.'
	when 2 then 'Uninstall failed will retry.'
	when 3 then 'Uninstall failed will NOT retry.'
	when 5 then 'User opted out.'
	when 6 then 'User deferred.'
	when 7 then 'User opted out and admin accepted'
END [Status]
from SiteMachineInfo SMI
join MachinePolicyHistory MPH on smi.smio_id = mph.mpch_smio_id
where mpch_status = @status
order by smio_MachineName

select *, --smio_MachineName [WKID], smio_TopUser [User], smio_OperatingSystem [OS],
CASE mpch_status
	when 0 then 'User chose to remove.'
	when 1 then 'Uninstalled.'
	when 2 then 'Uninstall failed will retry.'
	when 3 then 'Uninstall failed will NOT retry.'
	when 5 then 'User opted out.'
	when 6 then 'User deferred.'
	when 7 then 'User opted out and admin accepted'
END [Status]
from SiteMachineInfo SMI
join MachinePolicyHistory MPH on smi.smio_id = mph.mpch_smio_id

order by smio_MachineName

select *
from SiteMachineInfo

select distinct uapp_Publisher_desc, uapp_Product_desc, uapp_Release, uapp_vprd_guid, uapp_vprl_guid, mph.*
from Application APP
join MachinePolicyHistory MPH on app.uapp_vprl_guid = mph.mpch_prl_id
where 
order by mpch_completeddate_utc DESC



select distinct uapp_Publisher_desc [Publisher], Max(uapp_Product_desc) [Product], usp.uspc_EstimatedCost [Cost], Count(mpch_id) [Reclaimed]
from Application APP
join MachinePolicyHistory MPH on app.uapp_vprl_guid = mph.mpch_prl_id
join UserSpecifiedProductCost USP on app.uapp_vprd_guid = usp.uspc_prd_id
where mpch_status in (0,1)
--where mpch_completeddate_utc,
group by uapp_Publisher_desc, uapp_Product_desc, uspc_EstimatedCost


select *
from Application
where uapp_vprl_guid = 100335

select *
from MachinePolicyHistory

select *
from MachinePolicyStatus


select *
from MachinePolicyHistory
where mpch_status in (0,1) and mpch_additional_data = 0

--App license cost per seat.
select *
from UserSpecifiedProductCost