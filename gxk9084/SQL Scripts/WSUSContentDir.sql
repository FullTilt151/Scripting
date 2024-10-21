--get WSUSContentDir
select * from tbConfigurationB

--Reset WSUS Content Dir to Local path
--update tbConfigurationB set LocalContentCacheLocation ='d:\WSUS\WsusContent'

--Reset WSUS Content Dir to UNC path
--update tbConfigurationB set LocalContentCacheLocation ='\\LOUAPPWPS1740.rsc.humad.com\WSUS\WsusContent'