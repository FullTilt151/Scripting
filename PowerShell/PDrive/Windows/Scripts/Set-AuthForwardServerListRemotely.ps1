param(
    [parameter(Mandatory=$true)]
    $WKID
)

Invoke-Command -ComputerName $WKID -ScriptBlock {
    $list = @(
        "*.humana.com",
        "*.force.com",
        "*.salesforce.com"
    )

    Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\WebClient\Parameters -Type MultiString -Name AuthForwardServerList -Value $list
    Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\WebClient\Parameters -Name AuthForwardServerList | Select-Object -ExpandProperty AuthForwardServerList
}