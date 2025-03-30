Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
Set-Location WP1:

Get-CMConfigurationItem | Select-Object -ExpandProperty LocalizedDisplayName | Where-Object {$_ -notlike 'Script*' -and $_ -notlike 'Registry*' -and $_ -ne 'Built-In'} |
ForEach-Object {
    $xml = [xml]((Get-CMConfigurationItem -Name $_).SDMPackageXML)
    $xml.InnerXml | Out-File c:\temp\ci.xml
    [xml]$cifile = Get-Content C:\temp\ci.xml
    $SettingType = ($cifile.DesiredConfigurationDigest.OperatingSystem.Settings.RootComplexSetting.SimpleSetting.LogicalName).Split('_')[0]
    "$_ - " + $SettingType
    if ($SettingType -eq 'RegSetting') {
        Set-CMConfigurationItem -Name $_ -NewName "Registry - $_" -Verbose
    } elseif ($SettingType -eq 'ScriptSetting') {
        Set-CMConfigurationItem -Name $_ -NewName "Script - $_" -Verbose
    }
}

Remove-Item C:\temp\ci.xml