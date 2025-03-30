-- Returns the total number of incremental collections as well as a comparison of total incremental evaluation time
-- compared to the current incremental eval settings
SELECT ste.SiteName
       , srv.SiteCode
       , cmp.Value3 AS [IncrementalRefreshInterval]
       , CONVERT(time(0),DATEADD(millisecond,evl.EvalLength,0)) AS [hh:mm:ss EvalTime]
       , CASE WHEN evl.EvalLength/1000.0/60 < cmp.Value3 THEN 'True'
             ELSE 'False'
        END AS [Interval > EvalTime]
       , evl.[IncrementalCount]
FROM dbo.SC_Component_Property cmp
    INNER JOIN dbo.ServerData srv
    ON cmp.SiteNumber = srv.ID
    INNER JOIN dbo.Sites ste
    ON srv.SiteCode = ste.SiteCode
    INNER JOIN (
                   SELECT COUNT(col.CollID) AS [IncrementalCount]
						  , lcl.SiteNumber
                          , SUM(lcl.IncrementalEvaluationLength) AS [EvalLength]
    FROM dbo.Collections_L lcl
        INNER JOIN dbo.v_Collection col
        ON lcl.CollectionID = col.CollID
    WHERE col.RefreshType IN (4,6)
    GROUP BY lcl.SiteNumber
                   ) evl
    ON cmp.SiteNumber = evl.SiteNumber
WHERE cmp.Name  = 'Incremental Interval'
    AND cmp.SiteNumber = dbo.fnGetSiteNumber();
GO