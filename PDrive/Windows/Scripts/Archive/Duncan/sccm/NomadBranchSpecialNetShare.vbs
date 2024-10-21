const HKEY_CURRENT_USER = &H80000001
const HKEY_LOCAL_MACHINE = &H80000002
strComputer = "."
Set StdOut = WScript.StdOut
 
Set oShell = CreateObject("WScript.Shell")

sRegKey32 = "HKLM\Software\1E\Nomadbranch\"
sRegKey64 = "HKLM\Software\Wow6432Node\1E\Nomadbranch\"

sRegValue = "" ' init value in case value does not exist

On Error Resume Next
sDir = oShell.RegRead(sRegKey32 & "InstallationDirectory")
IF sDir <> "" THEN
	'wscript.echo "32 bit"
	sRegValue = oShell.RegRead(sRegKey32 & "SpecialNetShare")
	IF sRegValue = 0 THEN
		wscript.echo "it is zero, change it"
		sResult = oShell.RegWrite(sRegKey32 & "SpecialNetShare", 8192, "REG_DWORD")
		wscript.echo "result: " & sResult
		sRegValue = oShell.RegRead(sRegKey32 & "SpecialNetShare")
		wscript.echo "changed to " & sRegValue
	END IF
END IF
On Error Goto 0

On Error Resume Next
sDir = oShell.RegRead(sRegKey64 & "InstallationDirectory")
IF sDir <> "" THEN
	'wscript.echo "64 bit"
	sRegValue = oShell.RegRead(sRegKey64 & "SpecialNetShare")
	IF sRegValue = 0 THEN
		wscript.echo "it is zero, change it"
		sResult = oShell.RegWrite(sRegKey64 & "SpecialNetShare", 8192, "REG_DWORD")
		wscript.echo "result: " & sResult
		sRegValue = oShell.RegRead(sRegKey64 & "SpecialNetShare")
		wscript.echo "changed to " & sRegValue
	END IF
END IF
On Error Goto 0



