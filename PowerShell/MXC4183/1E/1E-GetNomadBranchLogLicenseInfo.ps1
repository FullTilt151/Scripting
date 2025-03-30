#Open Nomadbranch.log and check for licensing error.

Write-Log -Message 'CCMSetup has finished, checking the log to see if we are good to go'
        $isCCMSetup = $false
        $log = Get-Content C:\windows\ccmsetup\logs\ccmsetup.log
        for ($x = $log.Count - 10 ; $x -lt $log.Count ; $x++) {
            if ($log[$x] -match 'CcmSetup is exiting with return code [07]') {
                $isCCMSetup = $true
            }
        }
        If ($isCCMSetup) {
            Write-log -Message "CcmSetup successful."
        }
        else {
            Write-Log -Message 'CcmSetup has failed, check the C:\Windows\CCMSetup\logs\CCMSetup.log to find out why' -Severity 3
            throw 'CcmSetup has failed, check the C:\Windows\CCMSetup\logs\CCMSetup.log to find out why'
        }