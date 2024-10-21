'########## PARAMETERS ###############
 
'Define the SCCM Site Server
Const SiteServer = "LOUAPPWPS207"
Const SiteCode = "HUM"
 
'########## PROGRAM ###############
 
Dim sResourceID, oSMS
 
If WScript.Arguments.Count <> 2 Then
	WScript.Echo "Usage: AddComputerToCollection.vbs <Computer> <CollectionId>"
	WScript.Quit
End If

Dim sComputer : sComputer = WScript.arguments.item(0)
Dim CollectionId : CollectionId = WScript.arguments.item(1)
 
'Main Program Runs Here…
Call ConnectToSite() : 'Connect to Primary Site Server
Call AddMachineToCollection() 'Add machine to specified collection
 
'########## FUNCTIONS ###############
 
'Query site for machine and return resource ID
Function FindMachine
 
    'Query WMI for the machine
    Set oResults = oSMS.ExecQuery("SELECT * FROM SMS_R_System WHERE Name = '" & sComputer & "'")
 
    For Each oResourceID In oResults
        FindMachine = oResourceID.ResourceID 'Return the result of the query
    Next
End Function
 
'Connect to the SCCM server
Sub ConnectToSite()
 
    On Error Resume Next
    Set oLocator = CreateObject("WbemScripting.SWbemLocator")
 
    'Connect to the SCCM Site Server
    Set oSMS = oLocator.ConnectServer(SiteServer, "root\sms\site_" & SiteCode)
 
    'Quit the script with an error message if unable to connect
    If Err Then
        Err.Clear
        wScript.echo "Cannot connect to SCCM."
        wScript.Quit
    End If
 
    wScript.echo "Connected to " & SiteCode
    oSMS.Security_.ImpersonationLevel = 3
    oSMS.Security_.AuthenticationLevel = 6
End Sub
 
'Create a membership rule to add the machine to the collection
Sub AddMachineToCollection()
 
    'Return the resourceID of the machine
    sResourceID = FindMachine
 
    'Set the machine collection
    Dim oCollection : Set oCollection = oSMS.Get("SMS_Collection.CollectionID=" & """" & CollectionId & """")
    
    'check collection to see if computer already exists in it
    'Get RuleSet
    RuleSet = oCollection.CollectionRules  
    On Error Resume Next
    For Each Rule In RuleSet
    		If Err Then
		'Do nothing
		Else
	    		If Rule.Path_.Class = "SMS_CollectionRuleDirect" Then  
    				If Rule.ResourceID = sResourceID Then  
          	  		''''oCollection.DeleteMembershipRule Rule
            			wScript.echo sComputer  & " is already in collection " & oCollection.Name
            			Exit Sub
	        		End If  
    			End If  
    		End If
	Next
	If Err Then
		Err.Clear
	End If 
    On Error Goto 0
    'Create a membership rule
    Dim oCollectionRule : Set oCollectionRule = oSMS.Get("SMS_CollectionRuleDirect").SpawnInstance_() 
 
    'Define the membership rules properties
    oCollectionRule.ResourceClassName = "SMS_R_System"
    oCollectionRule.ResourceID = sResourceID
    oCollection.AddMembershipRule oCollectionRule : 'Create membership rule
 
    wScript.echo "Added " & sComputer  & " to collection " & oCollection.Name
End Sub
