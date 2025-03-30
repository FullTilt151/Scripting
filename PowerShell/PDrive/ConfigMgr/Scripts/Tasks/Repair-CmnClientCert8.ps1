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
$computers = ('SIMXDWPASW073',
'SIMXDWPASW074',
'SIMXDWPASW075',
'SIMXDWPASW076',
'SIMXDWPASW077',
'SIMXDWPASW078',
'SIMXDWPASW079',
'SIMXDWPASW080',
'SIMXDWPASW081',
'SIMXDWPASW082',
'SIMXDWPASW083',
'SIMXDWPASW084',
'SIMXDWPASW085',
'SIMXDWPASW086',
'SIMXDWPASW087',
'SIMXDWPASW089',
'SIMXDWPASW093',
'SIMXDWPASW094',
'SIMXDWPASW096',
'SIMXDWPASW097',
'SIMXDWPASW099',
'SIMXDWPASW100',
'SIMXDWPASW102',
'SIMXDWPASW103',
'SIMXDWPASW107',
'SIMXDWPASW108',
'SIMXDWPASW112',
'SIMXDWPASW113',
'SIMXDWPASW114',
'SIMXDWPASW115',
'SIMXDWPASW116',
'SIMXDWPASW117',
'SIMXDWPASW118',
'SIMXDWPASW119',
'SIMXDWPASW120',
'SIMXDWPASW121',
'SIMXDWPASW122',
'SIMXDWPASW123',
'SIMXDWPASW125',
'SIMXDWPASW128',
'SIMXDWPASW130',
'SIMXDWPASW131',
'SIMXDWPASW135',
'SIMXDWPASW137',
'SIMXDWPASW138',
'SIMXDWPASW141',
'SIMXDWPASW145',
'SIMXDWPASW146',
'SIMXDWPASW150',
'SIMXDWPASW151',
'SIMXDWPASW152',
'SIMXDWPASW155',
'SIMXDWPASW157',
'SIMXDWPASW160',
'SIMXDWPASW161',
'SIMXDWPASW162',
'SIMXDWPASW165',
'SIMXDWPASW167',
'SIMXDWPASW168',
'SIMXDWPASWP02',
'SIMXDWPASWP03',
'SIMXDWPASWP05',
'SIMXDWPASWS05',
'SIMXDWWKF0206',
'SIMXDWWKF0233',
'SIMXDWWKF0404')
Repair-CmnClientCert -computers $computers -Verbose