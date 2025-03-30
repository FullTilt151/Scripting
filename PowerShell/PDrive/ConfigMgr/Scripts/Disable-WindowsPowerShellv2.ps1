$remediate = $false

$State = (Get-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellv2).State

if($remediate -and $state -ne 'Disabled'){     
    Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellv2 -NoRestart
} elseif ($State -eq 'Disabled') {     
    Write-Output $true 
} else {
    Write-Output $false
}