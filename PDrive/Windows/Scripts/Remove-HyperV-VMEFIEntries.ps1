param(
    $VMHost = 'LOUHPVWTW001',
    $VMName
)

$HyperV = New-PSSession -ComputerName $VMHost -Name HyperV
Enter-PSSession -Name HyperV
(Get-VM $VMName | Get-VMFirmware).BootOrder
Get-VM $VMName | Get-VMFirmware | 
ForEach-Object {
    Set-VMFirmware -BootOrder ($_.BootOrder | Where-Object {$_.BootType -ne 'File'}) $_
}
Exit-PSSession
Get-PSSession -Name HyperV | Remove-PSSession