'
' Update Administrator Password
'
On Error Resume Next
Dim colItems
If WScript.Arguments.Count <> 3 Then
    WScript.Echo "SetAdminPassword.vbs [oldpassword] [newpassword] [encoding]"
    WScript.Quit
End If

strRequest = "pap,"+WScript.Arguments(0)+"," + WScript.Arguments(1) + "," +WScript.Arguments(2)+";"
strComputer = "LOCALHOST"     ' Change as needed.
Set objWMIService = GetObject("WinMgmts:" _
    &"{ImpersonationLevel=Impersonate}!\\" & strComputer & "\root\wmi")
Set colItems = objWMIService.ExecQuery("Select * from Lenovo_SetBiosPassword")

strReturn = "error"
For Each objItem in colItems
    ObjItem.SetBiosPassword strRequest, strReturn
Next

WScript.Echo strRequest
WScript.Echo " SetBiosPassword: "+ strReturn