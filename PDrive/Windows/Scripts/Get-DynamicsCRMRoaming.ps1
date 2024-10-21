New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS -ErrorAction SilentlyContinue | out-null
Get-ChildItem hku: | ForEach-Object {
    if ($_.Name -notin ('HKEY_USERS\.DEFAULT','HKEY_USERS\S-1-5-18','HKEY_USERS\S-1-5-19','HKEY_USERS\S-1-5-20') -and $_.Name -notlike "*_Classes") {
        $UserSID = ($_.Name).Replace('HKEY_USERS\','')
        $SID = New-Object System.Security.Principal.SecurityIdentifier($UserSID) -ErrorAction SilentlyContinue
        $User = $SID.Translate( [System.Security.Principal.NTAccount])
        $Username = $User.Value
        Set-ItemProperty -Path (($_.Name).Replace('HKEY_USERS','HKU:') + "\SOFTWARE\Microsoft\Office\14.0\Outlook\Security") -Name EnableRoamingFolderHomepages -ErrorAction SilentlyContinue -Value 2
        Set-ItemProperty -Path (($_.Name).Replace('HKEY_USERS','HKU:') + "\SOFTWARE\Microsoft\Office\15.0\Outlook\Security") -Name EnableRoamingFolderHomepages -ErrorAction SilentlyContinue -Value 2
        Set-ItemProperty -Path (($_.Name).Replace('HKEY_USERS','HKU:') + "\SOFTWARE\Microsoft\Office\16.0\Outlook\Security") -Name EnableRoamingFolderHomepages -ErrorAction SilentlyContinue -Value 2
    }
}

Write-Output 'Complete'