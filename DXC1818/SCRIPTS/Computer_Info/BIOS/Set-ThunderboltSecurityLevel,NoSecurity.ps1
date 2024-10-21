#ThunderboltSecurityLevel    : Enable,Disable
$WKID = 'WKR90R9CW9'
Invoke-Command -ComputerName $WKID -ScriptBlock {
    $CurrentSetting = Get-CimInstance -Namespace root\wmi -Class Lenovo_BiosSetting -Filter "CurrentSetting like 'ThunderboltSecurityLevel%'" | Select-Object -ExpandProperty CurrentSetting 
        if ($CurrentSetting -like 'ThunderboltSecurityLevel*') {
            $Interface = Get-WmiObject -Namespace root\wmi -Class Lenovo_SetBiosSetting
            $Interface.SetBiosSetting("ThunderboltSecurityLevel,NoSecurity,d51pcadm1n,ascii,us")
    }
    $SaveSettings = Get-WmiObject -Namespace root\wmi -Class Lenovo_SaveBiosSettings
    $SaveSettings.SaveBiosSettings("d51pcadm1n,ascii,us")
}
Get-CimInstance -ComputerName $WKID -Namespace root\wmi -Class Lenovo_BiosSetting -Filter "CurrentSetting like 'ThunderboltSecurityLevel%'"