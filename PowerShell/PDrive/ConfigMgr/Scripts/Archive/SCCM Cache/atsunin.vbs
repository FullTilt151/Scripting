Dim objWMIService, strComputer, intSleep, strService, objItem

Set WSHShell = CreateObject("WScript.Shell")
Set wshNetwork = WScript.CreateObject( "WScript.Network" )
strComputer = wshNetwork.ComputerName
intCacheSize = 5120
Set objWMIService = GetObject("winmgmts://" & strComputer & "/root/ccm/SoftMgmtAgent")
Set colItems = objWMIService.ExecQuery("Select * from CacheConfig")
For Each objItem in colItems
  objItem.Size = intCacheSize
  objItem.Put_ 0
  WshShell.Logevent 4, "The SCCM cache size on " & UCase(strComputer) & " located at " & objItem.Location & " will be changed to: " & objItem.Size & " MB"
Next
  
Dim objService, colListOfServices

intSleep = 15000
strService = " 'CCMExec' "
Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set colListOfServices = objWMIService.ExecQuery ("Select * from Win32_Service Where Name ="& strService & " ")
For Each objService in colListOfServices
'strServiceList = strServiceList & vbCr & objService.name
objService.StopService()
WSCript.Sleep intSleep
objService.StartService()
Next
'WScript.Echo strServiceList
WshShell.Logevent 4, "Your "& strService & " service has Started"
WshShell.Logevent 4, "The SCCM cache size on " & UCase(strComputer) & " has been changed to: " & intCacheSize & " MB"
WScript.Quit