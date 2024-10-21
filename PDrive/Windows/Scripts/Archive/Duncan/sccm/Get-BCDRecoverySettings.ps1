
$bcdedit = bcdedit /enum

if (($bcdedit | select-string recoveryenabled) -like "recoveryenabled*no" -and ($bcdedit | select-string bootstatuspolicy) -like "*IgnoreAllFailures") {
    Write-Output "0"
    exit 0
} else {
    Write-Output "1"
    exit 1
}