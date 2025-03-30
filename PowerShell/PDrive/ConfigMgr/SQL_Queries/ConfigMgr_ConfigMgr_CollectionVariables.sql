select coll.CollectionID, coll.Name, coll.MemberCount,  cv.name, cv.Value, cv.Masked
from vSMS_CollectionVariable cv join
	 v_Collection coll on cv.SiteID = coll.CollectionID