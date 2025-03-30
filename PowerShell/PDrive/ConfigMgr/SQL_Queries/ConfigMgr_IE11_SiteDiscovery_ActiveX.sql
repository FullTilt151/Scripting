SELECT 
      ClientInfo.Name As MachineName
      ,IESystemInfo.[IEVer0] AS SystemIEVer
      ,IEURLInfo.[Domain0] AS Domain
      ,IEURLInfo.[URL0] AS URL
      ,IEURLInfo.[NumberOfVisits0] AS NumberOfVisits
      ,IEURLInfo.[Zone0] AS Zone
      ,ActiveXInfo
      ,IEURLInfo.[DocMode0] AS DocMode
      ,IEURLInfo.[DocModeReason0] AS DocModeReason
      ,IEURLInfo.[BrowserStateReason0] AS BrowserStateReason
      ,IEURLInfo.[HangCount0]
      ,IEURLInfo.[CrashCount0]
  FROM
      (
	  SELECT IEURLInfo.[URL0], IEURLInfo.[ResourceID], IEURLInfo.[Domain0], IEURLInfo.[NumberOfVisits0], IEURLInfo.[Zone0], 
	  IEURLInfo.[DocMode0], IEURLInfo.[DocModeReason0], IEURLInfo.[BrowserStateReason0], IEURLInfo.[HangCount0], IEURLInfo.[CrashCount0],
	  Split.a.value('.', 'VARCHAR(100)') AS ActiveXInfo   FROM  
	  (SELECT [URL0],[ResourceID],  [Domain0], [NumberOfVisits0], [Zone0], [DocMode0], [DocModeReason0], 
	  [BrowserStateReason0], [HangCount0], [CrashCount0], CAST ('<M>' + REPLACE([ActiveXGUID0], ', ', '</M><M>') + '</M>' AS XML) AS String
		FROM  [dbo].[v_GS_IEURLINFO]) AS IEURLInfo 	
		CROSS APPLY String.nodes ('/M') AS Split(a)  
		) AS IEURLInfo,
  [dbo].[v_ClientMachines] AS ClientInfo,
  [dbo].[v_GS_IESYSTEMINFO] AS IESystemInfo,
  [dbo].[v_GS_IECOUNTINFO] AS IECountInfo
    Where  IEURLInfo.ResourceID = ClientInfo.ResourceID 
	AND IESystemInfo.ResourceID = ClientInfo.ResourceID
        AND IECountInfo.ResourceID = ClientInfo.ResourceID
    order by IESystemInfo.ResourceID ASC, IEURLInfo.[CrashCount0] DESC