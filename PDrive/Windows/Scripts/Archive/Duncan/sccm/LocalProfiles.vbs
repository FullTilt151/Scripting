on error resume next
'Steps
'enumerate from win32_userprofile
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
          
          Set oServices = oLocation.ConnectServer(,"root\cimv2") 
          set oNewObject = oServices.Get("CM_UserProfiles") 
          oNewObject.Delete_ 
          '==================
          'Get the local Group Names
          '==================
          Dim iProfiles(300)
          Dim iProfilePath(300)
          Dim iLastUseTime(300)
          Dim iProfileSize(300)
          
          i=0
          Set objWMIService = GetObject("winmgmts:" _
                  & "{impersonationLevel=impersonate}!\\.\root\cimv2")
          Set colGroup = objWMIService.ExecQuery("select * from win32_userprofile")
          for each obj in colGroup
          	IF (i < = 300) THEN
          		iProfiles(i)=obj.Name
          		iProfilePath = obj.LocalPath
          		iLastUseTime = obj.LastUseTime
          		i=i+1
          		
          	END IF
          next
          
          k = 0
          
          '===============
          'Get all of the names within each group
          dim strLocal(300)
          k=0
          Set oLocation = CreateObject("WbemScripting.SWbemLocator") 
          Set oServices = oLocation.ConnectServer(, "root\cimv2" ) 
          
          'group name, domain name, user or group
          for j = 0 to i-1
          
          squery = "select partcomponent from win32_groupuser where groupcomponent = ""\\\\" &_
           strComputer & "\\root\\cimv2:Win32_Group.Domain=\""" & strComputer &_
           "\"",Name=\""" &iProfiles(j) & "\""""" 
          
          Set oInstances = oServices.ExecQuery(sQuery) 
           FOR EACH oObject in oInstances 
            strLocal(k)=iProfiles(j) & "!" & oObject.PartComponent
          	wscript.echo strLocal(k)
            k=k+1
          
           Next
          next
          '==================
          'Drop that into a custom wmi Namespace
          '==================
          
          
          ' Create data class structure 
          Set oDataObject = oServices.Get 
          oDataObject.Path_.Class = "CM_UserProfiles" 
          oDataObject.Properties_.add "Account" , wbemCimtypeString 
          oDataObject.Properties_("Account").Qualifiers_.add "key" , True 
          oDataObject.Properties_.add "Domain" , wbemCimtypeString
          oDataObject.Properties_.add "Category" , wbemCimtypeString
          oDataObject.Properties_.add "Type" , wbemCimtypeString
          oDataObject.Properties_.add "Name" , wbemCimtypeString
          oDataObject.Properties_("Name").Qualifiers_.add "key" , True
          oDataObject.Put_ 
          
          for m = 0 to k-1
          Set oNewObject = oServices.Get("CM_LocalGroupMembers" ).SpawnInstance_ 
          str0 = Split(strLocal(m), "!", -1, 1)
          str1 = Split(str0(1), "," , -1, 1) 
          str2 = Split(str1(0), "\" , -1, 1) 
          str4 = Split(str2(4), Chr(34), -1, 1) 
          
          
          ' The Account name or Group Name is inside the quotes after the comma 
          str3 = Split(str1(1), Chr(34), -1, 1) 
          ' if the wmi source name is the same as the domain name inside the quotes, it' s a local account 
          ' str2(2) is the wmi source name, str4(1) is the domain name inside the quotes. 
          If lcase(str2(2)) = lcase(str4(1)) Then 
          oNewObject.Type = "Local" 
          Else 
          oNewObject.Type = "Domain" 
          End If
          oNewObject.Domain = str4(1) 
          oNewObject.Account = str3(1) 
          oNewObject.Name = str0(0)
          Select Case lcase(str4(0))
            case "cimv2:win32_useraccount.domain="
             oNewObject.Category = "UserAccount"
            Case "cimv2:win32_group.domain="
             oNewObject.Category = "Group"
            Case "cimv2:win32_systemaccount.domain="
             oNewObject.Category = "SystemAccount"
            case else
             oNewObject.Category = "unknown"
          end select
          oNewObject.Put_ 
          Next
          wscript.echo "ok"
     
     end if
Next

wscript.quit

Function GetFolderSize(FolderSpec)
	Global fso
	Dim TotalSize, fsize, sf
	ON ERROR RESUME NEXT
	IF NOT (fso.FolderExists(FolderSpec)) THEN
		GetFolderSize = 0
	ELSE
		Set SourceLoc = fso.GetFolder(sLoc)
		fsize = SourceLoc.Size
		TotalSize = FormatNumber(((fSize/1024)/1024),2)
		Set sf = SourceLoc.SubFolders
		For Each SubDirs in sf
			fsize = FindFolder(SubDirs.Path)
			TotalSize 
		Next 
	END IF

End Function

Function FindFolder (FolderSpec)
	Global fso
     'Get the specified folder object
     Set f1 = fso.GetFolder(FolderSpec)
     'Error processing - set if error occurs resume the script    
     On Error Resume Next 
 
     'Get the folder size
     fsize = f1.Size 
 
     'if the folder structure or any files are corrupted under this sub folder
     'getting the size will return an error
     '
     'check if we got an error,
     If Err.Number <> 0 Then
         'Yup, got an error
         Wscript.Echo f1.path & " is corrupted. Script cannot process this location."
         Err.Clear
         FindFolder = 0
     Else
         'display and log the folder name and size            
         FindFolder = FormatNumber(((fSize/1024)/1024),2)
     End If
     On Error Goto 0
     Set f1 = Nothing
End Function

