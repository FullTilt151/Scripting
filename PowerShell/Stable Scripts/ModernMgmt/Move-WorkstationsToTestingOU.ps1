if ($PSVersionTable.PSVersion -like "5.1*") {
    Import-Module ActiveDirectory
} else {
    Import-Module ActiveDirectory -UseWindowsPowerShell
}

$wkids = Get-Content C:\temp\wkids.txt

"Moving $(($wkids | Measure-Object).count) workstations..."

$wkids | 
ForEach-Object {
    $WKID = Get-ADComputer -Identity $_
    Move-ADObject -Identity $WKID -TargetPath 'OU=Physical,OU=Workstations,OU=Testing,DC=humad,DC=com'
}