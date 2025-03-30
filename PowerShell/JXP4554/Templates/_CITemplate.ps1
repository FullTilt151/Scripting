# Set this variable to true for the remediation script, false for the detection script
$remediate = $false

# Put code here to determine if item is compliant 
if (test condition) {$compliant = $true}
else {
    $compliant = $false

    # if the item is not compliant, be sure to run the lines below 
    if ($remediate) {     
        # Put code here to remediate
    }
}
Write-Output $compliant