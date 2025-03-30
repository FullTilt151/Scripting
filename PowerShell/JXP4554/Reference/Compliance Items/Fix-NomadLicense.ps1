# Set this variable to true for the remediation script, false for the detection script
$remediate = $false
$doTest = $true
try {
    $nomadLog = (Get-ItemProperty -Path HKLM:\SOFTWARE\1E\NomadBranch -ErrorAction SilentlyContinue).LogFileName
    if ($null -eq $nomadLog -or $nomadLog -eq '') {
        $compliant = $true
        $doTest = $false
    }
}
catch {
    $compliant = $true
    $doTest = $false
}
# Put code here to determine if item is compliant 
if ($doTest) {
    If (Test-Path -Path $nomadLog -ErrorAction SilentlyContinue) {
        If ((Measure-Object -InputObject (Get-Content -Path $nomadLog -Tail 20 | Where-Object {$_ -match 'NomadBranchMCast60 license error. Expired'})).Count -eq 0) {
            $compliant = $true
        }
    }
    else {
        $compliant = $false
        # if the item is not compliant, be sure to run the lines below 
        if ($remediate) {     
            Start-Process -FilePath 'C:\Program Files\1E\NomadBranch\nomadbranch.exe' -ArgumentList '-relicense=HUMNOM6-64RB-1ILL-9EBL-7UVF' -ErrorAction SilentlyContinue
        }
    }
}
Write-Output $compliant