$Licensed = $True
If(Test-Path -Path "\\WKMJ07C0R7\C$\windows\ccm\logs\NomadBranch.log"){
    Write-output -Message "NomadBranch.log found! Checking for licensing error."
    If($NBlog = Select-String -Path "\\WKMJ07C0R7\C$\windows\ccm\logs\nomadbranch.log" -Pattern "NomadBranchMCast60 license error. Expired"){
        Write-output -Message "NomadBranch licensing error found!"
        $Licensed = $False
    }
}
