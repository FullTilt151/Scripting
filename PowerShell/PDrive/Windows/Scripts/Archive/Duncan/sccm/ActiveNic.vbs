strComputer = "."
DIM blNetworkCard
blNetworkCard = false

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
Set colItems = objWMIService.ExecQuery("Select * from Win32_NetworkAdapter Where NetConnectionStatus = 2")
Wscript.echo "Cycling through the active network adapters..."
For Each objItem in colItems
    IF (blNetworkCard) THEN
    	   WScript.echo "Uh oh!  There is more than one network card active..."
    END IF
    blNetworkCard = true
    sActiveName = objItem.Name
    sMacAddress = objItem.MacAddress
    Wscript.Echo "Network Card - " & sActiveName
    Wscript.Echo "MAC Address - " & sMacAddress
    SetTsVariable "ActiveMacAddress", sMacAddress
next

Function SetTsVariable(variableName, variableValue)
	Set TSEnv = CreateObject("Microsoft.SMS.TSEnvironment")
	TSEnv(variableName) = variableValue
	Wscript.echo "Completed setting the TS variable " & variableName & "=" & variableValue
	Set TSEnv = Nothing
End Function