$remediate = $false

if (Test-Path C:\Windows\security\exception.sites) {
} else {
    Write-Output $false
}

Copy-File -Path ".\exception.sites" -Destination "c:\Windows\Security\exception.sites"



if($remediate)
{     
    Write-Output $false
} 
else
{     
    Write-Output $true 
}