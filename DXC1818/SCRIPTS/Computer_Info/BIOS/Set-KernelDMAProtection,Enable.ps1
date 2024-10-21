#KernelDMAProtection    : Enable,Disable
$WKID = 'WKR90VLDV0'
Invoke-Command -ComputerName $WKID -ScriptBlock {
    $CurrentSetting = Get-CimInstance -Namespace root\wmi -Class Lenovo_BiosSetting -Filter "CurrentSetting like 'KernelDMAProtection%'" | Select-Object -ExpandProperty CurrentSetting 
        if ($CurrentSetting -like 'KernelDMAProtection*') {
            $Interface = Get-WmiObject -Namespace root\wmi -Class Lenovo_SetBiosSetting
            $Interface.SetBiosSetting("KernelDMAProtection,Enable,d51pcadm1n,ascii,us")
    }
    $SaveSettings = Get-WmiObject -Namespace root\wmi -Class Lenovo_SaveBiosSettings
    $SaveSettings.SaveBiosSettings("d51pcadm1n,ascii,us")
}
Get-CimInstance -ComputerName $WKID -Namespace root\wmi -Class Lenovo_BiosSetting -Filter "CurrentSetting like 'KernelDMAProtection%'"