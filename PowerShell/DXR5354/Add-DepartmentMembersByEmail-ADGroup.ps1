Write-Output 'Current counts:'
"Kassem.Staff: $((Get-ADGroupMember -Identity 'TSS All Staff' -Recursive).Count)"
"T_ITI: $((Get-ADGroupMember -Identity T_ITI).Count)"

$DL = Get-ADGroupMember -Identity 'TSS All Staff' -Recursive
$ITI = Get-ADGroupMember -Identity 'T_ITI' -Recursive

$DL | ForEach-Object {
    $user = Get-ADUser -Identity $_
    Add-ADGroupMember -Identity 'T_ITI' -Members $user -ErrorAction SilentlyContinue
}

$ITI | ForEach-Object {
    $user = Get-ADUser -Identity $_
    if (!($dl.samaccountname -contains $user.samaccountname)) {
        Remove-ADGroupMember -Identity 'T_ITI' -Members $user -Confirm:$false
    }
}

Write-Output 'New counts:'
"Kassem.Staff: $((Get-ADGroupMember -Identity 'TSS All Staff' -Recursive).Count)"
"T_ITI: $((Get-ADGroupMember -Identity T_ITI).Count)"