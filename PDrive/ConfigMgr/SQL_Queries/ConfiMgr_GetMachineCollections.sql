SELECT
  *
FROM vSMS_ServiceWindow
WHERE CollectionID IN (SELECT
  CollectionID
FROM Collections_G
WHERE SiteID IN (SELECT
  v_fullcollectionmembership.collectionid
FROM v_r_system
JOIN v_fullcollectionmembership
  ON v_r_system.resourceid = v_fullcollectionmembership.resourceid
JOIN v_collection
  ON v_fullcollectionmembership.collectionid = v_collection.collectionid
WHERE v_r_system.name0 = 'LTLLOSWTS116'))