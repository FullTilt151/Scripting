<#
.SYNOPSIS
    ConfigMgr Client Health is a tool that validates and automatically fixes errors on Windows computers managed by Microsoft Configuration Manager.
.EXAMPLE
   .\ConfigMgrClientHealth.ps1 -Config .\Config.Xml
.PARAMETER Config
    A single parameter specifying the path to the configuration XML file.
.DESCRIPTION
    ConfigMgr Client Health detects and fixes following errors:
        * ConfigMgr client is not installed.
        * ConfigMgr client is assigned the correct site code.
        * ConfigMgr client is upgraded to current version if not at specified minimum version.
        * ConfigMgr client not able to forward state messages to management point.
        * ConfigMgr client stuck in provisioning mode.
        * ConfigMgr client maximum log file size.
        * ConfigMgr client cache size.
        * Corrupt WMI.
        * Services for ConfigMgr client is not running or disabled.
        * Other services can be specified to start and run and specific state.
        * Hardware inventory is running at correct schedule
        * Group Policy failes to update registry.pol
        * Pending reboot blocking updates from installing
        * ConfigMgr Client Update Handler is working correctly with registry.pol
        * Windows Update Agent not working correctly, causing client not to receive patches.
        * Windows Update Agent missing patches that fixes known bugs.
.NOTES
    You should run this with at least local administrator rights. It is recommended to run this script under the SYSTEM context.

    DO NOT GIVE USERS WRITE ACCESS TO THIS FILE. LOCK IT DOWN !

    Author: Anders Rødland
    Blog: https://www.andersrodland.com
    Twitter: @AndersRodland

    Editor: Cody Mathis
    Blog: https://sccmf12twice.com/author/cmathis/
    Twitter: @CodyMathis123
