Option Explicit

Const ERROR_SUCCESS = 0

Dim bolDebug
Dim colArgs
Dim objClientAction
Dim objClientActions
Dim objCPAppletMgr
Dim objLocator 
Dim objServices 
Dim objSMSClient
Dim objWShell
Dim strComputer

On Error Resume Next
Set colArgs = WScript.Arguments.Named
If LCase(colArgs("debug")) = "true" Then 
	bolDebug = True
	On Error Goto 0
Else
	bolDebug = False
	On Error Resume Next
End If

strComputer = "."

Set objLocator = CreateObject("WbemScripting.SWbemLocator")
Set objWShell = CreateObject("Wscript.Shell")
Output "Connecting to WMI"

Set objServices = objLocator.ConnectServer(strComputer , "root\ccm\invagt")

Output "Connecting to SCCM Applet"
Set objCPAppletMgr = CreateObject("CPApplet.CPAppletMgr")
Output "Getting Actions"
Set objClientActions = objCPAppletMgr.GetClientActions()
For Each objClientAction In objClientActions
	Output "Performing " & objClientAction.Name
	objClientAction.PerformAction  
Next
Output "Cleanning up"
Set objSMSClient = Nothing
Set objServices = Nothing
Output "Done!!"
Set objWShell = Nothing

Function Output(strMessage)
	If bolDebug Then WScript.Echo strMessage
	objWShell.LogEvent ERROR_SUCCESS, strMessage
End Function
