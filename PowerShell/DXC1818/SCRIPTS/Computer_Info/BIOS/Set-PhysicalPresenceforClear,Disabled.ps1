#Physical Presnce for Clear                : Enabled;[Optional:Disabled
$WKID = 'EUEPXEWPW03'
Invoke-Command -ComputerName $WKID -ScriptBlock {
    #$CurrentSetting = Get-CimInstance -Namespace root\wmi -Class Lenovo_BiosSetting -Filter "CurrentSetting like 'Physical Presnce for Clear'" | Select-Object -ExpandProperty CurrentSetting 
        #if ($CurrentSetting -like 'Physical Presnce for Clear') {
            $Interface = Get-WmiObject -Namespace root\wmi -Class Lenovo_SetBiosSetting
            $Interface.SetBiosSetting("Physical Presnce for Clear,Disabled,d51pcadm1n,ascii,us")
    #}
    $SaveSettings = Get-WmiObject -Namespace root\wmi -Class Lenovo_SaveBiosSettings
    $SaveSettings.SaveBiosSettings("d51pcadm1n,ascii,us")
}
Get-CimInstance -ComputerName $WKID -Namespace root\wmi -Class Lenovo_BiosSetting -Filter "CurrentSetting like 'Physical Presnce for Clear'"