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
$computers = ('SIMXDWDIGW764',
'SIMXDWDIGW767',
'SIMXDWDIGW768',
'SIMXDWDIGW769',
'SIMXDWDIGW770',
'SIMXDWDIGWP02',
'SIMXDWDIGWP06',
'SIMXDWDIGWS10',
'SIMXDWDIGWS11',
'SIMXDWPASW001',
'SIMXDWPASW002',
'SIMXDWPASW003',
'SIMXDWPASW004',
'SIMXDWPASW005',
'SIMXDWPASW006',
'SIMXDWPASW007',
'SIMXDWPASW008',
'SIMXDWPASW009',
'SIMXDWPASW010',
'SIMXDWPASW011',
'SIMXDWPASW012',
'SIMXDWPASW013',
'SIMXDWPASW014',
'SIMXDWPASW015',
'SIMXDWPASW016',
'SIMXDWPASW017',
'SIMXDWPASW018',
'SIMXDWPASW019',
'SIMXDWPASW020',
'SIMXDWPASW021',
'SIMXDWPASW022',
'SIMXDWPASW023',
'SIMXDWPASW024',
'SIMXDWPASW025',
'SIMXDWPASW026',
'SIMXDWPASW027',
'SIMXDWPASW028',
'SIMXDWPASW029',
'SIMXDWPASW030',
'SIMXDWPASW031',
'SIMXDWPASW032',
'SIMXDWPASW033',
'SIMXDWPASW034',
'SIMXDWPASW035',
'SIMXDWPASW036',
'SIMXDWPASW037',
'SIMXDWPASW038',
'SIMXDWPASW039',
'SIMXDWPASW040',
'SIMXDWPASW041',
'SIMXDWPASW042',
'SIMXDWPASW043',
'SIMXDWPASW044',
'SIMXDWPASW045',
'SIMXDWPASW046',
'SIMXDWPASW047',
'SIMXDWPASW048',
'SIMXDWPASW049',
'SIMXDWPASW050',
'SIMXDWPASW051',
'SIMXDWPASW052',
'SIMXDWPASW053',
'SIMXDWPASW054',
'SIMXDWPASW055',
'SIMXDWPASW056',
'SIMXDWPASW057',
'SIMXDWPASW058',
'SIMXDWPASW059',
'SIMXDWPASW060',
'SIMXDWPASW061',
'SIMXDWPASW062',
'SIMXDWPASW063',
'SIMXDWPASW064',
'SIMXDWPASW065',
'SIMXDWPASW066',
'SIMXDWPASW067',
'SIMXDWPASW068',
'SIMXDWPASW069',
'SIMXDWPASW070',
'SIMXDWPASW071',
'SIMXDWPASW072')
Repair-CmnClientCert -computers $computers -Verbose