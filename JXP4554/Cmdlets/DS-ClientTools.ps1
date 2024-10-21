Function Get-CmClientInfo {
    [CmdletBinding(ConfirmImpact = 'Low')]

    Param(
        [Parameter(Mandatory = $true, HelpMessage = 'Site client is to be pointed to')]
        [ValidateSet('SP1', 'SQ1', 'WP1', 'WQ1', 'MT1')]
        [string]$site
    )

    begin {
        #Create a hashtable with your output info
        $returnHashTable = @{}

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
        $ccmCacheDir = 'C:\Windows\'
        $ccmCacheSize = 5120
        $ccmLogDir = 'C:\Windows\CCM\Logs'
        $doInstallNomad = $false
        $isCcmClientInstalled = $false
        $isNomadInstalled = $false
        $isOSDmaster = $false
        $isSiteServer = $false
        $isSiteSystem = $false
        $isVirtual = $false
        $isWorkstation = $false

        #Note currently installed drives
        $drives = [Array](Get-WmiObject -Class Win32_LogicalDisk -ErrorAction SilentlyContinue | Where-Object {$_.DriveType -eq 3} | Sort-Object -Property FreeSpace -Descending).DeviceID

        #Virtual?
        $computerSystem = Get-Ciminstance -ClassName Win32_ComputerSystem -ErrorAction SilentlyContinue
        If ($computerSystem.Model -eq 'VMware Virtual Platform' -or $computerSystem.Model -eq 'Virtual Machine') {
            Write-Output 'This is a virtual machine'
            $isVirtual = $true
        }
        else {
            Write-Output 'This machine is not a virtual machine'
        }

        #Is NomadBranch installed?
        Write-Output 'Determinig if NomadBranch is installed, and what version'
        if (Test-Path -Path 'HKLM:SOFTWARE\1E\NomadBranch' -ErrorAction SilentlyContinue) {
            Write-Output 'We have a NomadBranch key, getting version'
            $nomadBranchVersion = Get-RegistryKey -Key 'HKLM:SOFTWARE\1E\NomadBranch' -Value ProductVersion
            Write-Output "NomadBranch version = $nomadBranchVersion"
            $isNomadInstalled = $true
        }
        else {
            Write-Output 'NomadBranch is not installed'
            $nomadBranchVersion = ''
        }

        #Is SCCM client installed and what site if so?
        try {
            $assignedsiteCode = (Invoke-WmiMethod -Class SMS_Client -Namespace root\ccm -Name GetAssignedSite -ErrorAction SilentlyContinue).ssiteCode
            if ($assignedsiteCode) {
                Write-Output "SCCM client is installed and assigned to site $assignedsiteCode"
                $isCcmClientInstalled = $true
            }
            else {
                Write-Output "SCCM Client is not installed."
            }
        }

        catch {
            Write-Output "Unable to determine if SCCM Client is installed" -Severity 3
        }

        #Get OS info
        $os = Get-WmiObject -Class Win32_OperatingSystem -ErrorAction SilentlyContinue
    }

    process {
        if ($os.ProductType -eq 1) {
            Write-Output 'Workstation OS, checking if Virtual or OSD Master'
            $isWorkstation = $true
            if ($isVirtual) {
                Write-Log  -Message 'It''s virtual, checking for B: drive'
                if ($drives.Contains('B:')) {
                    Write-Output 'There is a B: drive, setting ccmCacheDir to B:\CcmCache'
                    $ccmCacheDir = 'B:\'
                }
                else {
                    Write-Output 'No B: Drive'
                }
            }
            elseif ($env:COMPUTERNAME -match '...PXE.*') {
                Write-Output 'This is an OSD Master, setting CCMCache to 409600 (400GB) and ccmCacheDir to F:\CCMCache'
                $isOSDmaster = $true
                $ccmCacheSize = 409600
                $ccmCacheDir = 'F:\'
                $doInstallNomad = $true
                $nomadParams += $OSD
            }
            else {
                Write-Output 'Physical Workstation, setting CCMCache to 51200 (50GB)'
                $ccmCacheSize = 51200
                $doInstallNomad = $true
                $nomadParams += $wkstn
            }
        }
        else {
            Write-Output 'We are on a server, checking first if we are installing on a site system when we should not'
            if ((Measure-Object -InputObject (Get-Service SMS_Executive -ErrorAction SilentlyContinue)).Count -ne 0) {
                Write-Output 'This is a Site System' -Severity 2
                $isSiteSystem = $true
                Write-Output 'Installing on Site System, setting ccmCacheDir to D:\CCMCache'
                $ccmCacheDir = 'D:\'
                if ((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\SMS\DP\' -Name ContentLibraryPath -ErrorAction SilentlyContinue) -and $site -notmatch 'S[PQ]1') {
                    Write-Output 'Installing on DP, setting install of Nomad Branch'
                    $doInstallNomad = $true
                    $nomadParams += $DP
                }
                elseif ((Get-WmiObject -Class SMS_ProviderLocation -Namespace root\sms -ErrorAction SilentlyContinue).siteCode -ne '') {$isSiteServer = $true}
            }
            if ($computerSystem.Domain -eq 'ts.humad.com' -or $computerSystem.Domain -eq 'tmt.loutms.tree') {
                Write-Output 'Machine in Citrix domain, checking if persistent or non-persistent'
                if ((($computerSystem.Name -notmatch '...[CX][MA][FH].*' -or $computerSystem.Name -match '...[CX][MA][ABCDFLNSPX].....S.*')) -and $computerSystem.Name -notmatch '......WP[VU].*') {
                    Write-Output 'This is a Citrix persistent server, setting ccmCacheDir to D:\Program Files\CCMCache and logs to D:\Program Files\CCM\Logs'
                    $ccmCacheDir = 'D:\Program Files\'
                    $ccmLogDir = 'D:\Program Files\CCM\Logs'
                }
                else {
                    Write-Output 'This is a Citrix non-persistent server, setting ccmCacheDir to E:\Persistent\CCMCache and CcmLogs to E:\Persistent\CCM\Logs'
                    $ccmCacheDir = 'E:\Persistent\'
                    $ccmLogDir = 'E:\Persistent\CCM\Logs'
                }
            }
            elseif ($computerSystem.Name -match '............c.*') {
                Write-Output 'This is a cluster server determining CcmCache drive'
                foreach ($drive in $drives) {
                    if ($drive -match '[CD]:') {
                        $ccmCacheDrive = $drive
                        break
                    }
                }
                if ($ccmCacheDrive -eq 'D:') {
                    Write-Output 'Setting ccmCacheDir to D:\CCMCache'
                    $ccmCacheDir = 'D:\'
                }
                else {
                    Write-Output 'Leaving ccmCacheDir as C:\Windows\CCMCache'
                }
            }
            else {
                if ($drives[0] -eq 'C:') {
                    Write-Output 'Standard Server, leaving ccmCacheDir as C:\Windows\CCMCache'
                    $ccmCacheDir = 'C:\Windows\'
                }
                else {
                    $ccmCacheDir = "$($drives[0])\"
                    Write-Output "Standard Server, setting CcmCache to $ccmCacheDir"
                }
            }
        }
        $nomadString = ''
        foreach ($value in $nomadParams.GetEnumerator()) {
            $nomadString = "$nomadString $value"
        }
        $nomadString = $nomadString.Substring(2)
        $returnHashTable.Add('assignedsiteCode', $assignedsiteCode)
        Write-Output "assignedsiteCode = $assignedsiteCode"
        $returnHashTable.Add('ccmCacheDir', $ccmCacheDir)
        Write-Output "ccmCacheDir = $ccmCacheDir"
        $returnHashTable.Add('ccmCacheSize', $ccmCacheSize)
        Write-Output "ccmCacheSize = $ccmCacheSize"
        $returnHashTable.Add('ccmLogDir', $ccmLogDir)
        Write-Output "ccmLogDir = $ccmLogDir"
        $returnHashTable.Add('doInstallNomad', $doInstallNomad)
        Write-Output "do InstallNomad = $doInstallNomad"
        $returnHashTable.Add('isCcmClientInstalled', $isCcmClientInstalled)
        Write-Output "isCcmClientInstalled = $isCcmClientInstalled"
        $returnHashTable.Add('isNomadInstalled', $isNomadInstalled)
        Write-Output "isNomadInstalled = $isNomadInstalled"
        $returnHashTable.Add('isOSDMaster', $isOSDmaster)
        Write-Output "isOSDMaster = $isOSDmaster"
        $returnHashTable.Add('isSiteServer', $isSiteServer)
        Write-Output "isSiteServer = $isSiteServer"
        $returnHashTable.Add('isSiteSystem', $isSiteSystem)
        Write-Output "isSiteSystem = $isSiteSystem"
        $returnHashTable.Add('isVirtual', $isVirtual)
        Write-Output "isVirtual = $isVirtual"
        $returnHashTable.Add('isWorkstation', $isWorkstation)
        Write-Output "isWorkstation = $isWorkstation"
        $returnHashTable.Add('nomadBranchVersion', $nomadBranchVersion)
        Write-Output "nomadBranchVersion = $nomadBranchVersion"
        $returnHashTable.Add('nomadParams', $nomadString)
        Write-Output "nomadParams = $nomadString"
        $returnHashTable.Add('site', $site)
        Write-Output "site = $site"
        $returnHashTable.Add('siteServers', $siteServers[$site])
        Write-Output "siteServers = $($siteServers[$site])"
    }

    End {
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.ClientInfo')
        Return $obj	
    }
} #End Get-CMNClientInfo

Function Repair-CMNCacheLocation {
    <#
    .SYNOPSIS

    .DESCRIPTION
        All my functions assume you are using the Get-CMNSCCMConnectoinInfo and New-CMNLogEntry functions for these scripts, 
        please make sure you account for that.

    .EXAMPLE

    .LINK
        http://configman-notes.com

    .NOTES
        Author:	    Jim Parris
        Email:	    Jim@ConfigMan-Notes.com
        Date:	    yyyy-mm-dd
        Updated:    
        PSVer:	    3.0
        Version:    1.0.0		
	#>

    [CmdletBinding(ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [String]$computerName,

        [Parameter(Mandatory = $false, HelpMessage = 'Force move, even if on good drive')]
        [Switch]$force
    )

    begin {
        Write-Output 'Starting Function'
        Write-Output "computerName = $computerName"
        Write-Output "logFile = $logFile"
        Write-Output "logEntries = $logEntries"
        Write-Output "maxLogSize = $maxLogSize"
        Write-Output "maxLogHistory = $maxLogHistory"
    }

    process {
        Write-Output 'Beginning process loop'

        try {
            Write-Output "Fixing $computerName"
            $results = New-Object psobject
            Add-Member -InputObject $results -MemberType NoteProperty -Name 'ComputerName' -Value $computerName
            Add-Member -InputObject $results -MemberType NoteProperty -Name 'CurrentCacheLocation' -Value 'UnKnown'
            Add-Member -InputObject $results -MemberType NoteProperty -Name 'CurrentCacheSize' -Value 'UnKnown'
            Add-Member -InputObject $results -MemberType NoteProperty -Name 'UpdatedCacheLocation' -Value 'None'
            Add-Member -InputObject $results -MemberType NoteProperty -name 'UpdatedCacheSize' -Value 'None'
            Add-Member -InputObject $results -MemberType NoteProperty -Name 'Results' -Value 'Error'
            
            #Gather current Cache Location and size
            $cache = Get-WmiObject -Namespace root\ccm\softmgmtagent -Class cacheconfig -ComputerName $computerName
            if ($cache.Location -eq $null) {$cache.Location = 'Z:\Error'}
            $results.CurrentCacheLocation = $cache.Location
            $results.CurrentCacheSize = $cache.Size
            Write-Output "`tCurrent cache location - $($Cache.Location)"
            if ($PSBoundParameters['force']) {
                $cache.Location = 'C:\Temp\'
                $cache.put() | Out-Null
                $cache.get()
                Get-Service -ComputerName $computerName -Name CcmExec | Restart-Service
            }
            $drives = [Array](Get-WmiObject -ComputerName $computerName -Class Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | Sort-Object -Property FreeSpace -Descending).DeviceID
            Write-Output "`tDrives = $drives"
            
            #Time to figure out what we've got
            Write-Output "`tDetermining if virtual"
            $computerSystem = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $computerName
            if ($computerSystem.Model -match 'Virtual') {
                Write-Output "`tThis is a virtual machine"
                $isVirtual = $true
            }
            else {
                Write-Output "`tThis is a physical machine"
                $isVirtual = $false
            }
            
            #What OS are we working with?
            #ProductType 1=Workstation, 2 = DC, 3=Server Ref - https://docs.microsoft.com/en-us/windows/desktop/CIMWin32Prov/win32-operatingsystem
            Write-Output "`tChecking OS"
            $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computerName
            if ($os.ProductType -eq 1) {
                Write-Output "`tThis is a workstation"
                $isWorkstation = $true
            }
            else {
                Write-Output "`tThis is a server"
                $isWorkstation = $false
            }
                   
            #Let's work with workstations first...
            if ($isWorkstation) {
                if ($drives.Contains('B:') -and $isVirtual) {$CCMCacheDir = 'B:\CCMCache'}
                else {$CCMCacheDir = 'C:\Windows\CCMCache'}
            }
            elseif ($computerSystem.Domain -eq 'ts.humad.com' -or $computerSystem.Domain -eq 'tmt.loutms.tree') {
                #It's a server, is it Citrix?
                if ((($computerSystem.Name -notmatch '...[CX][MA][FH].*' -or $computerSystem.Name -match '...[CX][MA][ABCDFLNSPX].....S.*')) -and $computerSystem.Name -notmatch '......WP[VU].*') {
                    #Persistent machines with cache on D:\Program Files\CCMCache
                    Write-Output "`tPersistent Citrix Server, setting cache to D:\Program Files\CCMCache"
                    $CCMCacheDir = 'D:\Program Files\CCMCache'
                }
                else {
                    #Non-persistent machines
                    Write-Output "`tNon-persistent Citrix Server, setting cache to E:\Persistent\CCMCache"
                    $CCMCacheDir = 'E:\Persistent\CCMCache'
                }
            }
            elseif ($computerSystem.Name -match '............c.*') {
                #ClusterNode - Cache must be on C: or D:
                foreach ($drive in $drives) {
                    if ($drive -match '[CD]:') {
                        $CCMCacheDir = "$drive\CCMCache"
                        if ($CCMCacheDir -eq 'C:\CCMCache') {$CCMCacheDir = 'C:\Windows\CCMCache'}
                    }
                }
                #Make sure it's on C or D
                if ($CCMCacheDir -notmatch '[CD]:\CCMCache') {$CCMCacheDir = 'C:\Windows\CCMCache'}
                if ($CCMCacheDir -eq 'C:\CCMCache') {$CCMCacheDir = 'C:\Windows\CCMCache'}
            }
            else {
                #Standard server, put cache on drive with most free space
                $CCMCacheDir = "$($drives[0])\CCMCache"
                if ($CCMCacheDir -eq 'C:\CCMCache') {$CCMCacheDir = 'C:\Windows\CCMCache'}
            }
            
            if ($isWorkstation -and !$isVirtual) {$ccmCacheSize = 51200}
            else {$ccmCacheSize = 5120}
            
            #We should have a cache directory, now to verify and set (need to add checks for cahce size as well)
            if ($CCMCacheDir -ne $results.CurrentCacheLocation -or $PSBoundParameters['force']) {
                $CacheDriveExists = $false
                $CacheDrive = $CCMCacheDir.Substring(0, 2)
                foreach ($drive in $drives) {if ($CacheDrive -eq $drive) {$CacheDriveExists = $true}}
                if (-not($CacheDriveExists)) {
                    Write-Output "`tCache drive doesn''t exist, looking for a new one."
                    $CCMCacheDir = "$($drives[0])\CCMCache"
                    if ($CCMCacheDir -eq 'C:\CCMCache') {$CCMCacheDir = 'C:\Windows\CCMCache'}
                    Write-Output "`tNew cache location is $CCMCacheDir"
                } #End if(-not($CacheDriveExists))
                $results.UpdatedCacheLocation = $CCMCacheDir
                $cache.Location = $CCMCacheDir
                if ($cache.Size -ne $ccmCacheSize) {
                    $results.UpdatedCacheSize = $ccmCacheSize
                    $cache.Size = $ccmCacheSize
                }
                $cache.put() | Out-Null
                $cache.Get()
                Write-Output "`tCache location is now $($Cache.Location)"
                $results.Results = 'Updated'
                Get-Service -ComputerName $computerName -Name CcmExec | Restart-Service
            }
            else {
                Write-Output "`tCache location is good"
                $results.Results = 'Good'
            } #End of else
        } #End of try
        Catch [System.Exception] {
            Write-Output "`t!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            Write-Output "`tUnable to fix $computerName"
            Write-Output "`t$($Error[0])"
            $results.Results = 'Error'
            $results | Export-Csv -Path $logFile -Append -NoTypeInformation
        } #End of catch
    }

    End {
        Write-Output 'Completing Function'
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.ObjectType')
        Return $obj	
    }
} #End Repair-CMNCacheLocation

Function Repair-CMNClient {
    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory = $false, HelpMessage = 'Do we ignore maintenance windows?')]
        [switch]$ignoreMW
    )
    #Get cimclass for future use
    $client = Get-CimClass -Namespace Root\CCM -ClassName SMS_Client

    $mwInstances = Get-CimInstance -Namespace ROOT\ccm\ClientSDK -ClassName CCM_ServiceWindow -Filter "Type != 6"
    if ($mwInstances.Count -ne 0) {
        $inMW = $false
        if ($mwInstances.Count -gt 0) {
            $currentTime = Get-Date
            foreach ($mwInstance in $mwInstances) {
                if ($mwInstance.StartTime -lt $currentTime -and $mwInstance.EndTime -lt $currentTime) {$inMW = $true}
            }
        }
    }
    else {$inMW = $true}

    if ($inMW -or $PSBoundParameters['ignoreMW']) {
        #Reset machine group policy so we clear out any Windows Update settings
        try {
            Write-Output "Renaming $env:windir\System32\GroupPolicy\Machine\Registry.pol to $env:windir\System32\GroupPolicy\Machine\Registry.old"
            if (Test-Path "$env:windir\System32\GroupPolicy\Machine\Registry.pol") {
                Write-Output "Moving $env:windir\System32\GroupPolicy\Machine\Registry.pol to $env:windir\System32\GroupPolicy\Machine\Registry.old"
                Move-Item -Path "$env:windir\System32\GroupPolicy\Machine\Registry.pol" -Destination "$env:windir\System32\GroupPolicy\Machine\Registry.old" -Force
            }
            else {
                Write-Output "unable to find $env:windir\System32\GroupPolicy\Machine\Registry.pol"
            }
        }
        catch {
            Write-Output "Unable to rename $env:windir\System32\GroupPolicy\Machine\Registry.pol"
            Return "Unable to rename $env:windir\System32\GroupPolicy\Machine\Registry.pol"
        }

        try {
            Write-Output 'Cleaning CCM Temp Dir'
            $ccmTempDir = (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\CCM).TempDir
            if ((Test-Path $ccmTempDir) -and $ccmTempDir -ne $null -and $ccmTempDir -ne '') {Get-ChildItem -Path $ccmTempDir | Where-Object {!$_.PSisContainer} | Remove-Item -Force -ErrorAction SilentlyContinue}
        }
        catch {
            Write-Output "Unable to clear $ccmTempDir"
            Return "Unable to clear $ccmTempDir"
        }

        #Force a resync of inventory and DDR information
        try {
            Write-Output "Removing InventoryActionSatus from WMI"
            Get-CimInstance -Namespace root\CCM\InvAgt -ClassName InventoryActionStatus -Filter "InventoryActionID = '{00000000-0000-0000-0000-000000000001}' or InventoryActionID = '{00000000-0000-0000-0000-000000000003}'" -ErrorAction SilentlyContinue | Remove-CimInstance
        }
        catch {
            Write-Output "Unable to remove InventoryActionSatus from WMI"
            Write-Output $Error.
            Return "Unable to remove InventoryActionSatus from WMI"
        }

        #Clear out the WMI repository where policy was stored, force refresh
        Write-Output 'Resetting Policy'
        Invoke-CimMethod -CimClass $client -MethodName ResetPolicy -Arguments @{uFlags = 1} | Out-Null

        #Remove SMS Certs
        Write-Output 'Removing SMS Certs'
        Get-ChildItem Cert:\LocalMachine\SMS | Where-Object {$_.Subject -match "^CN=SMS, CN=$($env:COMPUTERNAME)"} | Remove-Item -Force -ErrorAction SilentlyContinue

        Write-Output 'Restarting CCMExec'
        Restart-Service CcmExec | out-null

        Write-Output 'Running GPUpdate'
        & gpupdate.exe

        Write-Output "$(get-date) - Sleeping for 5 minutes until $((Get-date).AddMinutes(5))"
        Start-Sleep -Seconds 300

        try {
            Write-Output 'Refreshing compliance state'
            $sccmClient = New-Object -ComObject Microsoft.CCM.UpdatesStore
            $sccmClient.RefreshServerComplianceState()
        }
        catch {
            Write-Output 'Unable to refresh compliance state'
            Return 'Unable to refresh compliance state'
        }

        try {
            Write-Output 'Running Machine Policy Retrieval & Evaluation Cycle'
            Invoke-CimMethod -CimClass $client -MethodName TriggerSchedule -Arguments @{sScheduleID = '{00000000-0000-0000-0000-000000000021}'} -ErrorAction SilentlyContinue | Out-Null

            Write-Output 'Running Discovery Data Collection Cycle'
            Invoke-CimMethod -CimClass $client -MethodName TriggerSchedule -Arguments @{sScheduleID = '{00000000-0000-0000-0000-000000000003}'} -ErrorAction SilentlyContinue | Out-Null

            Write-Output 'Running Hardware Inventory Cycle'
            Invoke-CimMethod -CimClass $client -MethodName TriggerSchedule -Arguments @{sScheduleID = '{00000000-0000-0000-0000-000000000001}'} -ErrorAction SilentlyContinue | Out-Null
        }
        catch {
            Write-Output "Unable to reset $env:COMPUTERNAME"
            Write-Output $Error.
            Return "Unable to reset $env:COMPUTERNAME"
        }

        Return "$env:COMPUTERNAME complete!"
    }
    else {
        Write-Output "$env:COMPUTERNAME is not currently in it's maintenance window and ignoreMW parameter was not specified, not resetting client"
    }
} #End Repair-CMNClient

