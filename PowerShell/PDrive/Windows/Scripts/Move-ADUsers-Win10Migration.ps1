Get-ADUser -Identity nxb5866
ForEach-Object {
    if ($_.DistinguishedName -like "*OU=Contractors,OU=Special Accounts,DC=humad,DC=com") {
    Move-ADObject -TargetPath "*OU=Contractors,OU=UserAccounts,DC=humad,DC=com" -Verbose
    } else {
        Move-ADObject -TargetPath "*OU=UserAccounts,DC=humad,DC=com" -Verbose
    }
}