
Const HKEY_LOCAL_MACHINE = &H80000002
strComputer = "."
strKeyPath = "SOFTWARE\1e\NomadBranch\MaxWorkRates"
strArrayValue = "80,80,80,80,80,80,80,40,40,40,40,40,40,40,40,40,40,40,80,80,80,80,80,80"
strArubaValue = "80,80,80,80,80,80,80,20,20,20,20,20,20,20,20,20,20,20,80,80,80,80,80,80"

Set objRegistry = GetObject("winmgmts:\\" & strComputer & "\root\default:StdRegProv")
objRegistry.CreateKey HKEY_LOCAL_MACHINE, strKeyPath

FOR x = 1 to 5
	strValueName = "Day" & x
	objRegistry.SetStringValue HKEY_LOCAL_MACHINE, strKeyPath, strValueName, strArrayValue
NEXT
wscript.echo 0
wscript.quit