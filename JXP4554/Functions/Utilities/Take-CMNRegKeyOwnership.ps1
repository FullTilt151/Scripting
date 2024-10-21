function set-regkeyowner {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false)]
        [string]$ComputerName = 'localhost',

        [parameter(Mandatory = $true)]
        [Validateset('HKCR', 'HKCU', 'HKLM', 'HKUS', 'HKCC')]
        [string]$hive,

        [parameter(Mandatory = $true)]
        [string]$key
    )
    begin { }

    process {
        Write-Verbose "Set Hive"
        switch ($hive) {
            'HKCR' { $reg = [Microsoft.Win32.Registry]::ClassesRoot }
            'HKCU' { $reg = [Microsoft.Win32.Registry]::CurrentUser }
            'HKLM' { $reg = [Microsoft.Win32.Registry]::LocalMachine }
            'HKUS' { $reg = [Microsoft.Win32.Registry]::Users }
            'HKCC' { $reg = [Microsoft.Win32.Registry]::CurrentConfig }
        }

        $permchk = [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree
        $regrights = [System.Security.AccessControl.RegistryRights]::ChangePermissions

        Write-Verbose 'Open Key and get access control'
        $regkey = $reg.OpenSubKey($key, $permchk, $regrights)
        #add errorcheck for null regkey
        $rs = $regkey.GetAccessControl()

        Write-Verbose 'Create security principal'
        $user = New-Object -TypeName Security.Principal.NTaccount -ArgumentList 'Administrators'

        $rs.SetGroup($user)
        $rs.SetOwner($user)
        $regkey.SetAccessControl($rs)
    }

    end { }
}
$key = 'SOFTWARE\humana\Test'
$hive = 'HKLM'
set-regkeyowner -Hive $hive -key $key -ComputerName $ComputerName
# Remove-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod'