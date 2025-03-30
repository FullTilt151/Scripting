on error resume next
'Steps
'enumerate from win32_group where localaccount=1 (change to win32_UserAccount)
'Read in the members of each local group returned
'Add the returned information to a custom WMI namespace
'sms-def.mof to pull that back.
Set fso = CreateObject("Scripting.FileSystemObject") 
Set nwo = CreateObject("Wscript.Network") 
Set sho = CreateObject("Wscript.Shell") 
TempFolder = sho.ExpandEnvironmentStrings("%temp%")
strWindir = sho.ExpandEnvironmentStrings("%windir%")
strComputer = nwo.ComputerName
Dim wbemCimtypeSint16 
Dim wbemCimtypeSint32 
Dim wbemCimtypeReal32 
Dim wbemCimtypeReal64 
Dim wbemCimtypeString 
Dim wbemCimtypeBoolean 
Dim wbemCimtypeObject 
Dim wbemCimtypeSint8 
Dim wbemCimtypeUint8 
Dim wbemCimtypeUint16 
Dim wbemCimtypeUint32 
Dim wbemCimtypeSint64 
Dim wbemCimtypeUint64 
Dim wbemCimtypeDateTime 
Dim wbemCimtypeReference 
Dim wbemCimtypeChar16 

wbemCimtypeSint16 = 2 
wbemCimtypeSint32 = 3 
wbemCimtypeReal32 = 4 
wbemCimtypeReal64 = 5 
wbemCimtypeString = 8 
wbemCimtypeBoolean = 11 
wbemCimtypeObject = 13 
wbemCimtypeSint8 = 16 
wbemCimtypeUint8 = 17 
wbemCimtypeUint16 = 18 
wbemCimtypeUint32 = 19 
wbemCimtypeSint64 = 20 
wbemCimtypeUint64 = 21 
wbemCimtypeDateTime = 101 
wbemCimtypeReference = 102 
wbemCimtypeChar16 = 103 
' Remove classes 
Set oLocation = CreateObject("WbemScripting.SWbemLocator") 
'===================
'If this is a Domain Controller, bail!
'===================
Set oWMI = GetObject("winmgmts:" _
& "{impersonationLevel=impersonate}!\\.\root\cimv2")
Set colComputer = oWMI.ExecQuery _
("Select DomainRole from Win32_ComputerSystem")
For Each oComputer in colComputer
      if (oComputer.DomainRole = 4 or oComputer.DomainRole = 5) then
           wscript.echo "DomainController, So I'm quitting!"
           'wscript.quit
      Else
          '==================
          'If it is NOT a domain controller, then continue gathering info 
          'and stuff it into WMI for later easy retrieval
          '==================
          
          '==================
          'Create custom wmi Namespace
          '==================
          
          Set oServices = oLocation.ConnectServer(,"root\cimv2")
          
          'Delete custom space if it already exists
          set oNewObject = oServices.Get("CM_LocalUserAccounts") 
          oNewObject.Delete_ 
          
          ' Create data class structure 
          Set oDataObject = oServices.Get 
          oDataObject.Path_.Class = "CM_LocalUserAccounts" 
          oDataObject.Properties_.add "Name" , wbemCimtypeString
          oDataObject.Properties_("Name").Qualifiers_.add "key" , True
          oDataObject.Properties_.add "FullName" , wbemCimtypeString
          oDataObject.Properties_.add "Description" , wbemCimtypeString
          oDataObject.Properties_.add "SID" , wbemCimtypeString
          oDataObject.Properties_("SID").Qualifiers_.add "key" , True
          oDataObject.Properties_.add "Disabled" , wbemCimtypeBoolean
          oDataObject.Put_ 
          
          '==================
          'Get the local User Accounts
          '==================
          Set objWMIService = GetObject("winmgmts:" _
                  & "{impersonationLevel=impersonate}!\\.\root\cimv2")
          Set colUsers = objWMIService.ExecQuery("select * from win32_useraccount where localaccount = True")
          
          '==================
          'Insert local User Accounts into custom wmi Namespace
          '==================
          FOR EACH obj IN colUsers
          	Set oNewObject = oServices.Get("CM_LocalUserAccounts" ).SpawnInstance_
          	oNewObject.Name = obj.Name
          	oNewObject.FullName = obj.FullName
          	oNewObject.Description = obj.Description
          	oNewObject.SID = obj.SID
          	oNewObject.Disabled = obj.Disabled
          	oNewObject.Put_
          NEXT     
     END IF
NEXT

wscript.quit