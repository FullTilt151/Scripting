SELECT
  v_FullCollectionMembership.CollectionID,
  v_Collection.Name,
  v_R_System.Name0
FROM v_FullCollectionMembership
JOIN v_R_System
  ON v_FullCollectionMembership.ResourceID = v_R_System.ResourceID
JOIN v_Collection
  ON v_FullCollectionMembership.CollectionID = v_Collection.CollectionID
WHERE v_R_System.Name0 = 'wkmj059hl0'