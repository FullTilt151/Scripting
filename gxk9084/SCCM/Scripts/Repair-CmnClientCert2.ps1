function Repair-CmnClientCert {
    [Cmdletbinding()]
    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'List of computers to repair')]
        [String[]]$computers
    )
    foreach ($computer in $computers) {
        if (Test-Connection -ComputerName $computer -quiet -Count 1) {
            Write-Verbose -Message "Fixing $computer"
            Invoke-Command -ComputerName $computer -ScriptBlock { $smsCertTB = (Get-Content -Path 'C:\WINDOWS\SMSCFG.ini' | Where-Object { $_ -match 'Certificate Identifier' }) -replace 'SMS Certificate Identifier=SMS;'

                $smsCert = (Get-ChildItem -Path Cert:\LocalMachine\SMS | Where-Object { $_.Thumbprint -eq $smsCertTB }).Subject

                if ($smsCert -notmatch $env:COMPUTERNAME) {

                    Get-ChildItem -Path Cert:\LocalMachine\SMS | Where-Object { $_.Thumbprint -eq $smsCertTB } | Remove-Item

                    Restart-Service -Name CcmExec -Force -ErrorAction SilentlyContinue

                } }
        }
        else { Write-Verbose -Message "Unable to contact $computer" }
    }
    Get-PSSession
}
$computers = ('LOUHVMWFP0205','WKMJ07ADSP','WKMJ04LYB9','WKMJ07ADXN','WKPC0MLLU8','WKMJ07AE46','WKMJ07C3DQ','WKMJ39P7E','WKMJ0345ZL','WKPC0E29GQ','WKMJ07C21B','WKMJ01R2X4','WKPF0I37GD','WKMJ05J41Y','WKMJ05XBNT','WKPC0WWD44')
Repair-CmnClientCert -computers $computers -Verbose