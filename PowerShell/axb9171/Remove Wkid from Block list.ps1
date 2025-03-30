#Get AD/AAD Info
$machine = read-host "Please enter the WKID:"
$MBR = Get-ADComputer -Identity $WKID -Properties MemberOf,OperatingSystemVersion
$MBR.MemberOf
$MBR.OperatingSystemVersion
$DistinguishedName = Get-ADComputer -Identity "$WKID"
Remove-ADGroupMember -Identity 'T_Azure_Intune_Compliance_Tier2' -Members $DistinguishedName -Confirm:$False
$Sndr = 'windows10@humana.com'
$Rcpt = Read-Host -Prompt "Enter the associates email address."
Connect-AzureAD
Do {
Start-Sleep -Seconds 300
$ObjID = Get-AzureADDevice -SearchString $WKID | Select-Object -ExpandProperty ObjectId
$GrpMbr = Get-AzureADGroupMember -ObjectId "50b553dd-2c7d-44bc-b39f-8ac583bcf226" -Top 10000 | Where-Object -Property "ObjectId" -EQ $ObjID
} Until ($GrpMbr -eq $null)
Disconnect-AzureAD
Write-Host "T_Azure_Intune_Compliance_Tier2 has been removed from " -NoNewline -ForegroundColor Cyan
Write-Host "$WKID" -ForegroundColor Green
Send-MailMessage -From $Sndr -To $Rcpt -Subject 'REMOVED - This app has been blocked by your system administrator' -Body '
Perform the following:
In Search (Magnifying Glass) type "access work".
You should see auto suggestions.
Select "Access work or school".
Select Connected to HUMAD AD Domain.
Select Info.
Select Sync.
Logout (Sign Out) of Windows. (CTRL + ALT + DEL / Sign out)
Login.
Verify "Blocking" has been removed.' -SmtpServer pobox.humana.com -Port 25