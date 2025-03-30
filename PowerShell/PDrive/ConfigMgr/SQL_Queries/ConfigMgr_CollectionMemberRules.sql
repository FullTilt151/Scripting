select crd.CollectionID, col.Name, col.MemberCount, Count(*) [Rules]
from v_CollectionRuleDirect CRD join
	 v_Collection COL on CRD.CollectionID = COL.CollectionID
where crd.CollectionID in ('cas029b1','CAS028D8','CAS028D9')
group by crd.CollectionID, col.Name, col.MemberCount
order by crd.CollectionID