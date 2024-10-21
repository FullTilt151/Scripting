-- All incremental collections
select CollectionID, Name, 
		CASE RefreshType
		WHEN 1 THEN 'No Scheduled Update'
		WHEN 2 THEN 'Full Scheduled Update'
		WHEN 4 THEN 'Incremental Update (only)'
		WHEN 6 THEN 'Incremental and Full Update Scheduled'
		ELSE 'Unknown'
		END AS RefreshType,
		CASE CollectionType
		WHEN 0 THEN 'Other'
		WHEN 1 THEN 'User'
		WHEN 2 THEN 'Device'
		END AS 'CollectionType', 
		MemberCount
from v_Collection
where RefreshType in (4,6)

-- All full collections without query rules
select CollectionID, Name, 
		CASE RefreshType
		WHEN 1 THEN 'No Scheduled Update'
		WHEN 2 THEN 'Full Scheduled Update'
		WHEN 4 THEN 'Incremental Update (only)'
		WHEN 6 THEN 'Incremental and Full Update Scheduled'
		ELSE 'Unknown'
		END AS RefreshType,
		CASE CollectionType
		WHEN 0 THEN 'Other'
		WHEN 1 THEN 'User'
		WHEN 2 THEN 'Device'
		END AS 'CollectionType', 
		MemberCount
from v_Collection
where RefreshType in (2,6) and CollectionID not in (select CollectionID
												from v_CollectionRuleQuery)
order by CollectionType, RefreshType, Name