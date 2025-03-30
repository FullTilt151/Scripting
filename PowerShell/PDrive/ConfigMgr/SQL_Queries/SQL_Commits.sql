SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO
SELECT
 count(*) as number_commits,
 MIN(commit_time) as minimum_commit_time,
 DateDiff(D,MIN(commit_time),getdate()) [MinDays],
 MAX(commit_time) as maximum_commit_time,
 DateDiff(D,MAX(commit_time),getdate()) [MaxDays]
from sys.dm_tran_commit_table
GO