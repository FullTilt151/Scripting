<#
.Synopsis

.DESCRIPTION

.PARAMETER

.EXAMPLE

.LINK
    http://parrisfamily.com

.NOTES

#>

Param
(
    [Parameter(Mandatory = $false)]
    [String[]]$ComputerNames = ('localhost'),

    [Parameter(Mandatory = $false)]
    [Switch]$purge
)

foreach($ComputerName in $ComputerNames)
{
    if($PSBoundParameters['purge'])
    {
        Invoke-WmiMethod -ComputerName $ComputerName -Namespace root\ccm -Class sms_client -Name ResetPolicy -ArgumentList 1
    }
    else
    {
        Invoke-WmiMethod -ComputerName $ComputerName -Namespace root\ccm -Class sms_client -Name ResetPolicy -ArgumentList 0
    }
    Get-Service -ComputerName $ComputerName -Name 'SMS Agent Host' | Stop-Service
    Get-Service -ComputerName $ComputerName -Name 'SMS Agent Host' | Start-Service
}