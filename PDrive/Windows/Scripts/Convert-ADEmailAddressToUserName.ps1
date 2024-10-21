$emails = Get-Content C:\temp\emails.txt

foreach ($addy in $emails) {
    Get-ADUser -Filter "EmailAddress -eq '$addy'" -Properties SamAccountName, EmailAddress | Select-Object SamAccountName,EmailAddress | Export-Csv c:\temp\emails.csv -Append
}