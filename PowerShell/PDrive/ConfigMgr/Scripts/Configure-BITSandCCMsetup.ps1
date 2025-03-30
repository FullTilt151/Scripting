Param(
[parameter(Mandatory=$true,HelpMessage='Computer to reset BITS and restart CM install')]
[string]$WKID
)
$regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $WKID)
$ref = $regKey.OpenSubKey("SOFTWARE\Policies\Microsoft\Windows\BITS\",$true)
$ref.SetValue("EnableBitsMaxBandwidth","0","DWORD")
$ref.SetValue("MaxTransferRateOffSchedule","0","DWORD")

$CCMSETUP = Get-Process -ComputerName $WKID -Name 'ccmsetup'
 
  IF ($CCMSETUP -ne $null){
    (Get-WmiObject Win32_process -Filter "Name = 'ccmsetup.exe'" -ComputerName $WKID).terminate()
}
Get-Service -ComputerName $WKID -Name BITS | Stop-Service -Force
Get-Service -ComputerName $WKID -Name ccmsetup | Start-Service


