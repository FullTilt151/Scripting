Get-CimClass -Namespace root/WMI -ClassName l*
#Lenovo_BIOSElement
#Lenovo_SetBiosSetting
#Lenovo_DiscardBiosSettings
#Lenovo_BiosSetting
#Lenovo_SaveBiosSettings
#Lenovo_SetBiosPassword
#Lenovo_BiosPasswordSettings
#Lenovo_LoadDefaultSettings

$PasswordSettings = Get-CimInstance -Namespace root\wmi -Class Lenovo_BiosPasswordSettings
$PasswordSettings.PasswordState
#0 – No passwords set
#1 – Power on password set
#2 – Supervisor password set
#3 – Power on and supervisor passwords set
#4 – Hard drive password(s) set
#5 – Power on and hard drive passwords set
#6 – Supervisor and hard drive passwords set
#7 – Supervisor, power on, and hard drive passwords set

$PasswordSet = Get-CimInstance -Namespace root\wmi -Class Lenovo_SetBiosPassword -ComputerName WKPC0MLLCS
$PasswordSet.SetBiosPassword("pap,oldpwd1,newpwd1,ascii,us")

#Get Lenovo BIOS Settings
$WKID = 'WKPC0MLLCS'
$SysModel = Get-CimInstance Win32_ComputerSystem -ComputerName $WKID | Select-Object -ExpandProperty SystemFamily
Get-CimInstance -Namespace root/WMI -ClassName Lenovo_BiosSetting -ComputerName $WKID | Select-Object CurrentSetting | Format-Table -AutoSize | Out-File "C:\CIS_TEMP\BIOS_Settings\$SysModel.csv"


#Get TPM Version
Get-CimInstance -Namespace root\CIMV2\Security\MicrosoftTpm -Class Win32_TPM | Select-Object SpecVersion

(Get-CimInstance -Namespace root\wmi -Class Lenovo_SetBiosSetting).SetBiosSetting("BottomCoverTamperDetected,Enable,%BIOSPWFormatted%,ascii,us")