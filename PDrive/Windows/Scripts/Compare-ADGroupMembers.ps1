$old = Get-ADGroupMember -Identity G_NTLMv2 | Select-Object -ExpandProperty Name
$new = Get-ADGroupMember -Identity G_NTLMCompat | Select-Object -ExpandProperty Name

$missing = Compare-Object -ReferenceObject $old -DifferenceObject $new
$missing.inputobject