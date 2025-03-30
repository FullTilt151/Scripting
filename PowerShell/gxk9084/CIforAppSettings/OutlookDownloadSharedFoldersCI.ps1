$Remediate = $false
$Compliant = $false
New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS -ErrorAction Ignore
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\windows NT\CurrentVersion\profilelist' -Name | ForEach-Object {
    $key = "HKU:\$_\Software\Policies\Microsoft\office\16.0\outlook\cached mode"
    If (Test-Path $key) {
        If (-Not (Get-ItemProperty $key DownloadSharedFolders -ErrorAction SilentlyContinue)) {
            $Compliant = $true
        }
        else {
            if ($Remediate) {
                Remove-ItemProperty $key DownloadSharedFolders
            }
            Break
        }
    }
    else {
        $Compliant = $true
    }
    
}
Write-Host $Compliant




