--get collection info
select *
from v_Collection
where CollectionID = 'WP106F02'

--get # of wkids in a certain collection.
select count(*)
from v_ClientCollectionMembers
where CollectionID = 'WP106F02'