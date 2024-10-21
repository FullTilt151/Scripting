function Reset-PIN { 
    $DriveLetter = "C:"
    # Get the WMI object of the drive $DriveLetter if it’s encrypted
    $EncryptableVolume = Get-CimInstance -Namespace "Root\CIMV2\Security\MicrosoftVolumeEncryption" -class Win32_EncryptableVolume -Filter "ProtectionStatus=1 AND DriveLetter='$DriveLetter'"
    If ($EncryptableVolume) {
        $sysfldr = "system32"
        # Build command line and run it
        $cmd = @("$ENV:windir\$sysfldr\bitlockerwizardelev.exe", '$($EncryptableVolume.DeviceID)', "J") -join " "
        Invoke-Expression -Command $cmd
    }
}

#Get Current User, if EUT quit
$USR = (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object username).username
If ($USR.EndsWith('a')) {
    Write-Output "Current user is a workstation admin"
    exit 0
}

#Enable Protection on C:
(Get-BitLockerVolume).ProtectionStatus
If ($PSItem -eq "Off") {
    manage-bde -protectors -enable c:
    #Remove "On Logon" Sch Task
}

#90 Day Password rotation
#Event ID 4724 (Security) will not work
#Possible Event ID is 45057 (System) Will not work
#Unable to find an event when user changes password via go/reset

# Get last PIN change
Do {
    $TDY = Get-Date -Format MMddyyyy
    $DTEPIN = Get-WinEvent -FilterHashtable @{logname = "Microsoft-Windows-BitLocker/BitLocker Management"; ID = "777" }–MaxEvents 1 -ErrorAction SilentlyContinue
    IF ($TDY -eq $DTEPIN.TimeCreated.ToString("MMddyyyy")) {
        $PINSET = 'True'
        }
    IF (!($DTEPIN)) {
        Write-Output "Event ID not found"
        Reset-PIN
        $DTEPIN = Get-WinEvent -FilterHashtable @{logname = "Microsoft-Windows-BitLocker/BitLocker Management"; ID = "777" }–MaxEvents 1 -ErrorAction SilentlyContinue
        IF ($TDY -eq $DTEPIN.TimeCreated.ToString("MMddyyyy")) {
            $PINSET = 'True'
        }
    }
    IF ($TDY -ne $DTEPIN.TimeCreated.ToString("MMddyyyy")) {
        Reset-PIN
        Write-Output "Date not equal"
        $DTEPIN = Get-WinEvent -FilterHashtable @{logname = "Microsoft-Windows-BitLocker/BitLocker Management"; ID = "777" }–MaxEvents 1 -ErrorAction SilentlyContinue
        IF ($TDY -eq $DTEPIN.TimeCreated.ToString("MMddyyyy")) {
            $PINSET = 'True'
        }
    }
}
Until ($PINSET -eq 'True')
Write-Output "PIN has been set!"