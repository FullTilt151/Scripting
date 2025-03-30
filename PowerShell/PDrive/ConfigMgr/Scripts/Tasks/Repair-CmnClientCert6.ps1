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
$computers = ('SIMXDWDIGW587',
'SIMXDWDIGW588',
'SIMXDWDIGW589',
'SIMXDWDIGW590',
'SIMXDWDIGW591',
'SIMXDWDIGW592',
'SIMXDWDIGW593',
'SIMXDWDIGW595',
'SIMXDWDIGW596',
'SIMXDWDIGW597',
'SIMXDWDIGW598',
'SIMXDWDIGW599',
'SIMXDWDIGW600',
'SIMXDWDIGW601',
'SIMXDWDIGW602',
'SIMXDWDIGW604',
'SIMXDWDIGW605',
'SIMXDWDIGW606',
'SIMXDWDIGW607',
'SIMXDWDIGW608',
'SIMXDWDIGW609',
'SIMXDWDIGW610',
'SIMXDWDIGW611',
'SIMXDWDIGW612',
'SIMXDWDIGW614',
'SIMXDWDIGW615',
'SIMXDWDIGW616',
'SIMXDWDIGW618',
'SIMXDWDIGW619',
'SIMXDWDIGW623',
'SIMXDWDIGW624',
'SIMXDWDIGW626',
'SIMXDWDIGW629',
'SIMXDWDIGW630',
'SIMXDWDIGW632',
'SIMXDWDIGW634',
'SIMXDWDIGW636',
'SIMXDWDIGW637',
'SIMXDWDIGW638',
'SIMXDWDIGW640',
'SIMXDWDIGW641',
'SIMXDWDIGW648',
'SIMXDWDIGW649',
'SIMXDWDIGW650',
'SIMXDWDIGW653',
'SIMXDWDIGW654',
'SIMXDWDIGW655',
'SIMXDWDIGW659',
'SIMXDWDIGW661',
'SIMXDWDIGW662',
'SIMXDWDIGW663',
'SIMXDWDIGW665',
'SIMXDWDIGW666',
'SIMXDWDIGW667',
'SIMXDWDIGW668',
'SIMXDWDIGW671',
'SIMXDWDIGW672',
'SIMXDWDIGW678',
'SIMXDWDIGW680',
'SIMXDWDIGW681',
'SIMXDWDIGW683',
'SIMXDWDIGW684',
'SIMXDWDIGW686',
'SIMXDWDIGW689',
'SIMXDWDIGW690',
'SIMXDWDIGW692',
'SIMXDWDIGW693',
'SIMXDWDIGW698',
'SIMXDWDIGW699',
'SIMXDWDIGW701',
'SIMXDWDIGW703',
'SIMXDWDIGW704',
'SIMXDWDIGW706',
'SIMXDWDIGW707',
'SIMXDWDIGW717',
'SIMXDWDIGW718',
'SIMXDWDIGW719',
'SIMXDWDIGW725',
'SIMXDWDIGW729',
'SIMXDWDIGW731',
'SIMXDWDIGW733',
'SIMXDWDIGW734',
'SIMXDWDIGW735',
'SIMXDWDIGW736',
'SIMXDWDIGW737',
'SIMXDWDIGW739',
'SIMXDWDIGW740',
'SIMXDWDIGW744',
'SIMXDWDIGW747',
'SIMXDWDIGW748',
'SIMXDWDIGW750',
'SIMXDWDIGW754',
'SIMXDWDIGW755',
'SIMXDWDIGW756',
'SIMXDWDIGW758',
'SIMXDWDIGW759')
Repair-CmnClientCert -computers $computers -Verbose