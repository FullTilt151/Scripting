if ((Get-BitLockerVolume -MountPoint c:).keyprotector -ne $null -and $_.EncryptionMethod -ne 'None') {
    "Executing manage-bde.exe -forcerecovery c:"| Out-File c:\temp\poisonpill.log
    & manage-bde.exe -status | Out-File c:\temp\poisonpill.log -Append
    Start-Sleep -Seconds 5
    & manage-bde.exe -forcerecovery c:
    Start-Sleep -Seconds 5
    Restart-Computer -Force
}