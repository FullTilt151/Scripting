Stop-Service -Name CcmExec -Force
Stop-Service -Name BITS -Force
if (Test-Path -Path "$($env:ALLUSERSPROFILE)\Microsoft\Network\Downloader\qmgr?.dat") {
    Write-Output 'Removing existing bits transfers'
    Remove-Item -Path "$($env:ALLUSERSPROFILE)\Microsoft\Network\Downloader\qmgr?.dat" -Force
}
if ((Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\BITS).EnableBitsMaxBandwidth -ne 1) {
    Write-Output 'Enableing BITS limitations'
    Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\BITS -Name EnableBitsMaxBandwidth -Value 1
}
if((Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\BITS).MaxTransferRateOnSchedule -ne 9999){
    Write-Output 'Setting MaxTransferRateOnSchedule'
    Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\BITS -Name MaxTransferRateOnSchedule -Value 9999
}
if((Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\BITS).MaxTransferRateOffSchedule -ne 999999){
    Write-Output 'Setting MaxTransferRateOffSchedule'
    Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\BITS -Name MaxTransferRateOffSchedule -Value 999999
}
Start-Service -Name BITS
Start-Service -Name CcmExec