Function Repair-CmnProgressStuck {
    Stop-Service -Name CcmExec -Force
    Stop-Service -Name BITS -Force
    if (Test-Path -Path "$($env:ALLUSERSPROFILE)\Microsoft\Network\Downloader\qmgr?.dat") {
        Write-Output 'Removing existing bits transfers'
        Remove-Item -Path "$($env:ALLUSERSPROFILE)\Microsoft\Network\Downloader\qmgr?.dat" -Force
    }
    if ((Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\BITS).EnableBitsMaxBandwidth -ne 1) {
        Write-Output 'Enableing BITS limitations'
        Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\BITS -Name EnableBitsMaxBandwidth -Value 1
    }
    if ((Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\BITS).MaxTransferRateOnSchedule -ne 9999) {
        Write-Output 'Setting MaxTransferRateOnSchedule'
        Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\BITS -Name MaxTransferRateOnSchedule -Value 9999
    }
    if ((Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\BITS).MaxTransferRateOffSchedule -ne 999999) {
        Write-Output 'Setting MaxTransferRateOffSchedule'
        Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\BITS -Name MaxTransferRateOffSchedule -Value 999999
    }
    Start-Service -Name BITS
    Start-Service -Name CcmExec
} #End Repair-CmnProgressStuck

Function Repair-CMNWsusSoftwareDir {

    #https://gallery.technet.microsoft.com/scriptcenter/ConfigMgr-Client-Action-16a364a5
    #https://powershell.org/forums/topic/remotely-invoking-sccm-client-actions/

    [CmdletBinding(ConfirmImpact = 'Low')]

    PARAM()
    Write-Output 'Starting'
    Write-Output 'Stopping WUAUSERV'
    Stop-Service -Name wuauserv
    Write-Output 'Deleting Downloads'
    Remove-Item C:\windows\SoftwareDistribution\Download\* -Recurse -Force -ErrorAction SilentlyContinue
    Write-Output 'Deleting Datastore'
    Remove-Item C:\windows\SoftwareDistribution\DataStore\*.edb -Force -ErrorAction SilentlyContinue
    Write-Output 'Starting WUAUSERV'
    Start-Service -Name wuauserv
    Write-Output 'Deleteing DownloadContentRequestEx2 class'
    Get-WmiObject -Namespace root\ccm\SoftMgmtAgent -Class DownloadContentRequestEx2 | Remove-WmiObject -ErrorAction SilentlyContinue
    Write-Output 'Deleting DownloadInfoex2 class'
    Get-WmiObject -Namespace root\ccm\SoftMgmtAgent -Class DownloadInfoex2 | Remove-WmiObject -ErrorAction SilentlyContinue
    Write-Output 'Restarting CcmExec'
    Restart-Service -Name CcmExec
    Write-Output 'Sleeping for 60 seconds'
    Start-Sleep -Seconds 60
    Invoke-WmiMethod -Namespace root\ccm -Class SMS_Client -Name TriggerSchedule -ArgumentList '{00000000-0000-0000-0000-000000000108}' | Out-Null
    Write-Output 'Finished'
} #End Repair-CMNWsusSoftwareDir

