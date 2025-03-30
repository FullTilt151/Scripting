' VBScript source code
' ------------------------------------------------------------------------------------------------------------------------------- 
' Nomad LSZ cleanup	  												
' 
' This Script scans all the LSZ files in the Nomad Cache and checks to see if they are missing HashV4
' If missing then the file is deleted.
' 
' This is for use on a 1E Nomad 6.0 Environment 
' 
' 1E Ltd Copyright August 2016
' 
' Disclaimer:															
' Your use of this script is at your sole risk. This script is provided "as-is", without any warranty, whether express 	
' or implied, of accuracy, completeness, fitness for a particular purpose, title or non-infringement, and is not 		
' supported or guaranteed by 1E. 1E shall not be liable for any damages you may sustain by using this script, whether 	
' direct, indirect, special, incidental or consequential, even if it has been advised of the possibility of such damages. 	
'
' ------------------------------------------------------------------------------------------------------------------------------- 
' Version History
' ---------------
'
' Date      Who  	Desc 
' 13/May/16 RobN  	Initial version
' 29/Aug/16 DuncanR	Adjusted for HashV4



logfolder="c:\Temp"
LogFileName = "NomadBranch_LSZ_CleanUp.log"

' ------------------------------------------------------------------------------------------------------------------------------- 
'   		Do Not change anything below this line without confirming details with 1E first.
' ------------------------------------------------------------------------------------------------------------------------------- 


Dim oShell
dim fso
RegistryHead="HKLM"
RegistryNomad="NomadBranch"
Set fso = WScript.CreateObject("Scripting.FileSystemObject")
Set oShell = CreateObject("Wscript.Shell")

set oEnv = oShell.Environment("PROCESS")

RegistryHead="HKLM"
RegistryNomad="NomadBranch"
Registry1E="SOFTWARE\1E"   





' **********************************************************************************************************************************
' ****																****
' ****  						Main Script Loop							****
' ****																****
' **********************************************************************************************************************************

DeleteOldLog

logevent ""
logevent "*****************************"
logevent "Script to clean LSZ files"

call CheckRegistry
CacheDirectory = GetCachePath()

DeletedFiles=0
totalFiles=0

' ** Recurses through the LSZ in the Cache Folder **

	set objFolder = fso.GetFolder(CacheDirectory)
	Set colFiles = objFolder.Files
	For Each objFile in colFiles
		'LogEvent "LST Found : " & objFile.Name & " - " & fso.GetBaseName(objFile.Name)
		If Lcase(right(objFile.Name,4))=".lsz" then 
			
			LogEvent "LSZ Found : " & objFile.Name
			If CheckFile(objFile.Name)= False then
				logevent "Invalid file"
			
				DeleteLST(objFile.Name)
				DeletedFiles = DeletedFiles +1
			else
				totalFiles=totalFiles+1
			end if 
		end if
	Next



LogEvent "Removed " & DeletedFiles & " out of " &  totalFiles & " LSZ Files Processed"
LogEvent "Script Completed Successfully"
LogEvent ""
wscript.quit(0)



' **********************************************************************************************************************************
' ****																****
' ****  					Functions Used By Script							****
' ****																****
' **********************************************************************************************************************************

