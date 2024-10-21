' EXAMPLE
' cscript CheckForAdvert.vbs /MAC:90:FB:A6:11:8B:DD /UUID:32A7E113-1388-4527-93AB-CF2FD8EFA332 /CollID:CAS0056B /SiteCode:CAS /Timeout:10"

CONST sDeploymentWsBase = "http://louappwps875.rsc.humad.com/DeploymentWS/sccm.asmx"
CONST sFunction = "/HasOSDAdvertisementByCollectionID"
CONST iTimerDefault = 30
DIM sMAC, sUUID, sCollID, sSiteCode, iLoopTimer, oXMLDoc, oXMLHTTP

iLoopTimer = 30 'Default timeout setting

CheckUsage
Main

Sub CheckUsage()
     DIM colNamedArguments
     DIM sScriptUsage : sScriptUsage = "Usage: cscript CheckForAdvert.vbs /MAC:<Computer MAC address> /UUID:<Computer UUID> /CollID:<Collection ID> /SiteCode:<Site Code> [/Timer:<Timeout minutes>]"
     DIM sScriptParams: sScriptParams = "PARAMETERS:" & CHR(10) & _
     	"_____________________" & CHR(10) & _
     	"MAC:	Computer's MAC address" & CHR(10) & _
     	"UUID:	Computer's UUID" & CHR(10) & _
     	"CollID:	Collection ID" & CHR(10) & _
     	"SiteCode:	Config Manager three-digit site code" & CHR(10) & _
     	"Timer:	(Optional) Timeout value for loop, default is 5 minutes"
     DIM sScriptExample : sScriptExample = "EXAMPLE:" & CHR(10) & "cscript CheckForAdvert.vbs /MAC:90:FB:A6:11:8B:DD /UUID:32A7E113-1388-4527-93AB-CF2FD8EFA332 /CollID:CAS0056B /SiteCode:CAS /Timer:10"
     
     Set colNamedArguments = WScript.Arguments.Named
     
     If ((colNamedArguments.Item("MAC") = "") OR (colNamedArguments.Item("UUID") = "") OR (colNamedArguments.Item("CollID") = "") OR (colNamedArguments.Item("SiteCode") = "")) THEN
     	WScript.Echo sScriptUsage
     	WScript.Echo ""
     	WScript.Echo sScriptParams
     	WScript.Echo ""
     	WScript.Echo sScriptExample
     	WScript.Quit
     END IF
     
     sMAC = colNamedArguments.Item("MAC")
     sUUID = colNamedArguments.Item("UUID")
     sCollID = colNamedArguments.Item("CollID")
     sSiteCode = colNamedArguments.Item("SiteCode")
	
	IF (colNamedArguments.Item("Timer") <> "") THEN
     	iLoopTimer = CInt(colNamedArguments.Item("Timer"))
     END IF
End Sub

Sub Main()
     
     'sParams = "MACAddress=90:FB:A6:11:8B:DD&UUID=32A7E113-1388-4527-93AB-CF2FD8EFA332&collectionID=CAS0056B&SiteCode=CAS"
     sParams = "MACAddress=" & sMAC & "&UUID=" & sUUID & "&collectionID=" & sCollID & "&SiteCode=" & sSiteCode
     Dim Starting, Ending, t
     Starting = Now()
     Ending = DateAdd("n",iLoopTimer,Starting)
Wscript.echo Starting &  "," & Ending
     Do
     	wscript.echo Now() & "...checking..."
     	MakeCall sDeploymentWsBase & sFunction, sParams
     	t = DateDiff("n",Now(),Ending)
     	If  t <= 0 Then Exit Do
     	WScript.Sleep 10000
     Loop
     WScript.Echo "Timeout reached!"
     WScript.Quit -1
     
END SUB

SUB MakeCall(sUrl, sParams)
	Set oXMLHTTP = Nothing
	Set oXMLDoc = Nothing
     'The object that will make the call to the WS
     Set oXMLHTTP = CreateObject("Microsoft.XMLHTTP")
     'The object that will receive the answer from the WS
     Set oXMLDoc = CreateObject("MSXML.DOMDocument")
	oXMLHTTP.onreadystatechange = getRef("HandleStateChange")
	oXMLHTTP.open "POST", sUrl, False
	oXMLHTTP.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
	oXMLHTTP.send sParams
End sub

 
Sub HandleStateChange()
	Dim szResponse, sResult
	'When the call has been completed (ready state 4)
	If oXMLHTTP.readyState = 4 Then
		szResponse = oXMLHTTP.responseText
		oXMLDoc.loadXML szResponse
		'If the WS response is not in XML format, there is a problem
		If oXMLDoc.parseError.errorCode <> 0 Then
			WScript.Echo "ERROR:"
			WScript.Echo oXMLHTTP.responseText
			WScript.Echo oXMLDoc.parseError.reason
		Else
			'wscript.echo oXMLDoc
			sResult = oXMLDoc.getElementsByTagName("boolean")(0).childNodes(0).Text
			WScript.Echo "Result: " & oXMLDoc.getElementsByTagName("boolean")(0).childNodes(0).Text
			IF instr(LCASE(sResult), "true") THEN WSCRIPT.Quit 0
		End If
	End If
End Sub