.LINK
    Full documentation: https://www.andersrodland.com/configmgr-client-health/
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
param(
    [Parameter(Mandatory = $false, HelpMessage = 'Path to XML Configuration File')]
    [ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
    [ValidatePattern('.xml$')]
    [string]$Config
)

Begin {
    # ConfigMgr Client Health Version
    $Version = '0.1.0'
    $PowerShellVersion = [int]$PSVersionTable.PSVersion.Major
    $global:ScriptPath = Split-Path -parent $MyInvocation.MyCommand.Definition

    #If no config file was passed in, use the default.
    If (-not $PSBoundParameters.ContainsKey('Config')) {
        $Config = Join-Path -Path ($global:ScriptPath) -ChildPath "PFERemediationSettings.xml"
        Write-Verbose "No config provided, defaulting to $Config"
    }

    Write-Verbose "Script version: $Version"
    Write-Verbose "PowerShell version: $PowerShellVersion"

    #region proxy functions for logging
    # #Write-Verbose
    $WriteVerboseMetadata = New-Object System.Management.Automation.CommandMetadata (Get-Command Write-Verbose)
    $WriteVerboseBinding = [System.Management.Automation.ProxyCommand]::GetCmdletBindingAttribute($WriteVerboseMetadata)
    $WriteVerboseParams = [System.Management.Automation.ProxyCommand]::GetParamBlock($WriteVerboseMetadata)
    $WriteVerboseWrapped = { Microsoft.PowerShell.Utility\Write-Verbose @PSBoundParameters; switch ($VerbosePreference) {
            'Continue' {
                Out-LogFile -Text $Message
            }
        } }
    ${Function:Write-Verbose} = [string]::Format('{0}param({1}) {2}', $WriteVerboseBinding, $WriteVerboseParams, $WriteVerboseWrapped)

    #Write-Host
    $WriteHostMetadata = New-Object System.Management.Automation.CommandMetadata (Get-Command Write-Host)
    $WriteHostBinding = [System.Management.Automation.ProxyCommand]::GetCmdletBindingAttribute($WriteHostMetadata)
    $WriteHostParams = [System.Management.Automation.ProxyCommand]::GetParamBlock($WriteHostMetadata)
    $WriteHostWrapped = { Microsoft.PowerShell.Utility\Write-Host @PSBoundParameters; Out-LogFile -Text $Object }
    ${Function:Write-Host} = [string]::Format('{0}param({1}) {2}', $WriteHostBinding, $WriteHostParams, $WriteHostWrapped)

    # #Write-Information
    # $WriteInformationMetadata = New-Object System.Management.Automation.CommandMetadata (Get-Command Write-Information)
    # $WriteInformationBinding = [System.Management.Automation.ProxyCommand]::GetCmdletBindingAttribute($WriteInformationMetadata)
    # $WriteInformationParams = [System.Management.Automation.ProxyCommand]::GetParamBlock($WriteInformationMetadata)
    # $WriteInformationWrapped = {Microsoft.Powershell.Utility\Write-Information @PSBoundParameters; Out-LogFile -Text $MessageData}
    # ${Function:Write-Information} = '{0}param({1}) {2}' -f $WriteInformationBinding, $WriteInformationParams, $WriteInformationWrapped

    #Write-Warning
    $WriteWarningMetadata = New-Object System.Management.Automation.CommandMetadata (Get-Command Write-Warning)
    $WriteWarningBinding = [System.Management.Automation.ProxyCommand]::GetCmdletBindingAttribute($WriteWarningMetadata)
    $WriteWarningParams = [System.Management.Automation.ProxyCommand]::GetParamBlock($WriteWarningMetadata)
    $WriteWarningWrapped = { Microsoft.PowerShell.Utility\Write-Warning @PSBoundParameters; Out-LogFile -Text $Message -Severity 2 }
    ${Function:Write-Warning} = [string]::Format('{0}param({1}) {2}', $WriteWarningBinding, $WriteWarningParams, $WriteWarningWrapped)

    #Write-Error
    $WriteErrorMetadata = New-Object System.Management.Automation.CommandMetadata (Get-Command Write-Error)
    $WriteErrorBinding = [System.Management.Automation.ProxyCommand]::GetCmdletBindingAttribute($WriteErrorMetadata)
    $WriteErrorParams = [System.Management.Automation.ProxyCommand]::GetParamBlock($WriteErrorMetadata)
    $WriteErrorWrapped = { Microsoft.PowerShell.Utility\Write-Error @PSBoundParameters; Out-LogFile -Text $Message -Severity 3 }
    ${Function:Write-Error} = [string]::Format('{0}param({1}) {2}', $WriteErrorBinding, $WriteErrorParams, $WriteErrorWrapped)
    #endregion proxy functions for logging

    #region Test-XML Function to validate config XML file
    Function Test-XML {
        <#
        .SYNOPSIS
        Test the validity of an XML file
        #>
        [CmdletBinding()]
        param (
            [parameter(mandatory = $true)]
            [ValidateNotNullorEmpty()]
            [ValidatePattern('.xml$')]
            [string]$xmlFilePath
        )
        # Check the file exists
        if (-not (Test-Path -Path $xmlFilePath)) {
            throw "$xmlFilePath is not valid. Please provide a valid path to the .xml config file"
        }
        # Check for Load or Parse errors when loading the XML file
        $xml = New-Object System.Xml.XmlDocument
        try {
            $xml.Load((Get-ChildItem -Path $xmlFilePath).FullName)
            return $true
        }
        catch [System.Xml.XmlException] {
            Write-Error "$xmlFilePath : $($_.toString())"
            Write-Error "Configuration file $Config is NOT valid XML. Script will not execute."
            return $FALSE
        }
    }
    #endregion Test-XML Function to validate config XML file

    #region Validate and read configuration from XML file
    if (Test-Path $Config) {
        # Test if valid XML
        switch (Test-XML -xmlFilePath $Config) {
            $false {
                Exit 1
            }
        }

        # Load XML file into variable
        Try {
            [xml]$Xml = Get-Content -Path $Config -ErrorAction Stop
        }
        Catch {
            $ErrorMessage = $_.Exception.Message
            $text = "Error, could not read $Config. Check file location and share/ntfs permissions. Is XML config file damaged?`nError message: $ErrorMessage"
            Write-Error $text
            Exit 1
        }
    }
    else {
        $text = "Error, could not access $Config. Check file location and share/ntfs permissions. Did you misspell the name?"
        Write-Error $text
        Exit 1
    }
    #endregion Validate and read configuration from XML file

    #region Import Modules
    # Import BitsTransfer Module (Does not work on PowerShell Core (6), disable check if module failes to import.)
    $BitsCheckEnabled = $false
    if (Get-Module -ListAvailable -Name BitsTransfer) {
        try {
            Import-Module BitsTransfer -ErrorAction stop
            $BitsCheckEnabled = $true
        }
        catch {
            $BitsCheckEnabled = $false
        }
    }
    #endregion Import Modules

    #region functions
    #region Get-* functions
    Function Get-DateTime {
        <#
            .SYNOPSIS
            Return a DateTime option in the format "yyyy-MM-dd HH:mm:ss" and timezone based on Config XML
        #>

        $Format = (Get-XMLConfigLoggingTimeFormat).ToLower()

        $obj = switch ($Format) {
            'UTC' {
                ([DateTime]::UtcNow).ToString("yyyy-MM-dd HH:mm:ss")
            }
            default {
                Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $obj
    }

    Function Get-UTCTime {
        <#
            .SYNOPSIS
            Return a DateTime in UTC format, based on input DateTime object

            .PARAMETER DateTime
            A datetime object that you wish to be converted to UTC
        #>
        param(
            [Parameter(Mandatory = $true)]
            [DateTime]$DateTime
        )
        $obj = $DateTime.ToUniversalTime()
        Write-Output $obj
    }

    Function Get-Hostname {
        <#
            .SYNOPSIS
            Simply returns the $env:COMPUTERNAME environment variable
        #>
        $obj = $env:COMPUTERNAME
        Write-Output $Obj
    }

    Function Get-ServiceUpTime {
        param(
            [Parameter(Mandatory = $true)]
            [string]$Name
        )

        Try {
            $ServiceDisplayName = Get-Service -Name $Name | Select-Object -ExpandProperty DisplayName
        }
        Catch {
            Write-Warning "The '$($Name)' service could not be found."
            Return
        }

        #First try and get the service start time based on the last start event message in the system log.
        Try {
            [datetime]$ServiceStartTime = (Get-EventLog -LogName System -Source "Service Control Manager" -EntryType Information -Message "*$($ServiceDisplayName)*running*" -Newest 1).TimeGenerated
            Return (New-TimeSpan -Start $ServiceStartTime -End (Get-Date)).Days
        }
        Catch {
            Write-Verbose "Could not get the uptime time for the '$($Name)' service from the event log.  Relying on the process instead."
        }

        #If the event log doesn't contain a start event then use the start time of the service's process.  Since processes can be shared this is less reliable.
        Try {
            if ($PowerShellVersion -ge 6) {
                $ServiceProcessID = (Get-CimInstance Win32_Service -Filter "Name='$($Name)'").ProcessID
            }
            else {
                $ServiceProcessID = (Get-WmiObject -Class Win32_Service -Filter "Name='$($Name)'").ProcessID
            }

            [datetime]$ServiceStartTime = (Get-Process -Id $ServiceProcessID).StartTime
            Return (New-TimeSpan -Start $ServiceStartTime -End (Get-Date)).Days

        }
        Catch {
            Write-Warning "Could not get the uptime time for the '$($Name)' service.  Returning max value."
            Return [int]::MaxValue
        }
    }

    Function Get-OperatingSystem {
        if ($PowerShellVersion -ge 6) {
            $OS = Get-CimInstance Win32_OperatingSystem
        }
        else {
            $OS = Get-WmiObject Win32_OperatingSystem
        }


        # Handles different OS languages
        $OSArchitecture = ($OS.OSArchitecture -replace ('([^0-9])(\.*)', '')) + '-Bit'
        switch -Wildcard ($OS.Caption) {
            "*Embedded*" {
                $OSName = "Windows 7 " + $OSArchitecture
            }
            "*Windows 7*" {
                $OSName = "Windows 7 " + $OSArchitecture
            }
            "*Windows 8.1*" {
                $OSName = "Windows 8.1 " + $OSArchitecture
            }
            "*Windows 10*" {
                $OSName = "Windows 10 " + $OSArchitecture
            }
            "*Server 2008*" {
                if ($OS.Caption -like "*R2*") {
                    $OSName = "Windows Server 2008 R2 " + $OSArchitecture
                }
                else {
                    $OSName = "Windows Server 2008 " + $OSArchitecture
                }
            }
            "*Server 2012*" {
                if ($OS.Caption -like "*R2*") {
                    $OSName = "Windows Server 2012 R2 " + $OSArchitecture
                }
                else {
                    $OSName = "Windows Server 2012 " + $OSArchitecture
                }
            }
            "*Server 2016*" {
                $OSName = "Windows Server 2016 " + $OSArchitecture
            }
            "*Server 2019*" {
                $OSName = "Windows Server 2019 " + $OSArchitecture
            }
        }
        Write-Output $OSName
    }

    Function Get-MissingUpdates {
        $UpdateShare = Get-XMLConfigUpdatesShare
        $OSName = Get-OperatingSystem

        $build = $null
        if ($OSName -like "*Windows 10*") {
            $build = Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber
            switch ($build) {
                10240 {
                    $OSName = $OSName + " 1507"
                }
                10586 {
                    $OSName = $OSName + " 1511"
                }
                14393 {
                    $OSName = $OSName + " 1607"
                }
                15063 {
                    $OSName = $OSName + " 1703"
                }
                16299 {
                    $OSName = $OSName + " 1709"
                }
                17134 {
                    $OSName = $OSName + " 1803"
                }
                17763 {
                    $OSName = $OSName + " 1809"
                }
                default {
                    $OSName = $OSName + " Insider Preview"
                }
            }
        }

        $Updates = $UpdateShare + "\" + $OSName + "\"
        $obj = New-Object PSObject @{ }
        If ((Test-Path $Updates) -eq $true) {
            $regex = "\b(?!(KB)+(\d+)\b)\w+"
            $hotfixes = (Get-ChildItem $Updates | Select-Object -ExpandProperty Name)
            if ($PowerShellVersion -ge 6) {
                $installedUpdates = (Get-CimInstance -ClassName Win32_QuickFixEngineering).HotFixID
            }
            else {
                $installedUpdates = Get-HotFix | Select-Object -ExpandProperty HotFixID
            }

            foreach ($hotfix in $hotfixes) {
                $kb = $hotfix -replace $regex -replace "\." -replace "-"
                if ($installedUpdates -like $kb) {
                }
                else {
                    $obj.Add('Hotfix', $hotfix)
                }
            }
        }
        Write-Output $obj
    }

    Function Get-RegistryValue {
        param (
            [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]$Path,
            [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]$Name
        )

        Return (Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue).$Name
    }

    Function Get-ClientVersion {
        try {
            if ($PowerShellVersion -ge 6) {
                $obj = (Get-CimInstance -Namespace root/ccm SMS_Client).ClientVersion
            }
            else {
                $obj = (Get-WmiObject -Namespace root/ccm SMS_Client).ClientVersion
            }
        }
        catch {
            $obj = $false
        }
        finally {
            Write-Output $obj
        }
    }

    Function Get-ClientCache {
        try {
            $obj = (New-Object -ComObject UIResource.UIResourceMgr).GetCacheInfo().TotalSize
        }
        catch {
            $obj = 0
        }
        finally {
            if ($null -eq $obj) {
                $obj = 0
            }
            Write-Output $obj
        }
    }

    Function Get-ClientMaxLogSize {
        try {
            $obj = [Math]::Round(((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\CCM\Logging\@Global').LogMaxSize) / 1000)
        }
        catch {
            $obj = 0
        }
        finally {
            Write-Output $obj
        }
    }

    Function Get-ClientMaxLogHistory {
        try {
            $obj = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\CCM\Logging\@Global').LogMaxHistory
        }
        catch {
            $obj = 0
        }
        finally {
            Write-Output $obj
        }
    }

    Function Get-Domain {
        try {
            if ($PowerShellVersion -ge 6) {
                $obj = (Get-CimInstance Win32_ComputerSystem).Domain
            }
            else {
                $obj = (Get-WmiObject Win32_ComputerSystem).Domain
            }
        }
        catch {
            $obj = $false
        }
        finally {
            Write-Output $obj
        }
    }

    Function Get-CCMLogDirectory {
        $obj = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\CCM\Logging\@Global').LogDirectory
        if ($null -eq $obj) {
            $obj = "$env:SystemDrive\windows\ccm\Logs"
        }
        Write-Output $obj
    }

    Function Get-CCMDirectory {
        $logdir = Get-CCMLogDirectory
        $obj = $logdir.replace("\Logs", "")
        Write-Output $obj
    }

    function Get-ClientSiteCode {
        try {
            $sms = New-Object -comobject "Microsoft.SMS.Client" -ErrorAction Stop
            $currentSiteCode = $sms.GetAssignedSite()
            Write-Verbose "Determined client site code to be $currentSiteCode"
            Write-Output $currentSiteCode
        }
        catch {
            Write-Error "Failed to determine clients current site code"
        }
    }

    Function Get-OSDiskFreeSpace {

        if ($PowerShellVersion -ge 6) {
            $driveC = Get-CimInstance -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "$env:SystemDrive" } | Select-Object FreeSpace, Size
        }
        else {
            $driveC = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "$env:SystemDrive" } | Select-Object FreeSpace, Size
        }
        $freeSpace = (($driveC.FreeSpace / $driveC.Size) * 100)
        Write-Output ([math]::Round($freeSpace, 2))
    }

    Function Get-LastBootTime {
        if ($PowerShellVersion -ge 6) {
            $wmi = Get-CimInstance Win32_OperatingSystem
        }
        else {
            $wmi = Get-WmiObject Win32_OperatingSystem
        }
        $obj = $wmi.ConvertToDateTime($wmi.LastBootUpTime)
        Write-Output $obj
    }

    Function Get-LastInstalledPatches {
        Param([Parameter(Mandatory = $true)]$Log)
        # Reading date from Windows Update COM object.
        $Session = New-Object -ComObject Microsoft.Update.Session
        $Searcher = $Session.CreateUpdateSearcher()
        $HistoryCount = $Searcher.GetTotalHistoryCount()
        $Updates = $Searcher.QueryHistory(0, $HistoryCount)
        $OS = Get-OperatingSystem
        $ClientApplicationID = switch -Regex ($OS) {
            "Windows 7" {
                'AutomaticUpdates'
            }
            "Windows 8" {
                'AutomaticUpdatesWuApp'
            }
            "Windows 10" {
                'UpdateOrchestrator'
            }
            "Server 2008" {
                'AutomaticUpdates'
            }
            "Server 2012" {
                'AutomaticUpdatesWuApp'
            }
            "Server 2016" {
                'UpdateOrchestrator'
            }
        }
        $Date = $Updates | Where-Object { ($_.ClientApplicationID -in @($ClientApplicationID, 'ccmexec')) -and ($_.Title -notmatch "Definition Update") } | Select-Object -ExpandProperty Date | Measure-Latest

        if ($PowerShellVersion -ge 6) {
            $Hotfix = Get-CimInstance -ClassName Win32_QuickFixEngineering | Select-Object @{Name = "InstalledOn"; Expression = { [DateTime]::Parse($_.InstalledOn, $([System.Globalization.CultureInfo]::GetCultureInfo("en-US"))) } }
        }
        else {
            $Hotfix = Get-HotFix | Select-Object @{l = "InstalledOn"; e = { [DateTime]::Parse($_.psbase.properties["installedon"].value, $([System.Globalization.CultureInfo]::GetCultureInfo("en-US"))) } }
        }

        $Hotfix = $Hotfix | Select-Object -ExpandProperty InstalledOn

        $Date2 = $null

        if ($null -ne $hotfix) {
            $Date2 = Get-Date -Date ($hotfix | Measure-Latest) -ErrorAction SilentlyContinue
        }

        if (($Date -ge $Date2) -and ($null -ne $Date)) {
            $LatestPatchDate = $Date
        }
        elseif (($Date2 -gt $Date) -and ($null -ne $Date2)) {
            $LatestPatchDate = $Date2
        }

        $Log.OSUpdates = Get-SmallDateTime -Date $LatestPatchDate
        $RegistryKey = Get-XMLConfigRegistryKey
        $null = Set-RegistryValue -Path $RegistryKey -Name 'LastPatchDate' -Value $LatestPatchDate
    }

    Function Get-UBR {
        $UBR = (Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion').UBR
        Write-Output $UBR
    }

    Function Get-LastReboot {
        Param([Parameter(Mandatory = $false)][xml]$Xml)

        # Only run if option in config is enabled
        if (($Xml.Configuration.Option | Where-Object { $_.Name -eq 'RebootApplication' } | Select-Object -ExpandProperty 'Enable') -eq 'True') {
            $execute = $true
        }

        if ($execute -eq $true) {

            [float]$maxRebootDays = Get-XMLConfigMaxRebootDays
            if ($PowerShellVersion -ge 6) {
                $wmi = Get-CimInstance Win32_OperatingSystem
            }
            else {
                $wmi = Get-WmiObject Win32_OperatingSystem
            }

            $lastBootTime = $wmi.ConvertToDateTime($wmi.LastBootUpTime)

            $uptime = (Get-Date) - ($wmi.ConvertToDateTime($wmi.lastbootuptime))
            if ($uptime.TotalDays -lt $maxRebootDays) {
                $text = 'Last boot time: ' + $lastBootTime + ': OK'
                Write-Host $text
            }
            elseif (($uptime.TotalDays -ge $maxRebootDays) -and (Get-XMLConfigRebootApplicationEnable -eq $true)) {
                $text = 'Last boot time: ' + $lastBootTime + ': More than ' + $maxRebootDays + ' days since last reboot. Starting reboot application.'
                Write-Warning $text
                Start-RebootApplication
            }
            else {
                $text = 'Last boot time: ' + $lastBootTime + ': More than ' + $maxRebootDays + ' days since last reboot. Reboot application disabled.'
                Write-Warning $text
            }
        }
    }

    Function Get-SmallDateTime {
        Param([Parameter(Mandatory = $false)]$Date)
        #Write-Verbose "Start Get-SmallDateTime"

        $UTC = (Get-XMLConfigLoggingTimeFormat).ToLower()

        if ($null -ne $Date) {
            if ($UTC -eq "utc") {
                $obj = (Get-UTCTime -DateTime $Date).ToString("yyyy-MM-dd HH:mm:ss")
            }
            else {
                $obj = ($Date).ToString("yyyy-MM-dd HH:mm:ss")
            }
        }
        else {
            $obj = Get-DateTime
        }
        $obj = $obj -replace '\.', ':'
        Write-Output $obj
        #Write-Verbose "End Get-SmallDateTime"
    }

    Function Get-Info {
        if ($PowerShellVersion -ge 6) {
            $OS = Get-CimInstance Win32_OperatingSystem
            $ComputerSystem = Get-CimInstance Win32_ComputerSystem
            if ($ComputerSystem.Manufacturer -eq 'Lenovo') {
                $Model = (Get-CimInstance Win32_ComputerSystemProduct).Version
            }
            else {
                $Model = $ComputerSystem.Model
            }
        }
        else {
            $OS = Get-WmiObject Win32_OperatingSystem
            $ComputerSystem = Get-WmiObject Win32_ComputerSystem
            if ($ComputerSystem.Manufacturer -eq 'Lenovo') {
                $Model = (Get-WmiObject Win32_ComputerSystemProduct).Version
            }
            else {
                $Model = $ComputerSystem.Model
            }
        }

        $obj = New-Object PSObject -Property @{
            Hostname         = $ComputerSystem.Name;
            Manufacturer     = $ComputerSystem.Manufacturer
            Model            = $Model
            Operatingsystem  = $OS.Caption;
            Architecture     = $OS.OSArchitecture;
            Build            = $OS.BuildNumber;
            InstallDate      = Get-SmallDateTime -Date ($OS.ConvertToDateTime($OS.InstallDate))
            LastLoggedOnUser = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\').LastLoggedOnUser;
        }

        $obj = $obj
        Write-Output $obj
    }

    Function Get-CHini {
        <#
        .SYNOPSIS
        Reads an ini file and returns back the value of the provided key
        .DESCRIPTION
        Parses through a provided ini file and finds the value of a key under a particular section of the file
        .EXAMPLE
        Get-CHINI -parameter "value"
        .EXAMPLE
        Get-CHINI -File "c:\Windows\smscfg.ini" -Section "Configuration - Client Properties" -Key "SID"
        .PARAMETER File
        Full path to desired ini file
        .PARAMETER Section
        Section name from the ini file where the requested key is located
        .PARAMETER Key
        Key name of requested value
         #>
        param
        (
            [Parameter(Mandatory = $True)]
            [ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
            [ValidatePattern('.ini$')]
            [string]$File,

            [Parameter(Mandatory = $True,
                ValueFromPipelineByPropertyName = $True)]
            [string]$Section,

            [Parameter(Mandatory = $True,
                ValueFromPipelineByPropertyName = $True)]
            [string]$Key

        )
        Set-LastAction -LastAction "Parsing INI $File"
        $InitialMessage = [string]::Format("Parsing [File = '{0}'] for [Key = '{1}'] under [Section = '{2}']", $File, $Key, $Section)
        Write-Verbose $InitialMessage
        [object]$INI = New-Object -TypeName psobject

        switch -regex -file $File {
            '^\[(.+)\]' {
                #Section
                $INISection = $matches[1]
            }
            '(.+?)\s*=(.*)' {
                #Key
                $name, $value = $matches[1..2]
                $INI | Add-Member -MemberType NoteProperty -Name ('{0}.{1}' -f $INISection, $name) -Value $value
            }
        }

        #$Value = $INI[$Section][$Key]
        $Value = $INI.(('{0}.{1}' -f $Section, $key))
        If ($null -eq $Value) {
            Write-Warning "$Key value is blank"
        }
        Else {
            Write-Verbose "$Key value found"
            Write-Verbose "$Key = $Value"
            return $Value
        }
    }

    function Get-CMClientGUID {
        <#
            Checks WMI first, then parses SMSCFG.INI as a fallback to determine the current GUID associated with the machine.
        #>
        Try {
            $return = $null
            $GUID = Get-WmiObject -Namespace root\ccm -Query "Select ClientID from CCM_Client" | Select-Object -ExpandProperty ClientID
            if ([string]::IsNullOrWhiteSpace($GUID)) {
                Write-Error 'Failed to get CM Client GUID from WMI - falling back to parsing smscfg.ini'
                throw 'Failed to get CM Client GUID from WMI - falling back to parsing smscfg.ini'
            }
            else {
                $return = $GUID
            }
        }
        catch {
            $GUID = Get-CHini -File "$env:windir\smscfg.ini" -Section 'Configuration - Client Properties' -Key 'SID'
            if ([string]::IsNullOrWhiteSpace($GUID)) {
                Write-Error 'Failed to get CM Client GUID from smscfg.ini'
            }
            else {
                $return = $GUID
            }
        }
        Write-Host "SMSGUID: $return"
        Write-Output $return
    }
    #endregion Get-* functions

    #region Test-* functions
    Function Test-LocalLogging {
        $clientpath = Get-LocalFilesPath
        if ((Test-Path -Path $clientpath) -eq $False) {
            New-Item -Path $clientpath -ItemType Directory -Force | Out-Null
        }
    }

    Function Test-CcmSDF {
        <#
            .SYNOPSIS
            Function to test if local database files are missing from the ConfigMgr client.

            .DESCRIPTION
            Function to test if local database files are missing from the ConfigMgr client. Will tag client for reinstall if less than 7. Returns $True if compliant or $False if non-compliant

            .EXAMPLE
            An example

            .NOTES
            Returns $True if compliant or $False if non-compliant. Non.compliant computers require remediation and will be tagged for ConfigMgr client reinstall.
        #>

        $ccmdir = Get-CCMDirectory
        $files = @(Get-ChildItem "$ccmdir\*.sdf" -ErrorAction SilentlyContinue)
        if ($files.Count -lt 7) {
            $obj = $false
        }
        else {
            $obj = $true
        }
        Write-Output $obj
    }

    Function Test-CcmSQLCELog {
        $logdir = Get-CCMLogDirectory
        $ccmdir = Get-CCMDirectory
        $logFile = "$logdir\CcmSQLCE.log"
        $logLevel = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\CCM\Logging\@Global').logLevel

        if ( (Test-Path -Path $logFile) -and ($logLevel -ne 0) ) {
            # Not in debug mode, and CcmSQLCE.log exists. This could be bad.
            $LastWriteTime = (Get-ChildItem $logFile).LastWriteTime
            $CreationTime = (Get-ChildItem $logFile).CreationTime
            $FileDate = Get-Date($LastWriteTime)
            $FileCreated = Get-Date($CreationTime)

            $now = Get-Date
            if ( (($now - $FileDate).Days -lt 7) -and ((($now - $FileCreated).Days) -gt 7) ) {
                $text = "CM client not in debug mode, and CcmSQLCE.log exists. This is very bad. Cleaning up local SDF files and reinstalling CM client"
                Write-Host $text -ForegroundColor Red
                # Delete *.SDF Files
                $Service = Get-Service -Name ccmexec
                $Service.Stop()

                $seconds = 0
                Do {
                    Start-Sleep -Seconds 1
                    $seconds++
                } while ( ($Service.Status -ne "Stopped") -and ($seconds -le 60) )

                # Do another test to make sure CcmExec service really is stopped
                if ($Service.Status -ne "Stopped") {
                    Stop-Service -Name ccmexec -Force
                }

                Write-Verbose "Waiting 10 seconds to allow file locking issues to clear up"
                Start-Sleep -seconds 10

                try {
                    $files = Get-ChildItem "$ccmdir\*.sdf"
                    $files | Remove-Item -Force -ErrorAction Stop
                    Remove-Item -Path $logFile -Force -ErrorAction Stop
                }
                catch {
                    Write-Verbose "Obviously that wasn't enough time"
                    Start-Sleep -Seconds 30
                    # We try again
                    $files = Get-ChildItem "$ccmdir\*.sdf"
                    $files | Remove-Item -Force -ErrorAction SilentlyContinue
                    Remove-Item -Path $logFile -Force -ErrorAction SilentlyContinue
                }

                $obj = $true
            }

            # CcmSQLCE.log has not been updated for two days. We are good for now.
            else {
                $obj = $false
            }
        }

        # we are good
        else {
            $obj = $false
        }
        Write-Output $obj

    }

    function Test-CCMCertificateError {
        Param([Parameter(Mandatory = $true)]$Log)
        # More checks to come
        Set-LastAction -LastAction 'Valdating SCCM Client Certificate'
        $null = Get-XMLConfigRegistryKey
        $logdir = Get-CCMLogDirectory
        $logFile1 = "$logdir\ClientIDManagerStartup.log"
        $error1 = 'Failed to find the certificate in the store'
        $error2 = '[RegTask] - Server rejected registration 3'
        $content = Get-Content -Path $logFile1

        $ok = $true

        if ($content -match $error1) {
            $ok = $false
            $text = 'ConfigMgr Client Certificate: Error failed to find the certificate in store. Attempting fix.'
            Write-Warning $text
            Stop-Service -Name ccmexec -Force
            # Name is persistant across systems.
            $cert = "$env:ProgramData\Microsoft\Crypto\RSA\MachineKeys\19c5cf9c7b5dc9de3e548adb70398402_50e417e0-e461-474b-96e2-077b80325612"
            # CCM creates new certificate when missing.
            Remove-Item -Path $cert -Force -ErrorAction SilentlyContinue | Out-Null
            # Remove the error from the logfile to avoid double remediations based on false positives
            $newContent = $content | Select-String -pattern $Error1 -notmatch
            Out-File -FilePath $logfile -InputObject $newContent -Encoding utf8 -Force
            Start-Service -Name ccmexec
            $null = Set-RegistryValue -Path $RegistryKey -Name 'ConfigMgr Certificate' -Value 'Remediated'
            # Update log object
            $log.ClientCertificate = $error1
        }

        if ($content -match $error2) {
            $ok = $false
            $text = 'ConfigMgr Client Certificate: Error! Server rejected client registration. Client Certificate not valid. No auto-remediation.'
            Write-Error $text
            $null = Set-RegistryValue -Path $RegistryKey -Name 'ConfigMgr Certificate' -Value 'Server rejected registration'
            $log.ClientCertificate = $error2
        }

        if ($ok -eq $true) {
            $null = Set-RegistryValue -Path $RegistryKey -Name 'ConfigMgr Certificate' -Value 'Healthy'
            $text = 'ConfigMgr Client Certificate: OK'
            Write-Host $text
            $log.ClientCertificate = 'OK'
        }
    }

    Function Test-InTaskSequence {
        try {
            $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment -ErrorAction Stop
            if ($null -ne $tsenv) {
                $TSName = $tsenv.Value("_SMSTSAdvertID")
                Write-Error "Task sequence $TSName is active executing on computer. ConfigMgr Client Health will not execute."
                Exit 2
            }
        }
        catch {
            $tsenv = $null
        }
    }

    Function Test-BITS {
        Param([Parameter(Mandatory = $true)]$Log)

        if ($BitsCheckEnabled -eq $true) {
            Set-LastAction -LastAction 'Test-Bits'
            $Errors = Get-BitsTransfer -AllUsers | Where-Object { ($_.JobState -eq "TransientError") -or ($_.JobState -eq "Transient_Error") -or ($_.JobState -eq "Error") }

            if ($null -ne $Errors) {
                $fix = (Get-XMLConfigBITSCheckFix).ToLower()

                if ($fix -eq "true") {
                    $text = "BITS: Error. Remediating"
                    $Errors | Remove-BitsTransfer -ErrorAction SilentlyContinue
                    Invoke-Expression -Command 'sc.exe sdset bits "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"' | Out-Null
                    $log.BITS = 'Remediated'
                    $obj = $true
                }
                else {
                    $text = "BITS: Error. Monitor only"
                    $log.BITS = 'Error'
                    $obj = $false
                }
            }

            else {
                $text = "BITS: OK"
                $log.BITS = 'OK'
                $Obj = $false
            }

        }
        else {
            $text = "BITS: PowerShell Module BitsTransfer missing. Skipping check"
            $log.BITS = "PS Module BitsTransfer missing"
            $obj = $false
        }

        Write-Host $text
        Write-Output $Obj

    }

    Function Test-ClientSettingsConfiguration {
        Param([Parameter(Mandatory = $true)]$Log)

        $ClientSettingsConfig = @(Get-WmiObject -Namespace "root\ccm\Policy\DefaultMachine\RequestedConfig" -Class CCM_ClientAgentConfig -ErrorAction SilentlyContinue | Where-Object { $_.PolicySource -eq "CcmTaskSequence" })

        if ($ClientSettingsConfig.Count -gt 0) {

            $fix = (Get-XMLConfigClientSettingsCheckFix).ToLower()

            if ($fix -eq "true") {
                $text = "ClientSettings: Error. Remediating"
                DO {
                    Get-WmiObject -Namespace "root\ccm\Policy\DefaultMachine\RequestedConfig" -Class CCM_ClientAgentConfig | Where-Object { $_.PolicySource -eq "CcmTaskSequence" } | Select-Object -first 1000 | ForEach-Object { Remove-WmiObject -InputObject $_ }
                } Until (!(Get-WmiObject -Namespace "root\ccm\Policy\DefaultMachine\RequestedConfig" -Class CCM_ClientAgentConfig | Where-Object { $_.PolicySource -eq "CcmTaskSequence" } | Select-Object -first 1))
                $log.ClientSettings = 'Remediated'
            }
            else {
                $text = "ClientSettings: Error. Monitor only"
                $log.ClientSettings = 'Error'
            }
        }

        else {
            $text = "ClientSettings: OK"
            $log.ClientSettings = 'OK'
        }
        Write-Host $text
    }

    Function Test-LogFileHistory {
        Param([Parameter(Mandatory = $true)]$Logfile)
        $startString = '<--- ConfigMgr Client Health Check starting --->'
        $content = ''

        # Handle the network share log file
        if (Test-Path $logfile -ErrorAction SilentlyContinue) {
            $content = Get-Content $logfile -ErrorAction SilentlyContinue
        }
        else {
            return
        }
        $maxHistory = Get-XMLConfigLoggingMaxHistory
        $startCount = [regex]::matches($content, $startString).count

        # Delete logfile if more start and stop entries than max history
        if ($startCount -ge $maxHistory) {
            Remove-Item $logfile -Force
        }
    }

    Function Test-DNSConfiguration {
        Param([Parameter(Mandatory = $true)]$Log)
        Set-LastAction -LastAction 'Test DNS Configuration'
        $fqdn = [System.Net.Dns]::GetHostEntry([string]"localhost").HostName
        if ($PowerShellVersion -ge 6) {
            $localIPs = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -Match "True" } | Select-Object -ExpandProperty IPAddress
        }
        else {
            $localIPs = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -Match "True" } | Select-Object -ExpandProperty IPAddress
        }
        $dnscheck = [System.Net.DNS]::GetHostByName($fqdn)

        $OSName = Get-OperatingSystem
        if (($OSName -notlike "*Windows 7*") -and ($OSName -notlike "*Server 2008*")) {
            # This method is supported on Windows 8 / Server 2012 and higher. More acurate than using .NET object method
            try {
                $ActiveAdapters = (Get-NetAdapter | Where-Object { $_.Status -eq "Up" }).Name
                $dnsServers = Get-DnsClientServerAddress | Where-Object { $ActiveAdapters -contains $_.InterfaceAlias } | Where-Object { $_.AddressFamily -eq 2 } | Select-Object -ExpandProperty ServerAddresses
                $dnsAddressList = Resolve-DnsName -Name $fqdn -Server ($dnsServers | Select-Object -First 1) -Type A -DnsOnly | Select-Object -ExpandProperty IPAddress
            }
            catch {
                # Fallback to depreciated method
                $dnsAddressList = $dnscheck.AddressList | Select-Object -ExpandProperty IPAddressToString
                $dnsAddressList = $dnsAddressList -replace ("%(.*)", "")
            }
        }

        else {
            # This method cannot guarantee to only resolve against DNS sever. Local cache can be used in some circumstances.
            # For Windows 7 only

            $dnsAddressList = $dnscheck.AddressList | Select-Object -ExpandProperty IPAddressToString
            $dnsAddressList = $dnsAddressList -replace ("%(.*)", "")
        }

        $dnsFail = ''
        $logFail = ''

        Write-Verbose 'Verify that local machines FQDN matches DNS'
        if ($dnscheck.HostName -eq $fqdn) {
            $obj = $true
            Write-Verbose 'Checking if one local IP matches on IP from DNS'
            Write-Verbose 'Loop through each IP address published in DNS'
            foreach ($dnsIP in $dnsAddressList) {
                #Write-Host "Testing if IP address: $dnsIP published in DNS exist in local IP configuration."
                ##if ($dnsIP -notin $localIPs) { ## Requires PowerShell 3. Works fine :(
                if ($localIPs -notcontains $dnsIP) {
                    $dnsFail += "IP '$dnsIP' in DNS record do not exist locally`n"
                    $logFail += "$dnsIP "
                    $obj = $false
                }
            }
        }
        else {
            $hn = $dnscheck.HostName
            $dnsFail = 'DNS name: ' + $hn + ' local fqdn: ' + $fqdn + ' DNS IPs: ' + $dnsAddressList + ' Local IPs: ' + $localIPs
            $obj = $false
            Write-Host $dnsFail
        }

        $FileLogLevel = ((Get-XMLConfigLoggingLevel).ToString()).ToLower()

        $RegistryKey = Get-XMLConfigRegistryKey
        switch ($obj) {
            $false {
                $fix = (Get-XMLConfigDNSFix).ToLower()
                if ($fix -eq "true") {
                    $text = 'DNS Check: FAILED. IP address published in DNS do not match IP address on local machine. Trying to resolve by registerting with DNS server'
                    if ($PowerShellVersion -ge 4) {
                        Register-DnsClient | Out-Null
                    }
                    else {
                        ipconfig /registerdns | Out-Null
                    }
                    $null = Set-RegistryValue -Path $RegistryKey -Name 'DNS' -Value 'Remediated'
                    Write-Host $text
                    $log.DNS = $logFail
                    if (-NOT($FileLogLevel -eq "clientlocal")) {
                        Out-LogFile -Text $text -Severity 2
                        Out-LogFile -Text $dnsFail -Severity 2
                    }

                }
                else {
                    $text = 'DNS Check: FAILED. IP address published in DNS do not match IP address on local machine. Monitor mode only, no remediation'
                    $log.DNS = $logFail
                    if (-NOT($FileLogLevel -eq "clientlocal")) {
                        Out-LogFile -Text $text  -Severity 2
                    }
                    $null = Set-RegistryValue -Path $RegistryKey -Name 'DNS' -Value 'Unhealthy'
                    Write-Host $text
                }

            }
            $true {
                $text = 'DNS Check: OK'
                Write-Host $text
                $null = Set-RegistryValue -Path $RegistryKey -Name 'DNS' -Value 'Healthy'
                $log.DNS = 'OK'
            }
        }
        #Write-Output $obj
    }

    # Function to test that 'HKU:\S-1-5-18\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders\' is set to '%USERPROFILE%\AppData\Roaming'. CCMSETUP will fail if not.
    # Reference: https://www.systemcenterdudes.com/could-not-access-network-location-appdata-ccmsetup-log/
    Function Test-CCMSetup1 {
        New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS -ErrorAction SilentlyContinue | Out-Null
        $correctValue = '%USERPROFILE%\AppData\Roaming'
        $currentValue = (Get-Item 'HKU:\S-1-5-18\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders\').GetValue('AppData', $null, 'DoNotExpandEnvironmentNames')

        # Only fix if the value is wrong
        if ($currentValue -ne $correctValue) {
            Set-ItemProperty -Path  'HKU:\S-1-5-18\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders\' -Name 'AppData' -Value $correctValue
        }
    }

    Function Test-Update {
        Param([Parameter(Mandatory = $true)]$Log)

        #if (($Xml.Configuration.Option | Where-Object {$_.Name -eq 'Updates'} | Select-Object -ExpandProperty 'Enable') -eq 'True') {

        $UpdateShare = Get-XMLConfigUpdatesShare
        #$UpdateShare = $Xml.Configuration.Option | Where-Object {$_.Name -eq 'Updates'} | Select-Object -ExpandProperty 'Share'


        Write-Verbose "Validating required updates is installed on the client. Required updates will be installed if missing on client."
        #$OS = Get-WmiObject -class Win32_OperatingSystem
        $OSName = Get-OperatingSystem


        $build = $null
        if ($OSName -like "*Windows 10*") {
            $build = Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber
            switch ($build) {
                10240 {
                    $OSName = $OSName + " 1507"
                }
                10586 {
                    $OSName = $OSName + " 1511"
                }
                14393 {
                    $OSName = $OSName + " 1607"
                }
                15063 {
                    $OSName = $OSName + " 1703"
                }
                16299 {
                    $OSName = $OSName + " 1709"
                }
                17134 {
                    $OSName = $OSName + " 1803"
                }
                17763 {
                    $OSName = $OSName + " 1809"
                }
                default {
                    $OSName = $OSName + " Insider Preview"
                }
            }
        }

        $Updates = (Join-Path $UpdateShare $OSName)
        If ((Test-Path $Updates) -eq $true) {
            $regex = '(?i)^.+-kb[0-9]{6,}-(?:v[0-9]+-)?x[0-9]+\.msu$'
            $hotfixes = @(Get-ChildItem $Updates | Where-Object { $_.Name -match $regex } | Select-Object -ExpandProperty Name)

            if ($PowerShellVersion -ge 6) {
                $installedUpdates = @((Get-CimInstance Win32_QuickFixEngineering).HotFixID)
            }
            else {
                $installedUpdates = @(Get-HotFix | Select-Object -ExpandProperty HotFixID)
            }

            $count = $hotfixes.count

            if (($count -eq 0) -or ($null -eq $count)) {
                $text = 'Updates: No mandatory updates to install.'
                Write-Host $text
                $log.Updates = 'OK'
            }
            else {
                $logEntry = $null

                $regex = '\b(?!(KB)+(\d+)\b)\w+'
                foreach ($hotfix in $hotfixes) {
                    $kb = $hotfix -replace $regex -replace "\." -replace "-"
                    if ($installedUpdates -contains $kb) {
                        $text = "Update $hotfix" + ": OK"
                        Write-Host $text
                    }
                    else {
                        if ($null -eq $logEntry) {
                            $logEntry = $kb
                        }
                        else {
                            $logEntry += ", $kb"
                        }

                        $fix = (Get-XMLConfigUpdatesFix).ToLower()
                        if ($fix -eq "true") {
                            $kbfullpath = Join-Path $updates $hotfix
                            $text = "Update $hotfix" + ": Missing. Installing now..."
                            Write-Warning $text

                            $temppath = Join-Path (Get-LocalFilesPath) "Temp"

                            If ((Test-Path $temppath) -eq $false) {
                                New-Item -Path $temppath -ItemType Directory | Out-Null
                            }

                            Copy-Item -Path $kbfullpath -Destination $temppath
                            $install = Join-Path $temppath $hotfix

                            wusa.exe $install /quiet /norestart
                            While (Get-Process wusa -ErrorAction SilentlyContinue) {
                                Start-Sleep -Seconds 2
                            }
                            Remove-Item $install -Force -Recurse

                        }
                        else {
                            $text = "Update $hotfix" + ": Missing. Monitor mode only, no remediation."
                            Write-Warning $text
                        }
                    }

                    if ($null -eq $logEntry) {
                        $log.Updates = 'OK'
                    }
                    else {
                        $log.Updates = $logEntry
                    }
                }
            }
        }
        Else {
            $log.Updates = 'Failed'
            Write-Warning "Updates Failed: Could not locate update folder '$($Updates)'."
        }
    }

    Function Test-ConfigMgrClient {
        Param([Parameter(Mandatory = $true)]$Log)
        Set-LastAction 'Testing SCCM Client'
        # Check if the SCCM Agent is installed or not.
        # If installed, perform tests to decide if reinstall is needed or not.
        # return a boolean if installed
        if (Get-Service -Name ccmexec -ErrorAction SilentlyContinue) {
            $text = "Configuration Manager Client is installed"
            Write-Host $text

            # Lets not reinstall client unless tests tells us to.
            $Reinstall = $false

            # We test that the local database files exists. Less than 7 means the client is horrible broken and requires reinstall.
            $LocalDBFilesPresent = Test-CcmSDF
            if ($LocalDBFilesPresent -eq $False) {
                New-ClientInstalledReason -Log $Log -Message "ConfigMgr Client database files missing."
                Write-Host "ConfigMgr Client database files missing. Reinstalling..."
                # Add /ForceInstall to Client Install Properties to ensure the client is uninstalled before we install client again.
                #if (-NOT ($clientInstallProperties -like "*/forceinstall*")) { $clientInstallProperties = $clientInstallProperties + " /forceinstall" }
                $Reinstall = $true
                $Uninstall = $true
            }

            # Only test CM client local DB if this check is enabled
            $testLocalDB = (Get-XMLConfigCcmSQLCELog).ToLower()
            if ($testLocalDB -eq "enable") {
                Write-Host "Testing CcmSQLCELog"
                $LocalDB = Test-CcmSQLCELog
                if ($LocalDB -eq $true) {
                    # LocalDB is messed up
                    New-ClientInstalledReason -Log $Log -Message "ConfigMgr Client database corrupt."
                    Write-Host "ConfigMgr Client database corrupt. Reinstalling..."
                    $Reinstall = $true
                    $Uninstall = $true
                }
            }

            $CCMService = Get-Service -Name ccmexec -ErrorAction SilentlyContinue

            # Reinstall if we are unable to start the CM client
            if (($CCMService.Status -eq "Stopped") -and ($LocalDB -eq $false)) {
                try {
                    Write-Host "ConfigMgr Agent not running. Attempting to start it."
                    if ($CCMService.StartType -ne "Automatic") {
                        $text = "Configuring service CcmExec StartupType to: Automatic (Delayed Start)..."
                        Write-Host $text
                        Set-Service -Name CcmExec -StartupType Automatic
                    }
                    Start-Service -Name CcmExec
                }
                catch {
                    $Reinstall = $true
                    New-ClientInstalledReason -Log $Log -Message "Service not running, failed to start."
                }
            }

            # Test that we are able to connect to SMS_Client WMI class
            Try {
                if ($PowerShellVersion -ge 6) {
                    $null = Get-CimInstance -Namespace root/ccm -Class SMS_Client -ErrorAction Stop
                }
                else {
                    $null = Get-WmiObject -Namespace root/ccm -Class SMS_Client -ErrorAction Stop
                }
            }
            Catch {
                Write-Verbose 'Failed to connect to WMI namespace "root/ccm" class "SMS_Client". Clearing WMI and tagging client for reinstall to fix.'

                # Clear the WMI namespace to avoid having to uninstall first
                # This is the same action the install after an uninstall would perform
                Get-WmiObject -Query "Select * from __Namespace WHERE Name='CCM'" -Namespace root | Remove-WmiObject

                $Reinstall = $true
                New-ClientInstalledReason -Log $Log -Message "Failed to connect to SMS_Client WMI class."
            }

            if ( $reinstall -eq $true) {
                $text = "ConfigMgr Client Health thinks the agent need to be reinstalled.."
                Write-Host $text
                # Lets check that registry settings are OK before we try a new installation.
                Test-CCMSetup1

                # Adding forceinstall to the client install properties to make sure previous client is uninstalled.
                #if ( ($localDB -eq $true) -and (-NOT ($clientInstallProperties -like "*/forceinstall*")) ) { $clientInstallProperties = $clientInstallProperties + " /forceinstall" }
                Invoke-CMClientRemediationAction -Install
                $log.ClientInstalled = Get-SmallDateTime
                Start-Sleep 600
                return $true
            }
            else {
                return $true
            }
        }
        else {
            $text = "Configuration Manager client is not installed. Installing..."
            Write-Host $text
            Invoke-CMClientRemediationAction -Install -FirstInstall
            New-ClientInstalledReason -Log $Log -Message "No agent found."
            $log.ClientInstalled = Get-SmallDateTime
            #Start-Sleep 600

            # Test again if agent is installed
            if (Get-Service -Name ccmexec -ErrorAction SilentlyContinue) {
                return $true
            }
            else {
                Write-Error "ConfigMgr Client installation failed. Agent not detected 10 minutes after triggering installation."
                return $false
            }
        }
    }

    Function Test-ClientCacheSize {
        Param([Parameter(Mandatory = $true)]$Log)
        $ClientCacheSize = Get-XMLConfigClientCache
        #if ($PowerShellVersion -ge 6) { $Cache = Get-CimInstance -Namespace "ROOT\CCM\SoftMgmtAgent" -Class CacheConfig }
        #else { $Cache = Get-WmiObject -Namespace "ROOT\CCM\SoftMgmtAgent" -Class CacheConfig }

        $CurrentCache = Get-ClientCache

        if ($ClientCacheSize -match '%') {
            $type = 'percentage'
            # percentage based cache based on disk space
            $num = $ClientCacheSize -replace '%'
            $num = ($num / 100)
            # TotalDiskSpace in Byte
            if ($PowerShellVersion -ge 6) {
                $TotalDiskSpace = (Get-CimInstance -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "$env:SystemDrive" } | Select-Object -ExpandProperty Size)
            }
            else {
                $TotalDiskSpace = (Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "$env:SystemDrive" } | Select-Object -ExpandProperty Size)
            }
            $ClientCacheSize = ([math]::Round(($TotalDiskSpace * $num) / 1048576))
        }
        else {
            $type = 'fixed'
        }

        if ($CurrentCache -eq $ClientCacheSize) {
            $text = "ConfigMgr Client Cache Size: OK"
            Write-Host $text
            $Log.CacheSize = $CurrentCache
            $obj = $false
        }

        else {
            switch ($type) {
                'fixed' {
                    $text = "ConfigMgr Client Cache Size: $CurrentCache. Expected: $ClientCacheSize. Remediating."
                }
                'percentage' {
                    $percent = Get-XMLConfigClientCache
                    if ($ClientCacheSize -gt "99999") {
                        $ClientCacheSize = "99999"
                    }
                    $text = "ConfigMgr Client Cache Size: $CurrentCache. Expected: $ClientCacheSize ($percent). (99999 maximum). Remediating."
                }
            }

            Write-Warning $text
            #$Cache.Size = $ClientCacheSize
            #$Cache.Put()
            $log.CacheSize = $ClientCacheSize
            (New-Object -ComObject UIResource.UIResourceMgr).GetCacheInfo().TotalSize = "$ClientCacheSize"
            $obj = $true
        }
        Write-Output $obj
    }

    Function Test-ClientVersion {
        Param([Parameter(Mandatory = $true)]$Log)
        $ClientVersion = Get-XMLConfigClientVersion
        [String]$ClientAutoUpgrade = Get-XMLConfigClientAutoUpgrade
        $ClientAutoUpgrade = $ClientAutoUpgrade.ToLower()
        $installedVersion = Get-ClientVersion
        $log.ClientVersion = $installedVersion

        if ($installedVersion -ge $ClientVersion) {
            $text = 'ConfigMgr Client version is: ' + $installedVersion + ': OK'
            Write-Host $text
            $obj = $false
        }
        elseif ($ClientAutoUpgrade -eq 'true') {
            $text = 'ConfigMgr Client version is: ' + $installedVersion + ': Tagging client for upgrade to version: ' + $ClientVersion
            Write-Warning $text
            $obj = $true
        }
        else {
            $text = 'ConfigMgr Client version is: ' + $installedVersion + ': Required version: ' + $ClientVersion + ' AutoUpgrade: false. Skipping upgrade'
            Write-Host $text
            $obj = $false
        }
        Write-Output $obj
    }

    Function Test-ClientSiteCode {
        Param([Parameter(Mandatory = $true)]$Log)
        $ClientSiteCode = Get-XMLConfigClientSitecode
        [String]$currentSiteCode = Get-ClientSiteCode
        if ($null -ne $currentSiteCode) {
            $null = Set-RegistryValue -Path $RegistryKey -Name 'AgentSite' -Value $currentSiteCode
        }
        $Log.Sitecode = $currentSiteCode

        if ($ClientSiteCode -eq $currentSiteCode) {
            $text = "ConfigMgr Client Site Code: OK"
            Write-Host $text
        }
        else {
            $text = [string]::Format('ConfigMgr Client Site Code is "{0}". Expected: "{1}". Changing SiteCode.', $currentSiteCode, $ClientSiteCode)
            Write-Warning $text
            $sms.SetAssignedSite($ClientSiteCode)
        }
    }

    function Test-PendingReboot {
        Param([Parameter(Mandatory = $true)]$Log)
        # Only run pending reboot check if enabled in config
        if (($Xml.Configuration.Option | Where-Object { $_.Name -like 'PendingReboot' } | Select-Object -ExpandProperty 'Enable') -like 'True') {
            $result = @{
                CBSRebootPending            = $false
                WindowsUpdateRebootRequired = $false
                FileRenamePending           = $false
                SCCMRebootPending           = $false
            }

            #Check CBS Registry
            $key = Get-ChildItem "HKLM:Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -ErrorAction SilentlyContinue
            if ($null -ne $key) {
                $result.CBSRebootPending = $true
            }

            #Check Windows Update
            $key = Get-Item 'HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired' -ErrorAction SilentlyContinue
            if ($null -ne $key) {
                $result.WindowsUpdateRebootRequired = $true
            }

            #Check PendingFileRenameOperations
            $prop = Get-ItemProperty 'HKLM:SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue
            if ($null -ne $prop) {
                #PendingFileRenameOperations is not *must* to reboot?
                #$result.FileRenamePending = $true
            }

            try {
                $util = [wmiclass]'\\.\root\ccm\clientsdk:CCM_ClientUtilities'
                $status = $util.DetermineIfRebootPending()
                if (($null -ne $status) -and $status.RebootPending) {
                    $result.SCCMRebootPending = $true
                }
            }
            catch {
            }

            #Return Reboot required
            if ($result.ContainsValue($true)) {
                $text = 'Pending Reboot: Computer is in pending reboot'
                Write-Warning $text
                Write-Output $true
                $log.PendingReboot = 'Pending Reboot'

                if ((Get-XMLConfigPendingRebootApp) -eq $true) {
                    Start-RebootApplication
                    $log.RebootApp = Get-SmallDateTime
                }
            }
            else {
                $text = 'Pending Reboot: OK'
                Write-Host $text
                $log.PendingReboot = 'OK'
                Write-Output $false
            }
            #Out-LogFile -Xml $xml -Text $text
        }
    }

    # Functions to detect and fix errors
    Function Test-ProvisioningMode {
        Param([Parameter(Mandatory = $true)]$Log)
        Set-LastAction -LastAction 'Testing Provisiong Mode'
        $RegistryKey = Get-XmlConfigRegistryKey
        $registryPath = 'HKLM:\SOFTWARE\Microsoft\CCM\CcmExec'
        $provisioningMode = Get-RegistryValue -Path $registryPath -Name ProvisiongMode

        if ($provisioningMode -eq 'true') {
            $text = 'ConfigMgr Client Provisioning Mode: YES. Remediating...'
            Write-Warning $text
            try {
                $Client = New-Object -comobject "Microsoft.SMS.Client"
                $Client.SetClientProvisioningMode($false)
                $log.ProvisioningMode = 'Repaired'
                $null = Set-RegistryValue -Path $RegistryKey -Name 'ProvisioningMode' -Value 'Remediated'
            }
            catch {
                Write-Error 'Failed to remediate provisiong mode'
                $null = Set-RegistryValue -Path $RegistryKey -Name 'ProvisioningMode' -Value 'Remediation Failed'
            }
        }
        else {
            $text = 'ConfigMgr Client Provisioning Mode: OK'
            $null = Set-RegistryValue -Path $RegistryKey -Name 'ProvisioningMode' -Value 'Off'
            Write-Host $text
            $log.ProvisioningMode = 'OK'
        }
    }

    Function Test-UpdateStore {
        Param([Parameter(Mandatory = $true)]$Log)
        Write-Verbose "Check StateMessage.log if State Messages are successfully forwarded to Management Point"
        $logdir = Get-CCMLogDirectory
        $logfile = "$logdir\StateMessage.log"
        $StateMessage = Get-Content($logfile)
        if ($StateMessage -match 'Successfully forwarded State Messages to the MP') {
            $text = 'StateMessage: OK'
            $log.StateMessages = 'OK'
            Write-Host $text
        }
        else {
            $text = 'StateMessage: ERROR. Remediating...'
            Write-Warning $text
            Update-State
            $log.StateMessages = 'Repaired'
        }
    }

    Function Test-RegistryPol {
        Param(
            [datetime]$StartTime = [datetime]::MinValue,
            $Days,
            [Parameter(Mandatory = $true)]$Log)
        $log.WUAHandler = "Checking"
        $RepairReason = ""
        $MachineRegistryFile = "$($env:WinDir)\System32\GroupPolicy\Machine\registry.pol"

        # Check 1 - Error in WUAHandler.log
        Write-Verbose "Check WUAHandler.log for errors since $($StartTime)."
        $logdir = Get-CCMLogDirectory
        $logfile = "$logdir\WUAHandler.log"
        $logLine = Search-CMLogFile -LogFile $logfile -StartTime $StartTime -SearchStrings @('0x80004005', '0x87d00692')
        if ($logLine) {
            $RepairReason = "WUAHandler Log"
        }

        # Check 2 - Registry.pol is too old.
        if ($Days) {
            Write-Verbose "Check machine registry file to see if it's older than $($Days) days."
            try {
                $file = Get-ChildItem -Path $MachineRegistryFile -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty LastWriteTime
                $regPolDate = Get-Date($file)
                $now = Get-Date
                if (($now - $regPolDate).Days -ge $Days) {
                    $RepairReason = "File Age"
                }
            }
            catch {
                Write-Warning "GPO Cache: Failed to check machine policy age."
            }
        }

        # Check 3 - Look back through the last 7 days for group policy processing errors.
        #Event IDs documented here: https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-vista/cc749336(v=ws.10)#troubleshooting-group-policy-using-event-logs-1
        try {
            Write-Verbose "Checking the Group Policy event log for errors since $($StartTime)."
            $numberOfGPOErrors = (Get-WinEvent -Verbose:$false -FilterHashTable @{LogName = 'Microsoft-Windows-GroupPolicy/Operational'; Level = 2; StartTime = $StartTime } -ErrorAction SilentlyContinue | Where-Object { ($_.ID -ge 7000 -and $_.ID -le 7007) -or ($_.ID -ge 7017 -and $_.ID -le 7299) -or ($_.ID -eq 1096) }).Count
            if ($numberOfGPOErrors -gt 0) {
                $RepairReason = "Event Log"
            }

        }
        catch {
            Write-Warning "GPO Cache: Failed to check the event log for policy errors."
        }

        #If we need to repart the policy files then do so.
        if ($RepairReason -ne "") {
            $log.WUAHandler = "Broken ($RepairReason)"
            Write-Warning "GPO Cache: Broken ($RepairReason)"
            Write-Verbose 'Deleting registry.pol and running gpupdate...'

            try {
                if (Test-Path -Path $MachineRegistryFile) {
                    Remove-Item $MachineRegistryFile -Force
                }
            }
            catch {
                Write-Warning "GPO Cache: Failed to remove the registry file ($($MachineRegistryFile))."
            }
            finally {
                & Write-Output n | gpupdate.exe /force /target:computer | Out-Null
            }

            #Write-Verbose 'Sleeping for 1 minute to allow for group policy to refresh'
            #Start-Sleep -Seconds 60

            Write-Verbose 'Refreshing update policy'
            Invoke-CCMClientAction -Schedule UpdateScan, SourceUpdateMessage -Delay 5 -Timeout 1

            $log.WUAHandler = "Repaired ($RepairReason)"
            Write-Host "GPO Cache: $($log.WUAHandler)"
        }
        else {
            $log.WUAHandler = 'OK'
            Write-Host "GPO Cache: OK"
        }
    }

    Function Test-ClientLogSize {
        Param([Parameter(Mandatory = $true)]$Log)
        try {
            [int]$currentLogSize = Get-ClientMaxLogSize
        }
        catch {
            [int]$currentLogSize = 0
        }
        try {
            [int]$currentMaxHistory = Get-ClientMaxLogHistory
        }
        catch {
            [int]$currentMaxHistory = 0
        }
        try {
            $logLevel = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\CCM\Logging\@Global').logLevel
        }
        catch {
            $logLevel = 1
        }

        $clientLogSize = Get-XMLConfigClientMaxLogSize
        $clientLogMaxHistory = Get-XMLConfigClientMaxLogHistory

        $text = ''

        if ( ($currentLogSize -eq $clientLogSize) -and ($currentMaxHistory -eq $clientLogMaxHistory) ) {
            $Log.MaxLogSize = $currentLogSize
            $Log.MaxLogHistory = $currentMaxHistory
            $text = "ConfigMgr Client Max Log Size: OK ($currentLogSize)"
            Write-Host $text
            $text = "ConfigMgr Client Max Log History: OK ($currentMaxHistory)"
            Write-Host $text
            $obj = $false
        }
        else {
            if ($currentLogSize -ne $clientLogSize) {
                $text = 'ConfigMgr Client Max Log Size: Configuring to ' + $clientLogSize + ' KB'
                $Log.MaxLogSize = $clientLogSize
                Write-Warning $text
            }
            else {
                $text = "ConfigMgr Client Max Log Size: OK ($currentLogSize)"
                Write-Host $text
            }
            if ($currentMaxHistory -ne $clientLogMaxHistory) {
                $text = 'ConfigMgr Client Max Log History: Configuring to ' + $clientLogMaxHistory
                $Log.MaxLogHistory = $clientLogMaxHistory
                Write-Warning $text
            }
            else {
                $text = "ConfigMgr Client Max Log History: OK ($currentMaxHistory)"
                Write-Host $text
            }

            $newLogSize = [int]$clientLogSize
            $newLogSize = $newLogSize * 1000

            if ($PowerShellVersion -ge 6) {
                Invoke-CimMethod -Namespace "root/ccm" -ClassName "sms_client" -MethodName SetGlobalLoggingConfiguration -Arguments @{LogLevel = $loglevel; LogMaxHistory = $clientLogMaxHistory; LogMaxSize = $newLogSize }
            }
            else {
                $smsClient = [wmiclass]"root/ccm:sms_client"
                $smsClient.SetGlobalLoggingConfiguration($logLevel, $newLogSize, $clientLogMaxHistory)
            }
            #Write-Verbose 'Returning true to trigger restart of ccmexec service'

            #Write-Verbose 'Sleeping for 5 seconds to allow WMI method complete before we collect new results...'
            #Start-Sleep -Seconds 5

            try {
                $Log.MaxLogSize = Get-ClientMaxLogSize
            }
            catch {
                $Log.MaxLogSize = 0
            }
            try {
                $Log.MaxLogHistory = Get-ClientMaxLogHistory
            }
            catch {
                $Log.MaxLogHistory = 0
            }
            $obj = $true
        }
        Write-Output $obj
    }

    # Test if the compliance state messages should be resent.
    Function Test-RefreshComplianceState {
        Param(
            $Days = 0,
            [Parameter(Mandatory = $true)]$RegistryKey,
            [Parameter(Mandatory = $true)]$Log
        )
        $RegValueName = "RefreshServerComplianceState"

        #Get the last time this script was ran.  If the registry isn't found just use the current date.
        Try {
            [datetime]$LastSent = Get-RegistryValue -Path $RegistryKey -Name $RegValueName
        }
        Catch {
            [datetime]$LastSent = Get-Date
        }

        Write-Verbose "The compliance states were last sent on $($LastSent)"
        #Determine the number of days until the next run.
        $NumberOfDays = (New-TimeSpan -Start (Get-Date) -End ($LastSent.AddDays($Days))).Days

        #Resend complianc states if the next interval has already arrived or randomly based on the number of days left until the next interval.
        If (($NumberOfDays -le 0) -or ((Get-Random -Maximum $NumberOfDays) -eq 0 )) {
            Try {
                Write-Verbose "Resending compliance states."
                (New-Object -ComObject Microsoft.CCM.UpdatesStore).RefreshServerComplianceState()
                $LastSent = Get-Date
                Write-Host "Compliance States: Refreshed."
            }
            Catch {
                Write-Error "Failed to resend the compliance states."
                $LastSent = [datetime]::MinValue
            }
        }
        Else {
            Write-Host "Compliance States: OK."
        }

        $null = Set-RegistryValue -Path $RegistryKey -Name $RegValueName -Value $LastSent
        $Log.RefreshComplianceState = Get-SmallDateTime $LastSent
    }

    Function Test-SMSTSMgr {
        $service = Get-Service smstsmgr
        if (($service.ServicesDependedOn).name -contains "ccmexec") {
            Write-Host "SMSTSMgr: Removing dependency on CCMExec service."
            Start-Process sc.exe -ArgumentList "config smstsmgr depend= winmgmt" -wait
        }

        # WMI service depenency is present by default
        if (($service.ServicesDependedOn).name -notcontains "Winmgmt") {
            Write-Host "SMSTSMgr: Adding dependency on Windows Management Instrumentaion service."
            Start-Process sc.exe -ArgumentList "config smstsmgr depend= winmgmt" -wait
        }
        else {
            Write-Host "SMSTSMgr: OK"
        }
    }

    # Windows Service Functions
    Function Test-Services {
        Param([Parameter(Mandatory = $false)]$Xml, $log, $ProfileID)

        $log.Services = 'OK'

        # Test services defined by config.xml
        if ($Config) {
            Write-Verbose 'Test services from XML configuration file'
            foreach ($service in $Xml.Configuration.Service) {
                $startuptype = ($service.StartupType).ToLower()

                if ($startuptype -eq "automatic (delayed start)") {
                    $service.StartupType = "automaticd"
                }

                if ($service.uptime) {
                    $uptime = ($service.Uptime).ToLower()
                    Test-Service -Name $service.Name -StartupType $service.StartupType -State $service.State -Log $log -Uptime $uptime
                }
                else {
                    Test-Service -Name $service.Name -StartupType $service.StartupType -State $service.State -Log $log
                }
            }
        }
    }

    Function Test-Service {
        param(
            [Parameter(Mandatory = $True,
                HelpMessage = 'Name')]
            [string]$Name,
            [Parameter(Mandatory = $True,
                HelpMessage = 'StartupType: Automatic, Automatic (Delayed Start), Manual, Disabled')]
            [string]$StartupType,
            [Parameter(Mandatory = $True,
                HelpMessage = 'State: Running, Stopped')]
            [string]$State,
            [Parameter(Mandatory = $False,
                HelpMessage = 'Updatime in days')]
            [int]$Uptime,
            [Parameter(Mandatory = $True)]$log
        )
        $RegistryKey = Get-XMLConfigRegistryKey
        $OSName = Get-OperatingSystem
        Set-LastAction -LastAction "Testing Service: $Name"
        # Handle all sorts of casing and mispelling of delayed and triggerd start in config.xml services
        $val = $StartupType.ToLower()
        switch -Wildcard ($val) {
            "automaticd*" {
                $StartupType = "Automatic (Delayed Start)"
            }
            "automatic(d*" {
                $StartupType = "Automatic (Delayed Start)"
            }
            "automatic(t*" {
                $StartupType = "Automatic (Trigger Start)"
            }
            "automatict*" {
                $StartupType = "Automatic (Trigger Start)"
            }
        }

        $path = "HKLM:\SYSTEM\CurrentControlSet\Services\$name"

        $DelayedAutostart = (Get-ItemProperty -Path $path).DelayedAutostart
        if ($DelayedAutostart -ne 1) {
            $DelayedAutostart = 0
        }

        $service = Get-Service -Name $Name
        if ($PowerShellVersion -ge 6) {
            $WMIService = Get-CimInstance -Class Win32_Service -Property StartMode, ProcessID, Status -Filter "Name='$Name'"
        }
        else {
            $WMIService = Get-WmiObject -Class Win32_Service -Property StartMode, ProcessID, Status -Filter "Name='$Name'"
        }
        $StartMode = ($WMIService.StartMode).ToLower()

        switch -Wildcard ($StartMode) {
            "auto*" {
                if ($DelayedAutostart -eq 1) {
                    $serviceStartType = "Automatic (Delayed Start)"
                }
                else {
                    $serviceStartType = "Automatic"
                }
            }

            <# This will be implemented at a later time.
            "automatic d*" {$serviceStartType = "Automatic (Delayed Start)"}
            "automatic (d*" {$serviceStartType = "Automatic (Delayed Start)"}
            "automatic (t*" {$serviceStartType = "Automatic (Trigger Start)"}
            "automatic t*" {$serviceStartType = "Automatic (Trigger Start)"}
            #>
            "manual" {
                $serviceStartType = "Manual"
            }
            "disabled" {
                $serviceStartType = "Disabled"
            }
        }

        Write-Verbose "Verify startup type"
        if ($serviceStartType -eq $StartupType) {
            $text = "Service $Name startup: OK"
            $null = Set-RegistryValue -Path $RegistryKey -Name "Service $Name startup" -Value "Healthy"
            Write-Host $text
        }
        elseif ($StartupType -eq "Automatic (Delayed Start)") {
            # Handle Automatic Trigger Start the dirty way for these two services. Implement in a nice way in future version.
            if ( (($name -eq "wuauserv") -or ($name -eq "W32Time")) -and (($OSName -like "Windows 10*") -or ($OSName -like "*Server 2016*")) ) {
                if ($service.StartType -ne "Automatic") {
                    $text = "Configuring service $Name StartupType to: Automatic"
                    $null = Set-RegistryValue -Path $RegistryKey -Name "Service $Name startup" -Value "Remediated"
                    Set-Service -Name $service.Name -StartupType Automatic
                }
                else {
                    $null = Set-RegistryValue -Path $RegistryKey -Name "Service $Name startup" -Value "Healthy"
                    $text = "Service $Name startup: OK"
                }
                Write-Host $text
            }
            else {
                # Automatic delayed requires the use of sc.exe
                & sc.exe config $service start= delayed-auto | Out-Null
                $text = "Configuring service $Name StartupType to: $StartupType..."
                $null = Set-RegistryValue -Path $RegistryKey -Name "Service $Name startup" -Value "Remediated"
                Write-Host $text
                $log.Services = 'Started'
            }
        }

        else {
            try {
                $text = "Configuring service $Name StartupType to: $StartupType..."
                Write-Host $text
                Set-Service -Name $service.Name -StartupType $StartupType
                $null = Set-RegistryValue -Path $RegistryKey -Name "Service $Name startup" -Value "Remediated"
                $log.Services = 'Started'
            }
            catch {
                $null = Set-RegistryValue -Path $RegistryKey -Name "Service $Name startup" -Value "Failed to Remediate"
                $text = "Failed to set $StartupType StartupType on service $Name"
                Write-Error $text
            }
        }

        Write-Verbose 'Verify service is running'
        if ($service.Status -eq "Running") {
            $text = 'Service ' + $Name + ' running: OK'
            Write-Host $text

            #If we are checking uptime.
            If ($Uptime) {
                Write-Verbose "Verify the $($Name) service hasn't exceeded uptime of $($Uptime) days."
                $ServiceUptime = Get-ServiceUpTime -Name $Name
                if ($ServiceUptime -ge $Uptime) {
                    try {

                        #Before restarting the service wait for some known processes to end.  Restarting the service while an app or updates is installing might cause issues.
                        $Timer = [Diagnostics.Stopwatch]::StartNew()
                        $WaitMinutes = 30
                        $ProcessesStopped = $True
                        While ((Get-Process -Name WUSA, wuauclt, setup, TrustedInstaller, msiexec, TiWorker, ccmsetup -ErrorAction SilentlyContinue).Count -gt 0) {
                            $MinutesLeft = $WaitMinutes - $Timer.Elapsed.Minutes

                            If ($MinutesLeft -le 0) {
                                Write-Warning "Timed out waiting $($WaitMinutes) minutes for installation processes to complete.  Will not restart the $($Name) service."
                                $ProcessesStopped = $False
                                Break
                            }
                            Write-Warning "Waiting $($MinutesLeft) minutes for installation processes to complete."
                            Start-Sleep -Seconds 30
                        }
                        $Timer.Stop()

                        #If the processes are not running the restart the service.
                        If ($ProcessesStopped) {
                            Write-Host "Restarting service: $($Name)..."
                            Restart-Service  -Name $service.Name -Force
                            Write-Host "Restarted service: $($Name)..."
                            $null = Set-RegistryValue -Path $RegistryKey -Name "Service $Name uptime" -Value "Restarted"
                            $log.Services = 'Restarted'
                        }
                    }
                    catch {
                        $null = Set-RegistryValue -Path $RegistryKey -Name "Service $Name uptime" -Value "Failed to restart"
                        $text = "Failed to restart service $($Name)"
                        Write-Error $text
                    }
                }
                else {
                    $null = Set-RegistryValue -Path $RegistryKey -Name "Service $Name uptime" -Value "Healthy"
                    Write-Host "Service $($Name) uptime: OK"
                }
            }
        }
        else {
            if ($WMIService.Status -eq 'Degraded') {
                try {
                    Write-Warning "Identified $Name service in a 'Degraded' state. Will force $Name process to stop."
                    $ServicePID = $WMIService | Select-Object -ExpandProperty ProcessID
                    Stop-Process -ID $ServicePID -Force:$true -Confirm:$false -ErrorAction Stop
                    Write-Verbose "Succesfully stopped the $Name service process which was in a degraded state."
                }
                Catch {
                    Write-Error "Failed to force $Name process to stop."
                }
            }
            try {
                $RetryService = $False
                $text = 'Starting service: ' + $Name + '...'
                Write-Host $text
                Start-Service -Name $service.Name -ErrorAction Stop
                $log.Services = 'Started'
            }
            catch {
                #Error 1290 (-2146233087) indicates that the service is sharing a thread with another service that is protected and cannot share its thread.
                #This is resolved by configuring the service to run on its own thread.
                If ($_.Exception.Hresult -eq '-2146233087') {
                    Write-Warning "Failed to start service $Name because it's sharing a thread with another process.  Changing to use its own thread."
                    & cmd /c sc config $Name type= own
                    $RetryService = $True
                }
                Else {
                    $null = Set-RegistryValue -Path $RegistryKey -Name "Service $Name uptime" -Value "Failed to restart"
                    $text = 'Failed to start service ' + $Name
                    Write-Error $text
                }
            }

            #If a recoverable error was found, try starting it again.
            If ($RetryService) {
                try {
                    Start-Service -Name $service.Name -ErrorAction Stop
                    $null = Set-RegistryValue -Path $RegistryKey -Name "Service $Name uptime" -Value "Restarted"
                    $log.Services = 'Started'
                }
                catch {
                    $null = Set-RegistryValue -Path $RegistryKey -Name "Service $Name uptime" -Value "Failed to restart"
                    $text = 'Failed to start service ' + $Name
                    Write-Error $text
                }
            }
        }
    }

    function Test-AdminShare {
        Param([Parameter(Mandatory = $true)]$Log)
        Write-Verbose "Test the ADMIN$ and C$"
        Set-LastAction -LastAction 'Testing Admin Shares'
        $RegistryKey = Get-XMLConfigRegistryKey
        if ($PowerShellVersion -ge 6) {
            $share = Get-CimInstance Win32_Share | Where-Object { $_.Name -eq 'ADMIN$' }
        }
        else {
            $share = Get-WmiObject Win32_Share | Where-Object { $_.Name -eq 'ADMIN$' }
        }

        if ($share.Name -contains 'ADMIN$') {
            $text = 'Adminshare Admin$: OK'
            $null = Set-RegistryValue -Path $RegistryKey -Name 'AdminShare ADMIN$' -Value 'Healthy'
            Write-Host $text
        }
        else {
            $null = Set-RegistryValue -Path $RegistryKey -Name 'AdminShare ADMIN$' -Value 'Unhealthy'
            $fix = $true
        }

        if ($PowerShellVersion -ge 6) {
            $share = Get-CimInstance Win32_Share | Where-Object { $_.Name -eq 'C$' }
        }
        else {
            $share = Get-WmiObject Win32_Share | Where-Object { $_.Name -eq 'C$' }
        }

        if ($share.Name -contains "C$") {
            $text = 'Adminshare C$: OK'
            $null = Set-RegistryValue -Path $RegistryKey -Name 'AdminShare C$' -Value 'Healthy'
            Write-Host $text
        }
        else {
            $null = Set-RegistryValue -Path $RegistryKey -Name 'AdminShare C$' -Value 'Unhealthy'
            $fix = $true
        }

        if ($fix -eq $true) {
            $text = 'Error with Adminshares. Remediating...'
            $log.AdminShare = 'Repaired'
            $null = Set-RegistryValue -Path $RegistryKey -Name 'AdminShare C$' -Value 'Remediated'
            $null = Set-RegistryValue -Path $RegistryKey -Name 'AdminShare ADMIN$' -Value 'Remediated'
            Write-Warning $text
            Stop-Service server -Force
            Start-Service server
        }
        else {
            $log.AdminShare = 'OK'
        }
    }

    Function Test-DiskSpace {
        Set-LastAction -LastAction 'Testing Diskpace'
        $RegistryKey = Get-XMLConfigRegistryKey
        $XMLDiskSpace = Get-XMLConfigOSDiskFreeSpace
        if ($PowerShellVersion -ge 6) {
            $driveC = Get-CimInstance -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "$env:SystemDrive" } | Select-Object FreeSpace, Size
        }
        else {
            $driveC = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "$env:SystemDrive" } | Select-Object FreeSpace, Size
        }
        $null = Set-RegistryValue -Path $RegistryKey -Name 'CFreeSpace' -Value $([math]::Round(($driveC.FreeSpace / 1mb)))
        $freeSpace = (($driveC.FreeSpace / $driveC.Size) * 100)

        if ($freeSpace -le $XMLDiskSpace) {
            $text = "Local disk $env:SystemDrive Less than $XMLDiskSpace % free space"
            Write-Error $text
        }
        else {
            $text = "Free space $env:SystemDrive OK"
            Write-Host $text
        }
    }

    Function Test-CCMSoftwareDistribution {
        # TODO Implement this function
        Get-WmiObject -Class CCM_SoftwareDistributionClientConfig
    }

    Function Test-MissingDrivers {
        Param([Parameter(Mandatory = $true)]$Log)
        $FileLogLevel = ((Get-XMLConfigLoggingLevel).ToString()).ToLower()
        $i = 0
        if ($PowerShellVersion -ge 6) {
            $devices = Get-CimInstance Win32_PNPEntity | Where-Object { ($_.ConfigManagerErrorCode -ne 0) -and ($_.ConfigManagerErrorCode -ne 22) -and ($_.Name -notlike "*PS/2*") } | Select-Object Name, DeviceID
        }
        else {
            $devices = Get-WmiObject Win32_PNPEntity | Where-Object { ($_.ConfigManagerErrorCode -ne 0) -and ($_.ConfigManagerErrorCode -ne 22) -and ($_.Name -notlike "*PS/2*") } | Select-Object Name, DeviceID
        }
        $devices | ForEach-Object { $i++ }

        if ($null -ne $devices) {
            $text = "Drivers: $i unknown or faulty device(s)"
            Write-Warning $text
            $log.Drivers = "$i unknown or faulty driver(s)"

            foreach ($device in $devices) {
                $text = 'Missing or faulty driver: ' + $device.Name + '. Device ID: ' + $device.DeviceID
                Write-Warning $text
                if (-NOT($FileLogLevel -eq "clientlocal")) {
                    Out-LogFile -Text $text -Severity 2
                }
            }
        }
        else {
            $text = "Drivers: OK"
            Write-Host $text
            $log.Drivers = 'OK'
        }
    }

    Function Test-SCCMHardwareInventoryScan {
        Param([Parameter(Mandatory = $true)]$Log)

        Write-Verbose "Start Test-SCCMHardwareInventoryScan"
        $days = Get-XMLConfigHardwareInventoryDays
        if ($PowerShellVersion -ge 6) {
            $wmi = Get-CimInstance -Namespace root\ccm\invagt -Class InventoryActionStatus | Where-Object { $_.InventoryActionID -eq '{00000000-0000-0000-0000-000000000001}' } | Select-Object @{label = 'HWSCAN'; expression = { $_.ConvertToDateTime($_.LastCycleStartedDate) } }
        }
        else {
            $wmi = Get-WmiObject -Namespace root\ccm\invagt -Class InventoryActionStatus | Where-Object { $_.InventoryActionID -eq '{00000000-0000-0000-0000-000000000001}' } | Select-Object @{label = 'HWSCAN'; expression = { $_.ConvertToDateTime($_.LastCycleStartedDate) } }
        }
        $HWScanDate = $wmi | Select-Object -ExpandProperty HWSCAN
        $HWScanDate = Get-SmallDateTime $HWScanDate
        $minDate = Get-SmallDateTime((Get-Date).AddDays(-$days))
        if ($HWScanDate -le $minDate) {
            $fix = (Get-XMLConfigHardwareInventoryFix).ToLower()
            if ($fix -eq "true") {
                $text = "ConfigMgr Hardware Inventory scan: $HWScanDate. Starting hardware inventory scan of the client."
                Write-Host $Text
                Invoke-CCMClientAction -Schedule HardwareInv

                # Get the new date after policy trigger
                if ($PowerShellVersion -ge 6) {
                    $wmi = Get-CimInstance -Namespace root\ccm\invagt -Class InventoryActionStatus | Where-Object { $_.InventoryActionID -eq '{00000000-0000-0000-0000-000000000001}' } | Select-Object @{label = 'HWSCAN'; expression = { $_.ConvertToDateTime($_.LastCycleStartedDate) } }
                }
                else {
                    $wmi = Get-WmiObject -Namespace root\ccm\invagt -Class InventoryActionStatus | Where-Object { $_.InventoryActionID -eq '{00000000-0000-0000-0000-000000000001}' } | Select-Object @{label = 'HWSCAN'; expression = { $_.ConvertToDateTime($_.LastCycleStartedDate) } }
                }
                $HWScanDate = $wmi | Select-Object -ExpandProperty HWSCAN
                $HWScanDate = Get-SmallDateTime -Date $HWScanDate
            }
            else {
                # No need to update anything if fix = false. Last date will still be set in log
            }


        }
        else {
            $text = "ConfigMgr Hardware Inventory scan: OK"
            Write-Host $text
        }
        $log.HWInventory = $HWScanDate
        Write-Verbose "End Test-SCCMHardwareInventoryScan"
    }

    # ref: https://social.technet.microsoft.com/Forums/de-DE/1f48e8d8-4e13-47b5-ae1b-dcb831c0a93b/setup-was-unable-to-compile-the-file-discoverystatusmof-the-error-code-is-8004100e?forum=configmanagerdeployment
    Function Test-PolicyPlatform {
        Param([Parameter(Mandatory = $true)]$Log)
        try {
            if (Get-WmiObject -Namespace 'root/Microsoft' -Class '__Namespace' -Filter 'Name = "PolicyPlatform"') {
                Write-Host "PolicyPlatform: OK"
            }
            else {
                Write-Warning "PolicyPlatform: Not found, recompiling WMI 'Microsoft Policy Platform\ExtendedStatus.mof'"

                if ($PowerShellVersion -ge 6) {
                    $OS = Get-CimInstance Win32_OperatingSystem
                }
                else {
                    $OS = Get-WmiObject Win32_OperatingSystem
                }

                # 32 or 64?
                if ($OS.OSArchitecture -match '64') {
                    & mofcomp "$env:ProgramW6432\Microsoft Policy Platform\ExtendedStatus.mof"
                }
                else {
                    &  mofcomp "$env:ProgramFiles\Microsoft Policy Platform\ExtendedStatus.mof"
                }

                # Update WMI log object
                $text = 'PolicyPlatform Recompiled.'
                if (-NOT($Log.WMI -eq 'OK')) {
                    $Log.WMI += ". $text"
                }
                else {
                    $Log.WMI = $text
                }
            }
        }
        catch {
            Write-Warning "PolicyPlatform: RecompilePolicyPlatform failed!"
        }
    }

    Function Test-SoftwareMeteringPrepDriver {
        Param([Parameter(Mandatory = $true)]$Log)
        # To execute function: if (Test-SoftwareMeteringPrepDriver -eq $false) {$restartCCMExec = $true}
        # Thanks to Paul Andrews for letting me know about this issue.
        # And Sherry Kissinger for a nice fix: https://mnscug.org/blogs/sherry-kissinger/481-configmgr-ccmrecentlyusedapps-blank-or-mtrmgr-log-with-startprepdriver-openservice-failed-with-error-issue

        Write-Verbose "Start Test-SoftwareMeteringPrepDriver"

        $logdir = Get-CCMLogDirectory
        $logfile = "$logdir\mtrmgr.log"
        $content = Get-Content -Path $logfile
        $error1 = "StartPrepDriver - OpenService Failed with Error"
        $error2 = "Software Metering failed to start PrepDriver"

        if (($content -match $error1) -or ($content -match $error2)) {
            $fix = (Get-XMLConfigSoftwareMeteringFix).ToLower()

            if ($fix -eq "true") {
                $Text = "Software Metering - PrepDriver: Error. Remediating..."
                Write-Host $Text
                $CMClientDIR = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\SMS\Client\Configuration\Client Properties" -Name 'Local SMS Path').'Local SMS Path'
                $ExePath = $env:windir + '\system32\RUNDLL32.EXE'
                $CLine = ' SETUPAPI.DLL,InstallHinfSection DefaultInstall 128 ' + $CMClientDIR + 'prepdrv.inf'
                $ExePath = $env:windir + '\system32\RUNDLL32.EXE'
                $Prms = $Cline.Split(" ")
                & "$Exepath" $Prms

                $newContent = $content | Select-String -pattern $error1, $error2 -notmatch
                Stop-Service -Name CcmExec
                Out-File -FilePath $logfile -InputObject $newContent -Encoding utf8 -Force
                Start-Service -Name CcmExec

                $Obj = $false
                $Log.SWMetering = "Remediated"
            }
            else {
                # Set $obj to true as we don't want to do anything with the CM agent.
                $obj = $true
                $Log.SWMetering = "Error"
            }
        }
        else {
            $Text = "Software Metering - PrepDriver: OK"
            Write-Host $Text
            $Obj = $true
            $Log.SWMetering = "OK"
        }
        $content = $null # Clean the variable containing the log file.

        Write-Output $Obj
        Write-Verbose "End Test-SoftwareMeteringPrepDriver"
    }

    Function Test-SCCMHWScanErrors {
        # Function to test and fix errors that prevent a computer to perform a HW scan. Not sure if this is really needed or not.
    }

    Function Test-ConfigMgrHealthLogging {
        # Verifies that logfiles are not bigger than max history

        $localLogging = Get-XMLConfigLoggingLocalFile

        if ($localLogging -eq "true") {
            $clientpath = Get-LocalFilesPath
            $logfile = "$clientpath\ClientHealth.log"
            Test-LogFileHistory -Logfile $logfile
        }
    }

    # Test some values are whole numbers before attempting to insert / update database
    Function Test-ValuesBeforeLogUpdate {
        Write-Verbose "Start Test-ValuesBeforeLogUpdate"
        [int]$Log.MaxLogSize = [Math]::Round($Log.MaxLogSize)
        [int]$Log.MaxLogHistory = [Math]::Round($Log.MaxLogHistory)
        [int]$Log.PSBuild = [Math]::Round($Log.PSBuild)
        [int]$Log.CacheSize = [Math]::Round($Log.CacheSize)
        Write-Verbose "End Test-ValuesBeforeLogUpdate"
    }

    Function Test-WriteWMI {
        <#
        .SYNOPSIS
        Checks the ability to write to WMI, creates and deletes a class and instance
        .DESCRIPTION
        This function will create a classes, and an instance with a test property under the specified namespace.
        It will return a boolean for success or failure
        .EXAMPLE
        Test-WriteWMI -Namespace "root\ccm"
        .EXAMPLE
        Test-WriteWMI "root\ccm"
        .PARAMETER Namespace
        Namespace to test WMI writeability against
    #>
        param
        (
            [Parameter(Mandatory = $True)]
            [string]$Namespace
        )
        Write-Verbose $([string]::Format('Attempting to write to {0}', $Namespace))

        #region check for prior existence of ClientHealth class in $Namespace, remove if found
        if ($null -ne (Get-WmiObject -namespace $Namespace -Class 'ClientHealth' -ErrorAction SilentlyContinue)) {
            Write-Verbose $([string]::Format('The test class ClientHealth already existed in Namespace {0}; cleaning up created class', $Namespace))
            Try {
                #Delete test class from namespace prior to testing

                Write-Verbose $([string]::Format('Namespace {0} can be written to; cleaning up created class', $Namespace))
                [wmiclass]$OldClass = Get-WmiObject -namespace $Namespace -Class 'ClientHealth'
                $OldClass.Delete()
            }
            Catch {
                Write-Error $([string]::Format('Failed to delete test class ClientHealth from {0}', $Namespace))
                return $False
            }
        }
        #endregion check for prior existence of ClientHealth class in $Namespace, remove if found

        Try {
            #region attempt creation of new class object in namespace
            [wmiclass]$WMIClass = New-Object -TypeName System.Management.ManagementClass -ArgumentList ($Namespace, $null, $null)
            $WMIClass.Name = 'ClientHealth'
            $null = $WMIClass.Put()
            #endregion attempt creation of new class object in namespace

            Try {
                #add a property to the class called TestProperty and give it a value of TestValue
                $WMIClass.Properties.Add('TestProperty', '')
                $WMIClass.SetPropertyValue('TestProperty', 'TestValue')
                $null = $WMIClass.Put()

                Try {
                    #create a new instance of the ClientHealth class and changing the value of the TestProperty in this instance
                    $NewWMIInstance = $WMIClass.CreateInstance()
                    $NewWMIInstance.TestProperty = 'New Instance'

                    Try {
                        #Cleanup test class in the namespace and returning True for success
                        Write-Verbose $([string]::Format('Namespace {0} can be written to; cleaning up created class', $Namespace))
                        $WMIClass.Delete()
                        return $True
                    }
                    Catch {
                        Write-Error $([string]::Format('Failed to delete test class ClientHealth from {0}', $Namespace))
                        return false
                    }
                }
                Catch {
                    Write-Error $([string]::Format('Failed to create instance of class ClientHealth to {0}', $Namespace))
                    return $false
                }
            }
            Catch {
                Write-Error $([string]::Format('Failed to write property TestProperty to ClientHealth class of namespace {0}', $Namespace))
                return $false
            }
        }
        Catch {
            Write-Error $([string]::Format('Failed to write class ClientHealth to {0}', $Namespace))
            return $false
        }
    }

    Function Test-WMIHealth {
        <#
        .SYNOPSIS
        Verifies health of WMI under cimv2, and recursively under root\ccm
        .DESCRIPTION
        Attempts to read WMI and write to namespaces recursively along with basic WMI health checks and returns boolean value
        .EXAMPLE
        Test-WMIHealth
        #>
        Set-LastAction -LastAction 'Running Test-WMIHealth'
        Write-Verbose 'Running winmgmt /verifyrepository'

        $null = & "$env:windir\system32\wbem\winmgmt.exe" /verifyrepository
        if ($lastexitcode -ne 0) {
            Write-Error 'Result of WMI repository check is not consistent'
            return $False
        }
        else {
            #get value of WMI repository corruption status
            [int]$RepositoryCorrupt = Get-RegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\Wbem\CIMOM' -Name 'RepositoryCorruptionReported'

            if ($RepositoryCorrupt -eq 0) {
                Write-Verbose $([string]::Format('Result of WMI repository check is {0}', $RepositoryCorrupt))
                Try {
                    #attempt to read a core class from root\cimv2 namespace
                    $null = Get-WmiObject -Class win32_operatingsystem -ErrorAction Stop

                    $WMIWriteTest = Get-XMLConfigWMIWriteEnable
                    if ($WMIWriteTest -eq 'true') {
                        #basic test of WMI deems initial success
                        if ($RepositoryCorrupt -eq 0 -and (Test-WriteWMI -Namespace 'root\cimv2')) {

                            #If SCCM client is installed, verify WMI core namespace health
                            if ($script:ClientInstalled -eq $true) {
                                #continue testing by attempting write to all CCM namespaces
                                [array]$CCMNamespaces = Get-WmiObject -Namespace root\ccm -Class __namespace -Recurse
                                [bool]$Status = $True
                                ForEach ($CCMNamespace in $CCMNamespaces) {
                                    $FullNamespace = [string]::Format('{0}\{1}', $CCMNamespace.__NAMESPACE, $CCMNamespace.Name)
                                    if (-not (Test-WriteWMI -Namespace $FullNamespace)) {
                                        Write-Error "Unable to write to $FullNamespace"
                                        $Status = $false
                                        return $Status
                                    }
                                }
                                return $true
                            }
                            else {
                                return $true
                            }
                        }
                        else {
                            Write-Error 'Failed to write to default WMI namespace or WMI is corrupt; rebuild of WMI is suggested'
                            return $False
                        }
                    }
                    else {
                        return $true
                    }
                }
                Catch {
                    Write-Verbose 'Failed to get basic WMI information'
                    return $False
                }
            }
            else {
                Write-Verbose 'ERROR: WMI is corrupt; rebuild of WMI is suggested'
                return $False
            }
        }
    }

    Function Test-StaleLog {
        <#
        .SYNOPSIS
        Returns a boolean based on whether a log file has been written to in the timeframe specified

        .DESCRIPTION
        This function is used to check the LastWriteTime property of a specified file
        It will be compared to the *Stale parameters

        .EXAMPLE
        Test-StaleLog -LogFileName ccmexec -DaysStale 2

        .PARAMETER LogFileName
        Name of the log file under the CCM\Logs directory to check

        .PARAMETER DaysStale
        Number of days of inactivity that you would consider the specified log stale.

        .PARAMETER HoursStale
        Number of days of inactivity that you would consider the specified log stale.

        .PARAMETER MinutesStale
        #>

        PARAM
        (
            [Parameter(Mandatory = $True)]
            [string]$LogFileName,
            [Parameter(Mandatory = $false)]
            [int]$DaysStale,
            [Parameter(Mandatory = $false)]
            [int]$HoursStale,
            [Parameter(Mandatory = $false)]
            [int]$MinutesStale
        )

        $TimeSpanSplat = @{ }
        switch ($true) {
            $PSBoundParameters.ContainsKey('DaysStale') {
                $TimeSpanSplat['Days'] = $DaysStale
            }
            $PSBoundParameters.ContainsKey('HoursStale') {
                $TimeSpanSplat['Hours'] = $HoursStale
            }
            $PSBoundParameters.ContainsKey('MinutesStale') {
                $TimeSpanSplat['Minutes'] = $MinutesStale
            }
        }
        $StaleTimeframe = New-TimeSpan @TimeSpanSplat

        Set-LastAction -LastAction "Check if $LogFileName stale"

        [string]$CMClientInstallLog = "$env:windir\ccmsetup\Logs\ccmsetup.log"

        [string]$CCMLogDirectory = Get-CCMLogDirectory
        switch ($LogFileName.EndsWith('.log')) {
            $false {
                $LogFileName = [string]::Format('{0}.Log', $LogFileName)
            }
        }
        $Log = Join-Path -Path $CCMLogDirectory -ChildPath $LogFileName

        Write-Verbose $([string]::Format('Checking {0} for activity', $Log))

        if (Test-Path -Path $Log) {
            [datetime]$LogLastWriteTime = (Get-Item -Path $Log).LastWriteTime
            $LastWriteDiff = New-TimeSpan -Start $LogLastWriteTime -End (Get-Date -format yyyy-MM-dd)
            if ($LastWriteDiff -gt $StaleTimeframe) {
                #Unhealthy
                Write-Verbose $([string]::Format('{0} is not active', $LogFileName))
                Write-Verbose $([string]::Format('{0} last date modified is {1}', $LogFileName, $LogDate))
                Write-Verbose $([string]::Format("Current Date and Time is {0}", (Get-Date)))
                return $true
            }
            else {
                #Healthy
                Write-Verbose $([string]::Format('{0}.log is active', $LogFileName))
                return $false
            }
        }
        else {
            #Log File Missing
            Write-Verbose $([string]::('{0} is missing; checking for recent ccmsetup activity', $LogFileName))
            if (Test-Path -Path $CMClientInstallLog) {
                [datetime]$dtmCMClientInstallLogDate = (Get-Item -Path $CMClientInstallLog).LastWriteTime
                [int]$ClientInstallHours = (New-TimeSpan -Start (Get-Date -format yyyy-MM-dd) -End $dtmCMClientInstallLogDate).TotalHours
                if ($ClientInstallHours -lt 24) {
                    #Log has been written to recently / client has been installed recently
                    Write-Verbose 'CCMSetup activity detected within last 24 hours, will not attempt to repair'
                    return $false
                }
                else {
                    #Log has not been written to recently / client has not been installed or repaired recently
                    Write-Verbose 'CCMSetup activity not detected within last 24 hours, will attempt to repair'
                    return $true
                }
            }
            else {
                #Client Never Installed
                Write-Verbose $([string]::Format('CCMSetup.log not found in {0}, will attempt to install client', $CMClientInstallLog))
                return $true
            }
        }
    }

    Function Test-AppPolicy {
        <#
        .SYNOPSIS
        Validate that all Application Policies that have been retrived by the machine are processed correctly.

        .DESCRIPTION
        Compare the CCM_ApplicaitonCIAssignments on the local machine to validate that all policies have been added to the ClientSDK.
        In some instances the Lantern module can be corrupt and while there is a policy, the CI is not processed and added to the local database or WMI.
        This will cause the deployment to never run or evaluate.
        The return will be a Boolean value of True or False indicating if the Check passed.

        .EXAMPLE
        Test-AppPolicy
         #>

        Try {
            #Create an arry of all the Application CI Assignments from the local Policy
            [array]$AppDeployments = $null
            [array]$AppDeployments = Get-WmiObject -Namespace root\CCM\Policy\Machine\ActualConfig -Query 'Select * from CCM_ApplicationCIAssignment' -ErrorAction SilentlyContinue

            if ($AppDeployments) {
                #Create an array of all the Application Policy stored in the ClientSDK
                [array]$AppPolicies = Get-WmiObject -Namespace root\CCM\ClientSDK -Query 'SELECT * FROM CCM_ApplicationPolicy' -ErrorAction Stop

                #Loop through each AppDeployment Policy to see if it has an entry in the ClientSDK

                ForEach ($AppDeployment in $AppDeployments) {
                    #Pull the Application Unique ID from the machine policy to use for comparison
                    [string]$CIXML = $AppDeployment.AssignedCIs[0]
                    [int]$ModelStart = $CIXML.indexof('<ModelName>')
                    [int]$ModelFinish = $CIXML.indexof('</ModelName>')
                    [string]$CIID = $CIXML.Substring($ModelStart + 11, $ModelFinish - ($ModelStart + 11))

                    #Set to False and wait to be proven wrong
                    [bool]$AppPolicyMatch = $FALSE

                    #Loop throgh each Application Policy in ClientSDK looking for a match
                    ForEach ($AppPolicy in $AppPolicies) {
                        #If there is a match set AppPolicyMatch to true
                        If (($AppPolicy.ID -eq $CIID) -and ($AppPolicy.IsMachineTarget)) {
                            $AppPolicyMatch = $TRUE
                        }
                    }

                    #If we did not find a match, set Function to False and exit as it only takes one to error
                    If (-not ($AppPolicyMatch)) {
                        Write-Warning 'Application Policy does not match Deployment Policy, possible CI Corruption.'
                        Return $False
                    }
                }
            }

            #If we made it through the loop without and error, then all policies exists
            Return $True
        }
        Catch {
            #Get first line of error only
            [string]$ErrorMsg = ($Error[0].toString()).Split('.')[0]

            Write-Error $([string]::Format('ERROR - Check Application policy failed with error ({0})', $ErrorMsg))
            Return $False
        }
    }

    Function Test-AppIntentEval {
        <#
        .SYNOPSIS
        Check to see if the AppIntentEval log was modified in the last 5 minutes.

        .DESCRIPTION
        Check to see if the AppIntentEval log was modified in the last 5 minutes.
        Returns a boolean value of True or False.

        .EXAMPLE
        Test-AppIntentEval

        #>

        $CCMLogDir = Get-CCMLogDirectory
        #Set Variable for the Application Intent Evaluation log file
        [string]$LogFile = Join-Path -PAth $CCMLogDir -ChildPath 'AppIntentEval.log'

        If (Test-Path -Path $LogFile) {
            $LogStale = Test-StaleLog -LogFileName 'AppIntentEval' -MinutesStale 5

            #If the time is less than 5 min exit with True.
            If (-not $LogStale) {
                Return $True
            }

        }
        Else {
            #Log files does not exists. This could be expected for newly installed clients.
            Write-Verbose $([string]::Format('{0} file does not exist.  No further action needed for AppIntentEval.', $LogFile))
            Return $True
        }

        #If we got here without an exit it must be false
        Return $False
    }

    Function Test-Lantern {
        <#
        .SYNOPSIS
        Check to see if ConfigMgr CI processing is working, aslo known as lantern.

        .DESCRIPTION
        Check to see if there is a conflict in the Application Policy received and stored in the WMI.  If an issue is found will kick off an Application
        Deployment Evaluation cycle to check to see that the AppIntentEval log is updated, if not this will identify an issue with Lantern processing.
        If found a client repair forcing the CCMStore.sdf file to be repaired is the only fix.

        Return value will be boolean based and a FALSE should flag a CCMRepair.

        .EXAMPLE
        Test-Lantern
        #>

        Write-Verbose 'Checking Application Policy.'

        #Run Function to check Application Policy
        [bool]$AppPolicy = Test-AppPolicy

        #Check for Application Policy, if there is no Policy will assume everything is working.
        If (-not ($AppPolicy)) {
            Write-Error 'There was Application Policy conflict found.  Will trigger Application Deployment Evaluation.'

            #Call Application Deployment Evaluation
            Invoke-CCMClientAction -Schedule AppEval

            #Sleep for 2 min to allow for Application Deployment to complete
            Write-Host 'Waiting for 2 minutes to allow Application Deployment Evaluation to Complete.'
            Start-Sleep -Seconds 120

            If (Test-AppIntentEval) {
                #All is well, return healthy
                Write-Host 'Client appears to be healthy.  Exiting Application Policy Check.'
                Return $True
            }
            Else {
                #AppIntent Eval does not appear to be heatlhy.  Need to repair the client.
                Write-Error 'Client does not appear to be healthy.  Requesting a repair of the client.'

                #Repair CCM Client needed and force the ccmstore.sdf to be replaced
                $null = Set-RegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\CCMSetup' -Name 'CcmStore.sdf' -Data 'corrupted' -DataType string

                Return $False
            }
        }
        Else {
            #All is well, return healthy
            Write-Host 'No Application Policy conflict found.  Client appears to be healthy.'
            Return $True
        }
    }
    #endregion Test-* functions

    #Loop backwards through a Configuration Manager log file looking for the latest matching message after the start time.
    Function Search-CMLogFile {
        Param(
            [Parameter(Mandatory = $true)]$LogFile,
            [Parameter(Mandatory = $true)][String[]]$SearchStrings,
            [datetime]$StartTime = [datetime]::MinValue
        )

        #Get the log data.
        $LogData = Get-Content $LogFile

        #Loop backwards through the log file.
        :loop for ($i = ($LogData.Count - 1); $i -ge 0; $i--) {

            #Parse the log line into its parts.
            try {
                $LogData[$i] -match '\<\!\[LOG\[(?<Message>.*)?\]LOG\]\!\>\<time=\"(?<Time>.+)(?<TZAdjust>[+|-])(?<TZOffset>\d{2,3})\"\s+date=\"(?<Date>.+)?\"\s+component=\"(?<Component>.+)?\"\s+context="(?<Context>.*)?\"\s+type=\"(?<Type>\d)?\"\s+thread=\"(?<TID>\d+)?\"\s+file=\"(?<Reference>.+)?\"\>' | Out-Null
                $LogTime = [datetime]::ParseExact($("$($matches.date) $($matches.time)"), "MM-dd-yyyy HH:mm:ss.fff", $null)
                $LogMessage = $matches.message
            }
            catch {
                Write-Warning "Could not parse the line $($i) in '$($LogFile)': $($LogData[$i])"
                continue
            }

            #If we have gone beyond the start time then stop searching.
            If ($LogTime -lt $StartTime) {
                Write-Verbose "No log lines in $($LogFile) matched $($SearchStrings) before $($StartTime)."
                break loop
            }

            #Loop through each search string looking for a match.
            ForEach ($String in $SearchStrings) {
                If ($LogMessage -match $String) {
                    Write-Output $LogMessage
                    break loop
                }
            }
        }

        #Looped through log file without finding a match.
        #Return
    }

    Function Out-LogFile {
        Param($Text, $Mode,
            [Parameter(Mandatory = $false)][ValidateSet(1, 2, 3, 'Information', 'Warning', 'Error')]$Severity = 1)

        switch ($Severity) {
            'Information' {
                $Severity = 1
            }
            'Warning' {
                $Severity = 2
            }
            'Error' {
                $Severity = 3
            }
        }
        $localLogging = Get-XMLConfigLoggingLocalFile
        if ($LocalLogging -eq 'true' -or $Mode -match "Local") {
            Test-LocalLogging
            $clientpath = Get-LocalFilesPath
            $Logfile = "$clientpath\ClientHealth.log"
        }

        if ($mode -eq "ClientInstall" ) {
            $text = "ConfigMgr Client installation failed. Agent not detected 10 minutes after triggering installation."
            $Severity = 3
        }

        foreach ($item in $text) {
            $time = (Get-Date -Format HH:mm:ss.fff)
            $date = (Get-Date -Format MM-dd-yyyy)

            $logblock = [string]::Format('<![LOG[{0}]LOG]!><time="{1}+000" date="{2}" component="ConfigMgrClientHealth" context="" type="{3}" thread="{4}" file="">', $item, $time, $date, $Severity, $PID)

            $logblock | Out-File -Encoding utf8 -Append $logFile
        }
    }

    Function Set-RegistryValue {
        param (
            [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]$Path,
            [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]$Name,
            [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]$Value,
            [ValidateSet("String", "ExpandString", "Binary", "DWord", "MultiString", "Qword")]$PropertyType = "String"
        )

        #Make sure the key exists
        If (!(Test-Path $Path)) {
            New-Item $Path -Force | Out-Null
        }

        try {
            $null = New-ItemProperty -Force -Path $Path -Name $Name -Value $Value -PropertyType $PropertyType -ErrorAction Stop
            return $True
        }
        catch {
            return $false
        }
    }

    Function New-ClientInstalledReason {
        Param(
            [Parameter(Mandatory = $true)]$Message,
            [Parameter(Mandatory = $true)]$Log
        )

        if ($null -eq $log.ClientInstalledReason) {
            $log.ClientInstalledReason = $Message
        }
        else {
            $log.ClientInstalledReason += " $Message"
        }
    }

    function Measure-Latest {
        BEGIN {
            $latest = $null
        }
        PROCESS {
            if (($null -ne $_) -and (($null -eq $latest) -or ($_ -gt $latest))) {
                $latest = $_
            }
        }
        END {
            $latest
        }
    }

    Function Update-State {
        Write-Verbose "Start Update-State"
        $SCCMUpdatesStore = New-Object -ComObject Microsoft.CCM.UpdatesStore
        $SCCMUpdatesStore.RefreshServerComplianceState()
        $log.StateMessages = 'OK'
        Write-Verbose "End Update-State"
    }

    Function Remove-CCMOrphanedCache {
        Write-Host "Clearing ConfigMgr orphaned Cache items."
        Set-LastAction -LastAction 'Removing orphaned cache items'
        try {
            $CCMCache = "$env:SystemDrive\Windows\ccmcache"
            $CCMCache = (New-Object -ComObject "UIResource.UIResourceMgr").GetCacheInfo().Location
            if ($null -eq $CCMCache) {
                $CCMCache = "$env:SystemDrive\Windows\ccmcache"
            }
            $ValidCachedFolders = (New-Object -ComObject "UIResource.UIResourceMgr").GetCacheInfo().GetCacheElements() | ForEach-Object { $_.Location }
            $AllCachedFolders = (Get-ChildItem -Path $CCMCache) | Select-Object Fullname -ExpandProperty Fullname

            ForEach ($CachedFolder in $AllCachedFolders) {
                If ($ValidCachedFolders -notcontains $CachedFolder) {
                    #Don't delete new folders that might be syncing data with BITS
                    if ((Get-ItemProperty $CachedFolder).LastWriteTime -le (Get-Date).AddDays(-14)) {
                        Write-Verbose "Removing orphaned folder: $CachedFolder - LastWriteTime: $((Get-ItemProperty $CachedFolder).LastWriteTime)"
                        Remove-Item -Path $CachedFolder -Force -Recurse
                    }
                }
            }
        }
        catch {
            Write-Warning "Failed Clearing ConfigMgr orphaned Cache items."
        }
    }

    Function Invoke-CMClientRemediationAction {
        <#
        .SYNOPSIS
        Install, uninstall, or repair the SCCM client

        .DESCRIPTION
        Function to install the most current version of the SCCM client

        .EXAMPLE
        Invoke-CMClientRemediationAction -Action Install

        .PARAMETER Action
        The name of the client action to be taken
        #>

        param
        (
            [Parameter(Mandatory = $true, ParameterSetName = 'Install')]
            [switch]$Install,
            [Parameter(Mandatory = $true, ParameterSetName = 'Repair')]
            [switch]$Repair,
            [Parameter(Mandatory = $true, ParameterSetName = 'Uninstall')]
            [switch]$Uninstall,
            [Parameter(Mandatory = $false)]
            [switch]$FirstInstall
        )

        $Action = $PSCmdlet.ParameterSetName
        Write-Verbose $([string]::Format('The client action {0} has been initiated', $Action))
        $RegistryKey = Get-XMLConfigRegistryKey
        $SiteServer = Get-XMLConfigSiteServer
        $clientInstallProperties = Get-XMLConfigClientInstallProperty

        Set-LastAction -LastAction "Client $Action"

        $ClientInstallCount = Get-RegistryValue -Path $RegistryKey -Name 'ClientInstallCount' -ErrorAction SilentlyContinue

        if ($ClientInstallCount) {
            Write-Verbose $([string]::Format('The client has been installed {0} number of times.', $ClientInstallCount))
        }
        else {
            Write-Verbose 'The ClientInstallCount property does not exist. Creating ClientInstallCount property and setting value to 0'
            try {
                $null = Set-RegistryValue -Path $RegistryKey -Name 'ClientInstallCount' -Value 0
                $ClientInstallCount = Get-RegistryValue -Path $RegistryKey -Name 'ClientInstallCount'
                Write-Verbose 'Created ClientInstallCount'
            }
            catch {
                Write-Warning 'ERROR: Failed to create ClientInstallCount property.'
            }
        }


        Stop-Service -Name 'CCMSetup' -Force -ErrorAction SilentlyContinue
        Stop-Process -Name 'CCMSetup' -Force -ErrorAction SilentlyContinue
        Stop-Process -Name 'CCMRestart' -Force -ErrorAction SilentlyContinue

        if (Test-Path -Path "$env:windir\ccmsetup\ccmsetup.exe") {
            [string]$ClientActionCommand = "$env:windir\ccmsetup\ccmsetup.exe"
        }
        else {
            If (Test-Path -Path ('\\{0}\PFEClient$\ccmsetup.exe' -f $SiteServer)) {
                [string]$ClientActionCommand = ('\\{0}\PFEClient$\ccmsetup.exe' -f $SiteServer)
            }
            else {
                Write-Warning $([string]::Format('ERROR: no CCMSetup.exe found at {0}\PFEClient$', $SiteServer))
                return $false
            }
        }

        #Convert friendly parameter to values for the SC command
        [string]$ClientActionArgs = switch ($true) {
            $Install {
                $clientInstallProperties
            }
            $Uninstall {
                '/Uninstall'
            }
            $Repair {
                [string]::('RESETKEYINFORMATION=TRUE REMEDIATE=TRUE {0}', $clientInstallProperties)
            }
        }
        Write-Verbose $([string]::Format('Starting Client {0} with command line {1} {2}', $Action, $ClientActionCommand, $ClientActionArgs))

        Write-Verbose "Perform a test on a specific registry key required for ccmsetup to succeed."
        Test-CCMSetup1

        Write-Verbose "Enforce registration of common DLL files to make sure CCM Agent works."
        $DllFiles = 'actxprxy.dll', 'atl.dll', 'Bitsprx2.dll', 'Bitsprx3.dll', 'browseui.dll', 'cryptdlg.dll', 'dssenh.dll', 'gpkcsp.dll', 'initpki.dll', 'jscript.dll', 'mshtml.dll', 'msi.dll', 'mssip32.dll', 'msxml.dll', 'msxml3.dll', 'msxml3a.dll', 'msxml3r.dll', 'msxml4.dll', 'msxml4a.dll', 'msxml4r.dll', 'msxml6.dll', 'msxml6r.dll', 'muweb.dll', 'ole32.dll', 'oleaut32.dll', 'Qmgr.dll', 'Qmgrprxy.dll', 'rsaenh.dll', 'sccbase.dll', 'scrrun.dll', 'shdocvw.dll', 'shell32.dll', 'slbcsp.dll', 'softpub.dll', 'rlmon.dll', 'userenv.dll', 'vbscript.dll', 'Winhttp.dll', 'wintrust.dll', 'wuapi.dll', 'wuaueng.dll', 'wuaueng1.dll', 'wucltui.dll', 'wucltux.dll', 'wups.dll', 'wups2.dll', 'wuweb.dll', 'wuwebv.dll', 'Xpob2res.dll', 'WBEM\wmisvc.dll'
        foreach ($Dll in $DllFiles) {
            $file = $env:windir + "\System32\$Dll"
            Register-DLLFile -FilePath $File
        }


        [int]$ClientActionExitCode = (Start-Process -FilePath $ClientActionCommand -ArgumentList $ClientActionArgs -Wait -NoNewWindow -PassThru).ExitCode

        if ($Install -or $Repair) {
            if (($ClientActionExitCode -eq 0) -and ($ClientActionArgs.ToLower() -contains '/noservice')) {
                #Client install complete
                Write-Verbose $([string]::Format('{0} of ConfigMgr Client complete', $Action))
                # Increment Client Count
                [int]$NewClientInstallCount = 1 + (Get-RegistryValue -Path $RegistryKey -Name 'ClientInstallCount')
                $null = Set-RegistryValue -Path $RegistryKey -Name 'ClientInstallCount' -Value $NewClientInstallCount
                if ($FirstInstall -eq $true) {
                    Write-Host "ConfigMgr Client was installed for the first time. Waiting 6 minutes for client to syncronize policy before proceeding."
                    Start-Sleep -Seconds 360
                }
                return $true
            }
            elseif (($ClientActionExitCode -eq 0) -and ($ClientActionArgs.ToLower() -notcontains '/noservice')) {
                #client installing
                Write-Verbose $([string]::Format('{0} of ConfigMgr Client has begun', $Action))
                Start-Sleep -Seconds 30
                [string]$ProcessID = Get-Process -name 'ccmsetup' -ErrorAction SilentlyContinue | ForEach-Object { $_.Id }
                if ($ProcessID.Trim() -eq '') {
                    Write-Warning 'No Process ID found for CCMSETUP'
                    Write-Warning 'ERROR - CCMSETUP not launched successfully, validate command line is correct'
                    return $false
                }
                else {
                    Write-Verbose $([string]::Format('Monitoring Process ID {0} for CCMSETUP to complete'. $ProcessID))
                    Write-Verbose $([string]::Format('ConfigMgr client {0} is running', $Action))
                    Wait-Process -Id $ProcessID
                    Write-Verbose $([string]::Format('ConfigMgr client {0} complete', $Action))

                    #Service Startup Checks
                    try {
                        $null = Get-Process -name 'ccmexec' -ErrorAction Stop
                        $null = Get-Service -name 'ccmexec' -ErrorAction Stop

                        # Increment Client Count
                        [int]$NewClientInstallCount = 1 + (Get-RegistryValue -Path $RegistryKey -Name 'ClientInstallCount')
                        $null = Set-RegistryValue -Path $RegistryKey -Name 'ClientInstallCount' -Value $NewClientInstallCount
                        if ($FirstInstall -eq $true) {
                            Write-Host "ConfigMgr Client was installed for the first time. Waiting 6 minutes for client to syncronize policy before proceeding."
                            Start-Sleep -Seconds 360
                        }

                        return $true
                    }
                    catch {
                        Write-Error $([string]::Format('ERROR - Service check after client {0} failed', $Action))
                        return $false
                    }
                    #Detect Application that needs to install
                }
            }
            else {
                #client install failed
                Write-Error $([string]::Format('ERROR - {0} of ConfigMgr Client has failed', $Action))
                return $false
            }
        }
        else {
            if ($ClientActionExitCode -eq 0) {
                Write-Verbose 'System Center ConfigMgr Client successfully uninstalled'
                $script:SCCMInstalled = $false
                #If Policy Platform is installed, Remove it
                Try {
                    [string]$FilePath = Get-ChildItem -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall | Where-Object { $_.GetValue('DisplayName') -eq 'Microsoft Policy Provider' } | ForEach-Object { $_.GetValue('UninstallString') }
                    [string]$ProcessName = $FilePath.Substring(0, $FilePath.IndexOf(' '))
                    [string]$ArgList = $FilePath.Substring($FilePath.IndexOf('/'), $FilePath.Length - $FilePath.IndexOf('/'))
                    [int]$PolProvUninstall = (Start-Process -FilePath $ProcessName -ArgumentList $ArgList -Wait -NoNewWindow -PassThru ).ExitCode
                    If ($PolProvUninstall -eq 0) {
                        Write-Verbose 'Microsoft Policy Platform successfully uninstalled'
                    }
                    Else {
                        Write-Warning $([string]::Format('ERROR - Microsoft Policy Platform failed to uninstall with exit code {0}', $PolProvUninstall))
                    }
                }
                Catch {
                    Write-Warning 'ERROR - Could not bind to registry to do uninstall of Microsoft Policy Platform.  Either cannot access registry, or the MPP is not installed'
                }
            }
            Else {
                Write-Warning 'ERROR - Failed to uninstall System Center ConfigMgr Client'
            }
        }

        Set-LastAction -LastAction "Client $Action"
    }

    function Register-DLLFile {
        [CmdletBinding()]
        param ([string]$FilePath)

        try {
            $null = Start-Process -FilePath 'regsvr32.exe' -Args "/s `"$FilePath`"" -Wait -NoNewWindow -PassThru
        }
        catch {
        }
    }

    Function Start-RebootApplication {
        $taskName = 'ConfigMgr Client Health - Reboot on demand'
        #$OS = Get-OperatingSystem
        #if ($OS -like "*Windows 7*") {
        $task = schtasks.exe /query | FIND /I "ConfigMgr Client Health - Reboot"
        #}
        #else { $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue }
        if ($null -eq $task) {
            New-RebootTask -taskName $taskName
        }
        #if ($OS -notlike "*Windows 7*") {Start-ScheduledTask -TaskName $taskName }
        #else {
        schtasks.exe /Run /TN $taskName
        #}
    }

    Function New-RebootTask {
        Param([Parameter(Mandatory = $true)]$taskName)
        $rebootApp = Get-XMLConfigRebootApplication

        # $execute is the executable file, $arguement is all the arguments added to it.
        $execute, $arguments = $rebootApp.Split(' ')
        $argument = $null

        foreach ($i in $arguments) {
            $argument += $i + " "
        }

        # Trim the " " from argument if present
        $i = $argument.Length - 1
        if ($argument.Substring($i) -eq ' ') {
            $argument = $argument.Substring(0, $argument.Length - 1)
        }

        #$OS = Get-OperatingSystem
        #if ($OS -like "*Windows 7*") {
        schtasks.exe /Create /tn $taskName /tr "$execute $argument" /ru "BUILTIN\Users" /sc ONCE /st 00:00 /sd 01/01/1901
        #}
        <#
        else {
            $action = New-ScheduledTaskAction -Execute $execute -Argument $argument
            $userPrincipal = New-ScheduledTaskPrincipal -GroupId "S-1-5-32-545"
            Register-ScheduledTask -Action $action -TaskName $taskName -Principal $userPrincipal | Out-Null
        }
        #>
    }

    Function Start-Ccmeval {
        Write-Host "Starting Built-in Configuration Manager Client Health Evaluation"
        Set-LastAction -LastAction 'Starting CCMEval'
        $task = "Microsoft\Configuration Manager\Configuration Manager Health Evaluation"
        schtasks.exe /Run /TN $task | Out-Null
    }

    # Function to store SCCM log file changes to be processed
    Function New-SCCMLogFileJob {
        Param(
            [Parameter(Mandatory = $true)]$Logfile,
            [Parameter(Mandatory = $true)]$Text,
            [Parameter(Mandatory = $true)]$SCCMLogJobs
        )

        $path = Get-CCMLogDirectory
        $file = "$path\$LogFile"
        $SCCMLogJobs.Rows.Add($file, $text)
    }

    # Function to remove info in SCCM logfiles after remediation. This to prevent false positives triggering remediation next time script runs
    Function Update-SCCMLogFile {
        Param([Parameter(Mandatory = $true)]$SCCMLogJobs)
        Write-Verbose "Start Update-SCCMLogFile"
        foreach ($job in $SCCMLogJobs) {
            Get-Content -Path $job.File | Where-Object { $_ -notmatch $job.Text } | Out-File $job.File -Force
        }
        Write-Verbose "End Update-SCCMLogFile"
    }

    function Invoke-CCMClientAction {
        [CmdletBinding(SupportsShouldProcess)]
        <#
            .SYNOPSIS
                Invokes CM Client actions on local or remote machines
            .DESCRIPTION
                This script will allow you to invoke a set of CM Client actions on a machine (with optional credentials), providing a list of the actions and an optional delay betweens actions.
                The function will attempt for a default of 5 minutes to invoke the action, with a 10 second delay inbetween attempts. This is to account for invoke-wmimethod failures.
            .PARAMETER Schedule
                Define the schedules to run on the machine - 'HardwareInv', 'FullHardwareInv', 'SoftwareInv', 'UpdateScan', 'UpdateEval', 'MachinePol', 'AppEval', 'DDR', 'SourceUpdateMessage', 'SendUnsentStateMessage'
            .PARAMETER Delay
                Specify the delay in seconds between each schedule when more than one is ran - 0-30 seconds
            .PARAMETER ComputerName
                Specifies the computers to run this against
            .PARAMETER Timeout
                Specifies the timeout in minutes after which any individual computer will stop attempting the schedules. Default is 5 minutes.
            .PARAMETER Credential
                Optional PSCredential
            .EXAMPLE
                C:\PS> Invoke-CCMClientAction -Schedule MachinePol,HardwareInv
                    Start a machine policy eval and a hardware inventory cycle
            .NOTES
                FileName:    Invoke-CCMClientAction.ps1
                Author:      Cody Mathis
                Contact:     @CodyMathis123
                Created:     11-29-2018
                Updated:     10-15-2019
        #>
        param
        (
            [parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
            [Alias('Computer', 'PSComputerName', 'IPAddress', 'ServerName', 'HostName', 'DNSHostName')]
            [string[]]$ComputerName = $env:COMPUTERNAME,
            [parameter(Mandatory = $true)]
            [ValidateSet('HardwareInv', 'FullHardwareInv', 'SoftwareInv', 'UpdateScan', 'UpdateEval', 'MachinePol', 'AppEval', 'DDR', 'SourceUpdateMessage', 'SendUnsentStateMessage')]
            [string[]]$Schedule,
            [parameter(Mandatory = $false)]
            [ValidateRange(0, 30)]
            [int]$Delay = 0,
            [parameter(Mandatory = $false)]
            [int]$Timeout = 5,
            [parameter(Mandatory = $false)]
            [pscredential]$Credential
        )
        begin {
            $TimeSpan = New-TimeSpan -Minutes $Timeout
        }
        process {
            foreach ($Computer in $ComputerName) {
                foreach ($Option in $Schedule) {
                    if ($PSCmdlet.ShouldProcess("[ComputerName = '$Computer'] [Schedule = '$Option']", "Invoke Schedule")) {
                        $Action = switch -Regex ($Option) {
                            '^HardwareInv$|^FullHardwareInv$' {
                                '{00000000-0000-0000-0000-000000000001}'
                            }
                            'SoftwareInv' {
                                '{00000000-0000-0000-0000-000000000002}'
                            }
                            'UpdateScan' {
                                '{00000000-0000-0000-0000-000000000113}'
                            }
                            'UpdateEval' {
                                '{00000000-0000-0000-0000-000000000108}'
                            }
                            'MachinePol' {
                                '{00000000-0000-0000-0000-000000000021}'
                            }
                            'AppEval' {
                                '{00000000-0000-0000-0000-000000000121}'
                            }
                            'DDR' {
                                '{00000000-0000-0000-0000-000000000003}'
                            }
                            'SourceUpdateMessage' {
                                '{00000000-0000-0000-0000-000000000032}'
                            }
                            'SendUnsentStateMessage' {
                                '{00000000-0000-0000-0000-000000000111}'
                            }
                        }
                        $StopWatch = [System.Diagnostics.Stopwatch]::StartNew()
                        do {
                            try {
                                Remove-Variable MustExit -ErrorAction SilentlyContinue
                                Remove-Variable Invocation -ErrorAction SilentlyContinue
                                if ($Option -eq 'FullHardwareInv') {
                                    $getWMIObjectSplat = @{
                                        ComputerName = $Computer
                                        Namespace    = 'root\ccm\invagt'
                                        Class        = 'InventoryActionStatus'
                                        Filter       = "InventoryActionID ='$Action'"
                                        ErrorAction  = 'Stop'
                                    }
                                    if ($PSBoundParameters.ContainsKey('Credential')) {
                                        $getWMIObjectSplat.Add('Credential', $Credential)
                                    }
                                    Write-Verbose "Attempting to delete Hardware Inventory history for $Computer as a FullHardwareInv was requested"
                                    $HWInv = Get-WmiObject @getWMIObjectSplat
                                    if ($null -ne $HWInv) {
                                        $HWInv.Delete()
                                        Write-Verbose "Hardware Inventory history deleted for $Computer"
                                    }
                                    else {
                                        Write-Verbose "No Hardware Inventory history to delete for $Computer"
                                    }
                                }
                                $invokeWmiMethodSplat = @{
                                    ComputerName = $Computer
                                    Name         = 'TriggerSchedule'
                                    Namespace    = 'root\ccm'
                                    Class        = 'sms_client'
                                    ArgumentList = $Action
                                    ErrorAction  = 'Stop'
                                }
                                if ($PSBoundParameters.ContainsKey('Credential')) {
                                    $invokeWmiMethodSplat.Add('Credential', $Credential)
                                }
                                Write-Verbose "Triggering a $Option Cycle on $Computer via the 'TriggerSchedule' WMI method"
                                $Invocation = Invoke-WmiMethod @invokeWmiMethodSplat
                            }
                            catch [System.UnauthorizedAccessException] {
                                Write-Error -Message "Access denied to $Computer" -Category AuthenticationError -Exception $_.Exception
                                $MustExit = $true
                            }
                            catch {
                                Write-Warning "Failed to invoke the $Option cycle via WMI. Will retry every 10 seconds until [StopWatch $($StopWatch.Elapsed) -ge $Timeout minutes] Error: $($_.Exception.Message)"
                                Start-Sleep -Seconds 10
                            }
                        }
                        until ($Invocation -or $StopWatch.Elapsed -ge $TimeSpan -or $MustExit)
                        if ($Invocation) {
                            Write-Verbose "Successfully invoked the $Option Cycle on $Computer via the 'TriggerSchedule' WMI method"
                            Start-Sleep -Seconds $Delay
                        }
                        elseif ($StopWatch.Elapsed -ge $TimeSpan) {
                            Write-Error "Failed to invoke $Option cycle via WMI after $Timeout minutes of retrrying."
                        }
                        $StopWatch.Reset()
                    }
                }
            }
        }
        end {
            Write-Verbose "Following actions invoked - $Schedule"
        }
    }

    Function CleanUp {
        $clientpath = (Get-LocalFilesPath).ToLower()
        $forbidden = "$env:SystemDrive", "$env:SystemDrive\", "$env:SystemDrive\windows", "$env:SystemDrive\windows\"
        $NoDelete = $false
        foreach ($item in $forbidden) {
            if ($clientpath -eq $item) {
                $NoDelete = $true
            }
        }

        if (((Test-Path "$clientpath\Temp" -ErrorAction SilentlyContinue) -eq $True) -and ($NoDelete -eq $false) ) {
            Write-Verbose "Cleaning up temporary files in $clientpath\ClientHealth"
            Remove-Item "$clientpath\Temp" -Recurse -Force | Out-Null
        }

        $LocalLogging = ((Get-XMLConfigLoggingLocalFile).ToString()).ToLower()
        if (($LocalLogging -ne "true") -and ($NoDelete -eq $false)) {
            Write-Verbose "Local logging disabled. Removing $clientpath\ClientHealth"
            Remove-Item "$clientpath\Temp" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
        }
    }

    Function New-LogObject {
        # Write-Verbose "Start New-LogObject"

        if ($PowerShellVersion -ge 6) {
            $OS = Get-CimInstance -class Win32_OperatingSystem
            $CS = Get-CimInstance -class Win32_ComputerSystem
            if ($CS.Manufacturer -eq 'Lenovo') {
                $Model = (Get-CimInstance Win32_ComputerSystemProduct).Version
            }
            else {
                $Model = $CS.Model
            }
        }
        else {
            $OS = Get-WmiObject -class Win32_OperatingSystem
            $CS = Get-WmiObject -class Win32_ComputerSystem
            if ($CS.Manufacturer -eq 'Lenovo') {
                $Model = (Get-WmiObject Win32_ComputerSystemProduct).Version
            }
            else {
                $Model = $CS.Model
            }
        }

        # Handles different OS languages
        $Hostname = Get-Hostname
        $OperatingSystem = $OS.Caption
        $Architecture = ($OS.OSArchitecture -replace ('([^0-9])(\.*)', '')) + '-Bit'
        $Build = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').BuildLabEx
        $Manufacturer = $CS.Manufacturer
        $ClientVersion = 'Unknown'
        $Sitecode = Get-ClientSiteCode
        $Domain = Get-Domain
        [int]$MaxLogSize = 0
        $MaxLogHistory = 0
        if ($PowerShellVersion -ge 6) {
            $InstallDate = Get-SmallDateTime -Date ($OS.InstallDate)
        }
        else {
            $InstallDate = Get-SmallDateTime -Date ($OS.ConvertToDateTime($OS.InstallDate))
        }
        $InstallDate = $InstallDate -replace '\.', ':'
        $LastLoggedOnUser = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\').LastLoggedOnUser
        $CacheSize = Get-ClientCache
        $Services = 'Unknown'
        $Updates = 'Unknown'
        $DNS = 'Unknown'
        $Drivers = 'Unknown'
        $ClientCertificate = 'Unknown'
        $PendingReboot = 'Unknown'
        $RebootApp = 'Unknown'
        if ($PowerShellVersion -ge 6) {
            $LastBootTime = Get-SmallDateTime -Date ($OS.LastBootUpTime)
        }
        else {
            $LastBootTime = Get-SmallDateTime -Date ($OS.ConvertToDateTime($OS.LastBootUpTime))
        }
        $LastBootTime = $LastBootTime -replace '\.', ':'
        $OSDiskFreeSpace = Get-OSDiskFreeSpace
        $AdminShare = 'Unknown'
        $ProvisioningMode = 'Unknown'
        $StateMessages = 'Unknown'
        $WUAHandler = 'Unknown'
        $WMI = 'Unknown'
        $RefreshComplianceState = Get-SmallDateTime
        $smallDateTime = Get-SmallDateTime
        $smallDateTime = $smallDateTime -replace '\.', ':'
        [float]$PSVersion = [float]$psVersion = [float]$PSVersionTable.PSVersion.Major + ([float]$PSVersionTable.PSVersion.Minor / 10)
        [int]$PSBuild = [int]$PSVersionTable.PSVersion.Build
        if ($PSBuild -le 0) {
            $PSBuild = $null
        }
        $UBR = Get-UBR
        $BITS = $null
        $ClientSettings = $null

        $obj = New-Object PSObject -Property @{
            Hostname               = $Hostname
            Operatingsystem        = $OperatingSystem
            Architecture           = $Architecture
            Build                  = $Build
            Manufacturer           = $Manufacturer
            Model                  = $Model
            InstallDate            = $InstallDate
            OSUpdates              = $null
            LastLoggedOnUser       = $LastLoggedOnUser
            ClientVersion          = $ClientVersion
            PSVersion              = $PSVersion
            PSBuild                = $PSBuild
            Sitecode               = $Sitecode
            Domain                 = $Domain
            MaxLogSize             = $MaxLogSize
            MaxLogHistory          = $MaxLogHistory
            CacheSize              = $CacheSize
            ClientCertificate      = $ClientCertificate
            ProvisioningMode       = $ProvisioningMode
            DNS                    = $DNS
            Drivers                = $Drivers
            Updates                = $Updates
            PendingReboot          = $PendingReboot
            LastBootTime           = $LastBootTime
            OSDiskFreeSpace        = $OSDiskFreeSpace
            Services               = $Services
            AdminShare             = $AdminShare
            StateMessages          = $StateMessages
            WUAHandler             = $WUAHandler
            WMI                    = $WMI
            RefreshComplianceState = $RefreshComplianceState
            ClientInstalled        = $null
            Version                = $Version
            Timestamp              = $smallDateTime
            HWInventory            = $null
            SWMetering             = $null
            ClientSettings         = $null
            BITS                   = $BITS
            PatchLevel             = $UBR
            ClientInstalledReason  = $null
            RebootApp              = $RebootApp
        }
        Write-Output $obj
        # Write-Verbose "End New-LogObject"
    }

    Function Update-LogFile {
        Param(
            [Parameter(Mandatory = $true)]$Log,
            [Parameter(Mandatory = $false)]$Mode
        )
        # Start the logfile
        Write-Verbose "Start Update-LogFile"

        Test-ValuesBeforeLogUpdate
        $text = $log | Select-Object Hostname, Operatingsystem, Architecture, Build, Model, InstallDate, OSUpdates, LastLoggedOnUser, ClientVersion, PSVersion, PSBuild, SiteCode, Domain, MaxLogSize, MaxLogHistory, CacheSize, ClientCertificate, ProvisioningMode, DNS, PendingReboot, LastBootTime, OSDiskFreeSpace, Services, AdminShare, StateMessages, WUAHandler, WMI, RefreshComplianceState, ClientInstalled, Version, Timestamp, HWInventory, SWMetering, BITS, ClientSettings, PatchLevel, ClientInstalledReason | Out-String
        $text = $text -replace "`t" -replace "  " -replace " :", ":" -creplace '(?m)^\s*\r?\n'

        if ($Mode -eq 'Local') {
            Out-LogFile -Text $text -Mode $Mode -Severity 1
        }
        elseif ($Mode -eq 'ClientInstalledFailed') {
            Out-LogFile -Text $text -Mode $Mode -Severity 1
        }
        else {
            Out-LogFile -Text $text -Severity 1
        }
        Write-Verbose "End Update-LogFile"
    }

    function Set-LastAction {
        param(
            [parameter(Mandatory = $true)]
            [string]$LastAction
        )
        $KeyPath = Get-XMLConfigRegistryKey
        $null = Set-RegistryValue -Path $KeyPath -Name 'LastAction' -Value $LastAction -PropertyType string
        $null = Set-RegistryValue -Path $KeyPath -Name 'LastActionTimestamp' -Value (Get-Date) -PropertyType string
    }

    Function Invoke-WMIRebuild {
        <#
        .SYNOPSIS
        Initiated when WMI Rebuild is required
        .DESCRIPTION
        In depth rebuild of Windows Management Instrumentation (WMI)
        .EXAMPLE
        Invoke-WMIRebuild
        .EXAMPLE
        Invoke-WMIRebuild
        #>
        Write-Verbose 'Information: Starting the process of rebuilding WMI'

        [string]$WbemPath = "$($env:WINDIR)\system32\wbem"

        Write-Verbose 'Information: Stop SMS Agent Host if it exists'
        Try {
            $null = Get-Service -Name CcmExec -ErrorAction Stop | Stop-Service -ErrorAction Stop
            Write-Verbose 'Information: Stop SMS Agent Host service was successful'
        }
        Catch {
            Write-Warning 'Warning: Stop SMS Agent Host service was not successful'
        }

        #stop CCMSETUP process and delete service if it exists

        Write-Verbose 'Information: Stop CCMSETUP Service and delete if it exists'

        if ($null -ne (Get-Service -Name ccmsetup -ErrorAction SilentlyContinue)) {
            $null = Get-Process -Name ccmsetup -ErrorAction SilentlyContinue | Stop-Process -ErrorAction SilentlyContinue -Force

            #delete the ccmsetup service
            [object]$Status = Start-Process -FilePath "$env:windir\system32\sc.exe" -ArgumentList 'delete ccmsetup' -WindowStyle Hidden -PassThru -Wait
            if ($Status.ExitCode -eq 0) {
                Write-Verbose 'Information: CCMSETUP service was deleted'
            }
            else {
                Write-Warning 'Warning: CCMSETUP service was not deleted; continuing to repair WMI'
            }

            #cleaning up variable
            Remove-Variable -Name 'Status'
        }

        #uninstall SCCM client if the service exists
        if (Get-Service -Name ccmexec -ErrorAction SilentlyContinue) {
            Invoke-CMClientRemediationAction -Uninstall
        }

        #reset security on the WMI, Windows Update, and BITSF services
        [array]$Services = @('winmgmt', 'wuauserv', 'bits')

        foreach ($Service in $Services) {
            Write-Verbose $([string]::Format('Information: The current security descriptor for the {0} Service is {1}', $Service, (& "$env:windir\system32\sc.exe" sdshow $Service)))
            Write-Verbose $([string]::Format('Information: Setting default security descriptor on {0} to D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)', $Service))
            [object]$Status = Start-Process -FilePath "$env:windir\system32\sc.exe" -ArgumentList ('sdset {0} D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)' -f $Service) -WindowStyle Hidden -PassThru -Wait
            Write-Verbose $([string]::Format('Information: The exit code to set the security descriptor is {0}', $($Status.ExitCode)))
        }

        #cleaning up variable
        Remove-Variable -Name 'Status'

        #Re-enabling DCOM
        if (Set-RegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\OLE' -Name 'EnableDCOM' -Value 'Y') {
            Write-Verbose 'Information: Successfully enabled DCOM'
        }
        else {
            Write-Warning 'Warning: DCOM not enabled successfully'
        }

        #Resetting DCOM Permissions
        Write-Verbose 'Information: Resetting DCOM Permissions'

        [array]$RegEntries = @('DefaultLaunchPermission', 'MachineAccessRestriction', 'MachineLaunchRestriction')
        foreach ($RegEntry in $RegEntries) {
            [object]$Status = Start-Process -FilePath "$env:windir\system32\reg.exe" -ArgumentList ('delete HKLM\software\microsoft\ole /v {0} /f' -f $RegEntry) -WindowStyle Hidden -PassThru -Wait
            Write-Verbose $([string]::Format(('Information: The exit code to delete {0} from HKLM:\software\microsoft\ole is {1}', $RegEntry, $($Status.ExitCode))))
        }

        #Rebuild WMI using WINMGMT utility (supported in each OS with version 6 or higher)

        Write-Verbose 'Refreshing WMI ADAP'
        [object]$Status = Start-Process -FilePath ('{0}\wmiadap.exe' -f $WbemPath) -ArgumentList '/f' -WindowStyle Hidden -PassThru -Wait
        Write-Verbose $([string]::Format('Information: The exit code to Refresh WMI ADAP is {0}', $($Status.ExitCode)))

        Write-Verbose 'Registering WMI'
        [object]$Status = Start-Process -FilePath "$env:windir\system32\regsvr32.exe" -ArgumentList '/s wmisvc.dll' -WindowStyle Hidden -PassThru -Wait
        Write-Verbose $([string]::Format('Information: The exit code to Register WMI is {0}', $($Status.ExitCode)))

        Write-Verbose 'Resyncing Performance Counters'
        [object]$Status = Start-Process -FilePath ('{0}\winmgmt.exe' -f $WbemPath) -ArgumentList '/resyncperf' -WindowStyle Hidden -PassThru -Wait
        Write-Verbose $([string]::Format('Information: The exit code to Resync Performance Counters is {0}' -f $($Status.ExitCode)))

        Write-Verbose 'Attempting salvage of WMI repository using winmgmt /salvagerepository'
        [object]$Status = Start-Process -FilePath ('{0}\winmgmt.exe' -f $WbemPath) -ArgumentList '/salvagerepository' -WindowStyle Hidden -PassThru -Wait
        Write-Verbose $([string]::Format('Information: The exit code to Salvage the WMI Repository is {0}', $($Status.ExitCode)))

        #unregistering atl.dll
        [object]$Status = Start-Process -FilePath "$env:windir\system32\regsvr32.exe" -ArgumentList "/u $env:windir\system32\atl.dll /s" -WindowStyle Hidden -PassThru -Wait
        Write-Verbose $([string]::Format('Information: The exit code to Unregister ATL.DLL is {0}', $($Status.ExitCode)))

        #registering required DLLs
        [array]$DLLs = @('scecli.dll', 'userenv.dll', 'atl.dll')

        foreach ($Dll in $DLLs) {
            [object]$Status = Start-Process -FilePath "$env:windir\system32\regsvr32.exe" -ArgumentList ('/s {0}\system32\{1}' -f $env:windir, $Dll) -WindowStyle Hidden -PassThru -Wait
            Write-Verbose $([string]::Format('Information: The exit code to Register {0} is {1}', $DLL, $($Status.ExitCode)))
        }

        #Register WMI Provider
        [object]$Status = Start-Process -FilePath ('{0}\wmiprvse.exe' -f $WbemPath) -ArgumentList '/regserver' -WindowStyle Hidden -PassThru -Wait
        Write-Verbose $([string]::Format('Information: The exit code to Register WMI Provider is {0}', $($Status.ExitCode))

            #Restart WMI Service
            Try {
                Write-Host 'Restarting the WMI Service'

                [string]$SvcName = 'winmgmt'

                # Get dependent services
                [array]$DepSvcs = Get-Service -name $SvcName -dependentservices | Where-Object { $_.Status -eq 'Running' } | Select-Object -ExpandProperty Name

                # Check to see if dependent services are started
                if ($null -ne $DepSvcs) {
                    # Stop dependencies
                    foreach ($DepSvc in $DepSvcs) {
                        Write-Host $([string]::Format('Stopping {0} as it is a dependent of the WMI Service', $($DepSvc.Name)))
                        $null = Stop-Service -InputObject $DepSvc.Name -ErrorAction Stop
                        do {
                            [object]$Service = Get-Service -name $DepSvc.Name | Select-Object -ExpandProperty Status
                            Start-Sleep -seconds 1
                        }
                        until ($Service.Status -eq 'Stopped')
                    }
                }

                # Restart service
                $null = Restart-Service -InputObject $SvcName -Force -ErrorAction Stop
                do {
                    $Service = Get-Service -name $SvcName | Select-Object -ExpandProperty Status
                    Start-Sleep -seconds 1
                }
                until ($Service.Status -eq 'Running')

                # We check for Auto start flag on dependent services and start them even if they were stopped before
                foreach ($DepSvc in $DepSvcs) {
                    $StartMode = Get-WmiObject -Class win32_service -Filter ("NAME = '{0}'" -f $($DepSvc.Name)) | Select-Object -ExpandProperty StartMode
                    if ($StartMode.StartMode -eq 'Auto') {

                        Write-Host $([string]::Format('Starting {0} after restarting WMI Service', $($DepSvc.Name)))
                        $null = Start-Service -InputObject $DepSvc.Name -ErrorAction Stop
                        do {
                            $Service = Get-Service -name $DepSvc.Name | Select-Object -ExpandProperty Status
                            Start-Sleep -seconds 1
                        }
                        until ($Service.Status -eq 'Running')
                    }
                }
            }
            Catch {
                Write-Error 'ERROR - Restart of WMI service failed'
            }

            Write-Host 'ACTION: Rebuild of WMI completed; please reboot system'

            #Run GPUpdate if on Domain
            if ((Get-RegistryValue -Path 'HKLM:\System\CurrentControlSet\Services\Tcpip\Parameters' -Name 'Domain') -ne '') {
                $null = & "$env:windir\system32\gpupdate.exe"
            }

            Write-Host 'Testing WMI Health post repair'

            if (Test-WMIHealth -eq $False) {
                Write-Error 'ERROR - WMI Verification failed; reseting the repository with winmgmt /resetrepository'

                [object]$Status = Start-Process -FilePath ('{0}\winmgmt.exe' -f $WbemPath) -ArgumentList '/resetrepository' -WindowStyle Hidden -PassThru -Wait
                Write-Host $([string]::Format('Information: The exit code to Reset the WMI Repository is {0}', $($Status.ExitCode)))

                if ($Status.ExitCode -eq 0) {
                    Write-Host 'WMI reset successfully; verifying repository again'

                    if (Test-WMIHealth -eq $false) {
                        Write-Error 'ERROR - WMI Verification failed after reseting the repository with winmgmt /resetrepository'
                        [bool]$WMIHealth = $false
                    }
                    else {
                        [bool]$WMIHealth = $true
                    }
                }
            }
            else {
                [bool]$WMIHealth = $true
            }

            #increment WMI rebuild count by 1 and write back to registry; it is important to track this number no matter success or failure of the rebuild
            $RegistryKey = Get-XMLConfigRegistryKey
            [int]$WMIRebuildCount = 1 + (Get-RegistryValue -Path $RegistryKey -Name 'WMIRebuildAttempts')
            $null = Set-RegistryValue -Path $RegistryKey -Name 'WMIRebuildAttempts' -Value $WMIRebuildCount

            Write-Verbose $([string]::Format('Information: WMI has been rebuilt {0} times by the Client Health Remediation for Configuration Manager script', $WMIRebuildCount)))

        if ($WMIHealth) {
            Write-Host 'Information: WMI Verification successful after reseting the repository with winmgmt /resetrepository'
            Write-Verbose 'Information: Detecting Microsoft Policy Platform installation; if installed will attempt to compile MOF/MFL files'
            Write-Verbose 'Information: This is done to prevent ccmsetup from erroring when trying to compile DiscoveryStatus.mof and there are issues with the root\Microsoft\PolicyPlatform namespace'

            if (Test-Path -Path "$env:ProgramFiles\Microsoft Policy Platform" -ErrorAction SilentlyContinue) {
                [array]$MPPFiles = Get-ChildItem -Path "$env:ProgramFiles\Microsoft Policy Platform" | Where-Object { ($_.Extension -eq '.mof' -or $_.Extension -eq '.mfl') -and $_.Name -notlike '*uninst*' } | ForEach-Object { $_.fullname }
                foreach ($MPPFile in $MPPFiles) {
                    [object]$Status = Start-Process -FilePath ('{0}\mofcomp.exe' -f $WbemPath) -ArgumentList ('""{0}""' -f $MPPFile) -WindowStyle Hidden -PassThru -Wait
                    Write-Verbose $([string]::Format('Information: The exit code to MOFCOMP {0} is {1}', $MPPfile, $($Status.ExitCode)))
                }
            }
            else {
                Write-Error 'Warning: Unable to get Microsoft Policy Platform files'
            }
            return $True
        }
        else {
            return $false
        }
    }

    Function Send-CHHttpXML {
        <#
            .SYNOPSIS
            Uses HTTP to upload the XML created by the script to a WebService

            .DESCRIPTION
            Uses HTTP to upload the XML created by the script to a WebService.  The server the XML will be updloaded to will be the one located in HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft PFE Remediation for Configuration Manager\PrimarySiteName.
            Will return a bool value when complete.

            .EXAMPLE
            Send-CHHttpXML -XMLFile C:\test.xml -SiteServer HTTP:\\Primary01.contoso.local

            .PARAMETER XMLFile
            String value. Full path to the XML File.

            .PARAMETER SiteServer
            String value. Name of the Site Server with the installed webservice to upload the XML file to.
         #>

        PARAM
        (
            [Parameter(Mandatory = $True)]
            [ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
            [ValidatePattern('.xml$')]
            [string]$XMLFile,
            [Parameter(Mandatory = $True)]
            [string]$SiteServer
        )
        Set-LastAction -LastAction 'XML Upload'
        $WebServiceURL = [string]::Format('http://{0}/PFEIncoming/PFEIncoming.aspx', $SiteServer)
        Write-Verbose "Determined [WebServiceURL = '$WebServiceURL']"
        Write-Verbose "File '$XMLFile' selected for http upload"

        #Check to make sure the XML file is where it should be
        Try {
            Write-Verbose 'Sending XML to webservice'
            if (Test-XML -xmlFilePath $XMLFile) {
                [byte[]]$encodedContent = Get-Content -Encoding byte -Path $XMLFile

                if ($PSVersionTable.PSVersion.Major -gt 2) {
                    Write-Verbose 'Using "Invoke-WebRequest" to send XML to webservice'
                    $Request = Invoke-WebRequest -Uri $WebServiceURL -Method Post -Body $encodedContent -ContentType 'text/plain' -UseBasicParsing
                    switch ($Request.StatusCode) {
                        '200' {
                            Write-Host $([string]::Format('XML was sent to {0}.', $WebServiceURL))
                            $Return = $True                        
                        }
                        default {
                            Write-Warning $([string]::Format('Failed to send XML to {0} - Status Code: {1}.', $WebServiceURL, $Request.StatusCode))
                            $Return = $false                        
                        }
                    }
                }
                else {
                    Write-Verbose 'Using "[Net.WebRequest]" to send XML to webservice'
                    #Create the Web Request
                    $webRequest = [Net.WebRequest]::Create($WebServiceURL)
                    $webRequest.Method = 'POST'

                    #encode the message
                    if ($encodedContent.length -gt 0) {
                        $webRequest.ContentLength = $encodedContent.length
                        $requestStream = $webRequest.GetRequestStream()
                        $requestStream.Write($encodedContent, 0, $encodedContent.length)
                        $requestStream.Close()
                    }

                    Write-Host $([string]::Format('XML was sent to {0}.', $WebServiceURL))

                    $Return = $True
                }

                #Rename old XML file
                Remove-Item $XMLFile.Replace('xml', 'txt') -Force -ErrorAction SilentlyContinue
                Rename-Item $XMLFile -NewName $XMLFile.Replace('xml', 'txt').ToLower() -Force
                return $return
            }
            else {
                Write-Error 'Cannot upload invalid XML'
                return $false
            }
        }
        Catch {
            [string]$ErrorMsg = ($Error[0].toString()).Split('.')[0]
            #Catch any error and write tolog
            Write-Error $([string]::Format('ERROR - Failed to upload XML with error ({0})', $ErrorMsg))

            Return $False
        }
    }

    #region Getters - XML config file
    Function Get-LocalFilesPath {
        if ($config) {
            $obj = $Xml.Configuration.LocalFiles
        }
        if ($null -eq $obj) {
            $obj = Join-Path $env:SystemDrive "ClientHealth"
        }
        Return $obj
    }

    Function Get-XMLConfigClientVersion {
        if ($config) {
            $obj = $Xml.Configuration.Client | Where-Object { $_.Name -eq 'Version' } | Select-Object -ExpandProperty '#text'
        }

        Write-Output $obj
    }

    Function Get-XMLConfigClientSitecode {
        if ($config) {
            $obj = $Xml.Configuration.Client | Where-Object { $_.Name -eq 'SiteCode' } | Select-Object -ExpandProperty '#text'
        }

        Write-Output $obj
    }

    Function Get-XMLConfigClientAutoUpgrade {
        if ($config) {
            $obj = $Xml.Configuration.Client | Where-Object { $_.Name -eq 'AutoUpgrade' } | Select-Object -ExpandProperty '#text'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigClientMaxLogSize {
        if ($config) {
            $obj = $Xml.Configuration.Client | Where-Object { $_.Name -eq 'Log' } | Select-Object -ExpandProperty 'MaxLogSize'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigClientMaxLogHistory {
        if ($config) {
            $obj = $Xml.Configuration.Client | Where-Object { $_.Name -eq 'Log' } | Select-Object -ExpandProperty 'MaxLogHistory'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigClientMaxLogSizeEnabled {
        if ($config) {
            $obj = $Xml.Configuration.Client | Where-Object { $_.Name -eq 'Log' } | Select-Object -ExpandProperty 'Enable'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigClientCache {
        if ($config) {
            $obj = $Xml.Configuration.Client | Where-Object { $_.Name -eq 'CacheSize' } | Select-Object -ExpandProperty 'Value'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigClientCacheDeleteOrphanedData {
        if ($config) {
            $obj = $Xml.Configuration.Client | Where-Object { $_.Name -eq 'CacheSize' } | Select-Object -ExpandProperty 'DeleteOrphanedData'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigClientCacheEnable {
        if ($config) {
            $obj = $Xml.Configuration.Client | Where-Object { $_.Name -eq 'CacheSize' } | Select-Object -ExpandProperty 'Enable'
        }
        Write-Output $obj
    }
    
    Function Get-XMLConfigUpdatesShare {
        if ($config) {
            $obj = $Xml.Configuration.Option | Where-Object { $_.Name -eq 'Updates' } | Select-Object -ExpandProperty 'Share'
        }

        If (!($obj)) {
            $obj = Join-Path $global:ScriptPath "Updates"
        }
        Return $obj
    }

    Function Get-XMLConfigUpdatesEnable {
        if ($config) {
            $obj = $Xml.Configuration.Option | Where-Object { $_.Name -eq 'Updates' } | Select-Object -ExpandProperty 'Enable'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigUpdatesFix {
        if ($config) {
            $obj = $Xml.Configuration.Option | Where-Object { $_.Name -eq 'Updates' } | Select-Object -ExpandProperty 'Fix'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigLoggingLocalFile {
        if ($config) {
            $obj = $Xml.Configuration.Log | Where-Object { $_.Name -eq 'File' } | Select-Object -ExpandProperty 'LocalLogFile'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigLoggingEnable {
        if ($config) {
            $obj = $Xml.Configuration.Log | Where-Object { $_.Name -eq 'File' } | Select-Object -ExpandProperty 'Enable'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigLoggingMaxHistory {
        if ($config) {
            $obj = $Xml.Configuration.Log | Where-Object { $_.Name -eq 'File' } | Select-Object -ExpandProperty 'MaxLogHistory'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigLoggingLevel {
        if ($config) {
            $obj = $Xml.Configuration.Log | Where-Object { $_.Name -eq 'File' } | Select-Object -ExpandProperty 'Level'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigLoggingTimeFormat {
        if ($config) {
            $obj = $Xml.Configuration.Log | Where-Object { $_.Name -eq 'Time' } | Select-Object -ExpandProperty 'Format'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigPendingRebootApp {
        # TODO verify this function
        if ($config) {
            $obj = $Xml.Configuration.Option | Where-Object { $_.Name -eq 'PendingReboot' } | Select-Object -ExpandProperty 'StartRebootApplication'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigMaxRebootDays {
        if ($config) {
            $obj = $Xml.Configuration.Option | Where-Object { $_.Name -eq 'MaxRebootDays' } | Select-Object -ExpandProperty 'Days'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigRebootApplication {
        if ($config) {
            $obj = $Xml.Configuration.Option | Where-Object { $_.Name -eq 'RebootApplication' } | Select-Object -ExpandProperty 'Application'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigRebootApplicationEnable {
        if ($config) {
            $obj = $Xml.Configuration.Option | Where-Object { $_.Name -eq 'RebootApplication' } | Select-Object -ExpandProperty 'Enable'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigDNSCheck {
        # TODO verify switch, skip test and monitor for console extension
        if ($config) {
            $obj = $Xml.Configuration.Option | Where-Object { $_.Name -eq 'DNSCheck' } | Select-Object -ExpandProperty 'Enable'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigCcmSQLCELog {
        # TODO implement monitor mode
        if ($config) {
            $obj = $Xml.Configuration.Option | Where-Object { $_.Name -eq 'CcmSQLCELog' } | Select-Object -ExpandProperty 'Enable'
        }

        Write-Output $obj
    }

    Function Get-XMLConfigDNSFix {
        if ($config) {
            $obj = $Xml.Configuration.Option | Where-Object { $_.Name -eq 'DNSCheck' } | Select-Object -ExpandProperty 'Fix'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigDrivers {
        if ($config) {
            $obj = $Xml.Configuration.Option | Where-Object { $_.Name -eq 'Drivers' } | Select-Object -ExpandProperty 'Enable'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigOSDiskFreeSpace {
        if ($config) {
            $obj = $Xml.Configuration.Option | Where-Object { $_.Name -eq 'OSDiskFreeSpace' } | Select-Object -ExpandProperty '#text'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigHardwareInventoryEnable {
        if ($config) {
            $obj = $Xml.Configuration.Option | Where-Object { $_.Name -eq 'HardwareInventory' } | Select-Object -ExpandProperty 'Enable'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigHardwareInventoryFix {
        if ($config) {
            $obj = $Xml.Configuration.Option | Where-Object { $_.Name -eq 'HardwareInventory' } | Select-Object -ExpandProperty 'Fix'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigSoftwareMeteringEnable {
        if ($config) {
            $obj = $Xml.Configuration.Option | Where-Object { $_.Name -eq 'SoftwareMetering' } | Select-Object -ExpandProperty 'Enable'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigSoftwareMeteringFix {
        if ($config) {
            $obj = $Xml.Configuration.Option | Where-Object { $_.Name -eq 'SoftwareMetering' } | Select-Object -ExpandProperty 'Fix'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigHardwareInventoryDays {
        if ($config) {
            $obj = $Xml.Configuration.Option | Where-Object { $_.Name -eq 'HardwareInventory' } | Select-Object -ExpandProperty 'Days'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigRemediationAdminShare {
        if ($config) {
            $obj = $Xml.Configuration.Remediation | Where-Object { $_.Name -eq 'AdminShare' } | Select-Object -ExpandProperty 'Fix'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigRemediationClientProvisioningMode {
        if ($config) {
            $obj = $Xml.Configuration.Remediation | Where-Object { $_.Name -eq 'ClientProvisioningMode' } | Select-Object -ExpandProperty 'Fix'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigRemediationClientStateMessages {
        if ($config) {
            $obj = $Xml.Configuration.Remediation | Where-Object { $_.Name -eq 'ClientStateMessages' } | Select-Object -ExpandProperty 'Fix'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigRemediationClientWUAHandler {
        if ($config) {
            $obj = $Xml.Configuration.Remediation | Where-Object { $_.Name -eq 'ClientWUAHandler' } | Select-Object -ExpandProperty 'Fix'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigRemediationClientWUAHandlerDays {
        if ($config) {
            $obj = $Xml.Configuration.Remediation | Where-Object { $_.Name -eq 'ClientWUAHandler' } | Select-Object -ExpandProperty 'Days'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigBITSCheck {
        if ($config) {
            $obj = $Xml.Configuration.Option | Where-Object { $_.Name -eq 'BITSCheck' } | Select-Object -ExpandProperty 'Enable'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigBITSCheckFix {
        if ($config) {
            $obj = $Xml.Configuration.Option | Where-Object { $_.Name -eq 'BITSCheck' } | Select-Object -ExpandProperty 'Fix'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigClientSettingsCheck {
        $obj = $Xml.Configuration.Option | Where-Object { $_.Name -eq 'ClientSettingsCheck' } | Select-Object -ExpandProperty 'Enable'
        Write-Output $obj
    }

    Function Get-XMLConfigClientSettingsCheckFix {
        $obj = $Xml.Configuration.Option | Where-Object { $_.Name -eq 'ClientSettingsCheck' } | Select-Object -ExpandProperty 'Fix'
        Write-Output $obj
    }

    Function Get-XMLConfigWMI {
        if ($config) {
            $obj = $Xml.Configuration.Option | Where-Object { $_.Name -eq 'WMI' } | Select-Object -ExpandProperty 'Enable'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigWMIRepairEnable {
        if ($config) {
            $obj = $Xml.Configuration.Option | Where-Object { $_.Name -eq 'WMI' } | Select-Object -ExpandProperty 'Fix'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigWMIWriteEnable {
        if ($config) {
            $obj = $Xml.Configuration.Option | Where-Object { $_.Name -eq 'WMI' } | Select-Object -ExpandProperty 'Write'
        }
        Write-Output $obj
    }
    Function Get-XMLConfigRefreshComplianceState {
        # Measured in days
        if ($config) {
            $obj = $Xml.Configuration.Option | Where-Object { $_.Name -eq 'RefreshComplianceState' } | Select-Object -ExpandProperty 'Enable'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigRefreshComplianceStateDays {
        if ($config) {
            $obj = $Xml.Configuration.Option | Where-Object { $_.Name -eq 'RefreshComplianceState' } | Select-Object -ExpandProperty 'Days'
        }
        Write-Output $obj
    }

    Function Get-XMLConfigRemediationClientCertificate {
        if ($config) {
            $obj = $Xml.Configuration.Remediation | Where-Object { $_.Name -eq 'ClientCertificate' } | Select-Object -ExpandProperty 'Fix'
        }
        Write-Output $obj
    }

    function Get-XMLConfigClientInstallProperty {
        if ($Config) {
            $exeParams = [string]::Join(' ', $Xml.Configuration.ClientEXEInstallProperty)
            $msiParams = [string]::Join(' ', $Xml.Configuration.ClientMSIInstallProperty)
            $SiteCode = Get-XMLConfigClientSiteCode
            $CacheSize = Get-XMLConfigClientCache
            $obj = [string]::Format('{0} SMSSITECODE={1} SMSCACHESIZE={2} {3}', $exeParams, $SiteCode, $CacheSize, $msiParams)
        }
        Write-Output $obj
    }

    function Get-XMLConfigRegistryKey {
        if ($Config) {
            $obj = $Xml.Configuration.RegistryKey
        }
        Write-Output $obj
    }

    function Get-XMLConfigSiteServer {
        if ($Config) {
            $obj = $Xml.Configuration.PrimarySiteServer
        }
        Write-Output $obj
    }

    function Get-XMLConfigDCOMVerify {
        if ($Config) {
            $obj = $XML.Configuration.Option | Where-Object { $_.Name -eq 'DCOM' } | Select-Object -ExpandProperty 'Enable'
        }
        Write-Output $obj
    }

    function Get-XMLConfigDCOMCheckFix {
        if ($Config) {
            $obj = $XML.Configuration.Option | Where-Object { $_.Name -eq 'DCOM' } | Select-Object -ExpandProperty 'Fix'
        }
        Write-Output $obj
    }

    function Get-XMLConfigCheckStaleLogs {
        if ($Config) {
            $obj = $XML.Configuration.Option | Where-Object { $_.Name -eq 'StaleLogs' } | Select-Object -ExpandProperty 'Enable'
        }
        Write-Output $obj
    }

    function Get-XMLConfigCheckStaleLogsDays {
        if ($Config) {
            $obj = $XML.Configuration.Option | Where-Object { $_.Name -eq 'StaleLogs' } | Select-Object -ExpandProperty 'Days'
        }
        Write-Output $obj
    }

    function Get-XMLConfigLanternAppCI {
        if ($Config) {
            $obj = $XML.Configuration.Option | Where-Object { $_.Name -eq 'LanternAppCI' } | Select-Object -ExpandProperty 'Enable'
        }
        Write-Output $obj
    }

    #     <Log Name="DDR" UploadBy="HTTP" Enable="True" />

    function Get-XMLConfigDDREnable {
        if ($Config) {
            $obj = $Xml.Configuration.Log | Where-Object { $_.Name -eq 'DDR' } | Select-Object -ExpandProperty 'Enable'
        }
        Write-Output $obj
    }

    function Get-XMLConfigDDRUploadBy {
        if ($Config) {
            $obj = $Xml.Configuration.Log | Where-Object { $_.Name -eq 'DDR' } | Select-Object -ExpandProperty 'UploadBy'
        }
        Write-Output $obj
    }
    #endregion Getters - XML config file
    #endregion functions

    # Set default restart values to false
    $newinstall = $false
    $restartCCMExec = $false
    $Reinstall = $false


    # If config.xml is used
    if ($Config) {
        # Build the ConfigMgr Client Install Property string
        $clientCacheSize = Get-XMLConfigClientCache
        $clientAutoUpgrade = (Get-XMLConfigClientAutoUpgrade).ToLower()
        $AdminShare = Get-XMLConfigRemediationAdminShare
        $ClientProvisioningMode = Get-XMLConfigRemediationClientProvisioningMode
        $ClientStateMessages = Get-XMLConfigRemediationClientStateMessages
        $ClientWUAHandler = Get-XMLConfigRemediationClientWUAHandler
        $RegistryKey = Get-XMLConfigRegistryKey
    }
    $LastRunRegistryValueName = "LastRun"

    # Create a DataTable to store all changes to log files to be processed later. This to prevent false positives to remediate the next time script runs if error is already remediated.
    $SCCMLogJobs = New-Object System.Data.DataTable
    [Void]$SCCMLogJobs.Columns.Add("File")
    [Void]$SCCMLogJobs.Columns.Add("Text")

}
Process {
    Write-Host "<--- ConfigMgr Client Health Check starting --->"
    Set-LastAction -LastAction 'Started'

    #region Registry Stamping
    if (!(Test-Path -Path $RegistryKey)) {
        #region creating keys if they don't exist
        [string]$RegKey = Split-Path -Path $RegistryKey -Leaf
        [string]$RegPath = Split-Path -Path $RegistryKey -Parent
        Try {
            Write-Verbose "Creating Registry Key $RegistryKey"
            $null = New-Item -Path $RegPath -Name $RegKey -ErrorAction Stop
        }
        Catch {
            Write-Error "Error: Cannot write registry key $RegistryKey"
        }
        #endregion creating keys if they don't exist

        $null = Set-RegistryValue -Path $RegistryKey -Name 'WMIRebuildAttempts' -Value 0 -PropertyType 'dword'
        $null = Set-RegistryValue -Path $RegistryKey -Name 'ClientInstallCount' -Value 0 -PropertyType 'dword'
    }
    else {
        if ([string]::IsNullOrWhiteSpace($(Get-RegistryValue -Path $RegistryKey -Name 'WMIRebuildAttempts'))) {
            $null = Set-RegistryValue -Path $RegistryKey -Name 'WMIRebuildAttempts' -Value 0 -PropertyType 'dword'
        }
        if ([string]::IsNullOrWhiteSpace($(Get-RegistryValue -Path $RegistryKey -Name 'ClientInstallCount'))) {
            $null = Set-RegistryValue -Path $RegistryKey -Name 'ClientInstallCount' -Value 0 -PropertyType 'dword'
        }
    }
    $null = Set-RegistryValue -Path $RegistryKey -Name 'ScriptVer' -Value $Version
    #endregion Registry Stamping

    Write-Verbose "Starting precheck. Determing if script will run or not."
    # Veriy script is running with administrative priveleges.
    If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        $text = 'ERROR: Powershell not running as Administrator! Client Health aborting.'
        Out-LogFile -Text $text -Severity 3
        Write-Error $text
        Exit 1
    }
    else {
        # Will exit with errorcode 2 if in task sequence and not TS name in log
        Test-InTaskSequence

        $StartupText1 = [string]::Format('PowerShell version: {0}. Script executing with Administrator rights.', $PSVersionTable.PSVersion)
        Write-Host $StartupText1
        $StartupText2 = [string]::Format('ConfigMgr Client Health {0} starting.', $Version)
        Write-Host $StartupText2
    }

    # If config.xml is used
    $LocalLogging = Get-XMLConfigLoggingLocalFile
    $FileLogging = Get-XMLConfigLoggingEnable
    $FileLogLevel = Get-XMLConfigLoggingLevel

    #Get the last run from the registry, defaulting to the minimum date value if the script has never ran.
    try {
        [datetime]$LastRun = Get-RegistryValue -Path $RegistryKey -Name $LastRunRegistryValueName
    }
    catch {
        $LastRun = [datetime]::MinValue
    }
    Write-Host "Script last ran: $($LastRun)"

    Write-Verbose "Testing if log files are bigger than max history for logfiles."
    Test-ConfigMgrHealthLogging

    # Create the log object containing the result of health check
    $Log = New-LogObject

    Write-Verbose 'Testing if ConfigMgr client is installed. Installing if not.'
    $ClientInstalled = Test-ConfigMgrClient -Log $Log
    Write-Host "Client installed = $ClientInstalled"

    Write-Verbose 'Validating WMI is not corrupt...'
    $WMI = Get-XMLConfigWMI
    if ($WMI -eq 'True') {
        Write-Verbose 'Beginning WMI repository verification'
        if (-not (Test-WMIHealth)) {
            Write-Error 'Error - WMI repository verification failed'
            $Log.Wmi = 'Corrupt'
            [bool]$WMIHealth = $False
        }
        else {
            Write-Verbose 'WMI repository verification was successful'
            $Log.Wmi = 'Ok'
            [bool]$WMIHealth = $True
        }
        $null = Set-RegistryValue -Path $RegistryKey -Name 'WMIHealthy' -Value $WMIHealth
        Write-Host "WMI Healthy: $WMIHealth"
        if (-not $WMIHealth -and (Get-XMLConfigWMIRepairEnable) -eq 'True') {
            Write-Error "WMI is unhealthy, and Fix is set to true, will attempt repair"
            if (Invoke-WMIRebuild -eq $True) {
                Write-Host 'WMI Rebuild Successful'
                $Log.Wmi = 'Ok'
                $reinstall = $true
                New-ClientInstalledReason -Log $Log -Message "Corrupt WMI."
            }
            else {
                Write-Error 'Error - WMI rebuild failed; will not attempt to reinstall SCCM client'
            }
        }
    }

    [string]$DCOMVerify = Get-XMLConfigDCOMVerify
    [string]$DCOMFix = Get-XMLConfigDCOMCheckFix
    $DCOMVerify
    $DCOMFix
    if ($DCOMVerify -eq 'True') {
        Write-Verbose 'Checking DCOM health'
        Set-LastAction -LastAction 'Checking DCOM health'
        [string]$DCOMHealth = 'Healthy'
        [string]$DCOMProtocolHealth = 'Healthy'

        [string]$DCOM = Get-RegistryValue -Path 'HKLM:\Software\Microsoft\Ole' -Name 'EnableDCOM'
        [array]$DCOMProtocols = Get-RegistryValue -Path 'HKLM:\Software\Microsoft\RPC' -Name 'DCOM Protocols'

        if ($DCOMProtocols[0] -eq '') {
            [string]$DCOMProtocolHealth = 'Unhealthy'
            Write-Error 'Error - DCOM protocols are missing; if remediation is enabled, this will be created'

            if ($DCOMFix -eq 'True') {
                Set-LastAction -LastAction 'Remediating DCOM Protocols'
                [string]$DCOMProtocol = 'ncacn_ip_tcp'
                if ((Set-RegistryValue -Path 'HKLM:\Software\Microsoft\RPC' -Name 'DCOM Protocols' -Value $DCOMProtocol -PropertyType multistring) -eq $True) {
                    [string]$DCOMProtocolHealth = 'Healthy'
                    Write-Host 'DCOM Protocols Remediated'
                    Set-LastAction -LastAction 'DCOM Protocols Remediated'
                }
                else {
                    Write-Error "Failed to remediate DCOM Protocols"
                    Set-LastAction -LastAction 'DCOM Protocol Remediation failed'
                    [string]$DCOMProtocolHealth = 'Unhealthy'
                }
            }
            else {
                Write-Error 'Error - DCOM protocols are missing, but remediation is disabled for this hardware type; will not modify DCOM protocols'
            }
        }
        elseif ($DCOMProtocols -Contains 'ncacn_ip_tcp') {
            Write-Host 'DCOM Protocols: Ok'
        }
        else {
            Write-Error 'Error - DCOM Protocols are not configured correctly'

            if ($DCOMFix -eq 'True') {
                Write-Warning 'DCOM Protocol ncacn_ip_tcp is missing; adding it to the existing list of protocols'
                Set-LastAction -LastAction 'Remediating DCOM Protocols'

                [string]$DCOMProtocols = ''
                foreach ($DCOMProtocol in $DCOMProtocols) {
                    if ($DCOMProtocols -eq '') {
                        $DCOMProtocols = $DCOMProtocol
                    }
                    else {
                        $DCOMProtocols = ('{0},{1}' -f $DCOMProtocols, $DCOMProtocol)
                    }
                }
                $DCOMProtocols = ('{0},ncacn_ip_tcp' -f $DCOMProtocols)
                if ((Set-RegistryValue -Path 'HKLM:\Software\Microsoft\RPC' -Name 'DCOM Protocols' -Value $DCOMProtocols -PropertyType multistring) -eq $True) {
                    [string]$DCOMProtocolHealth = 'Healthy'
                    Write-Host 'DCOM Protocols Remediated'
                    Set-LastAction -LastAction 'DCOM Protocols Remediated'
                }
                else {
                    Write-Error "Failed to remediate DCOM Protocols"
                    [string]$DCOMProtocolHealth = 'Unhealthy'
                }
            }
            else {
                Write-Error 'Error - DCOM protocols are missing, but remediation is disabled for this hardware type; will not modify DCOM protocols'
            }
        }

        if ($DCOM -ne 'Y') {
            [string]$DCOMHealth = 'Unhealthy'
            Write-Error 'Error - DCOM is not enabled; if remediation is enabled, it will be enabled'

            if ($DCOMFix -eq 'True') {
                Set-LastAction -LastAction 'Remediation DCOM'
                [string]$DCOMProtocols = 'ncacn_ip_tcp'
                if ((Set-RegistryValue -Path 'HKLM:\Software\Microsoft\Ole' -Name 'EnableDCOM' -Value 'Y' -PropertyType string) -eq $True) {
                    [string]$DCOMHealth = 'Healthy'
                    Write-Host 'DCOM Remediated'
                    Set-LastAction -LastAction 'DCOM Remediated'
                }
                else {
                    Write-Error "Failed to remediate DCOM Protocols"
                    Set-LastAction -LastAction 'DCOM Remediation failed'
                    [string]$DCOMHealth = 'Unhealthy'
                }
            }
            else {
                Write-Error 'Error - DCOM is not enabled, but remediation is disabled for this hardware type; will not enable DCOM'
            }
        }
        else {
            Write-Host 'DCOM: Ok'
        }

        #Update script status in registry
        $null = Set-RegistryValue -Path $RegistryKey -Name 'DCOM' -Value $DCOMHealth -PropertyType 'string'
        $null = Set-RegistryValue -Path $RegistryKey -Name 'DCOMProtocols' -Value $DCOMProtocolHealth -PropertyType 'string'
        Set-LastAction -LastAction 'DCOM Verification Completed'
    }

    $CheckStaleLogs = Get-XMLConfigCheckStaleLogs
    if ($ClientInstalled -and $CheckStaleLogs -eq 'True') {
        $StaleLogDays = Get-XMLConfigCheckStaleLogsDays
        [array]$LogFiles = @('PolicyEvaluator', 'InventoryAgent')
        Set-LastAction -LastAction 'Checking if log files are stale'
        Write-Verbose 'Checking if log files are stale'

        [string]$StaleLogFiles = ''
        [bool]$SCCMClientRepair = $False

        foreach ($SCCMLogFile in $LogFiles) {
            if ((Test-StaleLog -LogFileName $SCCMLogFile -DaysStale $StaleLogDays) -eq $True) {
                if ($StaleLogFiles -eq '') {
                    $StaleLogFiles = $SCCMLogFile
                }
                else {
                    $StaleLogFiles = ('{0},{1}' -f $StaleLogFiles, $SCCMLogFile)
                }
                [bool]$SCCMClientRepair = $True
            }
        }

        if ($StaleLogFiles -eq '') {
            $StaleLogFiles = 'Healthy'
        }

        $null = Set-RegistryValue -Path $RegistryKey -Name 'StaleLogs' -Value $StaleLogFiles -PropertyType 'string'
        Set-LastAction -LastAction 'Checked Stale Logs'
        Write-Host "StaleLogs: $StaleLogFiles"
    }

    Write-Verbose 'Checking last inventory timestamps'
    Set-LastAction -LastAction 'Checking last inventory timestamps'
    $InventoryAction = @(('HWINVDate (UTC)', 'InventoryActionID = "{00000000-0000-0000-0000-000000000001}"', 'Error collecting hardware data from WMI for HWINV'),
        ('SWINVDate (UTC)', 'InventoryActionID = "{00000000-0000-0000-0000-000000000002}"', 'Error collecting software data from WMI for SWINV'),
        ('HeartbeatDate (UTC)', 'InventoryActionID = "{00000000-0000-0000-0000-000000000003}"', 'Error collecting heartbeat data from WMI Heartbeat'))
    foreach ($Action in $InventoryAction) {
        Try {
            $Inventory = Get-WmiObject -Class InventoryActionStatus -Namespace 'root\ccm\invagt' -Filter $Action[1] -ErrorAction Stop
            if ($Inventory.GetType()) {
                foreach ($Inv in $Inventory) {
                    [datetime]$dtmInvDate = Get-Date -Date ([Management.ManagementDateTimeconverter]::ToDateTime($Inv.LastReportDate))
                    [string]$dtmInvDateUTC = $dtmInvDate.ToUniversalTime()
                    $null = Set-RegistryValue -Path $RegistryKey -Name $Action[0] -Value $dtmInvDateUTC -PropertyType 'string'
                }
            }
        }
        Catch {
            Write-Error $Action[2]
        }
    }

    $LanternAppCI = Get-XMLConfigLanternAppCI
    if ($ClientInstalled -and $LanternAppCI -eq 'True') {
        Write-Verbose 'Checking Application Deployment Policy matches Application CI'
        Set-LastAction -LastAction 'Validating Application CI Lantern'

        if (!(Test-Lantern)) {
            [string]$LanternAppCI = 'Unhealthy'
            Write-Error "LanternAppCI: $LanternAppCI"
            $SCCMClientRepair = $True
        }
        else {
            [string]$LanternAppCI = 'Healthy'
            Write-Host "LanternAppCI: $LanternAppCI"
        }

        $Null = Set-RegistryValue -Path $RegistryKey -Name 'LanternAppCI' -Value $LanternAppCI -PropertyType 'string'
    }

    Write-Verbose 'Determining if compliance state should be resent...'
    $RefreshComplianceState = Get-XMLConfigRefreshComplianceState
    if ( ($RefreshComplianceState -eq 'True') -or ($RefreshComplianceState -ge 1)) {
        $RefreshComplianceStateDays = Get-XMLConfigRefreshComplianceStateDays

        Write-Verbose "Checking if compliance state should be resent after $($RefreshComplianceStateDays) days."
        Test-RefreshComplianceState -Days $RefreshComplianceStateDays -RegistryKey $RegistryKey  -log $Log
    }


    Write-Verbose 'Validating if ConfigMgr client is running the minimum version...'
    if ((Test-ClientVersion -Log $log) -eq $true) {
        if ($clientAutoUpgrade -eq 'true') {
            $reinstall = $true
            New-ClientInstalledReason -Log $Log -Message "Below minimum verison."
        }
    }

    Write-Verbose 'Validating services...'
    Test-Services -Xml $Xml -log $log

    Write-Verbose 'Validating SMSTSMgr service is depenent on CCMExec service...'
    Test-SMSTSMgr

    Write-Verbose 'Validating ConfigMgr SiteCode...'
    Test-ClientSiteCode -Log $Log

    Write-Verbose 'Checking SMSGUID...'
    $GUID = Get-CMClientGUID
    switch ([string]::IsNullOrWhiteSpace($GUID)) {
        $true {
            Set-RegistryValue -Path $RegistryKey -Name 'SMS Unique Identifier' -Value 'Unknown'
        }
        $false {
            Set-RegistryValue -Path $RegistryKey -Name 'SMS Unique Identifier' -Value $GUID
        }
    }

    Write-Verbose 'Validating client cache size.'

    $CacheCheckEnabled = Get-XMLConfigClientCacheEnable
    if ($CacheCheckEnabled -eq 'True') {
        $TestClientCacheSzie = Test-ClientCacheSize -Log $Log
        # This check is now able to set ClientCacheSize without restarting CCMExec service.
        if ($TestClientCacheSzie -eq $true) {
            $restartCCMExec = $false
        }
    }


    if ((Get-XMLConfigClientMaxLogSizeEnabled -eq 'True') -eq $true) {
        Write-Verbose 'Validating Max CCMClient Log Size...'
        $TestClientLogSize = Test-ClientLogSize -Log $Log
        if ($TestClientLogSize -eq $true) {
            $restartCCMExec = $true
        }
    }

    Write-Verbose 'Validating CCMClient provisioning mode...'
    if (($ClientProvisioningMode -eq 'True') -eq $true) {
        Test-ProvisioningMode -log $log
    }
    Write-Verbose 'Validating CCMClient certificate...'

    if ((Get-XMLConfigRemediationClientCertificate -eq 'True') -eq $true) {
        Test-CCMCertificateError -Log $Log
    }

    if (Get-XMLConfigHardwareInventoryEnable -eq 'True') {
        Test-SCCMHardwareInventoryScan -Log $log
    }

    if (Get-XMLConfigSoftwareMeteringEnable -eq 'True') {
        Write-Verbose "Testing software metering prep driver check"
        if ((Test-SoftwareMeteringPrepDriver -Log $Log) -eq $false) {
            $restartCCMExec = $true
        }
    }

    Write-Verbose 'Validating DNS...'
    if ((Get-XMLConfigDNSCheck -eq 'True' ) -eq $true) {
        Test-DNSConfiguration -Log $log
    }

    Write-Verbose 'Validating BITS'
    if (Get-XMLConfigBITSCheck -eq 'True') {
        if ((Test-BITS -Log $Log) -eq $true) {
            Set-RegistryValue -Path $RegistryKey -Name 'BITSQueue' -Value 'Unhealthy'
        }
        else {
            Set-RegistryValue -Path $RegistryKey -Name 'BITSQueue' -Value 'Healthy'
        }
    }

    Write-Verbose 'Validating ClientSettings'
    If (Get-XMLConfigClientSettingsCheck -eq 'True') {
        Test-ClientSettingsConfiguration -Log $log
    }

    if (($ClientWUAHandler -eq 'True') -eq $true) {
        Write-Verbose 'Validating Windows Update Scan not broken by bad group policy...'
        $days = Get-XMLConfigRemediationClientWUAHandlerDays
        Test-RegistryPol -Days $days -log $log -StartTime $LastRun
    }

    if (($ClientStateMessages -eq 'True') -eq $true) {
        Write-Verbose 'Validating that CCMClient is sending state messages...'
        Test-UpdateStore -log $log
    }

    Write-Verbose 'Validating Admin$ and C$ are shared...'
    if (($AdminShare -eq 'True') -eq $true) {
        Test-AdminShare -log $log
    }

    Write-Verbose 'Testing that all devices have functional drivers.'
    if ((Get-XMLConfigDrivers -eq 'True') -eq $true) {
        Test-MissingDrivers -Log $log
    }

    $UpdatesEnabled = Get-XMLConfigUpdatesEnable
    if ($UpdatesEnabled -eq 'True') {
        Write-Verbose 'Validating required updates are installed...'
        Test-Update -Log $log
    }

    Write-Verbose "Validating $env:SystemDrive free diskspace (Only warning, no remediation)..."
    Test-DiskSpace
    Write-Verbose 'Getting install date of last OS patch for log'
    Get-LastInstalledPatches -Log $log
    Write-Verbose 'Sending unsent state messages if any'
    Invoke-CCMClientAction -Schedule SendUnsentStateMessage -Delay 5 -Timeout 1
    Write-Verbose 'Getting Source Update Message policy and policy to trigger scan update source'

    if ($newinstall -eq $false) {
        Invoke-CCMClientAction -Schedule UpdateScan, SourceUpdateMessage, SendUnsentStateMessage -Delay 5 -Timeout 1
    }
    Invoke-CCMClientAction -Schedule MachinePol

    # Restart ConfigMgr client if tagged for restart and no reinstall tag
    if (($restartCCMExec -eq $true) -and ($Reinstall -eq $false)) {
        Write-Host "Restarting service CcmExec..."

        if ($SCCMLogJobs.Rows.Count -ge 1) {
            Stop-Service -Name CcmExec
            Write-Verbose "Processing changes to SCCM logfiles after remediation to prevent remediation again next time script runs."
            Update-SCCMLogFile
            Start-Service -Name CcmExec
        }
        else {
            Restart-Service -Name CcmExec
        }

        $Log.MaxLogSize = Get-ClientMaxLogSize
        $Log.MaxLogHistory = Get-ClientMaxLogHistory
        $log.CacheSize = Get-ClientCache
    }

    # Updating Log object with current version number
    $log.Version = $Version

    Write-Verbose 'Cleaning up after healthcheck'
    CleanUp
    Write-Verbose 'Validating pending reboot...'
    $PendingReboot = Test-PendingReboot -log $log
    $null = Set-RegistryValue -Path $RegistryKey -Name 'RebootPending' -Value $PendingReboot
    Write-Verbose 'Getting last reboot time'
    Get-LastReboot -Xml $xml

    if (Get-XMLConfigClientCacheDeleteOrphanedData -eq "true") {
        Write-Verbose "Removing orphaned ccm client cache items."
        Remove-CCMOrphanedCache
    }

    # Reinstall client if tagged for reinstall and configmgr client is not already installing
    $proc = Get-Process ccmsetup -ErrorAction SilentlyContinue

    if (($reinstall -eq $true -or $SCCMClientRepair) -and ($null -ne $proc) ) {
        Write-Warning "ConfigMgr Client set to reinstall or repair, but ccmsetup.exe is already running."
    }
    elseif (($Reinstall -eq $true) -and ($null -eq $proc)) {
        Write-Host 'Reinstalling ConfigMgr Client'
        Invoke-CMClientRemediationAction -Install

        # Add smalldate timestamp in to log object for when client was installed by Client Health.
        $log.ClientInstalled = Get-SmallDateTime
        $Log.MaxLogSize = Get-ClientMaxLogSize
        $Log.MaxLogHistory = Get-ClientMaxLogHistory
        $log.CacheSize = Get-ClientCache

        # Verify that installed client version is now equal or better that minimum required client version
        $NewClientVersion = Get-ClientVersion
        $MinimumClientVersion = Get-XMLConfigClientVersion

        if ( $NewClientVersion -lt $MinimumClientVersion) {
            # ConfigMgr client version is still not at expected level.
            # Log for now, remediation is comming
            $Log.ClientInstalledReason += " Upgrade failed."
        }

    }
    elseif ($SCCMClientRepair -and $null -eq $proc) {
        Write-Host 'Repairing ConfigMgr Client'
        Invoke-CMClientRemediationAction -Repair

        # Add smalldate timestamp to log object for when client was installed by Client Health.
        $log.ClientInstalled = Get-SmallDateTime
        $Log.MaxLogSize = Get-ClientMaxLogSize
        $Log.MaxLogHistory = Get-ClientMaxLogHistory
        $log.CacheSize = Get-ClientCache
    }

    $BoundaryError = Search-CMLogFile -LogFile "$env:WINDIR\ccmsetup\logs\ccmsetup.log" -SearchStrings "didn't return DP locations" -StartTime (Get-Date).AddHours(-2)
    if (-not ([string]::IsNullOrWhiteSpace($BoundaryError))) {
        Write-Error $BoundaryError
        $null = Set-RegistryValue -Path $RegistryKey -Name "Remediation" -Value $BoundaryError.Substring(0, 63)
    }

    # Get the latest client version in case it was reinstalled by the script
    $log.ClientVersion = Get-ClientVersion

    # Trigger default Microsoft CM client health evaluation
    Start-Ccmeval
    Write-Verbose "End Process"
}

End {
    #Set the last run.
    $Date = Get-Date
    Write-Host "Setting last ran to $($Date)"
    $null = Set-RegistryValue -Path $RegistryKey -Name $LastRunRegistryValueName -Value $Date

    if ($LocalLogging -eq 'true') {
        Write-Output 'Updating local logfile with results'
        Update-LogFile -Log $log -Mode 'Local'
    }

    if (($FileLogging -eq 'true') -and ($FileLogLevel -eq 'full')) {
        Write-Host 'Updating logfile with results'
        Update-LogFile -Log $log
    }

    Write-Verbose 'Beginning creation of XML to report remediation status'
    Set-LastAction -LastAction 'Create XML'
    Try {
        [xml]$pfexml = @"
<?xml version="1.0" encoding="UTF-8"?>
<DDR>
<Property Name="SiteCode" Value="$(Get-RegistryValue -Path $RegistryKey -Name 'AgentSite')" Type="String"/>
<Property Name="Name" Value="$env:COMPUTERNAME" Type="String"/>
<Property Name="SMS Unique Identifier" Value="$(Get-RegistryValue -Path $RegistryKey -Name 'SMS Unique Identifier')" Type="String"/>
<Property Name="NetBIOS Name" Value="$env:COMPUTERNAME" Type="String"/>
<Property Name="PFE_ScriptVer" Value="$Version" Type="String"/>
<Property Name="PFE_LastAction" Value="$(Get-RegistryValue -Path $RegistryKey -Name 'LastAction')" Type="String"/>
<Property Name="PFE_LastDate" Value="$((Get-Date -format yyyy-MM-dd).ToString())" Type="String"/>
<Property Name="PFE_LastTime" Value="$((Get-Date -format HH:mm:ss).ToString())" Type="String"/>
<Property Name="PFE_BITSStatus" Value="$(Get-RegistryValue -Path $RegistryKey -Name 'Service BITS startup')" Type="String"/>
<Property Name="PFE_BITSQueue" Value="$(Get-RegistryValue -Path $RegistryKey -Name 'BITSQueue')" Type="String"/>
<Property Name="PFE_WUAStatus" Value="$(Get-RegistryValue -Path $RegistryKey -Name 'Service wuauserv startup')" Type="String"/>
<Property Name="PFE_WMIStatus" Value="$(Get-RegistryValue -Path $RegistryKey -Name 'Service winmgmt startup')" Type="String"/>
<Property Name="PFE_CCMStatus" Value="$(Get-RegistryValue -Path $RegistryKey -Name 'Service ccmexec startup')" Type="String"/>
<Property Name="PFE_WMIHealthy" Value="$(Get-RegistryValue -Path $RegistryKey -Name 'WMIHealthy')" Type="String"/>
<Property Name="PFE_WMIReadRepository" Value="$(Get-RegistryValue -Path $RegistryKey -Name 'PFE_WMIReadRepository')" Type="String"/>
<Property Name="PFE_WMIWriteRepository" Value="$(Get-RegistryValue -Path $RegistryKey -Name 'WMIWriteRepository')" Type="String"/>
<Property Name="PFE_DCOM" Value="$(Get-RegistryValue -Path $RegistryKey -Name 'DCOM')" Type="String"/>
<Property Name="PFE_DCOMProtocols" Value="$(Get-RegistryValue -Path $RegistryKey -Name 'DCOMProtocols')" Type="String"/>
<Property Name="PFE_RebootPending" Value="$(Get-RegistryValue -Path $RegistryKey -Name 'RebootPending')" Type="String"/>
<Property Name="PFE_CFreeSpace" Value="$(Get-RegistryValue -Path $RegistryKey -Name 'CFreeSpace')" Type="Integer"/>
<Property Name="PFE_StaleLogs" Value="$(Get-RegistryValue -Path $RegistryKey -Name 'StaleLogs')" Type="String"/>
<Property Name="PFE_WMIRebuildAttempts" Value="$(Get-RegistryValue -Path $RegistryKey -Name 'WMIRebuildAttempts')" Type="Integer"/>
<Property Name="PFE_ClientInstallCount" Value="$(Get-RegistryValue -Path $RegistryKey -Name 'ClientInstallCount')" Type="Integer"/>
<Property Name="PFE_PolicyPlatformLAStatus" Value="$(Get-RegistryValue -Path $RegistryKey -Name 'Service lpasvc startup')" Type="String"/>
<Property Name="PFE_PolicyPlatformProcessorStatus" Value="$(Get-RegistryValue -Path $RegistryKey -Name 'Service lppsvc startup')" Type="String"/>
<Property Name="PFE_ACPStatus" Value="$(Get-RegistryValue -Path $RegistryKey -Name 'ACPStatus')" Type="String"/>
<Property Name="PFE_LanternAppCI" Value="$(Get-RegistryValue -Path $RegistryKey -Name 'LanternAppCI')" Type="String"/>
<Property Name="PFE_HardwareInventoryDate (UTC)" Value="$(Get-RegistryValue -Path $RegistryKey -Name 'HWINVDate (UTC)')" Type="String"/>
<Property Name="PFE_SoftwareInventoryDate (UTC)" Value="$(Get-RegistryValue -Path $RegistryKey -Name 'SWINVDate (UTC)')" Type="String"/>
<Property Name="PFE_HeartbeatDate (UTC)" Value="$(Get-RegistryValue -Path $RegistryKey -Name 'HeartbeatDate (UTC)')" Type="String"/>
<Property Name="PFE_ProvisioningMode" Value="$(Get-RegistryValue -Path $RegistryKey -Name 'ProvisioningMode')" Type="String"/>
<Property Name="PFE_Remediation" Value="$(Get-RegistryValue -Path $RegistryKey -Name 'Remediation')" Type="String"/>
</DDR>
"@
        # Saving the XML
        $XMLFileName = [string]::Format('{0}\{1}.xml', $global:ScriptPath, $env:COMPUTERNAME)
        $pfexml.Save($XMLFileName)
    }
    Catch {
        #capture error message and log
        [string]$ErrorMsg = ($Error[0].toString()).Split('.')[0]
        Write-Error ('Error - failed to create XML object: {0}' -f $ErrorMsg)
    }

    <#
        If the PFERemediation service exists, and is running, we will not take any upload action.
        The PFERemediation service will upload according to the PFERemediation.exe.config and
        PrimarySiteName defined in the HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft PFE Remediation for Configuration Manager

        If the PFEREmeidation service does not exist, or is not running, we will upload according to the configuration XML
    #>
    $DDRUpload = Get-XMLConfigDDREnable
    $DDRUploadBy = Get-XMLConfigDDRUploadBy
    $PFEService = Get-WmiObject -Query "SELECT * FROM Win32_Service WHERE Name = 'PFERemediation' AND State = 'Running'"
    switch ($Null) {
        $PFEService {
            switch ($DDRUpload) {
                'True' {
                    $SiteServer = Get-XMLConfigSiteServer
                    switch ($DDRUploadBy) {
                        'HTTP' {
                            Write-Verbose 'Sending the XML via HTTP Web Service'
                            $null = Send-CHHttpXML -XMLFile $XMLFileName -SiteServer $SiteServer
                        }
                        'SMB' {
                            $PFEIncoming = [string]::Format('\\{0}\PFEIncoming$', $SiteServer)
                            Write-Verbose "Copying XML to Network Share $PFEIncoming; validating share path exists"
                            if (Test-Path -Path $PFEIncoming) {
                                Write-Verbose ('Share path {0} exists; copying XML to Network Share' -f $PFEIncoming)

                                Try {
                                    Copy-Item -Path $XMLFileName -Destination $PFEIncoming -ErrorAction Stop
                                    Write-Host 'Successfully copied XML to network share'
                                }
                                Catch {
                                    [string]$ErrorMsg = ($Error[0].toString()).Split('.')[0]
                                    Write-Error ('Error - Copy to {0} failed with error {1}' -f $PFEIncoming, $ErrorMsg)
                                }
                            }
                            else {
                                Write-Error ('Error - PFEIncoming$ share is not accessible on {0}' -f $SiteServer)
                            }
                        }
                    }
                }
                Default {
                    Write-Verbose 'DDR Upload by script is disabled in configuration XML'
                }
            }
        }
        default {
            Write-Verbose 'Not copying XML as PFE Service is running and will perform this action on next cycle'
        }
    }

    Set-LastAction -LastAction 'Finished'
    Write-Verbose "Client Health script finished"
}