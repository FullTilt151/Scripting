if ((Get-CimInstance -ClassName win32_computersystemproduct).Vendor -eq 'LENOVO') {
    (Get-CimInstance -class Lenovo_SetBiosSetting –namespace root\wmi).SetBiosSetting("SecurityChip,Active")
    (Get-CimInstance -class Lenovo_SetBiosSetting –namespace root\wmi).SetBiosSetting("SecurityChip,Enable")
    (Get-CimInstance -class Lenovo_SetBiosSetting –namespace root\wmi).SetBiosSetting("TCG Security Feature,Active")
    (Get-CimInstance -class Lenovo_SetBiosSetting –namespace root\wmi).SetBiosSetting("Security Chip 2.0,Enabled")
    (Get-CimInstance -class Lenovo_SetBiosSetting –namespace root\wmi).SetBiosSetting("Security Chip,Enabled")
    (Get-CimInstance -class Lenovo_SaveBiosSettings -namespace root\wmi).SaveBiosSettings()
}