param (
    [Parameter(Mandatory=$true)]
    [string]$App
)
$App = "$App"

Get-WmiObject -Class Win32Reg_AddRemovePrograms | Where-Object ($_.DisplayName -like 'Hitachi ID Password Manager Local Reset Extension')

Write-output $Info


Get-WmiObject win32_product | select name, version

Get-WmiObject Win32Reg_AddRemovePrograms | Select-Object displayname, version
Get-WmiObject Win32Reg_AddRemovePrograms | Where-Object ($_.DisplayName -eq "Windows Admin Center")
