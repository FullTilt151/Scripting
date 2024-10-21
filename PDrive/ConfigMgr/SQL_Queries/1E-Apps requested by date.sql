Declare @StartDate DateTime
Declare @EndDate DateTime
Set @StartDate = '1/1/2016'
Set @EndDate = '1/14/2016'
	
select PackageName AS "Package Name", count(*) AS "Times Requested"
from tb_CompletedOrder
where CompletedTimestamp BETWEEN @StartDate AND @EndDate
group by PackageID, PackageName
order by count(*) DESC
