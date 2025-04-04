Const HKCR = &H80000000
Const HKCU = &H80000001
Const HKLM = &H80000002
Const HKUS = &H80000003
Const HKCC = &H80000005

MaxMegaByte = readfromRegistry("HKEY_LOCAL_MACHINE\SOFTWARE\1E\NomadBranch\NMDS\MaximumMegaByte", "")
If MaxMegaByte = 0 Then
	'Check for TS in ExecutionHistory

	strKeyBase = "SOFTWARE\Microsoft\SMS\Mobile Client\Software Distribution\Execution History\System"
	arrBackupTS = Array("CAS00342","CAS00365")
	Set oReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\localhost\root\default:StdRegProv")

	oReg.EnumKey HKLM, strKeyBase, arrSubKeys
	For Each strKey In arrSubKeys
		For Each strpkg In arrBackupTS
			If strKey = strpkg Then
				'Backup TS is either running or has been run, bomb out!
				WScript.Echo -1
				WScript.Quit
			End If
		Next
	Next
	'set MaximumMegaByte to 61440
	Set WshShell = CreateObject("WScript.Shell")
	myKey = "HKLM\SOFTWARE\1E\NomadBranch\NMDS\MaximumMegaByte"
	WshShell.RegWrite myKey,61440,"REG_DWORD"
	Set WshShell = Nothing
	WScript.Echo 1
Else
	WScript.Echo 1
End If

WScript.Quit

function readFromRegistry (strRegistryKey, strDefault )
    Dim WSHShell, value

    On Error Resume Next
    Set WSHShell = CreateObject("WScript.Shell")
    value = WSHShell.RegRead( strRegistryKey )

    if err.number <> 0 then
        readFromRegistry= strDefault
    else
        readFromRegistry=value
    end if

    set WSHShell = nothing
end Function

