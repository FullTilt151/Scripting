dim NeedRemediation, strComputer, objWMIService, colItems, objItem, results
NeedRemediation = False
strComputer = "."
Set objWMIService = GetObject("winmgmts:" _
    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")

Set colItems = objWMIService.ExecQuery("Select ExitCode from Win32_Service where Name = 'wuauserv'")

For Each objItem in colItems
	If objItem.ExitCode = -2147467243 Then
		wscript.echo 1
		NeedRemediation = True
	Else
		wscript.echo 0
	End If
Next

If (NeedRemediation = True) Then
	results = RunCommand("net stop bits")
	results = RunCommand("net stop wuauserv")
	results = RunCommand("%systemroot%\system32\sc.exe sdset bits D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)")
	results = RunCommand("%systemroot%\system32\sc.exe sdset wuauserv D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)")
	results = RunCommand("cmd /c del ""%ALLUSERSPROFILE%\Application Data\Microsoft\Network\Downloader\qmgr*.dat""")
	results = RunCommand("cmd /c Ren %systemroot%\SoftwareDistribution\DataStore *.bak")
	results = RunCommand("cmd /c Ren %systemroot%\SoftwareDistribution\Download *.bak")
	results = RunCommand("cmd /c Ren %systemroot%\system32\catroot2 *.bak")
	results = RunCommand("net start bits")
	results = RunCommand("net start wuauserv")
End If

Function RunCommand(strCommand)
	dim oShell
	On Error Resume Next
	Set oShell = WScript.CreateObject ("WScript.Shell")
	Return = oShell.Run(strCommand, 1, true)
	Set oShell = Nothing
	RunCommand = Return
End Function
