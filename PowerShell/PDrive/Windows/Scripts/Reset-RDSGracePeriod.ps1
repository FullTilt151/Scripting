Write-Output "RDS Days Left: $((Get-WmiObject -Namespace root\cimv2\terminalservices -Class win32_terminalservicesetting).GetGracePeriodDays().DaysLeft)"

$definition = @"
using System;
using System.Runtime.InteropServices; 
 
namespace Win32Api
{
 
 public class NtDll
 {
 [DllImport("ntdll.dll", EntryPoint="RtlAdjustPrivilege")]
 public static extern int RtlAdjustPrivilege(ulong Privilege, bool Enable, bool CurrentThread, ref bool Enabled);
 }
}
"@ 
 
Add-Type -TypeDefinition $definition -PassThru
 
$bEnabled = $false
 
# Enable SeTakeOwnershipPrivilege
$res = [Win32Api.NtDll]::RtlAdjustPrivilege(9, $true, $false, [ref]$bEnabled)

$key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod",[Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,[System.Security.AccessControl.RegistryRights]::TakeOwnership)
$acl = $key.GetAccessControl()
$acl.SetOwner([System.Security.Principal.NTAccount]"Administrators")
$key.SetAccessControl($acl)

$key1 = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod",[Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,[System.Security.AccessControl.RegistryRights]::ChangePermissions)
$acl1 = $key1.GetAccessControl()
$rule1 = New-Object System.Security.AccessControl.RegistryAccessRule ("Administrators","FullControl","ObjectInherit,ContainerInherit","None","Allow")
$acl1.SetAccessRule($rule1)
$key1.SetAccessControl($acl1)

Remove-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod' -Force

$os = Get-WmiObject -Namespace root\cimv2 -Class win32_operatingsystem -ErrorAction SilentlyContinue

switch ($os.caption) {
    "Microsoft Windows Server 2008 Enterprise" {set-itemproperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name LoadableProtocol_Object -Value '{18b726bb-6fe6-4fb9-9276-ed57ce7c7cb2}'}
    "Microsoft Windows Server 2008 R2 Enterprise" {set-itemproperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name LoadableProtocol_Object -Value '{18b726bb-6fe6-4fb9-9276-ed57ce7c7cb2}'}
    "Microsoft Windows Server 2008 R2 Enterprise " {set-itemproperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name LoadableProtocol_Object -Value '{18b726bb-6fe6-4fb9-9276-ed57ce7c7cb2}'}
    "Microsoft Windows Server 2012 Standard" {}
    "Microsoft Windows Server 2012 Enterprise" {}
    "Microsoft Windows Server 2012 R2 Standard" {set-itemproperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name LoadableProtocol_Object -Value '{5828227c-20cf-4408-b73f-73ab70b8849f}'}
    "Microsoft Windows Server 2012 R2 Enterprise" {set-itemproperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name LoadableProtocol_Object -Value '{5828227c-20cf-4408-b73f-73ab70b8849f}'}
    default {$osver = $os.caption}
}

Get-Service TermService | Restart-Service -Force

start-sleep -Seconds 30

Write-Output "RDS Days Left: $((Get-WmiObject -Namespace root\cimv2\terminalservices -Class win32_terminalservicesetting).GetGracePeriodDays().DaysLeft)"