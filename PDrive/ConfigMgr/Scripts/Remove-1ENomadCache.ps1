$remediate = $false

if($remediate) {     
    & 'C:\Program Files\1E\NomadBranch\CacheCleaner.exe' -DeleteAll -Force=9
} else {     
    if ((Get-ChildItem HKLM:\SOFTWARE\1E\NomadBranch\PkgStatus).Count -ne 0 -and $env:computername -notlike "*PXEWPW*" ) {
        Write-Output $false 
    } else {
        Write-Output $true
    }
}