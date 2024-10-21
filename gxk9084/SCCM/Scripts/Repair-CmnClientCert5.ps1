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
$computers = ('SIMXDWDIGW469',
'SIMXDWDIGW470',
'SIMXDWDIGW471',
'SIMXDWDIGW472',
'SIMXDWDIGW474',
'SIMXDWDIGW475',
'SIMXDWDIGW476',
'SIMXDWDIGW477',
'SIMXDWDIGW478',
'SIMXDWDIGW479',
'SIMXDWDIGW480',
'SIMXDWDIGW481',
'SIMXDWDIGW482',
'SIMXDWDIGW483',
'SIMXDWDIGW484',
'SIMXDWDIGW485',
'SIMXDWDIGW486',
'SIMXDWDIGW487',
'SIMXDWDIGW488',
'SIMXDWDIGW490',
'SIMXDWDIGW491',
'SIMXDWDIGW492',
'SIMXDWDIGW494',
'SIMXDWDIGW496',
'SIMXDWDIGW498',
'SIMXDWDIGW500',
'SIMXDWDIGW501',
'SIMXDWDIGW502',
'SIMXDWDIGW503',
'SIMXDWDIGW504',
'SIMXDWDIGW505',
'SIMXDWDIGW506',
'SIMXDWDIGW507',
'SIMXDWDIGW508',
'SIMXDWDIGW509',
'SIMXDWDIGW511',
'SIMXDWDIGW513',
'SIMXDWDIGW515',
'SIMXDWDIGW516',
'SIMXDWDIGW517',
'SIMXDWDIGW518',
'SIMXDWDIGW519',
'SIMXDWDIGW520',
'SIMXDWDIGW522',
'SIMXDWDIGW523',
'SIMXDWDIGW524',
'SIMXDWDIGW526',
'SIMXDWDIGW527',
'SIMXDWDIGW529',
'SIMXDWDIGW531',
'SIMXDWDIGW532',
'SIMXDWDIGW533',
'SIMXDWDIGW534',
'SIMXDWDIGW536',
'SIMXDWDIGW538',
'SIMXDWDIGW539',
'SIMXDWDIGW540',
'SIMXDWDIGW541',
'SIMXDWDIGW542',
'SIMXDWDIGW543',
'SIMXDWDIGW544',
'SIMXDWDIGW546',
'SIMXDWDIGW548',
'SIMXDWDIGW549',
'SIMXDWDIGW550',
'SIMXDWDIGW551',
'SIMXDWDIGW552',
'SIMXDWDIGW553',
'SIMXDWDIGW554',
'SIMXDWDIGW555',
'SIMXDWDIGW556',
'SIMXDWDIGW557',
'SIMXDWDIGW560',
'SIMXDWDIGW561',
'SIMXDWDIGW562',
'SIMXDWDIGW564',
'SIMXDWDIGW565',
'SIMXDWDIGW566',
'SIMXDWDIGW567',
'SIMXDWDIGW568',
'SIMXDWDIGW570',
'SIMXDWDIGW572',
'SIMXDWDIGW573',
'SIMXDWDIGW574',
'SIMXDWDIGW575',
'SIMXDWDIGW576',
'SIMXDWDIGW577',
'SIMXDWDIGW578',
'SIMXDWDIGW579',
'SIMXDWDIGW580',
'SIMXDWDIGW582',
'SIMXDWDIGW583',
'SIMXDWDIGW584',
'SIMXDWDIGW585',
'SIMXDWDIGW586')
Repair-CmnClientCert -computers $computers -Verbose