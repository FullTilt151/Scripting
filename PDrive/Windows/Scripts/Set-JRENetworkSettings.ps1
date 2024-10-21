$remediate = $false

$PropFile = Get-Content -Path C:\Windows\Sun\Java\Deployment\deployment.properties

if ($PropFile -contains 'deployment.proxy.type=0') {
    Write-Output $true
} else {
    if ($remediate) {
        Add-Content -Value 'deployment.proxy.type=0' -Path C:\Windows\Sun\Java\Deployment\deployment.properties
    } else {
        Write-Output $false
    }
}