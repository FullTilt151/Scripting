$Usertable = @()
New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS -ErrorAction SilentlyContinue | out-null
get-childitem hku: | foreach {
    if ($_.Name -notin ('HKEY_USERS\.DEFAULT','HKEY_USERS\S-1-5-18','HKEY_USERS\S-1-5-19','HKEY_USERS\S-1-5-20') -and $_.Name -notlike "*_Classes") {
        $UserSID = ($_.Name).Replace('HKEY_USERS\','')
        $SID = New-Object System.Security.Principal.SecurityIdentifier($UserSID) -ErrorAction SilentlyContinue
        $User = $SID.Translate( [System.Security.Principal.NTAccount])
        $Username = $User.Value
        $IsEnabled = (Get-ItemProperty -Path (($_.Name).Replace('HKEY_USERS','HKU:') + "\Software\Microsoft\Internet Explorer\Safety\ActiveXFiltering") -Name IsEnabled -ErrorAction SilentlyContinue).IsEnabled
        if ($IsEnabled -ne $null) {
            $usertable += ,@($Username, $IsEnabled)   
        }
    }
}

$Usertable