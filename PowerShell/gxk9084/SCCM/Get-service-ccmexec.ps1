$isrunning=(get-service -name CcmExec)
if ($isrunning.status -ne "Running"){
    Write-Output "Not Running, $($isrunning.starttype)"
    }