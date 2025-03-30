 On Error Resume Next
CompName = Wscript.Arguments(0)
If compname = "" Then
  CompName = InputBox("Input a Computer name or IP", "Computer Name",CompName)
End If
err.clear
set DCMInvoke = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" &_
 CompName & "\root\ccm\dcm:SMS_DesiredConfiguration")
 if err.number <> 0 then
 msgbox "unable to access " & CompName & vbcr &_
   "Error: " & err.description,,"SMS DCM Trigger Evaluation"
 else
  Set objSWbemServices = GetObject("winmgmts:\\" & CompName & "\root\ccm\dcm")
  Set colSWbemObjectSet = objSWbemServices.ExecQuery("SELECT * FROM SMS_DesiredConfiguration")
  For Each objSWbemObject In colSWbemObjectSet
   DCMInvoke.TriggerEvaluation objSWbemObject.Name,objSWbemObject.Version
  Next
 end if