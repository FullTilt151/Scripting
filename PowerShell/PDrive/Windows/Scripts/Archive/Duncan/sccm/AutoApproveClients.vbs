Option Explicit
'--------------------------------------------------------------------------------------------
' 
' Filename:		AutoApproveClients.vbs
' Created By:	Larry Brown
' Created:		08/05/09
' Related Files:	
'
' Purpose:		
' 
'
' Usage:		cscript.exe AutoApproveClients.vbs
' 
' Revision History: 
'  Sets all clients in a specific collection to Approved. Only runs on PCI if ran locally.
'			
'
'		
'--------------------------------------------------------------------------------------------
' Variable Declarations
'--------------------------------------------------------------------------------------------

Dim bDebug: bDebug = False
Dim bLogging: bLogging = True


If bDebug = False then on Error Resume Next

Const HKEY_CLASSES_ROOT = &H80000000
Const HKEY_CURRENT_USER = &H80000001
Const HKEY_LOCAL_MACHINE = &H80000002
Const HKEY_USERS = &H80000003
Const ForAppending = 8
Const ForReading = 1
Const ForWriting = 2

Dim objComputer
Dim SystemDrive, ProgramFiles, WinDir
Dim strAllUsersDesktopPath, strAllUsersProgramsPath, strUserProfilesMainFolder
Dim strScriptFileDirectory, strLogFile, strLogDir, strCurrentUserStartMenu, strCurrentUserDesktop
Dim objExplorer, objSMS
Dim strConsoleUserName

Dim objLocator: Set objLocator = CreateObject("WbemScripting.SWbemLocator")
Dim objComputerSet: Set objComputer = GetObject("WinNT://" & "." & "")
Dim objWshShell: Set objWshShell = WScript.CreateObject("WScript.Shell")
Dim objFSO: Set objFSO = CreateObject("Scripting.FileSystemObject")
Dim objNetwork: Set objNetwork = Wscript.CreateObject("WScript.Network")
Dim objWMI: Set objWMI = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\.\root\cimv2")
Dim objWshEnv: Set objWshEnv = objWshShell.Environment("PROCESS")
Dim objReg: Set objReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\default:StdRegProv")
Dim objADSysInfo: Set objADSysInfo = CreateObject("ADSystemInfo")
Dim objArgs: Set objArgs = WScript.Arguments

On Error Resume Next' The next line only works if it is a OSD Task Environment.
Dim TsEnv: Set TsEnv = CreateObject("Microsoft.SMS.TsEnvironment")
If bDebug = True Then On Error GoTo 0 ' Sets it back according to the bDebug Variable set at the top.

objComputer = objWshEnv("COMPUTERNAME")

'Set Environment Variables.
SetScriptItems