Function Reset-CmnInventory {
    try {
        Write-Output "Renaming $env:windir\System32\GroupPolicy\Machine\Registry.pol to $env:windir\System32\GroupPolicy\Machine\Registry.old"
        if (Test-Path "$env:windir\System32\GroupPolicy\Machine\Registry.pol") {
            Write-Output "Moving $env:windir\System32\GroupPolicy\Machine\Registry.pol to $env:windir\System32\GroupPolicy\Machine\Registry.old"
            Move-Item -Path "$env:windir\System32\GroupPolicy\Machine\Registry.pol" -Destination "$env:windir\System32\GroupPolicy\Machine\Registry.old" -Force
        }
        else {
            Write-Output "unable to find $env:windir\System32\GroupPolicy\Machine\Registry.pol"
        }
    }
    
    Catch {
        Write-Output "Unable to rename $env:windir\System32\GroupPolicy\Machine\Registry.pol"
        Throw "Unable to rename $env:windir\System32\GroupPolicy\Machine\Registry.pol"
    }
    
    try {
        Write-Output "Removing InventoryActionSatus from WMI"
        Get-CimInstance -Namespace root\CCM\InvAgt -ClassName InventoryActionStatus -Filter "InventoryActionID = '{00000000-0000-0000-0000-000000000001}'" -ErrorAction SilentlyContinue | Remove-CimInstance
        Invoke-CimMethod -Namespace root\ccm -ClassName SMS_Client -MethodName TriggerSchedule -Arguments @{sScheduleID = '{00000000-0000-0000-0000-000000000001}'} -ErrorAction SilentlyContinue | Out-Null
    }
    catch {
        Write-Output "Unable to reset inventory"
        Write-Output $Error.ErrorDetails
        Throw "Unable to reset inventory"
    }
    
    Write-Output "$env:COMPUTERNAME complete!"
}

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
        $cache.Put() | out-null
        Write-Log -Message "Restarting CCMEXEC service..." 
        restart-service ccmexec
        Write-Log -Message "Current SCCM Cache Size: $($cache.size)"
    }
    else {
        Write-Log -Message "Cache size is correct!"
    }
}

