Get-Content c:\temp\pkgs.txt |
ForEach-Object {
    Get-CMPackage -Id $_ | Get-CMProgram | Set-CMProgram -StandardProgram -EnableTaskSequence $true -Verbose
}