If bLogging = True Then
	LogEntry("Logging is enabled. Log file located " & strLogDir & "\" & strLogFile)
End If

If bDebug = True Then
	LogEntry("Debugging is enabled")
Else
	LogEntry("Debugging is disabled")
End If

'--------------------------------------------------------------------------------------------
' Sub Main
'--------------------------------------------------------------------------------------------

'<------------------Code in between these lines------------------->

Dim colSiteDetails, insSiteDetails
Dim insCollection, colCollections, insNewResource

Dim objSite, colSites, StrComputer, strType


' Dim strServer: strServer = "ServerName" ' Add your Server Name here.
' Dim strSiteCode: strSiteCode = "SiteCode" ' Add your 3 letter Site Code Here.
' Dim strCollID: strCollID = "SMSXXXXX"  ' this is the Collection to check for "Not Approved" machines.


Dim strServer: strServer = "LOUAPPWPS207" ' Add your Server Name here.
Dim strSiteCode: strSiteCode = "HUM" ' Add your 3 letter Site Code Here.
Dim strCollID: strCollID = "HUM0002B"  ' this is the Collection to check for "Not Approved" machines.
'HUM0002B

Call GenSrvList


For Each objSite In colSites
	StrComputer = objSite.Servername
	strType = objSite.Type
	strSiteCode = objSite.SiteCode
	StrComputer = UCase(StrComputer)
		If strType = 2 Then
			LogEntry StrComputer & ":"
			Call Main(StrComputer,strSiteCode)
	End If
Next   

ExitMessage



'<--------------------------End Of Code --------------------------->

' ~$~----------------------------------------~$~
'            FUNCTIONS & SUBROUTINES
' ~$~----------------------------------------~$~

Sub Main(StrComputer, strSiteCode)
	
	Dim strResult
	strResult = ConnecttoDB(StrComputer,strSiteCode)
	If strResult <> True Then
		Exit Sub
	End If
	Dim intNumber: intNumber = 0
	LogEntry "Refreshing All Systems Main Collection on " & strSiteCode
	call refeshCol("SMS00001",StrComputer,strSiteCode)
	LogEntry "Sleeping 20 Seconds, waiting for SCCM to catch up."
	WScript.Sleep 20000
	Call refeshCol(strCollID,StrComputer,strSiteCode)
	LogEntry "Collection refresh triggered. Waiting for 20 seconds before continuing"
	WScript.Sleep 20000
	Dim instColl:  set instColl = objSMS.Get("SMS_Collection.CollectionID="&"""" & strCollID & """") 
	if Instcoll.Name="" then      'check valid collection 
		LogEntry strCollID &" Not Found"
	End If
	Dim colNewResources, strNewResourceID
	Dim strQuery: strQuery = "SELECT ResourceID, Name FROM SMS_FullCollectionMembership WHERE CollectionID = '" & strCollID & "'" 
	
	set colNewResources=objSMS.ExecQuery(strQuery)  
	Dim strResourceIDs()
	ReDim Preserve strResourceIDs(1)
	Dim int: int = 0
	Dim arrLimit: arrLimit = 300
	For each insNewResource in colNewResources 
		
		strNewResourceID = insNewResource.ResourceID 
		LogEntry "Name: " & insNewResource.name & " ResourceID: " & strNewResourceID
		intNumber = intNumber + 1
		strResourceIDs(int) = strNewResourceID
		If UBound(strResourceIDs) = arrLimit THEN
				If ApproveComputer(strResourceIDs) = True Then
					LogEntry "exiting loop with Success"
					logentry "Updated " & intNumber & " Machines so far..."
				Else
					LogEntry "Problem running script!"
				End If

				ReDim strResourceIDs(1)
				int = 0
				LogEntry "strResourceIDs length = " & UBound(strResourceIDs)
		ELSE
			int = UBound(strResourceIDs) + 1
			ReDim Preserve strResourceIDs(int)
		End If
	Next
	
	
	
	If ApproveComputer(strResourceIDs) = True Then
		LogEntry "exiting script with Success"
	Else
		LogEntry "Problem running script. Exiting with Error"
	End If
	LogEntry "Refreshing collection Again."
	Call refeshCol(strCollID,StrComputer,strSiteCode)
	CloseDB
	logentry "Updated " & intNumber & " Machines."
	
End sub     

Sub refeshCol(strCollID,StrComputer,strSiteCode)
	
	Dim objLoc, objCollection
	Set objLoc = CreateObject("WbemScripting.SWbemLocator")
	Set objCollection = GetObject( "WinMgmts:!\\" & StrComputer & "\root\SMS\site_" & strSiteCode & _
	":SMS_Collection.CollectionID='" & strCollID & "'")
	objCollection.RequestRefresh True
	objLoc = Null
	
End Sub

Function ApproveComputer(strResourceIDs)
	

	ApproveComputer = False
	Dim objTest: Set objTest = objSMS.Get("SMS_Collection")
    Dim inParams: Set inParams = objTest.Methods_("ApproveClients").InParameters.SpawnInstance_()
    Dim outParams
    
    inParams.Properties_.Item("ResourceIDs") = strResourceIDs
    inParams.Properties_.Item("Approved") = True
    
    Set outParams = objSMS.ExecMethod("SMS_Collection", "ApproveClients", inParams)
	
    If Err.Number <> 0 Then 
        WScript.Echo "Error changing Clients to Approved."
    Else
        WScript.Echo "Bits changed with Success.."
        ApproveComputer = True
    End If
	
End Function

Sub SetScriptItems

	' Attempts to set the variables and objects that might be needed by the script (not all variables may be used by the script).
	SystemDrive = objWshShell.ExpandEnvironmentStrings("%SystemDrive%")
	ProgramFiles = objWshShell.ExpandEnvironmentStrings("%ProgramFiles%")
	WinDir = objWshShell.ExpandEnvironmentStrings("%windir%")
	
	' Attempts to set the needed directory paths.
	strScriptFileDirectory = objFSO.GetParentFolderName(wscript.ScriptFullName)
	
	' Sets the Log file location.
	Dim strLogArray: strLogArray = split(wscript.scriptname,".")
	strLogFile = strLogArray(0) & ".log"
	
	' strLogDir = SetupLogFileLocation
	
	strLogDir = strScriptFileDirectory
	' Attempts to obtain the Desktop and Star Menu paths for all users.
	strAllUsersProgramsPath = objWshShell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\Common Programs")
	strAllUsersDesktopPath = objWshShell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\Common Desktop")
	
	' Attempts to configure Windows XP paths.
	strUserProfilesMainFolder = Mid(strAllUsersDesktopPath,1,InStr(strAllUsersDesktopPath, "\All Users"))
	strCurrentUserDesktop = strUserProfilesMainFolder & objNetwork.UserName & "\Desktop"
	strCurrentUserStartMenu = strUserProfilesMainFolder & objNetwork.UserName & "\Start Menu"
	
	If strUserProfilesMainFolder = "" Then
		' Attempts to configure Windows Vista paths.
		strUserProfilesMainFolder = Mid(strAllUsersDesktopPath,1,InStr(strAllUsersDesktopPath, "\Public"))
		strCurrentUserDesktop = strUserProfilesMainFolder & objNetwork.UserName & "\Desktop"
		strCurrentUserStartMenu = strUserProfilesMainFolder & objNetwork.UserName & "\AppData\Roaming\Microsoft\Windows\Start Menu"
	End If
	
End Sub

Function SetupLogFileLocation

	Dim strScript: strScript = wscript.ScriptName
	Dim strPath, path, strRootFolder
	
	strRootFolder = "CORP"
	strPath = array(SystemDrive,strRootFolder,"Logs",objFSO.GetBaseName(strScript))
	
	For Each path In strPath
		If path <> SystemDrive Then
			strLogDir = strLogDir & "\" & path
		Else
			strLogDir = path
		End If
		If objFSO.FolderExists(strLogDir & "\") = False Then
			objFSO.CreateFolder(strLogDir & "\")
			If objFSO.FolderExists(strLogDir & "\") = False Then
				WScript.Quit(1)
				'Problem Creating Folder.
			End If
		End If
		
	Next
	Dim isHidden
	Dim HideFolder: Set HideFolder = objFSO.GetFolder(SystemDrive & "\" & strRootFolder)
	isHidden = HideFolder.Attributes
	If isHidden <> 18 Then
		HideFolder.Attributes = HideFolder.Attributes Or 2
	End If
	HideFolder = Null
	
	SetupLogFileLocation = strLogDir

End function

Function LogEntry(Info)

	If bDebug = True Then
		WScript.Echo (Info)
	End If
	
	If bLogging = True Then
		Dim objTextFile
		Dim FileName: FileName = strLogDir & "\" & strLogFile
		Set objTextFile = objFSO.OpenTextFile(FileName, ForAppending, True)
		objTextFile.WriteLine(Now() & " " & Info)
		objTextFile.Close
	End If

End Function

Sub CloseOut(strErrorCode)
	
	strErrorCode = Int(strErrorCode)
	If strErrorCode = 0 Then
		LogEntry "Exiting with Success"
	Else
		LogEntry "Exiting with Error " & strErrorCode
	End If
	
	objLocator = Null
	objComputer = Null
	objWshShell = Null
	'objFSO = Null
	objNetwork = Null
	objWMI = Null
	objWshEnv = Null
	objReg = Null
	objADSysInfo = Null
	objArgs = Null
	

	WScript.Quit(strErrorCode)
	
End Sub

Sub GenSrvList

	On Error GoTo 0

	ConnecttoDB strServer,strSiteCode 
	logentry "Refreshing All Systems Collection on " & strSiteCode
	refeshCol "SMS00001",strServer,strSiteCode

	Set colSites = objSMS.ExecQuery("select * from SMS_Site order by ServerName")
	LogEntry "List generation complete."
	LogEntry "*************************"

	CloseDB
	
End Sub

Function ConnecttoDB (StrComputer,strSiteCode)
	
	On Error Resume next
	ConnecttoDB = False
	LogEntry "Connecting to the database  " & StrComputer & "\site_" & strSiteCode
	LogEntry "*************************************"
	Set objLocator = CreateObject("WbemScripting.SWbemLocator")
	Set objSMS = objLocator.ConnectServer(StrComputer,"root\SMS\site_" & strSiteCode)
	If Err.Number <> 0 Then
		LogEntry "***Error: Unable to connect to SMS Database on " & StrComputer & "!"
		LogEntry "***Error code: " & Err.Number & " -- " & Err.Description
	Else
		ConnecttoDB = True
	End If 

end Function

Sub CloseDB

	objSMS = Null
	objLocator= Null
	
end Sub


Sub ExitMessage

	WScript.Echo ""
	WScript.Echo ""
	Dim strMessage: strMessage = "Press the ENTER key to continue. "
	Wscript.StdOut.Write strMessage
	Dim Input
	Do While Not WScript.StdIn.AtEndOfLine
	   Input = WScript.StdIn.Read(1)
	Loop
	WScript.Quit	
	
End sub
