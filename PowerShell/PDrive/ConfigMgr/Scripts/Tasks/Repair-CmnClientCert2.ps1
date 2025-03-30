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
$computers = ('SIMXDWDIGW109','SIMXDWDIGW110','SIMXDWDIGW111','SIMXDWDIGW112','SIMXDWDIGW113','SIMXDWDIGW114','SIMXDWDIGW115','SIMXDWDIGW116','SIMXDWDIGW117','SIMXDWDIGW118','SIMXDWDIGW119','SIMXDWDIGW120','SIMXDWDIGW121','SIMXDWDIGW122','SIMXDWDIGW123','SIMXDWDIGW124','SIMXDWDIGW125','SIMXDWDIGW126','SIMXDWDIGW128','SIMXDWDIGW129','SIMXDWDIGW130','SIMXDWDIGW132','SIMXDWDIGW133','SIMXDWDIGW134','SIMXDWDIGW135','SIMXDWDIGW136','SIMXDWDIGW137','SIMXDWDIGW138','SIMXDWDIGW140','SIMXDWDIGW141','SIMXDWDIGW142','SIMXDWDIGW143','SIMXDWDIGW144','SIMXDWDIGW145','SIMXDWDIGW146','SIMXDWDIGW147','SIMXDWDIGW148','SIMXDWDIGW149','SIMXDWDIGW150','SIMXDWDIGW151','SIMXDWDIGW152','SIMXDWDIGW153','SIMXDWDIGW155','SIMXDWDIGW156','SIMXDWDIGW158','SIMXDWDIGW159','SIMXDWDIGW160','SIMXDWDIGW161','SIMXDWDIGW162','SIMXDWDIGW163','SIMXDWDIGW165','SIMXDWDIGW167','SIMXDWDIGW169','SIMXDWDIGW172','SIMXDWDIGW173','SIMXDWDIGW175','SIMXDWDIGW177','SIMXDWDIGW179','SIMXDWDIGW181','SIMXDWDIGW183','SIMXDWDIGW185','SIMXDWDIGW187','SIMXDWDIGW189','SIMXDWDIGW191','SIMXDWDIGW194','SIMXDWDIGW196','SIMXDWDIGW198','SIMXDWDIGW199','SIMXDWDIGW201','SIMXDWDIGW204','SIMXDWDIGW206','SIMXDWDIGW208','SIMXDWDIGW210','SIMXDWDIGW211','SIMXDWDIGW213','SIMXDWDIGW214','SIMXDWDIGW215','SIMXDWDIGW217','SIMXDWDIGW218','SIMXDWDIGW221','SIMXDWDIGW222','SIMXDWDIGW224','SIMXDWDIGW225')
Repair-CmnClientCert -computers $computers -Verbose