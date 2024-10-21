SELECT ExecutionTime, PackageName, LastStatusMessageID, ActionName, ActionOutput
FROM            dbo.v_TaskExecutionStatus tse INNER JOIN
                dbo.v_advertisementinfo Adv ON tse.AdvertisementID = adv.AdvertisementID
Where CollectionName = 'All Unknown Computers' and 
		ActionName = 'Humana - Install Mapped Applications' and 
		ActionOutput not like '%No Env variable with specified basename APPLICATION_FILTERED%' and
		ActionOutput != ' '
ORDER BY ExecutionTime DESC

SELECT DATENAME(YEAR, ExecutionTime) [Year], DATENAME(Month, ExecutionTime) [Month], PackageName, Count (ExecutionTime) [Uses]
FROM            dbo.v_TaskExecutionStatus tse INNER JOIN
                dbo.v_advertisementinfo Adv ON tse.AdvertisementID = adv.AdvertisementID
Where CollectionName = 'All Unknown Computers' and 
		ActionName = 'Humana - Install Mapped Applications' and 
		ActionOutput not like '%No Env variable with specified basename APPLICATION_FILTERED%' and
		ActionOutput != ' '
GROUP BY DATENAME(YEAR, ExecutionTime), DATENAME(Month,ExecutionTime), MONTH(ExecutionTime), PackageName
order by Year DESC, MONTH(ExecutionTime) DESC, PackageName