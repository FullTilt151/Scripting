[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Windows.Forms.MessageBox]::Show('Paste the WKIDs in the notepad that will open automatically.') 
$InputPath = "filesystem::C:\Temp\WKIDs.txt"
Start-Process notepad C:\Temp\WKIDs.txt -Wait

#To HAADJ and co-manage any devices, do two things:
#•	Move the WKID to HUMAD\Testing\Workstations\Physical or Virtual
#•	Add the WKID to T_Azure_Intune_Win10HybridCompliance

$wkids = Get-Content -Path $InputPath
ForEach ($wkid in $wkids) {
    IF ($WKID -like "WK*") {
    Get-ADComputer -Identity "$wkid" | Select-Object  -ExpandProperty DistinguishedName | Move-ADObject -TargetPath "OU=Physical,OU=Workstations,OU=Testing,DC=humad,DC=com" 
    }
    IF ($WKID -like "*XDW*") {
    Get-ADComputer -Identity "$wkid" | Select-Object  -ExpandProperty DistinguishedName | Move-ADObject -TargetPath "OU=Virtual,OU=Workstations,OU=Testing,DC=humad,DC=com" 
    }
    $DistinguishedName = Get-ADComputer -Identity "$wkid" 
    Add-ADGroupMember -Identity 'T_Azure_Intune_Win10HybridCompliance' -Members $DistinguishedName
    Write-Host "Processed HAADJ/Co-Mgmt for $WKID"
}
Remove-Item -Path C:\temp\wkids.txt -ErrorAction SilentlyContinue