param(
[Parameter(Mandatory)][ValidateSet('WeRun','InspireWellness')]
[string]$Tenant
)

switch ($Tenant) {
'InspireWellness' {$TenantName = 'inspirewellness.onmicrosoft.com'; $TenantID = '56c62bbe-8598-4b85-9e51-1ca753fa50f2'}
'WeRun' {$TenantName = 'werun.onmicrosoft.com'; $TenantID = 'fce30af4-234c-4f60-b30b-b8f1bb3be972'}
}

if (!(Test-Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDJ)) {
    New-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion -Name CDJ -Force
}

if (!(Test-Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDJ\AAD)) {
    New-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDJ -Name AAD -Force
}

Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDJ\AAD -Name TenantId -Value $TenantID -Force
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDJ\AAD -Name TenantName -Value $TenantName -Force

& dsregcmd.exe /join