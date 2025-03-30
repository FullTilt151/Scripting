$CTS += Get-ADGroupMember 'Client Innovation' | Select-Object -ExpandProperty samaccountname
$CTS += Get-ADGroupMember 'Unified Communications' | Select-Object -ExpandProperty samaccountname
$CTS += Get-ADGroupMember 'Virtual access solutions' | Select-Object -ExpandProperty samaccountname
$CTS += Get-ADGroupMember 'ATS' | Select-Object -ExpandProperty samaccountname
$CTS += Get-ADGroupMember 'C_ATS Off-shore' | Select-Object -ExpandProperty samaccountname
$CTS += Get-ADGroupMember 'CTS TAC' | Select-Object -ExpandProperty samaccountname

"$(($CTS | measure-object).Count) members in CTS"

$CTS | out-file c:\temp\CTS.csv

$EIP += Get-ADGroupMember 'EIP - All Associates' | Select-Object -ExpandProperty samaccountname
$EIP += Get-ADGroupMember 'EIP - All Contractors' | Select-Object -ExpandProperty samaccountname
$EIP

$SCS = Get-ADGroupMember -Identity 'TSS All Staff' -Recursive | Select-Object -ExpandProperty samaccountname
$SCS