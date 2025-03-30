select col.name, obj.name [table], obj.type_desc, obj.type
from sys.columns col join
	 sys.objects obj on obj.object_id = col.object_id
where col.name like '%IP%add%' and (obj.type in ('V'))
order by [table]