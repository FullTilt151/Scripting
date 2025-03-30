if ($PSVersionTable.PSVersion.Major -lt 3) {
    If ((Get-Content -Path "$env:SystemRoot\system32\inetsrv\config\applicationHost.config") -match ('<periodicRestart time="29:00:00">')) {$true} Else {$false}
} elseif ($PSVersionTable.PSVersion.Major -ge 3) {
    If (([XML](Get-Content -Path "$env:SystemRoot\system32\inetsrv\config\applicationHost.config")).configuration.'system.applicationHost'.applicationPools.add.recycling.periodicRestart.time -eq '29:00:00') {$true} Else {$false}
} else {
    #PoSH version unknown
    $false
}