-- IP information by collection
select sys.netbios_name0 [WKID], sys.Resource_Domain_OR_Workgr0 [Domain], net.ipaddress0 [IP]
from v_r_system SYS join
	 v_GS_NETWORK_ADAPTER_CONFIGURATION NET on sys.resourceid = net.resourceid
where sys.Client0 = '1' and
	  IPAddress0 IS NOT NULL and
	  sys.ResourceID in (
	  select machineid
	  from vCollectionMembers
	  where SiteID = @CollID
	  )
order by WKID

-- All collections
select CollectionName + ' - ' + SiteID + ' (' + CAST(MemberCount as nvarchar) + ')', SiteID
from vCollections
where MemberCount != '0'
order by CollectionName