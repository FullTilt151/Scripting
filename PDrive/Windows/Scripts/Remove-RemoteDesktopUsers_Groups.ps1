# Set this variable to true for the remediation script, false for the detection script
$remediate = $false

# Put code here to determine if item is compliant #if the item is not compliant, be sure to run the lines below 
$RDPUsers = Get-LocalGroupMember -Group 'Remote Desktop Users' | Where-Object {$_.Name -like '*G_*'}

if($remediate) {     
    $RDPUsers | ForEach-Object {
        Remove-LocalGroupMember -Group 'Remote Desktop Users' -Member $_
    }
} else {
    if ($RDPUsers -ne $null) {
        Write-Output $false
    } else {
        Write-Output $true 
    }
}