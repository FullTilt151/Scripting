
## Check if we are a domain controller, and return compliant if we are
$DomainRole = (Get-WmiObject -Query "SELECT DomainRole FROM Win32_ComputerSystem").DomainRole
if ($DomainRole -eq 4 -or $DomainRole -eq 5) {
    ## Define new class name and date
    $NewClassName = 'CM_LocalUserAccounts'

    ## Remove class if exists
    Remove-WmiObject -Class $NewClassName -ErrorAction SilentlyContinue
        
    Write-Output 'Compliant'
}
else {
    ## Define new class name and date
    $NewClassName = 'CM_LocalUserAccounts'

    ## Remove class if exists
    Remove-WmiObject -Class $NewClassName -ErrorAction SilentlyContinue

    # Create new WMI class
    $newClass = New-Object System.Management.ManagementClass ("root\cimv2", [String]::Empty, $null)
    $newClass["__CLASS"] = $NewClassName

    ## Create properties you want inventoried
    $newClass.Qualifiers.Add("Static", $true)
    $newClass.Properties.Add("Name", [System.Management.CimType]::String, $false)
    $newClass.Properties.Add("SID", [System.Management.CimType]::String, $false)
    $newClass.Properties.Add("Description", [System.Management.CimType]::String, $false)
    $newClass.Properties.Add("Disabled", [System.Management.CimType]::String, $false)
    $newClass.Properties.Add("FullName", [System.Management.CimType]::String, $false)
    $newClass.Properties.Add("LastLogon", [System.Management.CimType]::String, $false)
    $newClass.Properties.Add("PasswordLastSet", [System.Management.CimType]::String, $false)
    $newClass.Properties.Add("UserFlags", [System.Management.CimType]::String, $false)
    $newClass.Properties["Name"].Qualifiers.Add("Key", $true)
    $newClass.Properties["SID"].Qualifiers.Add("Key", $true)
    $newClass.Put() | Out-Null

    #region functions
    Function Get-ADSILocalUser {
        [Cmdletbinding()]
        Param(
            [Parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
            [String[]]$Computername = $Env:Computername
        )
  
        Begin {
            #region  Helper Functions
            Function  ConvertTo-SID {
                Param(
                    [byte[]]$BinarySID
                )
                (New-Object  System.Security.Principal.SecurityIdentifier($BinarySID, 0)).Value
            }
  
            Function  Convert-UserFlag {
                Param  (
                    $UserFlag
                )
                $Results = Switch ($UserFlag) {
                    ($UserFlag  -BOR 0x0001) {
                        'SCRIPT'
                    }
                    ($UserFlag  -BOR 0x0002) {
                        'ACCOUNTDISABLE'
                    }
                    ($UserFlag  -BOR 0x0008) {
                        'HOMEDIR_REQUIRED'
                    }
                    ($UserFlag  -BOR 0x0010) {
                        'LOCKOUT'
                    }
                    ($UserFlag  -BOR 0x0020) {
                        'PASSWD_NOTREQD'
                    }
                    ($UserFlag  -BOR 0x0040) {
                        'PASSWD_CANT_CHANGE'
                    }
                    ($UserFlag  -BOR 0x0080) {
                        'ENCRYPTED_TEXT_PWD_ALLOWED'
                    }
                    ($UserFlag  -BOR 0x0100) {
                        'TEMP_DUPLICATE_ACCOUNT'
                    }
                    ($UserFlag  -BOR 0x0200) {
                        'NORMAL_ACCOUNT'
                    }
                    ($UserFlag  -BOR 0x0800) {
                        'INTERDOMAIN_TRUST_ACCOUNT'
                    }
                    ($UserFlag  -BOR 0x1000) {
                        'WORKSTATION_TRUST_ACCOUNT'
                    }
                    ($UserFlag  -BOR 0x2000) {
                        'SERVER_TRUST_ACCOUNT'
                    }
                    ($UserFlag  -BOR 0x10000) {
                        'DONT_EXPIRE_PASSWORD'
                    }
                    ($UserFlag  -BOR 0x20000) {
                        'MNS_LOGON_ACCOUNT'
                    }
                    ($UserFlag  -BOR 0x40000) {
                        'SMARTCARD_REQUIRED'
                    }
                    ($UserFlag  -BOR 0x80000) {
                        'TRUSTED_FOR_DELEGATION'
                    }
                    ($UserFlag  -BOR 0x100000) {
                        'NOT_DELEGATED'
                    }
                    ($UserFlag  -BOR 0x200000) {
                        'USE_DES_KEY_ONLY'
                    }
                    ($UserFlag  -BOR 0x400000) {
                        'DONT_REQ_PREAUTH'
                    }
                    ($UserFlag  -BOR 0x800000) {
                        'PASSWORD_EXPIRED'
                    }
                    ($UserFlag  -BOR 0x1000000) {
                        'TRUSTED_TO_AUTH_FOR_DELEGATION'
                    }
                    ($UserFlag  -BOR 0x04000000) {
                        'PARTIAL_SECRETS_ACCOUNT'
                    }
                }
                $Results
            }
        }
        #endregion  Helper Functions

        Process {
            ForEach ($Computer in  $Computername) {
                $adsi = [ADSI]"WinNT://$Computername"
                $adsi.Children | Where-Object { $_.SchemaClassName -eq 'user' } | ForEach-Object {
                    $PasswordAge = [math]::Round($_.PasswordAge[0] / 86400)
                    $PasswordLastSet = switch ($PasswordAge) {
                        0 {
                            'Never'
                        }
                        default {
                            $(Get-Date).AddDays("-$PasswordAge").ToString('MM/dd/yyyy')
                        }
                    }
                    $LastLogin = $(try {
                            if ($_.LastLogin[0] -is [datetime]) {
                                $_.LastLogin[0]
                            }
                            else {
                                'Never Logged On'
                            }
                        }
                        catch {
                            'Never Logged On'
                        })
                    $UserFlags = Convert-UserFlag -UserFlag $_.UserFlags[0]
                    $Disabled = $UserFlags -contains 'ACCOUNTDISABLE'

                    New-Object -TypeName PSObject -Property @{
                        Name            = $_.Name[0]
                        SID             = ConvertTo-SID -BinarySID $_.ObjectSID[0]
                        Description     = $_.Description[0]
                        Disabled        = $Disabled
                        FullName        = $_.FullName[0]
                        PasswordLastSet = $PasswordLastSet
                        LastLogon       = $LastLogin
                        UserFlags       = $UserFlags -join ', '
                    }
                }
            }
        }
    } 
    #endregion functions 

    ## Gather current local user info
    Get-ADSILocalUser | ForEach-Object {    
        ## Set local user info in new class
        Set-WmiInstance -Namespace root\cimv2 -class $NewClassName -ErrorAction SilentlyContinue -Arguments @{
            Name            = $_.Name
            SID             = $_.SID
            Description     = $_.Description
            Disabled        = $_.Disabled
            FullName        = $_.FullName
            LastLogon       = $_.LastLogon
            PasswordLastSet = $_.PasswordLastSet
            UserFlags       = $_.UserFlags
        } | Out-Null
    }

    Write-Output "Complete"
}