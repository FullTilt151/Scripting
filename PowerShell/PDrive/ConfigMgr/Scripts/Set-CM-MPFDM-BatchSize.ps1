Import-Module 'C:\Program Files (x86)\ConfigMGR\bin\ConfigurationManager.psd1'
Set-Location WP1:
Get-CMManagementPoint | Select-Object -ExpandProperty NetworkOSPath |
ForEach-Object {
$name = $_.replace('\\','')
    Invoke-Command -ComputerName $name -ScriptBlock {
        Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\SMS\MPFDM -Name 'State Message Batch Size' -Value 200000
        Restart-Service 'SMS_Executive'
    }
}