Function Set-CmCacheDir {
    PARAM([String]$ccmCacheDir)

    $cache = Get-WmiObject -Namespace 'root/CCM/SoftMgmtAgent' -Class CacheConfig
    Write-Log -Message "Current cache dir is $($cache.Location), need to change to $CCMCacheDir"
    $cache.Location = $CCMCacheDir
    $cache.Put() | Out-Null
} #End Set-CmCacheDir

Function Set-CmLogDirectory {
    PARAM([String]$ccmLogDir)

    Write-Log -Message 'Stopping CcmExec'
    Stop-Service CcmExec
    Write-Log -Message "Setting log directory in registry to $CCMLogDir"
    Set-RegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\CCM\Logging\@Global' -Name 'LogDirectory' -Type String -Value $CCMLogDir
    Write-Log -Message 'Starting CcmExec'
    Start-Service CcmExec
} #End Set-CmLogDirectory

Function Set-SiteAndMP {
    Param
    (
        [Parameter(Mandatory = $false)]
        $siteCode = 'WP1'
    )

    Switch ($siteCode) {
        'MT1' {$MP = 'LOUAPPWTS1150.rsc.humad.com'}
        'SP1' {$MP = 'LOUAPPWPS1740.rsc.humad.com'}
        'SQ1' {$MP = 'LOUAPPWQS1020.rsc.humad.com'}
        'WP1' {$MP = 'LOUAPPWPS1642.rsc.humad.com'}
        'WQ1' {$MP = 'LOUAPPWQS1023.rsc.humad.com'}
    }

    $Client = New-Object -ComObject Microsoft.SMS.Client
    $Client.SetAssignedSite($siteCode)
    $Client.SetCurrentManagementPoint($mp)
    Restart-Service CCMExec

    $Client = New-Object -ComObject Microsoft.SMS.Client
    $Client.GetAssignedSite()
    $Client.GetCurrentManagementPoint()
} #End Set-SiteAndMP


Function Clear-CMCache {
    #Connect to Resource Manager COM Object
    Write-Output "Getting SCCM info"
    Try{
        $resman = new-object -ComObject "UIResource.UIResourceMgr"
        $cacheInfo = $resman.GetCacheInfo()

        #Enum Cache elements
        $elements = $cacheinfo.GetCacheElements()
        if($elements.Count -gt 0){
            Write-Output "Looks like we have $($elements.Count) objects, deleteing"
            ForEach($element in $elements){
                Write-Output "Attempting to delete PackageID $($element.ContentID) from $($element.Location)"
                $cacheInfo.DeleteCacheElement($_.CacheElementID)
            }
            Write-Output "Complete! All Clear!"
        }
        else{
            Write-Output "All clear!!"
        }
    }
    catch{
        Write-Output 'Unable to connect to SCCM info, make sure you have rights and SCCM is installed'
    }
} #End Clear-CMCache

Function Set-CMActions{
    $cpAppletMgr = New-Object -ComObject CPApplet.CPAppletMgr
    ForEach($applet in $cpAppletMgr.GetClientActions()){
        Write-Output "$($applet.ActionID) - $($applet.Name)"
    }
}

Clear-CMCache