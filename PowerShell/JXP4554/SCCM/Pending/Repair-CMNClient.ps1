$logFile = 'c:\temp\Fix-CMNClient.log'
"Starting at $(Get-Date)" | Out-File -FilePath $logFile -Encoding ascii -Append -Force
$ccmLogFile = "C:\Windows\CCMSetup\logs\ccmsetup.log"
# Get last line of ccmsetup log
$ccmSetupLog = (Get-Content -Path $ccmLogFile -Tail 1) -replace '.*\[LOG\[(.*)\]LOG\].*', '$1'
$ccmSetupLog | Out-File -FilePath $logFile -Encoding ascii -Append
# Make sure the exit code is good
if($ccmSetupLog -notmatch '^CcmSetup is exiting with return code [07]'){
    "Need to run CCMRepair, getting directory" | Out-File -FilePath $logFile -Encoding ascii -Append
    $cmd = "$(Split-Path -Path (Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\CcmExec).ImagePath)\ccmrepair.exe"
    "Running $cmd" | Out-File -FilePath $logFile -Encoding ascii -Append
    & $cmd
    Write-Output 'Repaired'
}
else{
    Write-Output 'Good'
}
"Finished at $(Get-Date)" | Out-File -FilePath $logFile -Encoding ascii -Append -Force