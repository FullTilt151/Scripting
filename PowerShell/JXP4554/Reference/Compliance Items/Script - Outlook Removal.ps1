$Remediate = $false
$Compliant = $true
New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS -ErrorAction Ignore
Get-ChildItem 'HKU:\' | Select-Object -Property Name | Where-Object {$_.Name -ne 'HKEY_Users\.Default'} | ForEach-Object {
    $key = "HKU:\$($_.Name)\Software\Policies\Microsoft\office\16.0\outlook\cached mode"
    If (Test-Path $key) {
        If ((Get-ItemProperty -Path $key -ErrorAction SilentlyContinue).DownloadSharedFolders) {
            $Compliant = $false
        }
        else {
            if ($Remediate) {
                Remove-ItemProperty -Path $key -Name 'DownloadSharedFolders'
            }
        }
    }
}
Write-Host $Compliant