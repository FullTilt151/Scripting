$searchfor = 'PXE:','SMSTSRole:','Make:','DeployedBy:','Join OU:','SourceComp:','TaskSequence:','Failed to resolve the source','Execution of the instruction (Execute Task Sequence) has been skipped','Failed to run the Action','Hash could not be matched for the downloded content','Restoring Groups'
$Userid = $env:USERNAME
$ClocalUser = "C:\Users\$UserId"


If (-Not (Test-Path "P:\")) {
    New-PSDrive -Name "P" -PSProvider "FileSystem" -Root "\\LOUNASWPS08\pDrive"
} Else {
    cls
    $wkid = read-host "Please enter the Workstation ID:"
}

    $LogPath = "P:\Dept907.CIT\OSD\logs\$wkid"
    
If (Test-Path $LogPath) {
    #Select-String $LogPath\smsts*.log -Pattern $searchfor -Context 2,1
    $DataSet1 = Select-String $LogPath\smsts*.log -Pattern $searchfor -AllMatches | Foreach {$_.Line} {
    $Seperate = ""
    $Part1 = $_.Line.split($Seperate)
    Write-Host $Part1
}
    #Write-Host $DataSet1    
   } Else {
   Write-host "Logs not found on P:"
}
