#Load Write-log module.
try {
    [String]$moduleDir = "$scriptDirectory\Modules\"
    if (Test-Path -LiteralPath $moduleDir -PathType 'Container') {
        [Array]$modules = Get-ChildItem -LiteralPath $moduleDir -Filter '*.ps1'
        
    }
}
catch {
    Write-Error -Message "Unable to load module $($module.FullName)"
    If (Test-Path -LiteralPath 'variable:HostInvocation') { $script:ExitCode = $mainExitCode; Exit } Else { Exit $mainExitCode }
}


#CI for monitoring.
$Licensed = $True
If(Test-Path -Path "C:\windows\ccm\logs\NomadBranch.log"){
    #Write-Log -Message "NomadBranch.log found! Checking for licensing error."
    If($NBlog = Select-String -Path "C:\windows\ccm\logs\nomadbranch.log" -Pattern "NomadBranchMCast60 license error. Expired"){
        #Write-Log -Message "NomadBranch licensing error found!"
        $Licensed = $False
    }
}




#Check PXE machines for error.
Get-Content C:\Temp\pxe.txt | ForEach-Object {
    If(Select-String -Path "\\dsipxewpw04\C$\programdata\1e\nomadbranch\logfiles\nomadbranch.log" -Pattern "license error. Expired"){
        Write-Host "$_, error found." -ForegroundColor Red
    }
    else{
        Write-Host "$_, error NOT found." -ForegroundColor Green
    }

}

#Get machine names from text file then open the last line in the nomad log and display it.
Get-Content C:\Temp\pxe.txt | ForEach-Object {
    $NB = Get-Content "\\$_\c$\Windows\CCM\Logs\Nomadbranch.log" -Tail 1
    Write-Output "$NB" | Out-File "C:\temp\NomadOutputfile.txt" -Append
}

Select-String -Path C:\windows\ccm\logs\nomadbranchTEST.log -Pattern "NomadBranchMCast60 license error. Expired" #| Select-Object -Last 1
        for ($x = $log.Count - 10 ; $x -lt $log.Count ; $x++) {
            if ($log[$x] -match 'NomadBranchMCast60 license error. Expired') {
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