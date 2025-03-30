#0x87d01001 - Restart is pending error
Function Test-CMClientIssue {
    $smsCertTB = (Get-Content -Path 'C:\WINDOWS\SMSCFG.ini' | Where-Object { $_ -match 'Certificate Identifier' }) -replace 'SMS Certificate Identifier=SMS;'
    $smsCert = (Get-ChildItem -Path Cert:\LocalMachine\SMS | Where-Object { $_.Thumbprint -eq $smsCertTB }).Subject
    if ($smsCert -notmatch $env:COMPUTERNAME) {
        Get-ChildItem -Path Cert:\LocalMachine\SMS | Where-Object { $_.Thumbprint -eq $smsCertTB } | Remove-Item
        Restart-Service -Name CcmExec
    }
}

Function Remove-RegKey {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [Validateset('HKCR', 'HKCU', 'HKLM', 'HKUS', 'HKCC')]
        [string]$hive,

        [Parameter(Mandatory = $true)]
        [string]$key,

        [Parameter(Mandatory = $false)]
        [Int32]$retries = 10
    )
    Switch ($hive) {
        'HKCR' { $hiveName = 'HKEY_CLASSES_ROOT' }
        'HKCU' { $hiveName = 'HKEY_CURRENT_USER' }
        'HKLM' { $hiveName = 'HKEY_LOCAL_MACHINE' }
        'HKUS' { $hiveName = 'HKEY_USERS' }
        'HKCC' { $hiveName = 'HKEY_CURRENT_CONFIG' }
    }
    $count = 0
    While ($count -lt $retries -and (Test-Path -Path "$($hive):$($key)" -ErrorAction SilentlyContinue)) {
        $count++
        $dirs = Get-ChildItem -Path "$($hive):$($key)" -Recurse | Select-Object -Property Name
        foreach ($dir in $dirs) {
            $keyPath = $dir.Name -replace "$($hiveName)\\", ''
            Write-Log -Message "Taking Ownership of $keyPath"
            Set-RegKeyOwner -hive $hive -key -$keyPath
            Write-Log -Message "Removing $keyPath"
            Remove-Item "$($hive):$($key)" -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

Function Set-RegKeyOwner {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false)]
        [string]$ComputerName = 'localhost',

        [Parameter(Mandatory = $true)]
        [Validateset('HKCR', 'HKCU', 'HKLM', 'HKUS', 'HKCC')]
        [string]$hive,

        [Parameter(Mandatory = $true)]
        [string]$key
    )
    Write-Log -Message "Set Hive"
    switch ($hive) {
        'HKCR' { $reg = [Microsoft.Win32.Registry]::ClassesRoot }
        'HKCU' { $reg = [Microsoft.Win32.Registry]::CurrentUser }
        'HKLM' { $reg = [Microsoft.Win32.Registry]::LocalMachine }
        'HKUS' { $reg = [Microsoft.Win32.Registry]::Users }
        'HKCC' { $reg = [Microsoft.Win32.Registry]::CurrentConfig }
    }

    $permchk = [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree
    $regrights = [System.Security.AccessControl.RegistryRights]::ChangePermissions

    Write-Log -Message "Open Key ($key) and get access control"
    $regkey = $reg.OpenSubKey($key, $permchk, $regrights)
    $rs = $regkey.GetAccessControl()

    Write-Log -Message 'Create security principal'
    $user = New-Object -TypeName Security.Principal.NTaccount -ArgumentList 'Administrators'

    $rs.SetGroup($user)
    $rs.SetOwner($user)
    $regkey.SetAccessControl($rs)
}

