/* 
Dependency Types
1 = Limited to
2 = Include Collection Membership Rule
3 = Exclude Collection Membership Rule
*/

SELECT DISTINCT
  v_Collection.Name AS 'Collection Dependency Name',
  v_Collection.CollectionID,
  vSMS_CollectionDependencies.SourceCollectionID AS 'SourceCollection',
  CASE
    WHEN
      vSMS_CollectionDependencies.relationshiptype = 1 THEN 'Limited To ' + v_Collection.name + ' (' + vSMS_CollectionDependencies.SourceCollectionID + ')'
    WHEN vSMS_CollectionDependencies.relationshiptype = 2 THEN 'Include ' + v_Collection.name + ' (' + vSMS_CollectionDependencies.SourceCollectionID + ')'
    WHEN vSMS_CollectionDependencies.relationshiptype = 3 THEN 'Exclude ' + v_Collection.name + ' (' + vSMS_CollectionDependencies.SourceCollectionID + ')'
  END AS 'Type of Relationship'
FROM v_Collection
JOIN vSMS_CollectionDependencies
  ON vSMS_CollectionDependencies.DependentCollectionID = v_Collection.CollectionID
WHERE vSMS_CollectionDependencies.SourceCollectionID = 'WP10001B'