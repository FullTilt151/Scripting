# Microsoft Compatibility Appraiser Version Check
 
$Path = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Appraiser'
$Value = 'LastAttemptedRunDataVersion'
 
If (Test-Path -Path $Path) {
    $ValueExist = (Get-ItemProperty $Path).$Value -ne $null
    If ($ValueExist -eq $True) {
        Return (Get-ItemProperty $Path).$Value
    }
    Else {
        Return "Not Found"
    }
    Return $Value
}
Else {
    Return "Not Found"
}