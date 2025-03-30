Dim oNetwork, oLocator, oSWbemServices, oCollection  
Dim sComputerName, sSMSServer, sSMSSiteCode, sCollectionID, RuleSet  
 
Set oNetwork = CreateObject("WScript.NetWork")   
Set oArguments = Wscript.Arguments

'Constant definition
USE_BINARY_DELTA_REP = &H04000000

'————————————————————
'Main script

    Set swbemLocator = CreateObject("WbemScripting.SWbemLocator")
    swbemLocator.Security_.AuthenticationLevel = 6 'Packet Privacy.
    Set swbemServices = swbemLocator.ConnectServer(".", "root\SMS")
    Set oProviderLocation = swbemServices.InstancesOf("SMS_ProviderLocation")
    For Each oLocation In oProviderLocation
        If oLocation.ProviderForLocalSite = True Then
            Set swbemServices = swbemLocator.ConnectServer(oLocation.Machine, "root\sms\site_" + oLocation.SiteCode)
        End If       
    Next

Set oPackages = SWbemServices.InstancesOf("SMS_Package")  
 
For Each oPackage in oPackages
	If (oPackage.PkgFlags AND USE_BINARY_DELTA_REP) Then
		Wscript.Echo oPackage.Name
	End If
Next

WScript.Quit(0)