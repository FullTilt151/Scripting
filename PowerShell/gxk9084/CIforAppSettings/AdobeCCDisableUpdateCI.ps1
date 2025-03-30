$xml=[xml](Get-Content ${env:CommonProgramFiles(x86)}\Adobe\OOBE\Configs\ServiceConfig.xml)
$item = $xml.config.feature | ? {$_.name -eq "SelfUpdate"}


# Set this variable to true for the remediation script, false for the detection script
$remediate = $false

# Put code here to determine if item is compliant 
if ($item.enabled -eq "true") {$compliant = $true}
else {
    $compliant = $false

    # if the item is not compliant, be sure to run the lines below 
    if ($remediate) {     
        $item.enabled = "true"
        #write back to file
        $xml.Save("${env:CommonProgramFiles(x86)}\Adobe\OOBE\Configs\ServiceConfig.xml")
        }
}
Write-Output $compliant

