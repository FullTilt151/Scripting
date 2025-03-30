$Usertable = @()
New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS -ErrorAction SilentlyContinue | out-null
get-childitem hku: | foreach {
    if ($_.Name -notin ('HKEY_USERS\.DEFAULT','HKEY_USERS\S-1-5-18','HKEY_USERS\S-1-5-19','HKEY_USERS\S-1-5-20') -and $_.Name -notlike "*_Classes") {
        $UserSID = ($_.Name).Replace('HKEY_USERS\','')
        $SID = New-Object System.Security.Principal.SecurityIdentifier($UserSID) -ErrorAction SilentlyContinue
        $User = $SID.Translate( [System.Security.Principal.NTAccount])
        $Username = $User.Value
        $SP = (Get-ItemProperty -Path (($_.Name).Replace('HKEY_USERS','HKU:') + "\Software\Microsoft\Windows\CurrentVersion\Internet Settings") -Name SecureProtocols -ErrorAction SilentlyContinue).SecureProtocols
        if ($SP -ne '2688') {
            Set-ItemProperty -Path (($_.Name).Replace('HKEY_USERS','HKU:') + "\Software\Microsoft\Windows\CurrentVersion\Internet Settings") -Name SecureProtocols -Value 2688 -ErrorAction SilentlyContinue -Verbose
            $SP = (Get-ItemProperty -Path (($_.Name).Replace('HKEY_USERS','HKU:') + "\Software\Microsoft\Windows\CurrentVersion\Internet Settings") -Name SecureProtocols -ErrorAction SilentlyContinue).SecureProtocols
        }
        if ($SP -ne $null) {
            $usertable += ,@($Username, $SP)   
        }
    }
}
