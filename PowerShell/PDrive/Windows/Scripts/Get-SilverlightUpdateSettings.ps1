if (Get-ItemProperty -Path HKLM:\Software\Wow6432NodeMicrosoft\Silverlight -Name UpdateMode -ErrorAction SilentlyContinue) {
    $UpdateMode = $true
} else {
    $UpdateMode = $false
}

if ((Get-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Microsoft\Silverlight -Name UpdateConsentMode -ErrorAction SilentlyContinue).UpdateConsentMode -eq 0) {
    $UpdateConsentMode = $true
} else {
    $UpdateConsentMode = $false
}

if ($UpdateMode -and $UpdateConsentMode) {
    Write-Output 'Compliant'
} else {
    Write-Output 'Non-Compliant'
}