Function Get-CmClientInfo {
    [CmdletBinding(ConfirmImpact = 'Low')]

    Param(
        [Parameter(Mandatory = $true, HelpMessage = 'Site client is to be installed in')]
        [ValidateSet('SP1', 'SQ1', 'WP1', 'WQ1', 'MT1')]
        [string]$site
    )

    begin {
        #Create a hashtable with your output info
        $returnHashTable = @{ }

        #Hash Tables
        $siteServers = @{
            'SP1' = ('LOUAPPWPS1740.rsc.humad.com', 'LOUAPPWPS1741.rsc.humad.com', 'LOUAPPWPS1821.rsc.humad.com', 'LOUAPPWPS1822.rsc.humad.com', 'GRBAPPWPS12.rsc.humad.com');
            'SQ1' = ('LOUAPPWQS1020.rsc.humad.com', 'LOUAPPWQS1021.rsc.humad.com', 'LOUAPPWQS1022.rsc.humad.com');
            'WP1' = ('LOUAPPWPS1642.rsc.humad.com', 'LOUAPPWPS1643.rsc.humad.com', 'LOUAPPWPS1644.rsc.humad.com', 'LOUAPPWPS1645.rsc.humad.com', 'LOUAPPWPS1646.rsc.humad.com', 'LOUAPPWPS1647.rsc.humad.com', 'LOUAPPWPS1648.rsc.humad.com', 'LOUAPPWPS1649.rsc.humad.com', 'LOUAPPWPS1653.rsc.humad.com', 'LOUAPPWPS1654.rsc.humad.com', 'LOUAPPWPS1655.rsc.humad.com', 'LOUAPPWPS1656.rsc.humad.com', 'LOUAPPWPS1657.rsc.humad.com');
            'WQ1' = ('LOUAPPWQS1023.rsc.humad.com', 'LOUAPPWQS1024.rsc.humad.com', 'LOUAPPWQS1025.rsc.humad.com');
            'MT1' = ('LOUAPPWTS1150.rsc.humad.com', 'LOUAPPWTS1151.rsc.humad.com', 'LOUAPPWTS1152.rsc.humad.com');
        }

        #-----Parameters nomad installs will use-----#
        #Common parameters used by all installs.
        $nomadParams = @(
            "/qn",
            "CacheCleanCycleHrs=168",
            "COMPATIBILITYFLAGS=1572864",
            "MaxCacheDays=60",
            "MaxPreCacheDays=0",
            "MaxSUCacheDays=60",
            "MAXLOGSIZE=5242880",
            "NOMADINHIBITEDSUBNETS=`"133.17.0.0/16,10.94.0.0/16,133.200.0.0/16,133.201.0.0/16,193.65.240.0/23,193.65.242.0/23,193.201.14.0/23,193.201.16.0/23,193.201.18.0/23,193.201.20.0/23,193.201.22.0/23,193.201.24.0/23,193.201.10.0/23,193.201.12.0/23,193.193.2.0/23,193.193.1.0/23,10.52.0.0/14,10.60.0.0/14`"",
            "P2PENABLED=9",
            "PIDKEY=HUMNOM6-64RB-1ILL-9EBL-7UVF",
            "PLATFORMURL=http://ActiveEfficiency.humana.com/ActiveEfficiency",
            "SuccessCodes=0x206b,0x2077,0x103,0xffffffff,0x1,0x70,0x2050,0x2051,0x2052,0x2053,0x2054,0x2055,0x2056,0x2057,0x2058,0x205a,0x205b,0x205c,0x205d,0x205e,0x2060,0x2061,0x2062,0x2063,0x2064,0x2065,0x2066,0x2067,0x2068,0x2069,0x9999"
        )

        #Additional switches for standard workstations. (in adddtion to $params)
        $wkstn = @(
            "CONTENTREGISTRATION=1",
            "LOGPATH=C:\Windows\CCM\Logs",
            "MAXALLOCREQUEST=61440",
            "MAXIMUMMEGABYTE=61440",
            "MULTICASTSUPPORT=0",
            "PERCENTAVAILABLEDISK=3",
            "SPECIALNETSHARE=8256",
            "SSDENABLED=3",
            "SSPBAENABLED=0"
        )

        #Switches for OSD Masters. (in addition to $parms)
        $OSD = @(
            "CACHEPATH=F:\NomadCache"
            "CONTENTREGISTRATION=1",
            "LOGPATH=C:\Windows\CCM\Logs",
            "MAXALLOCREQUEST=61440",
            "MAXIMUMMEGABYTE=61440",
            "MULTICASTSUPPORT=0",
            "PERCENTAVAILABLEDISK=3",
            "SPECIALNETSHARE=8256",
            "SSDENABLED=3",
            "SSPBAENABLED=0"
        )
		 
        #Switches for distribution points.
        $DP = @(
            "INSTALLDIR=""D:\Program Files\1E\NomadBranch"""
            "LOGPATH=D:\SMS_CCM\Logs",
            "MULTICASTSUPPORT=0"
        )

        #defaults
        $ccmCacheDir = 'C:\Windows\CcmCache'
        $ccmCacheSize = 5120
        $ccmLogDir = 'C:\Windows\CCM\Logs'
        $doInstallNomad = $false
        $doInstallShopping = $false
        $isCcmClientInstalled = $false
        $isNomadInstalled = $false
        $isOSDmaster = $false
        $isSiteServer = $false
        $isSiteSystem = $false
        $isVirtual = $false
        $isWorkstation = $false

        #Note currently installed drives
        $drives = [Array](Get-WmiObject -Class Win32_LogicalDisk -ErrorAction SilentlyContinue | Where-Object { $_.DriveType -eq 3 } | Sort-Object -Property FreeSpace -Descending).DeviceID

        #Virtual?
        $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction SilentlyContinue
        If ($computerSystem.Model -eq 'VMware Virtual Platform' -or $computerSystem.Model -eq 'Virtual Machine') {
            Write-Log -Message 'This is a virtual machine'
            $isVirtual = $true
        }
        else {
            Write-Log -Message 'This machine is not a virtual machine'
        }

        # Is NomadBranch installed?
        Write-Log -Message 'Determinig if NomadBranch is installed, and what version'
        if (Test-Path -Path 'HKLM:SOFTWARE\1E\NomadBranch' -ErrorAction SilentlyContinue) {
            Write-Log -Message 'We have a NomadBranch key, getting version'
            $nomadBranchVersion = Get-RegistryKey -Key 'HKLM:SOFTWARE\1E\NomadBranch' -Value ProductVersion
            Write-Log -Message "NomadBranch version = $nomadBranchVersion"
            $isNomadInstalled = $true
        }
        else {
            Write-Log -Message 'NomadBranch is not installed'
            $nomadBranchVersion = ''
        }

        #Is SCCM client installed and what site if so?
        try {
            $assignedsiteCode = (Invoke-WmiMethod -Class SMS_Client -Namespace root\ccm -Name GetAssignedSite -ErrorAction SilentlyContinue).ssiteCode
            if ($assignedsiteCode) {
                Write-Log -Message "SCCM client is installed and assigned to site $assignedsiteCode"
                $isCcmClientInstalled = $true
            }
            else {
                Write-Log -Message "SCCM Client is not installed."
            }
        }

        catch {
            Write-Log -Message "Unable to determine if SCCM Client is installed" -Severity 3
        }

        #Get OS info
        $os = Get-WmiObject -Class Win32_OperatingSystem -ErrorAction SilentlyContinue
    }

    process {
        if ($os.ProductType -eq 1) {
            Write-Log -Message 'Workstation OS, checking if Virtual or OSD Master'
            $isWorkstation = $true
            if ($site -match '[WM][PQT]1') { $doInstallShopping = $true }
            if ($isVirtual) {
                Write-Log  -Message 'It''s virtual, checking for B: drive'
                if ($drives.Contains('B:')) {
                    Write-Log -Message 'There is a B: drive, setting ccmCacheDir to B:\CcmCache'
                    $ccmCacheDir = 'B:\CcmCache'
                }
                else {
                    Write-Log -Message 'No B: Drive'
                }
            }
            elseif ($env:COMPUTERNAME -match '...PXE.*') {
                Write-Log -Message 'This is an OSD Master, setting CCMCache to 409600 (400GB) and ccmCacheDir to F:\CCMCache'
                $isOSDmaster = $true
                $ccmCacheSize = 409600
                $ccmCacheDir = 'F:\CcmCache'
                $doInstallNomad = $true
                $nomadParams += $OSD
            }
            else {
                Write-Log -Message 'Physical Workstation, setting CCMCache to 51200 (50GB)'
                $ccmCacheSize = 51200
                $doInstallNomad = $true
                $nomadParams += $wkstn
            }
        }
        else {
            Write-Log -Message 'We are on a server, checking first if we are installing on a site system when we should not'
            if ((Measure-Object -InputObject (Get-Service SMS_Executive -ErrorAction SilentlyContinue)).Count -ne 0) {
                Write-Log -Message 'This is a Site System' -Severity 2
                $isSiteSystem = $true
                Write-Log -Message 'Installing on Site System, setting ccmCacheDir to D:\CCMCache'
                $ccmCacheDir = 'D:\CcmCache'
                if ((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\SMS\DP\' -Name ContentLibraryPath -ErrorAction SilentlyContinue) -and $site -notmatch 'S[PQ]1') {
                    Write-Log -Message 'Installing on DP, setting install of Nomad Branch'
                    $doInstallNomad = $true
                    $nomadParams += $DP
                }
                elseif ((Get-WmiObject -Class SMS_ProviderLocation -Namespace root\sms -ErrorAction SilentlyContinue).siteCode -ne '') { $isSiteServer = $true }
            }
            if ($computerSystem.Domain -eq 'ts.humad.com' -or $computerSystem.Domain -eq 'tmt.loutms.tree') {
                Write-Log -Message 'Machine in Citrix domain, checking if Server 2016'
                if ($os.Caption -match 'Server 2016') {
                    Write-Log -Message 'We have a 2016 Citrix server, setting ccmCacheDir to D:\Persistent\CCMCache and CcmLogs to D:\Persistent\CCM\Logs'
                    $ccmCacheDir = 'D:\Persistent\CCM\CcmCache'
                    $ccmLogDir = 'D:\Persistent\CCM\Logs'
                }
                else {
                    Write-Log -Message 'checking if persistent or non-persistent'
                    if ((($computerSystem.Name -notmatch '...[CX][MA][FH].*' -or $computerSystem.Name -match '...[CX][MA][ABCDFLNSPX].....S.*')) -and $computerSystem.Name -notmatch '......WP[VU].*') {
                        Write-Log -Message 'This is a Citrix persistent server, setting ccmCacheDir to D:\Program Files\CCM\CCMCache and logs to D:\Program Files\CCM\Logs'
                        $ccmCacheDir = 'D:\Program Files\CCM\CcmCache'
                        $ccmLogDir = 'D:\Program Files\CCM\Logs'
                    }
                    else {
                        Write-Log -Message 'This is a Citrix non-persistent server, setting ccmCacheDir to E:\Persistent\CCMCache and CcmLogs to E:\Persistent\CCM\Logs'
                        $ccmCacheDir = 'E:\Persistent\CCM\CcmCache'
                        $ccmLogDir = 'E:\Persistent\CCM\Logs'
                    }
                }
            }
            elseif ($computerSystem.Name -match '............c.*') {
                Write-Log -Message 'This is a cluster server determining CcmCache drive'
                foreach ($drive in $drives) {
                    if ($drive -match '[CD]:') {
                        $ccmCacheDrive = $drive
                        break
                    }
                }
                if ($ccmCacheDrive -eq 'D:') {
                    Write-Log -Message 'Setting ccmCacheDir to D:\CCMCache'
                    $ccmCacheDir = 'D:\CcmCache'
                }
                else {
                    Write-Log -Message 'Leaving ccmCacheDir as C:\Windows\CCMCache'
                }
            }
            else {
                if ($drives[0] -eq 'C:') {
                    Write-Log -Message 'Standard Server, leaving ccmCacheDir as C:\Windows\CCMCache'
                    $ccmCacheDir = 'C:\Windows\CcmCache'
                }
                else {
                    $ccmCacheDir = "$($drives[0])\CcmCache"
                    Write-Log -Message "Standard Server, setting CcmCache to $ccmCacheDir"
                }
            }
        }
        $nomadString = ''
        foreach ($value in $nomadParams) {
            $nomadString = "$nomadString $value"
        }
        $nomadString = $nomadString.Substring(1)
        $returnHashTable.Add('assignedsiteCode', $assignedsiteCode)
        Write-Log -Message "assignedsiteCode = $assignedsiteCode"
        $returnHashTable.Add('ccmCacheDir', $ccmCacheDir)
        Write-Log -Message "ccmCacheDir = $ccmCacheDir"
        $returnHashTable.Add('ccmCacheSize', $ccmCacheSize)
        Write-Log -Message "ccmCacheSize = $ccmCacheSize"
        $returnHashTable.Add('ccmLogDir', $ccmLogDir)
        Write-Log -Message "ccmLogDir = $ccmLogDir"
        $returnHashTable.Add('doInstallNomad', $doInstallNomad)
        Write-Log -Message "doInstallNomad = $doInstallNomad"
        $returnHashTable.Add('doInstallShopping', $doInstallShopping)
        Write-Log -Message "doInstallShopping = $doInstallShopping"
        $returnHashTable.Add('isCcmClientInstalled', $isCcmClientInstalled)
        Write-Log -Message "isCcmClientInstalled = $isCcmClientInstalled"
        $returnHashTable.Add('isNomadInstalled', $isNomadInstalled)
        Write-Log -Message "isNomadInstalled = $isNomadInstalled"
        $returnHashTable.Add('isOSDMaster', $isOSDmaster)
        Write-Log -Message "isOSDMaster = $isOSDmaster"
        $returnHashTable.Add('isSiteServer', $isSiteServer)
        Write-Log -Message "isSiteServer = $isSiteServer"
        $returnHashTable.Add('isSiteSystem', $isSiteSystem)
        Write-Log -Message "isSiteSystem = $isSiteSystem"
        $returnHashTable.Add('isVirtual', $isVirtual)
        Write-Log -Message "isVirtual = $isVirtual"
        $returnHashTable.Add('isWorkstation', $isWorkstation)
        Write-Log -Message "isWorkstation = $isWorkstation"
        $returnHashTable.Add('nomadBranchVersion', $nomadBranchVersion)
        Write-Log -Message "nomadBranchVersion = $nomadBranchVersion"
        $returnHashTable.Add('nomadParams', $nomadString)
        Write-Log -Message "nomadParams = $nomadString"
        $returnHashTable.Add('site', $site)
        Write-Log -Message "site = $site"
        $returnHashTable.Add('siteServers', $siteServers[$site])
        Write-Log -Message "siteServers = $($siteServers[$site])"
    }

    End {
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.ClientInfo')
        Return $obj	
    }
} #End Get-CMNClientInfo

Function Get-CmSiteAndMP {
    [CmdletBinding(ConfirmImpact = 'Low')]
    PARAM()
    begin {
        #Create a hashtable with your output info
        $returnHashTable = @{ }
    }

    process {
        try {
            $client = New-Object -ComObject Microsoft.SMS.Client -ErrorAction SilentlyContinue
            $returnHashTable.Add('SiteCode', $client.GetAssignedSite())
            $returnHashTable.Add('MP', $client.GetCurrentManagementPoint())
        }
        catch {
            $returnHashTable.Add('SiteCode', 'None')
            $returnHashTable.Add('MP', 'None')
        }
    }

    End {
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.CmSiteAndMP')
        Return $obj	
    }
} #End Get-CmSiteAndMP

Function Remove-CmClient {
    Write-Log -Message 'Cleaning old client'
    $ccmCacheDir = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\ccm\Logging\@Global -ErrorAction SilentlyContinue).LogDirectory 
    Remove-CmClientAssignment

    Write-Log -Message 'Beginning uninstallation. Client will be uninstalled'
    Execute-Process -FilePath "$dirfiles\SCCMClient\ccmsetup.exe" -Arguments '/Uninstall'

    #Delete SMSConfig.ini
    Write-Log -Message 'Deleting C:\Windows\SMSCFG.ini'
    if (Test-Path 'C:\Windows\SMSCFG.ini') { Remove-Item -Path 'C:\Windows\SMSCFG.ini' -Force -ErrorAction SilentlyContinue }

    #Delete CCM and CCMSetup Directories
    Write-Log -Message 'Deleting C:Windows\CCMSetup and C:\Windows\CCM directories'
    ('C:\Windows\CCM', 'C:\Windows\CCMSetup') | ForEach-Object { if (Test-Path $_) { Remove-Item -Path $_ -Recurse -Force -ErrorAction SilentlyContinue } }

    #Delete CCMCacheDir
    if ($null -ne $ccmCacheDir -and $ccmCacheDir -ne '') {
        Write-Log -Message "Deleting $ccmCacheDir"
        if (Test-Path $ccmCacheDir) { Remove-Item -Path $ccmCacheDir -Recurse -Force -ErrorAction SilentlyContinue }
    }
} #End Remove-CmClient

Function Remove-CmClientAssignment {
    #Delete WMI classes
    Write-Log -Message 'Removing WMI information'
    Get-WmiObject -Namespace root\ccm -List -ErrorAction SilentlyContinue | ForEach-Object { Get-WmiObject -Namespace root\ccm -Class $_.Name -ErrorAction SilentlyContinue | Remove-WmiObject -ErrorAction SilentlyContinue }
    Get-WmiObject -query "Select * From __Namespace Where Name='CCM'" -Namespace root -ErrorAction SilentlyContinue | Remove-WmiObject -ErrorAction SilentlyContinue
    Get-WmiObject -query "Select * From __Namespace Where Name='SMSDM'" -Namespace root -ErrorAction SilentlyContinue | Remove-WmiObject -ErrorAction SilentlyContinue

    #Delete Registry
    Write-Log -Message 'Removing registry information'
    Remove-Item -Path HKLM:\SOFTWARE\Microsoft\CCMSetup -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path HKLM:\SOFTWARE\Microsoft\CCM -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path HKLM:\SOFTWARE\Microsoft\SMS -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path HKLM:\SOFTWARE\Wow6432Node\Microsoft\CCMSetup -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path HKLM:\SOFTWARE\Wow6432Node\Microsoft\CCM -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path HKLM:\SOFTWARE\Wow6432Node\Microsoft\SMS -Recurse -Force -ErrorAction SilentlyContinue

    #Delete Certs
    Write-Log -Message 'Deleting SMS Certificates'
    Get-ChildItem Cert:\LocalMachine\SMS | Where-Object { $_.Subject -match '^CN=SMS, ' } | Remove-Item -ErrorAction SilentlyContinue
} #End Remove-CmClientAssignment

Function Reset-CmPolicies {
    Invoke-WmiMethod -Namespace root\ccm -Class sms_client -Name ResetPolicy -ArgumentList 1 -ErrorAction SilentlyContinue | Out-Null
} #End Reset-CmPolicies

Function Invoke-ClientScans {
    #Machine Policy Update
    Write-Log -Message 'Firing off Machine Policy Update and sleeping for 90 seconds'
    Invoke-CimMethod -ClassName SMS_Client -Namespace root\ccm -MethodName TriggerSchedule -Arguments @{sScheduleID = '{00000000-0000-0000-0000-000000000021}' } | Out-Null
    Start-Sleep -Seconds 90
    #Software Updates Deployment Evaluation Cycle
    Write-Log -Message 'Firing Software Update Deployment Evaluation Cycle'
    Invoke-CimMethod -ClassName SMS_Client -Namespace root\ccm -MethodName TriggerSchedule -Arguments @{sScheduleID = '{00000000-0000-0000-0000-000000000108}' } | Out-Null
    #Softwre Updates Scan Cycle
    Write-log -Message 'Firing off Software Update Scan Cycle'
    Invoke-CimMethod -ClassName SMS_Client -Namespace root\ccm -MethodName TriggerSchedule -Arguments @{sScheduleID = '{00000000-0000-0000-0000-000000000113}' } | Out-Null
}

Function Set-CmCacheDir {
    PARAM([String]$ccmCacheDir)
    begin {
        $cache = Get-WmiObject -Namespace 'root/CCM/SoftMgmtAgent' -Class CacheConfig
        Write-Log -message "Cleaning up ccmCachedir ($ccmCacheDir)"
        if ($ccmCacheDir -match '\\\\') { $ccmCacheDir = $ccmCacheDir -replace '\\\\', '\' }
        #Confirming a good directory
        #Make sure it doesn't have a double ccmcache directory
        if ($ccmCacheDir -match 'ccmcache\\ccmcache[\\]?$') {
            Write-Log "Variable ends in 'CcmCache\CcmCache', need to fix"
            $ccmCacheDir = $ccmCacheDir -replace 'ccmcache\\ccmcache', 'CcmCache' #remove ccmcache directory
        }
        if ($cache -eq "$ccmCacheDir") {
            Write-Log -Message "CcmCache already set. ($cache = $($ccmCacheDir)"
            return
        }
    }
    process {
        Write-Log -Message "Current cache dir is $($cache.Location), need to change to $($ccmCacheDir)"
        Write-Log -Message "Making sure $($ccmCacheDir) exists."
        if (!(Test-Path -Path ("$ccmCacheDir"))) {
            Write-Log -Message "Path does not exist, creating"
            [System.IO.Directory]::CreateDirectory("$ccmCacheDir") | Out-Null
        }
        Write-Log -Message "Setting cache dir to $($ccmCacheDir)"
        $cache.Location = $CCMCacheDir
    }
    end {
        $cache.Put() | Out-Null
        $cache.Get()
        #Make sure it doesn't have a double ccmcache directory
        if ($cache.Location -match 'ccmcache\\ccmcache[\\]?$') {
            Write-Log "Cache ends in 'CcmCache\CcmCache', need to fix"
            $cache.Location = $cache.Location -replace 'ccmcache\\ccmcache', 'CcmCache' #remove ccmcache directory
            $cache.Put() | Out-Null
        }
    }
} #End Set-CmCacheDir

Function Set-CmLogDirectory {
    PARAM([String]$ccmLogDir)

    Write-Log -Message 'Stopping CcmExec'
    Stop-Service CcmExec
    Write-Log -Message "Making sure $CCMLogDir exists."
    if (!(Test-Path -Path ($CCMLogDir))) {
        Write-Log -Message "Path does not exist, creating"
        [System.IO.Directory]::CreateDirectory($CCMLogDir) | Out-Null
    }
    Write-Log -Message "Setting log directory in registry to $CCMLogDir"
    Set-RegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\CCM\Logging\@Global' -Name 'LogDirectory' -Type String -Value $CCMLogDir
    Write-Log -Message 'Starting CcmExec'
    Start-Service CcmExec
} #End Set-CmLogDirectory

Function Set-CmSiteAndMP {
    [CmdletBinding(ConfirmImpact = 'Low')]
    Param(
        [Parameter(Mandatory = $false)]
        $siteCode = 'WP1'
    )

    begin {
        #Create a hashtable with your output info
        $returnHashTable = @{ }

        Switch ($siteCode) {
            'MT1' { $MP = 'LOUAPPWTS1150.rsc.humad.com' }
            'SP1' { $MP = 'LOUAPPWPS1740.rsc.humad.com' }
            'SQ1' { $MP = 'LOUAPPWQS1020.rsc.humad.com' }
            'WP1' { $MP = 'LOUAPPWPS1642.rsc.humad.com' }
            'WQ1' { $MP = 'LOUAPPWQS1023.rsc.humad.com' }
        }
    }

    process {
        $client = New-Object -ComObject Microsoft.SMS.Client
        try {
            $returnHashTable.Add('OldSiteCode', $client.GetAssignedSite())
            $returnHashTable.Add('OldMP', $client.GetCurrentManagementPoint())
        }
        catch {
            $returnHashTable.Add('OldSiteCode', 'None')
            $returnHashTable.Add('OldMP', 'None')
        }
        $client.SetAssignedSite($siteCode)
        $client.SetCurrentManagementPoint($mp)
        Restart-Service -Name CCMExec -ErrorAction SilentlyContinue
    }

    End {
        $client = New-Object -ComObject Microsoft.SMS.Client
        $returnHashTable.Add('NewSiteCode', $client.GetAssignedSite())
        $returnHashTable.Add('NewMP', $client.GetCurrentManagementPoint())
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.ObjectType')
        Return $obj	
    }
} #End Set-CmSiteAndMP

Function Set-CmCacheSize {
    [CmdletBinding(ConfirmImpact = 'Low')]
    param(
        [int]$cachesize = 51200
    )

    $cache = Get-WmiObject -Namespace root\ccm\SoftMgmtAgent -Class CacheConfig

    Write-Log -Message "Current SCCM Cache Size:$($cache.size)MB."

    if ($Cache.Size -ne $cachesize) {
        Write-Log -Message "Changing SCCM Cache Size to $cachesize MB..."
        $cache.Size = $cachesize
        $cache.Put() | Out-Null
        Write-Log -Message "Restarting CCMEXEC service..." 
        Restart-Service ccmexec
        Write-Log -Message "Current SCCM Cache Size: $($cache.size)"
    }
    else {
        Write-Log -Message "Cache size is correct!"
    }
}