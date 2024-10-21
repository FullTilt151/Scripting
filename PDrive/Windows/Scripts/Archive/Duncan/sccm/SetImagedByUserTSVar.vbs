Main ()

Function Main
 Dim fileSystem, theDrive, FilePath, fileObject, retval, snLine, ForReading
 Set fileSystem = CreateObject ("Scripting.FileSystemObject")
 theDrive = "X:"
 FilePath = theDrive & "\ImagedByUser.txt"
 ForReading = 1
 If fileSystem.DriveExists(theDrive) Then
     If fileSystem.FileExists(FilePath) Then
        Set fileObject = fileSystem.OpenTextFile (FilePath, 1, True, -2)
        Do Until fileObject.AtEndOfStream
            snLine = fileObject.ReadLine
            wscript.echo "snLine = " & snLine	              
            IF NOT(TRIM(snLine = "")) THEN
            	SetTsVariable "ImagedByUser", snLine
            	fileObject.Close
                set fileObject = nothing
                set fileSystem = nothing
            	Exit Function
            END IF
        Loop
        fileObject.Close
        set fileObject = nothing
        set fileSystem = nothing
     End If
 End If
End Function

Function SetTsVariable(variableName, variableValue)
	Set TSEnv = CreateObject("Microsoft.SMS.TSEnvironment")
	TSEnv(variableName) = variableValue
	Set TSEnv = Nothing
End Function
