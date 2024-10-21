param(
$computer
)

<#
Write-Output ' '
Write-Output '### Last 10 patches ###'
Get-WmiObject -ComputerName $computer win32_quickfixengineering | Select-Object -First 10 | sort InstalledOn -Descending
#>
if (Test-Connection $computer -Count 1 -ErrorAction SilentlyContinue) {
    Get-Service -ComputerName $computer -Name RemoteRegistry | Start-Service
    
    Write-Output ' '
    Write-Output '### IE Version ###'
    $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computer)
    $RegKey= $Reg.OpenSubKey("SOFTWARE\\Microsoft\\Internet Explorer")
    $RegKey.GetValue("svcUpdateVersion")

#    Write-Output ' '
#    Write-Output '### MSI Installs ###'
#    $msi = Get-WinEvent -FilterHashtable @{logname = 'setup'} -ComputerName $computer
#    $msi | Select-Object -First 20 | Format-Table -Property MachineName,TimeCreated, Message -AutoSize
    
    Write-Output ' '
    Write-Output '### SiteList Used ###'
    $reg1 = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computer)
    $regKey1= $reg1.OpenSubKey("SOFTWARE\\Policies\\Microsoft\\Internet Explorer\\MAIN\\EnterpriseMode")
    $regkey1.GetValue("SiteList")
    
    Write-Output ' '
    Write-Output '### HSTS Disabled ###'
    $reg2 = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computer)
    $regKey2= $reg2.OpenSubKey("SOFTWARE\\Microsoft\\Internet Explorer\\MAIN\\FeatureControl\\FEATURE_DISABLE_HSTS")
    $regkey2.GetValue("iexplore.exe")
} else {
    Write-warning "$computer is offline!"
}