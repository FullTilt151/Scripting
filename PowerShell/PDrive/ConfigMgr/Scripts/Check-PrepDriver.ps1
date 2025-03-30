#discovery
$Loaded = Get-Content -Tail 10 C:\windows\ccm\logs\mtrmgr.log | Where-Object { $_.Contains("StartPrepDriver - OpenService Failed with error") } 
$Command = "RUNDLL32.EXE SETUPAPI.DLL,InstallHinfSection DefaultInstall 128 C:\WINDOWS\CCM\prepdrv.inf"
$remediate = $false


If ($Loaded){
    Write-Output $false
    If ($remediate){
        Invoke-Expression $Command
        Start-Sleep -s 3
        Restart-Service CcmExec
    }
}
else{
    Write-Output $true
}



#remediate
$Loaded = Get-Content -Tail 10 C:\windows\ccm\logs\mtrmgr.log | Where-Object { $_.Contains("StartPrepDriver - OpenService Failed with error") } 
$Command = "RUNDLL32.EXE SETUPAPI.DLL,InstallHinfSection DefaultInstall 128 C:\WINDOWS\CCM\prepdrv.inf"
$remediate = $true


If ($Loaded){
    Write-Output $false
    If ($remediate){
        Invoke-Expression $Command
        Start-Sleep -s 3
        Restart-Service CcmExec
    }
}
else{
    Write-Output $true
}