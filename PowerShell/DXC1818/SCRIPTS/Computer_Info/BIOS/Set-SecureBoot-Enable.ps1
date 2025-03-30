[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ComputerName
)

if ($null -eq $ComputerName) {
    $CurrentSetting = Get-CimInstance -Namespace root\wmi -Class Lenovo_BiosSetting -Filter "CurrentSetting like 'Secure%boot%'" | Select-Object -ExpandProperty CurrentSetting 
    
    if ($CurrentSetting -like 'Secure Boot*') {
        $Interface = Get-WmiObject -Namespace root\wmi -Class Lenovo_SetBiosSetting
        $Interface.SetBiosSetting("Secure Boot,Enabled")
    } elseif ($CurrentSetting -like 'SecureBoot*') {
        $Interface = Get-WmiObject -Namespace root\wmi -Class Lenovo_SetBiosSetting
        $Interface.SetBiosSetting("SecureBoot,Enable")
    }

    $SaveSettings = Get-WmiObject -Namespace root\wmi -Class Lenovo_SaveBiosSettings
    $SaveSettings.SaveBiosSettings()
} else {
    $CurrentSetting = Get-CimInstance -ComputerName $ComputerName -Namespace root\wmi -Class Lenovo_BiosSetting -Filter "CurrentSetting like 'Secure%boot%'" | Select-Object -ExpandProperty CurrentSetting
    
    if ($CurrentSetting -like 'Secure Boot*') {
        $Interface = Get-WmiObject -Namespace root\wmi -Class Lenovo_SetBiosSetting -ComputerName $ComputerName
        $Interface.SetBiosSetting("Secure Boot,Enabled")
    } elseif ($CurrentSetting -like 'SecureBoot*') {
        $Interface = Get-WmiObject -Namespace root\wmi -Class Lenovo_SetBiosSetting -ComputerName $ComputerName
        $Interface.SetBiosSetting("SecureBoot,Enable")
    }

    $SaveSettings = Get-WmiObject -Namespace root\wmi -Class Lenovo_SaveBiosSettings -ComputerName $ComputerName
    $SaveSettings.SaveBiosSettings()
}