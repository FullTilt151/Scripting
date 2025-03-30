
$bcdedit = bcdedit /enum

if (($bcdedit | select-string recoveryenabled) -like "recoveryenabled*no" -and ($bcdedit | select-string bootstatuspolicy) -like "*IgnoreAllFailures") {
    write-output "RecoveryEnabled: No"
    write-output "BootStatusPolicy: IgnoreAllFailures"
    Write-Output "0"
    exit 0
} else {
    if (($bcdedit | select-string recoveryenabled) -like "recoveryenabled*yes") {
        write-output "RecoveryEnabled: Yes"
    } elseif (($bcdedit | select-string recoveryenabled) -like "recoveryenabled*no") {
        write-output "RecoveryEnabled: No"
    }
    if (($bcdedit | select-string bootstatuspolicy) -notlike "*IgnoreAllFailures") {
        write-output "BootStatusPolicy: Unknown"
    }
    Write-Output "1"
    exit 1
}