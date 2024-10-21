$Target = 'LOUHPVWTW002'
$Service = 'cifs'
$HostFQDN = 'LOUNASWPS08.rsc.humad.com'
$HostName = 'LOUNASWPS08'
$ADDN = Get-ADComputer -Identity $Target | Select-Object -ExpandProperty DistinguishedName
Set-ADObject $ADDN -Add @{"msDS-AllowedToDelegateTo"="$Service/$HostFQDN","$Service/$HostName"}
Get-ADObject $ADDN -Properties msDS-AllowedToDelegateTo