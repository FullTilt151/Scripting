Import-Module \\lounaswps01\pdrive\dept907.cit\windows\scripts\SharePoint\Connect-AccessDB.ps1

Connect-AccessDB "\\lounaswps08\pdrive\Dept907.CIT\Windows\Scripts\SharePoint\SoftwareCertPrioritization.accdb"
Open-AccessRecordSet "select * from [Software Cert Prioritization]"

Convert-AccessRecordSetToPSObject |
ForEach-Object {
    $CRID = $_.'CR#'
    $CRData = \\lounaswps01\pdrive\dept907.cit\windows\scripts\SharePoint\Get-SoftwareCertificationData.ps1 -CRID $CRID
    $Status = $CRData[0]
    $Team = $CRData[1]
    $DateApproved = $CRData[2]
    $DateApproved = Get-Date $DateApproved -UFormat %m/%d/%Y
    "$CRID $Status $Team $DateApproved"
    Execute-AccessSQLStatement "UPDATE [Software Cert Prioritization] SET [Status] = '$Status' WHERE [CR#] = $CRID"
    Execute-AccessSQLStatement "UPDATE [Software Cert Prioritization] SET [Team] = '$Team' WHERE [CR#] = $CRID"
    Execute-AccessSQLStatement "UPDATE [Software Cert Prioritization] SET [DateApproved] = '$DateApproved' WHERE [CR#] = $CRID"
    Execute-AccessSQLStatement "UPDATE [Software Cert Prioritization] SET [DateApprovedFilter] = '$DateApproved' WHERE [CR#] = $CRID"
}

Close-AccessRecordSet
Disconnect-AccessDB