$Date = Get-Date -UFormat %m%d%Y
$Count = 10000
$PMCount = $Count*.85
$VMCount = $Count*.15
$PMs = Get-ADComputer -SearchBase "OU=Physical,OU=Workstations,DC=HUMAD,DC=com" -SearchScope 1 -Filter 'Enabled -eq $true'
"Total physicals in Workstations OU: $($PMs | Measure-Object | select-object -ExpandProperty Count)"
$PMs | <#Get-Random -Count $PMCount |#> ForEach-Object {
    $_ | Export-Csv "c:\temp\HAADJ-$Date.csv" -Append -NoTypeInformation
    Move-ADObject -Identity $($_.DistinguishedName) -TargetPath 'OU=Physical,OU=Workstations,OU=Testing,DC=humad,DC=com'
}

$VMs = Get-ADComputer -SearchBase "OU=Virtual,OU=Workstations,DC=HUMAD,DC=com" -SearchScope 1 -Filter 'Enabled -eq $true' 
"Total virtuals in Workstations OU: $($VMs | Measure-Object | select-object -ExpandProperty Count)"
$VMs | <#Get-Random -Count $VMCount |#> ForEach-Object {
    $_ | Export-Csv "c:\temp\HAADJ-$Date.csv" -Append -NoTypeInformation
    Move-ADObject -Identity $($_.DistinguishedName) -TargetPath 'OU=Virtual,OU=Workstations,OU=Testing,DC=humad,DC=com'
}