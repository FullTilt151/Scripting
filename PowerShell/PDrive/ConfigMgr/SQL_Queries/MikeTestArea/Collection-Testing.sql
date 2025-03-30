Select Count(*) [Count], CurrentStatus
from V_collection
Group by CurrentStatus

select * 
from v_Collection

sp_who2

SELECT Count(*) [Count],
    CASE CurrentStatus
        WHEN 0
            THEN 'None'
        WHEN 1
            THEN 'Ready'
        WHEN 2
            THEN 'Refreshing'
        WHEN 3
            THEN 'Saving'
        WHEN 4
            THEN 'Evaluating'
        WHEN 5
            THEN 'Awaiting Refresh'
        WHEN 6
            THEN 'Deleting'
        WHEN 7
            THEN 'Appending Member'
        WHEN 8
            THEN 'Querying'
        END AS CurrentSTATUS
FROM V_collection
GROUP BY CurrentStatus 


SELECT CollectionID,
    Name,
    Comment,
    LastChangeTime,
    EvaluationStartTime,
    LastRefreshTime,
    RefreshType,
    CollectionType,
    CASE CurrentStatus
        WHEN 0
            THEN 'None'
        WHEN 1
            THEN 'Ready'
        WHEN 2
            THEN 'Refreshing'
        WHEN 3
            THEN 'Saving'
        WHEN 4
            THEN 'Evaluating'
        WHEN 5
            THEN 'Awaiting Refresh'
        WHEN 6
            THEN 'Deleting'
        WHEN 7
            THEN 'Appending Member'
        WHEN 8
            THEN 'Querying'
        END AS CurrentSTATUS,
    MemberCount,
    MemberClassName,
    LastMemberChangeTime
FROM v_collection
WHERE CurrentStatus != 1 