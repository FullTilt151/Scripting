$Remediate = $false

$CCMSetupREG = 'registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\CCMSetup'
$LastSuccessfulInstallParams = Get-ItemProperty -Path $CCMSetupREG -Name LastSuccessfulInstallParams -ErrorAction SilentlyContinue
if ($null -ne $LastSuccessfulInstallParams) {
    switch -regex ($LastSuccessfulInstallParams.LastSuccessfulInstallParams) {
        '"CCMHTTPPORTS=48022"|"CCMHTTPPORT=48018"' {
            switch ($Remediate) {
                $true {
                    $NewParams = $LastSuccessfulInstallParams.LastSuccessfulInstallParams -replace '"CCMHTTPPORTS=48022"' -replace '"CCMHTTPPORT=48018"' -replace '  ', ' '
                    Set-ItemProperty -Path $CCMSetupREG -Name LastSuccessfulInstallParams -Value $NewParams -Verbose
                }
                $false {
                    Write-Output $false
                }
            }
        }
        default {
            Write-Output $true
        }
    }
}
else {
    Write-Output $true
}