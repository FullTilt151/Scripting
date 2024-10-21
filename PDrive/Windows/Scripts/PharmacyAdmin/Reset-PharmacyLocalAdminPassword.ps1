param(
    [Parameter(Mandatory=$true)]
    $Spreadsheet
)

Import-Csv -Path $Spreadsheet -Header WKID, Username, Password | ForEach-Object {
    $WKID = $_
    Invoke-Command -ComputerName $_.WKID -ArgumentList $WKID -ScriptBlock {
        & "cmd.exe" "/c net user $($using:WKID.Username) $($using:WKID.Password)"
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoAdminLogon -Value 1
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultUsername -Value $($using:WKID.Username)
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultPassword -Value $($using:WKID.Password)
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultDomainName -Value 'RX1AD'
    }
}