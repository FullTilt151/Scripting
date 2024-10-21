$ComputerName = read-host "Please enter the WKID:"

$PasswordSettings = Get-CimInstance -Namespace root\wmi -Class Lenovo_BiosPasswordSettings -ComputerName $ComputerName
$PasswordSettings.PasswordState
IF ($PasswordSettings.PasswordState -eq 0) {
    Write-Output "No passwords set"}
IF ($PasswordSettings.PasswordState -eq 1) {
    Write-Output "Power on password set - POP"}
IF ($PasswordSettings.PasswordState -eq 2) {
    Write-Output "Supervisor password set - pap"}
IF ($PasswordSettings.PasswordState -eq 3) {
    Write-Output "Power on and supervisor passwords set"}
IF ($PasswordSettings.PasswordState -eq 4) {
    Write-Output "Hard drive password(s) set"}
IF ($PasswordSettings.PasswordState -eq 5) {
    Write-Output "Power on and hard drive passwords set"}
IF ($PasswordSettings.PasswordState -eq 6) {
    Write-Output "Supervisor and hard drive passwords set"}
IF ($PasswordSettings.PasswordState -eq 7) {
    Write-Output "Supervisor, power on, and hard drive passwords set"}
    IF ($PasswordSettings.PasswordState -eq 0) {
        #cmd /c exit 1
    }
    IF ($PasswordSettings.PasswordState -eq 2) {
        $PasswordSet = Get-WmiObject -Namespace root\wmi -Class Lenovo_SetBiosPassword -ComputerName $ComputerName
        $RTN = $PasswordSet.SetBiosPassword("pap,abc123,d51pcadm1n,ascii,us")
        IF  ($RTN.Return -eq 'Invalid Parameter') {
                cmd /c exit 1
        IF ($RTN.Return -eq 'Access Denied') {
            $RTN = $PasswordSet.SetBiosPassword("pap,d51pcadm1n,d51pcadm1n,ascii,us")
        }
            IF  ($RTN.Return -eq 'Access Denied') {
                cmd /c exit 1
            }
        #$Virtualization = Get-WmiObject -Namespace Root\WMI -Class Lenovo_SetBiosSetting -ComputerName $ComputerName
        #$Virtualization.SetBiosSetting('VirtualizationTechnology,Enable,d51pcadm1n,ascii,us')
        
        $SAVEPWD = Get-WmiObject -Namespace root\wmi -Class Lenovo_SaveBiosSettings -ComputerName $ComputerName
    }
