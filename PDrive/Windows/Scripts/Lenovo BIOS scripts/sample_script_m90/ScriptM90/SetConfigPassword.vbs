'
' Set specific BIOS Setting on local system when Administrator password exists
'
On Error Resume Next
Dim colItems

If WScript.Arguments.Count <> 3 Then
    WScript.Echo "SetConfigPassword.vbs [Item] [Value] [Password+Encoding]"
    WScript.Echo "Example:change Audio setting to Disabled when pap is ascii 123"
    WScript.Echo "SetConfigPassword.vbs ""Audio Support"" Disabled ""123,ascii,us"""
    WScript.Quit
End If

strRequest = WScript.Arguments(0) + "," + WScript.Arguments(1) + ";"
strSecurity = WScript.Arguments(2)+ ";"

strComputer = "LOCALHOST"     ' Change as needed.
Set objWMIService = GetObject("WinMgmts:" _
    &"{ImpersonationLevel=Impersonate}!\\" & strComputer & "\root\wmi")
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
