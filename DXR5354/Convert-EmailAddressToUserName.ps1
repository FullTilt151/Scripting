(Get-Content C:\temp\users.txt).Split(';').Split('<').Replace('>','') | Where-Object {$_ -match '@humana.com'} | ForEach-Object {
    Get-ADUser -Filter "UserPrincipalName -eq '$_'" | Select-Object -ExpandProperty samaccountname | out-file c:\temp\users1.txt -Append
}