[CmdletBinding(ConfirmImpact = 'Low')]

PARAM()
Write-Output 'Starting'
#Reset machine group policy so we clear out any Windows Update settings
#http://www.sherweb.com/blog/resolving-group-policy-error-0x8007000d/
#https://gallery.technet.microsoft.com/scriptcenter/ConfigMgr-Client-Action-16a364a5
#https://powershell.org/forums/topic/remotely-invoking-sccm-client-actions/
try {
    $gpoCacheDir = "$($env:ALLUSERSPROFILE)\Application Data\Microsoft\Group Policy\History\"
        
    if (Test-Path $gpoCacheDir -PathType Container) {
        Write-Output "Removing contents of $gpoCacheDir"
        Remove-Item -Path "$gpoCacheDir*" -Force -Recurse
    }
    else {
        Write-Output "Unable to find $gpoCacheDir"
    }
}
catch {
    Write-Output "Problem removing $gpoCacheDir"
    Return "Problem removing $gpoCacheDir"
}

try {
    Write-Output 'Cleaning CCM Temp Dir'
    $ccmTempDir = (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\CCM).TempDir
    if ((Test-Path $ccmTempDir) -and $ccmTempDir -ne $null -and $ccmTempDir -ne '') {Get-ChildItem -Path $ccmTempDir | Where-Object {!$_.PSisContainer} | Remove-Item -Force -ErrorAction SilentlyContinue}
}
catch {
    Write-Output "Unable to clear $ccmTempDir"
    Return "Unable to clear $ccmTempDir"
}
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
Write-Verbose 'Stopping WUAUSERV'
Stop-Service -Name wuauserv
Write-Verbose 'Deleting Downloads'
Remove-Item C:\windows\SoftwareDistribution\Download\* -Recurse -Force -ErrorAction SilentlyContinue
Write-Verbose 'Deleting Datastore'
Remove-Item C:\windows\SoftwareDistribution\DataStore\*.edb -Force -ErrorAction SilentlyContinue
Write-Verbose 'Starting WUAUSERV'
Start-Service -Name wuauserv
Write-Verbose 'Deleteing DownloadContentRequestEx2 class'
Get-WmiObject -Namespace root\ccm\SoftMgmtAgent -Class DownloadContentRequestEx2 | Remove-WmiObject -ErrorAction SilentlyContinue
Write-Verbose 'Deleting DownloadInfoex2 class'
Get-WmiObject -Namespace root\ccm\SoftMgmtAgent -Class DownloadInfoex2 | Remove-WmiObject -ErrorAction SilentlyContinue
Write-Verbose 'Restarting CcmExec'
Restart-Service -Name CcmExec
Write-Output 'Sleeping for 60 seconds'
Start-Sleep -Seconds 60
Invoke-WmiMethod -Namespace root\ccm -Class SMS_Client -Name TriggerSchedule -ArgumentList '{00000000-0000-0000-0000-000000000108}' | Out-Null
Write-Output 'Finished'

