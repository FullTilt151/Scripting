'
' Set specific BIOS Setting on a remote computer when Administrator password exists
'
On Error Resume Next
Dim colItems

If WScript.Arguments.Count <> 4 Then
    WScript.Echo "SetConfigPasswordRemote.vbs [Item] [Value] [Password+Encoding] [hostname]"
    WScript.Quit
End If

strRequest = WScript.Arguments(0) + "," + WScript.Arguments(1) + ";"
strSecurity = WScript.Arguments(2)+ ";"

strComputer = WScript.Arguments(3)
Set objWMIService = GetObject("WinMgmts:" _
    &"{ImpersonationLevel=Impersonate," _
    &"authenticationLevel=pktPrivacy}!\\" & strComputer & "\root\wmi")
Set colItems = objWMIService.ExecQuery("Select * from Lenovo_SetBiosSetting")

For Each objItem in colItems
    ObjItem.SetBiosSetting strRequest, strReturn
Next

WScript.Echo strRequest
WScript.Echo " SetBiosSetting: " + strReturn

If strReturn <> "Success" Then
    WScript.Quit
End If

Set colItems = objWMIService.ExecQuery("Select * from Lenovo_SaveBiosSettings")

strReturn = "error"
For Each objItem in colItems
    ObjItem.SaveBiosSettings strSecurity, strReturn
Next

WScript.Echo strRequest
WScript.Echo " SaveBiosSettings: " + strReturn
