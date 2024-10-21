param (
    $UserID
)

$Admin = Get-LocalGroupMember -Group Administrators
if ($Admin.Name -notcontains "HUMAD\$UserID") {
    Add-LocalGroupMember -Group Administrators -Member "HUMAD\$UserID"
}