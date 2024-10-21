/****** Script for Collecting IE Inventory  ******/
SELECT 
   ClientInfo.Name As MachineID
   ,IESystemInfo.[IEVer0] AS SystemIEVer
   ,IEURLInfo.Domain0 AS Domain
   ,IEURLInfo.[URL0] As URL
   ,IEURLInfo.[NumberOfVisits0] As NumberOfVisits
   ,IEURLInfo.[Zone0] As Zone
   ,IEURLInfo.[ActiveXGUID0] As ActiveXGuid
   ,IEURLInfo.[DocMode0] As DocMode
   ,IEURLInfo.[DocModeReason0] As DocModeReason
   ,IEURLInfo.[BrowserStateReason0] As BrowserStateReason
   ,IEURLInfo.[HangCount0] As NumberOfHangs
   ,IEURLInfo.[CrashCount0] As NumberOfCrashes
   ,OSInfo.Caption0 as OSName
   ,OSInfo.Version0 as OSVersion
   ,OSInfo.CSDVersion0 as CSDVersion
  FROM [dbo].[v_GS_IESYSTEMINFO] AS IESystemInfo,
       [dbo].[v_GS_IECOUNTINFO] AS IECountInfo,
       [dbo].[v_GS_IEURLINFO] AS IEURLInfo,
       [dbo].[v_ClientMachines] AS ClientInfo,
       [dbo].[v_GS_OPERATING_SYSTEM] AS OSInfo
  Where  IESystemInfo.ResourceID = ClientInfo.ResourceID
  AND  IECountInfo.ResourceID = ClientInfo.ResourceID 
  AND  IEURLInfo.ResourceID = ClientInfo.ResourceID 
  AND  OSInfo.ResourceID = ClientInfo.ResourceID 
  order by IESystemInfo.ResourceID ASC, NumberOfCrashes DESC


  /****** Script for Collecting IE Inventory  ******/
SELECT 
   ClientInfo.Name As MachineID
   ,IESystemInfo.[IEVer0] AS SystemIEVer
   ,IEURLInfo.Domain0 AS Domain
   ,IEURLInfo.[URL0] As URL
   ,IEURLInfo.[NumberOfVisits0] As NumberOfVisits
   ,IEURLInfo.[Zone0] As Zone
   ,IEURLInfo.[ActiveXGUID0] As ActiveXGuid
   ,IEURLInfo.[DocMode0] As DocMode
   ,IEURLInfo.[DocModeReason0] As DocModeReason
   ,IEURLInfo.[BrowserStateReason0] As BrowserStateReason
   ,IEURLInfo.[HangCount0] As NumberOfHangs
   ,IEURLInfo.[CrashCount0] As NumberOfCrashes
   ,OSInfo.Caption0 as OSName
   ,OSInfo.Version0 as OSVersion
   ,OSInfo.CSDVersion0 as CSDVersion
  FROM [dbo].[v_GS_IESYSTEMINFO] AS IESystemInfo,
       [dbo].[v_GS_IECOUNTINFO] AS IECountInfo,
       [dbo].[v_GS_IEURLINFO] AS IEURLInfo,
       [dbo].[v_ClientMachines] AS ClientInfo,
       [dbo].[v_GS_OPERATING_SYSTEM] AS OSInfo
  Where  IESystemInfo.ResourceID = ClientInfo.ResourceID
  AND  IECountInfo.ResourceID = ClientInfo.ResourceID 
  AND  IEURLInfo.ResourceID = ClientInfo.ResourceID 
  AND  OSInfo.ResourceID = ClientInfo.ResourceID 
  order by IESystemInfo.ResourceID ASC, NumberOfCrashes DESC

  /* IE11 Filtered */
SELECT 
   IEURLInfo.[URL0] As URL
   ,case IEURLInfo.[Zone0] 
   when 0 then 'Local'
   when 1 then 'Intranet'
   when 2 then 'Trusted'
   when 3 then 'Internet'
   when 4 then 'Restricted'
   end As Zone
   ,IEURLInfo.[DocMode0] As DocMode
   , case DocModeReason0
   when 0 then 'Uninitialized'
   when 1 then 'MSHTMPAD tracetags for DRTs'
   when 2 then 'Session document mode supplied'
   when 3 then 'FEATURE_DOCUMENT_COMPATIBLE_MODE fck'
   when 4 then 'X-UA-Compatible meta tag'
   when 5 then 'X-UA-Compatible HTTP header'
   when 6 then 'CVList-imposed mode'
   when 7 then 'Native XML Parsing Mode'
   when 8 then 'Toplevel QME FCK was set, and mode was determined by it'
   when 9 then 'DocMode is result of the pages doctype and the browser mode'
   when 10 then 'mode supplied as a hint (not set by a rule)'
   when 11 then 'Weve been constrained to a family can only have a single mode (not set by a rule)'
   when 12 then 'Webplatform version supplied; therefore align doc mode to webplatform version'
   when 13 then 'Top level image file is set; and mode was determined by it'
   when 14 then 'Fed viewer mode determines doc mode'
   end as [Reason]
   ,case BrowserStateReason0
   when 0 then 'Unitialized'
   when 1 then 'Display intranet sites in Compat View checkbox'
   when 2 then 'Site is on GPO CV list'
   when 3 then 'Added to CV list by user'
   when 4 then 'X-UA-Compatible applied to page'
   when 5 then 'Added via Dev toolbar'
   when 6 then 'FEATURE_BROWSER_EMULATION fck'
   when 7 then 'Site is on MS CV list'
   when 8 then 'Site is on GPO Quirks list'
   when 9 then 'MSHTMPAD override'
   when 10 then 'WebPlatform version supplied'
   when 11 then 'Browser Default'
   when 12 then 'Unknown'
   end as [Method]
   ,Count(*) [Total]
  FROM [dbo].[v_GS_IESYSTEMINFO] AS IESystemInfo,
       [dbo].[v_GS_IECOUNTINFO] AS IECountInfo,
       [dbo].[v_GS_IEURLINFO] AS IEURLInfo,
       [dbo].[v_ClientMachines] AS ClientInfo,
       [dbo].[v_GS_OPERATING_SYSTEM] AS OSInfo
  Where  IESystemInfo.ResourceID = ClientInfo.ResourceID
  AND  IECountInfo.ResourceID = ClientInfo.ResourceID 
  AND  IEURLInfo.ResourceID = ClientInfo.ResourceID 
  AND  OSInfo.ResourceID = ClientInfo.ResourceID 
  AND DocMode0 != '11'
  group by IEURLInfo.[URL0]
   ,IEURLInfo.[Zone0]
   ,IEURLInfo.[DocMode0]
   ,IEURLInfo.[DocModeReason0]
   ,IEURLInfo.[BrowserStateReason0]
Having count(*) > 4
order by count(*) DESC