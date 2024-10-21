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
$computers = ('SIMXDWDIGW226',
'SIMXDWDIGW228',
'SIMXDWDIGW229',
'SIMXDWDIGW231',
'SIMXDWDIGW233',
'SIMXDWDIGW234',
'SIMXDWDIGW235',
'SIMXDWDIGW237',
'SIMXDWDIGW238',
'SIMXDWDIGW239',
'SIMXDWDIGW241',
'SIMXDWDIGW243',
'SIMXDWDIGW245',
'SIMXDWDIGW247',
'SIMXDWDIGW251',
'SIMXDWDIGW254',
'SIMXDWDIGW255',
'SIMXDWDIGW256',
'SIMXDWDIGW257',
'SIMXDWDIGW258',
'SIMXDWDIGW259',
'SIMXDWDIGW260',
'SIMXDWDIGW261',
'SIMXDWDIGW263',
'SIMXDWDIGW265',
'SIMXDWDIGW266',
'SIMXDWDIGW267',
'SIMXDWDIGW269',
'SIMXDWDIGW270',
'SIMXDWDIGW272',
'SIMXDWDIGW274',
'SIMXDWDIGW276',
'SIMXDWDIGW280',
'SIMXDWDIGW281',
'SIMXDWDIGW282',
'SIMXDWDIGW283',
'SIMXDWDIGW284',
'SIMXDWDIGW286',
'SIMXDWDIGW287',
'SIMXDWDIGW289',
'SIMXDWDIGW291',
'SIMXDWDIGW293',
'SIMXDWDIGW295',
'SIMXDWDIGW297',
'SIMXDWDIGW298',
'SIMXDWDIGW300',
'SIMXDWDIGW302',
'SIMXDWDIGW303',
'SIMXDWDIGW306',
'SIMXDWDIGW307',
'SIMXDWDIGW308',
'SIMXDWDIGW309',
'SIMXDWDIGW310',
'SIMXDWDIGW312',
'SIMXDWDIGW313',
'SIMXDWDIGW314',
'SIMXDWDIGW315',
'SIMXDWDIGW316',
'SIMXDWDIGW317',
'SIMXDWDIGW318',
'SIMXDWDIGW319',
'SIMXDWDIGW320',
'SIMXDWDIGW321',
'SIMXDWDIGW322',
'SIMXDWDIGW323',
'SIMXDWDIGW324',
'SIMXDWDIGW325',
'SIMXDWDIGW326')
Repair-CmnClientCert -computers $computers -Verbose