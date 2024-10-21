RefreshServerComplianceState

Sub RefreshServerComplianceState()

    ' Initialize the UpdatesStore variable.
    dim newCCMUpdatesStore 
    
    ' Create the COM object.
    set newCCMUpdatesStore = CreateObject ("Microsoft.CCM.UpdatesStore")

    ' Refresh the server compliance state by running the RefreshServerComplianceState method.
    newCCMUpdatesStore.RefreshServerComplianceState
    
    ' Output success message.
    wscript.echo "Ran RefreshServerComplianceState."

End Sub