<#
    This is intended to be used as a configuration baseline in SCCM.
    It will ensure the servers referenced by the SCCM Console match up with the hash table provided below.
#>

$Remediate = $false

$SiteCodeToSiteServer = @{
    'MT1' = @('LOUAPPWTS1441.RSC.HUMAD.COM', 'LOUAPPWTS1442.RSC.HUMAD.COM')
    'WQ1' = 'LOUAPPWQS1151.RSC.HUMAD.COM'
    'SQ1' = 'LOUAPPWQS1150.RSC.HUMAD.COM'
    'WP1' = 'LOUAPPWPS1658.RSC.HUMAD.COM'
    'SP1' = 'LOUAPPWPS1825.RSC.HUMAD.COM'
}

$Results = @{ }

Function ConvertTo-NTAccount {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$SID
    )
    $NTAccountSID = New-Object -TypeName 'System.Security.Principal.SecurityIdentifier' -ArgumentList $SID
    $NTAccount = $NTAccountSID.Translate([Security.Principal.NTAccount])
    Write-Output -InputObject $NTAccount
}
#endregion

Function Get-UserProfiles {
    ## Get the User Profile Path, User Account Sid, and the User Account Name for all users that log onto the machine
    [string]$UserProfileListRegKey = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList'
    Get-ChildItem -LiteralPath $UserProfileListRegKey -ErrorAction 'Stop' |
        ForEach-Object {
            Get-ItemProperty -LiteralPath $_.PSPath -ErrorAction 'Stop' | Where-Object { $_.ProfileImagePath -and $_.ProfileImagePath -notmatch 'defaultuser0' } |
            Select-Object @{ Label = 'NTAccount'; Expression = { $(ConvertTo-NTAccount -SID $_.PSChildName).Value } }, @{ Label = 'SID'; Expression = { $_.PSChildName } }, @{ Label = 'ProfilePath'; Expression = { $_.ProfileImagePath } } | Where-Object { @('S-1-5-18', 'S-1-5-19', 'S-1-5-20') -notcontains $_.SID }
    }
}

$UserProfiles = Get-UserProfiles
ForEach ($UserProfile in $UserProfiles) {
    Try {
        #  Set the path to the user's registry hive when it is loaded
        [string]$UserRegistryPath = "Registry::HKEY_USERS\$($UserProfile.SID)"
                    
        #  Set the path to the user's registry hive file
        [string]$UserRegistryHiveFile = Join-Path -Path $UserProfile.ProfilePath -ChildPath 'NTUSER.DAT'
                    
        #  Load the User profile registry hive if it is not already loaded because the User is logged in
        [boolean]$ManuallyLoadedRegHive = $false
        If (-not (Test-Path -LiteralPath $UserRegistryPath)) {
            #  Load the User registry hive if the registry hive file exists
            If (Test-Path -LiteralPath $UserRegistryHiveFile -PathType 'Leaf') {
                [string]$HiveLoadResult = & reg.exe load "`"HKEY_USERS\$($UserProfile.SID)`"" "`"$UserRegistryHiveFile`""
                            
                If ($global:LastExitCode -ne 0) {
                    Throw "Failed to load the registry hive for User [$($UserProfile.NTAccount)] with SID [$($UserProfile.SID)]. Failure message [$HiveLoadResult]. Continue..."
                }
                            
                [boolean]$ManuallyLoadedRegHive = $true
            }
            Else {
                Throw "Failed to find the registry hive file [$UserRegistryHiveFile] for User [$($UserProfile.NTAccount)] with SID [$($UserProfile.SID)]. Continue..."
            }
        }
        try {
            $PerUserPath = [string]::Format('{0}\Software\Microsoft\ConfigMgr10\AdminUI\MRU', $UserRegistryPath)
            if (Test-Path -Path $PerUserPath) {
                $ALL = Get-ChildItem -Path $PerUserPath
                $UserSiteServerConnections = foreach ($Path in $ALL.Name) {
                    $RegPath = [string]::Format('registry::{0}', $Path)
                    $SiteServerConnection = Get-ItemProperty -Path $RegPath 
                    [pscustomobject]@{
                        ServerName = $SiteServerConnection.ServerName
                        SiteCode   = $SiteServerConnection.SiteCode
                        SiteName   = $SiteServerConnection.SiteName
                        RegPath    = $RegPath
                    }
                }

                switch ($UserSiteServerConnections) {
                    # if the registry entry for the servername does not match the hash table above based on sitecode, remediate or return $false as requested
                    { $_.ServerName -notin $SiteCodeToSiteServer[$($_.SiteCode)] -and $_.SiteCode -in $SiteCodeToSiteServer.Keys } {
                        # gather the path and server that needs set for each instance
                        $RegPathToUpdate = $_.RegPath
                        $ServerToSet = $SiteCodeToSiteServer[$($_.SiteCode)] | Select-Object -First 1
                        switch ($Remediate) {
                            $true {
                                Set-ItemProperty -Path $RegPathToUpdate -Name ServerName -Value $ServerToSet
                                $Results[$($UserProfile.NTAccount)] = $true
                            }
                            $false {
                                $Results[$($UserProfile.NTAccount)] = $false
                            }
                        }
                    }
                }
            }
            else {
                $Results[$($UserProfile.NTAccount)] = $true
            }
            

        }
        catch {
            $Results[$($UserProfile.NTAccount)] = $true
        }
    }
    Catch {
    }
    Finally {
        If ($ManuallyLoadedRegHive) {
            Try {
                $null = Start-Process -FilePath 'reg.exe' -ArgumentList 'unload', "`"HKEY_USERS\$($UserProfile.SID)`"" -NoNewWindow -RedirectStandardOutput ([guid]::NewGuid()).Guid -RedirectStandardError ([guid]::NewGuid()).Guid
                            
                If ($global:LastExitCode -ne 0) {
                    [GC]::Collect()
                    [GC]::WaitForPendingFinalizers()
                    Start-Sleep -Seconds 5
                                
                    $null = Start-Process -FilePath 'reg.exe' -ArgumentList 'unload', "`"HKEY_USERS\$($UserProfile.SID)`"" -NoNewWindow -RedirectStandardOutput ([guid]::NewGuid()).Guid -RedirectStandardError ([guid]::NewGuid()).Guid
                    If ($global:LastExitCode -ne 0) {
                        Throw "REG.exe failed with exit code [$($global:LastExitCode)]" 
                    }
                }
            }
            Catch {
            }
        }
    }
}

$Results.Count -ne 0 -and $Results.Values -notcontains $false