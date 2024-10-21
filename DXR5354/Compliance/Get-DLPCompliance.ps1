# Verify Windows Connection Manager
Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy -Name fBlockNonDomain | Select-Object -ExpandProperty fBlockNonDomain

# Verify Windows Firewall - Domain is on
Get-NetFirewallProfile -Name Domain | Select-Object -ExpandProperty Enabled

# Verify Windows Firewall - SMTP block
$FirewallRules = Get-NetFirewallRule -PolicyStore ActiveStore -PolicyStoreSourceType GroupPolicy
$FirewallRules.Where{$_.DisplayName -eq 'SMTP Block'}

# Verify Windows Firewall - FTP block
$FirewallRules.Where{$_.DisplayName -eq 'FTP Block (Inbound)'}
$FirewallRules.Where{$_.DisplayName -eq 'FTP Block (Outbound)'}

# Verify Bluetooth transfer blocks
Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\BTHPORT\Parameters -Name DisableFsquirt | Select-Object -ExpandProperty DisableFsquirt
Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\fsquirt.exe' -Name Debugger | Select-Object -ExpandProperty Debugger

# Verify CD-ROM block
Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices\{53f56308-b6bf-11d0-94f2-00a0c91efb8b}' -Name Deny_Write | Select-Object -ExpandProperty Deny_Write

# Verify Application Block
$ApplockerRules = @(
    '%OSDRIVE%\Users\*\AppData\Local\Temp\galaperidol8.exe',
    '%WINDIR%\taskhcst.eee',
    '%WINDIR%\taskhcst.exe',
    '%PROGRAMFILES%\Common Files\microsoft shared\EQUATION\eqnedt32.exe',
    '%OSDRIVE%\Users\*\AppData\Local\Temp\drefudre20.exe'
)

[xml]$Applocker = Get-AppLockerPolicy -Xml -Effective
$ApplockerEffectiveRules = @()
$ApplockerEffectiveRules = $Applocker.AppLockerPolicy.RuleCollection.Where{$_.type -eq 'Exe'}.ChildNodes.where{$_.Action -eq 'Deny'}.Conditions.Filepathcondition | Select-Object -ExpandProperty Path
$ApplockerEffectiveRules -match $ApplockerRules

