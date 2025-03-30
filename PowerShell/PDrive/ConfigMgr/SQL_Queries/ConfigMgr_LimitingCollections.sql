-- Count of all limiting collections
select LimitToCollectionID, LimitToCollectionName, count(*)
from v_Collections
group by LimitToCollectionID, LimitToCollectionName
order by count(*) DESC

-- Count of collections limited by limiting collections - IN PROGRESS
select LimitToCollectionID, LimitToCollectionName, count(*)
from v_Collections
where LimitToCollectionID = 'CAS0000B' or
	  LimitToCollectionID = 'CAS01815' or
	  LimitToCollectionID = 'CAS00614'
group by LimitToCollectionID, LimitToCollectionName
order by count(*) DESC

-- Collections and member counts limited by a certain collection
select SiteID, CollectionName, MemberCount, LimitToCollectionID, LimitToCollectionName
from v_collections
where LimitToCollectionID = 'CAS0000B'

-- Resourced in new collection
select *
from v_cm_res_coll_cas01e15
where resourceid not in (
select resourceid
from v_cm_res_coll_cas00025)