Function DeleteLST(filename)
	logEvent "** Deleting file - " & filename
	set FileToBin=fso.getfile(CacheDirectory & "\" & filename)
	
	filetobin.delete	
	if fso.fileexists(CacheDirectory & "\"&filename)=true then logevent "Error : file still exists"

end function

Function DeleteOldLog
	
	if fso.fileexists(LogFolder & "\" & LogFileName)=true then
		set FileToBin=fso.getfile(LogFolder & "\" & LogFileName)
	
		filetobin.delete	
	end if

End function


Function CheckFile(FileName)
	'Logevent "Opening File - " & FileName
	lstvalid=False
	
	
	Set fileObj = fso.GetFile(CacheDirectory & "\" & fileName)
	set lstfileRead = fileObj.OpenAsTextStream(1,-1)

	if lstfileRead.AtEndOfStream then
		logevent "Error : File Empty"
		lstvalid=False
	else

		Do Until lstfileRead.AtEndOfStream
    			strNextLine = lstfileRead.Readline
			'logevent strnextline
		

			if instr(strNextLine,"HashV4") > 0 then
				lstvalid=True
			end if

		Loop
	end if	

CheckFile = lstvalid
end Function






Function GetCachePath
' ** Gets the Nomad Cache Path from the Registry  **

	CacheDir=oshell.RegRead (RegistryHead &"\" &  Registry1E & "\" & RegistryNomad &"\LocalCachePath")
	LogEvent "Local Cache Path Read from Registry: " & CacheDir
	
	
    Call CheckFolder(CacheDir)

	GetCachePath = CacheDir

End Function

Function LogEvent(Txt)
' ** Logs The Details of the Script **

    

	If txt<>"" then
		outtxt= now() & "  -  " & Txt
	else
		outtxt= " "
	end if

	
	set outfile = fso.OpenTextFile(logfolder & "\" & LogFileName,8,true)
	outfile.writeline outtxt
	
	
end function

Function CheckFolder(folder)
' ** Checks to see if folder Exists  **

	'LogEvent "Path : " & CacheDirectory

	if fso.folderexists(folder) Then
		LogEvent "Cache Folder Exists"
	else
		LogEvent "ERROR : Folder Does Not exist"
		LogEvent "Exiting Script Early"
		LogEvent "Error code 103"
		wscript.quit (103)
	End if

End Function 

Function CheckRegistry
' ** Checks Registry to see if a Registry key for Nomad Exists **


	LogEvent "Checking Nomad Base Registry Key"
	If RegistryKeyExists(RegistryHead,Registry1E,RegistryNomad) = True Then 
 		LogEvent "Nomad Registry Entries Exist"

  	Else
		LogEvent "Nomad Registry Entries Don't Exist"
		LogEvent "ERROR : Nomad Not installed"
		LogEvent "Exiting Script Early"
		LogEvent "Error code 102"
		wscript.quit (102)
	end if 
 

 


End Function


Function GetNomadFolder




End Function

Function RegistryKeyExists(LNGHKEY, strKey, strSubkey)
' ** Checks Registry to see if a Registry key Exists **

   	Const HKLM = &H80000002
   	'Const HKCR= &H80000000T
   	Const HKCU = &H80000001
   	Const HKUSERS = &H80000003
   	RegistryKeyExists = False
   	Dim reg, aSubkeys, s, hkroot
   	If LNGHKEY = "HKLM" Then hkRoot = HKLM
   	If LNGHKEY = "HKCU" Then hkRoot = HKCU
   	If LNGHKEY = "HKCR" Then hkRoot = HKCR
   	If LNGHKEY = "HKUSERS" Then hkRoot = HKUSERS
   	Set reg = GetObject("WinMgmts:{impersonationLevel=impersonate}!\\.\root\default:StdRegProv")
   	reg.EnumKey hkroot, strKey, aSubkeys
   	If Not IsNull(aSubkeys) Then
   		For Each s In aSubkeys
	
           		If lcase(s)=lcase(strSubkey) Then
               			RegistryKeyExists = True
               			Exit Function
           		End If
       		Next
   	End If
End Function 
   
Function RegistryValueExists(LNGHKEY, strKeyPath, strValueName)
' ** Checks Registry to see if a Registry Value Exists **

	Const HKLM = &H80000002
   	'Const HKCR= &H80000000T
   	Const HKCU = &H80000001
   	Const HKUSERS = &H80000003
   	RegistryValueExists=False

 	If LNGHKEY = "HKLM" Then hkRoot = HKLM
   	If LNGHKEY = "HKCU" Then hkRoot = HKCU
   	If LNGHKEY = "HKCR" Then hkRoot = HKCR
   	If LNGHKEY = "HKUSERS" Then hkRoot = HKUSERS


	strComputer = "."
	Set objRegistry = GetObject("winmgmts:\\" & _ 
	strComputer & "\root\default:StdRegProv")

	objRegistry.GetStringValue hkRoot,strKeyPath,strValueName,strValue

	If IsNull(strValue) =False Then
    		RegistryValueExists=True	

	End If


End Function 












' **********************************************************************************************************************************
' ****																****
' ****  				  End of Script   -   1E Ltd Copyright August 2016					****
' ****																****
' **********************************************************************************************************************************