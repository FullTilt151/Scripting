select * from tb_OsdRecommendedItemsMapping as A
left join tb_Application as B
on a.TargetRequestItem = b.ApplicationId
where b.MarkedForDeletion = 1
order by DisplayName


select *
FROM [dbo].[tb_OsdCompleted]
order by MachineDiscoveredDateTime desc

SELECT *
FROM tb_OsdRecommendedItemsMapping as OSD
LEFT JOIN tb_Application as Apps
ON OSD.TargetRequestItem = Apps.ApplicationId
WHERE Apps.MarkedForDeletion = 1
ORDER BY DisplayName

SELECT *
FROM tb_OsdRecommendedItemsMapping

--Delete tb_OsdRecommendedItemsMapping
FROM         tb_OsdRecommendedItemsMapping OSDMapping LEFT OUTER JOIN
                      tb_Application Apps ON OSDMapping.TargetRequestItem = Apps.ApplicationId
WHERE     (Apps.MarkedForDeletion = 1)
