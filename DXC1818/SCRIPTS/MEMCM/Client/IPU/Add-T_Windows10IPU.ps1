[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Windows.Forms.MessageBox]::Show('Paste the WKIDs in the notepad that will open automatically.') 
$InputPath = "filesystem::C:\Temp\WKIDs.txt"
Start-Process notepad C:\Temp\WKIDs.txt -Wait


$wkids = Get-Content -Path $InputPath
ForEach ($wkid in $wkids) {
    $DistinguishedName = Get-ADComputer -Identity "$wkid" 
    Add-ADGroupMember -Identity 'T_Windows10IPU' -Members $DistinguishedName
    Write-Host "Processed T_Windows10IPU for $WKID"
}
Remove-Item -Path C:\temp\wkids.txt -ErrorAction SilentlyContinue