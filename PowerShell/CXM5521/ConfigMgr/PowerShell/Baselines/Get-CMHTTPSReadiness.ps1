#region functions
Function Get-CMLogFile {
    <#
    .SYNOPSIS
        Parse Configuration Manager format logs
    .DESCRIPTION
        This function is used to take Configuration Manager formatted logs and turn them into a PSCustomObject so that it can be
        searched and manipulated easily with PowerShell
    .PARAMETER LogFilePath
        Path to the log file(s) you would like to parse.
    .EXAMPLE
        PS C:\> Get-CMLogFile -LogFilePath 'c:\windows\ccm\logs\ccmexec.log'
        Returns the CCMExec.log as a PSCustomObject
    .EXAMPLE
        PS C:\> Get-CMLogFile -LogFilePath 'c:\windows\ccm\logs\AppEnforce.log', 'c:\windows\ccm\logs\AppDiscovery.log'
        Returns the AppEnforce.log and the AppDiscovery.log as a PSCustomObject
    .OUTPUTS
        [pscustomobject]
    .NOTES
        I've done my best to test this against various SCCM log files. They are all generally 'formatted' the same, but do have some
        variance. I had to also balance speed and parsing. In particular, date parsing was problematic around MM vs M and dd vs d.
        The method of splitting the $LogLineArray on multiple fields also takes slightly longer than some alternatives.

        With that said, it can still parse a typical SCCM log VERY quickly. Smaller logs are parsed in milliseconds in my testing.
        Rolled over logs that are 5mb can be parsed in a couple seconds or less.

            FileName: Get-CMLogFile.ps1
            Author:   Cody Mathis
            Contact:  @CodyMathis123
            Created:  9/19/2019
            Updated:  9/19/2019
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$LogFilePath
    )
    begin {
        try {
            Add-Type -TypeDefinition @"
            public enum Severity
            {
                None,
                Informational,
                Warning,
                Error
            }
"@ -ErrorAction Stop
        }
        catch {
            Write-Debug "Severity enum already exists"
        }
    }
    process {
        $ReturnLog = Foreach ($LogFile in $LogFilePath) {
            #region ingest log file with StreamReader. Quick, and prevents locks
            $File = [System.IO.File]::Open($LogFile, 'Open', 'Read', 'ReadWrite')
            $StreamReader = New-Object System.IO.StreamReader($File)
            [string]$LogFileRaw = $StreamReader.ReadToEnd()
            $StreamReader.Close()
            $File.Close()
            #endregion ingest log file with StreamReader. Quick, and prevents locks

            #region perform a regex match to determine the 'type' of log we are working with and parse appropriately
            switch ($true) {
                #region parse a 'typical' SCCM log
                (([Regex]::Match($LogFileRaw, "LOG\[(.*?)\]LOG(.*?)time(.*?)date")).Success) {
                    # split on what we know is a line beginning
                    switch -regex ($LogFileRaw -split "<!\[LOG\[") {
                        '^\s*$' {
                            # ignore empty lines
                            continue
                        }
                        default {
                            <#
                                split Log line into an array on what we know is the end of the message section
                                first item contains the message which can be parsed
                                second item contains all the information about the message/line (ie. type, component, datetime, thread) which can be parsed
                            #>
                            $LogLineArray = $PSItem -split "]LOG]!><"

                            # Strip the log message out of our first array index
                            $Message = $LogLineArray[0].Trim()

                            # Split LogLineArray into a a sub array based on double quotes to pull log line information
                            $LogLineSubArray = $LogLineArray[1] -split 'time="' -split '" date="' -split '" component="' -split '" context="' -split '" type="' -split '" thread="' -split '" file="'

                            $LogLine = @{ }
                            # Rebuild the LogLine into a hash table
                            $LogLine.Message = $Message
                            $LogLine.Type = [Severity]$LogLineSubArray[5]
                            $LogLine.Component = $LogLineSubArray[3]
                            $LogLine.Thread = $LogLineSubArray[6]

                            #region determine timestamp for log line
                            $DateString = $LogLineSubArray[2]
                            $DateStringArray = $DateString -split "-"

                            $MonthParser = switch ($DateStringArray[0].Length) {
                                1 {
                                    'M'
                                }
                                2 {
                                    'MM'
                                }
                            }
                            $DayParser = switch ($DateStringArray[1].Length) {
                                1 {
                                    'd'
                                }
                                2 {
                                    'dd'
                                }
                            }

                            $DateTimeFormat = [string]::Format('{0}-{1}-yyyyHH:mm:ss.fff', $MonthParser, $DayParser)
                            $TimeString = ($LogLineSubArray[1]).Split("+|-")[0].ToString().Substring(0, 12)
                            $DateTimeString = [string]::Format('{0}{1}', $DateString, $TimeString)
                            $LogLine.TimeStamp = [datetime]::ParseExact($DateTimeString, $DateTimeFormat, $null)
                            #region determine timestamp for log line

                            [pscustomobject]$LogLine
                        }
                    }
                }
                #endregion parse a 'typical' SCCM log

                #region parse a 'simple' SCCM log, usually found on site systems
                (([Regex]::Match($LogFileRaw, '\$\$\<(.*?)\>\<thread=')).Success) {
                    switch -regex ($LogFileRaw -split [System.Environment]::NewLine) {
                        '^\s*$' {
                            # ignore empty lines
                            continue
                        }
                        default {
                            <#
                                split Log line into an array
                                first item contains the message which can be parsed
                                second item contains all the information about the message/line (ie. type, component, timestamp, thread) which can be parsed
                            #>
                            $LogLineArray = $PSItem -split '\$\$<'

                            # Strip the log message out of our first array index
                            $Message = $LogLineArray[0]

                            # Split LogLineArray into a a sub array based on double quotes to pull log line information
                            $LogLineSubArray = $LogLineArray[1] -split '><'

                            switch -regex ($Message) {
                                '^\s*$' {
                                    # ignore empty messages
                                    continue
                                }
                                default {
                                    $LogLine = @{ }
                                    # Rebuild the LogLine into a hash table
                                    $LogLine.Message = $Message.Trim()
                                    $LogLine.Type = [Severity]0
                                    $LogLine.Component = $LogLineSubArray[0].Trim()
                                    $LogLine.Thread = ($LogLineSubArray[2] -split " ")[0].Substring(7)

                                    #region determine timestamp for log line
                                    $DateTimeString = $LogLineSubArray[1]
                                    $DateTimeStringArray = $DateTimeString -split " "
                                    $DateString = $DateTimeStringArray[0]
                                    $DateStringArray = $DateString -split "-"

                                    $MonthParser = switch ($DateStringArray[0].Length) {
                                        1 {
                                            'M'
                                        }
                                        2 {
                                            'MM'
                                        }
                                    }
                                    $DayParser = switch ($DateStringArray[1].Length) {
                                        1 {
                                            'd'
                                        }
                                        2 {
                                            'dd'
                                        }
                                    }
                                    $DateTimeFormat = [string]::Format('{0}-{1}-yyyy HH:mm:ss.fff', $MonthParser, $DayParser)
                                    $TimeString = $DateTimeStringArray[1].ToString().Substring(0, 12)
                                    $DateTimeString = [string]::Format('{0} {1}', $DateString, $TimeString)
                                    $LogLine.TimeStamp = [datetime]::ParseExact($DateTimeString, $DateTimeFormat, $null)
                                    #endregion determine timestamp for log line

                                    [pscustomobject]$LogLine
                                }
                            }
                        }
                    }
                }
                #endregion parse a 'simple' SCCM log, usually found on site systems
            }
            #endregion perform a regex match to determine the 'type' of log we are working with and parse appropriately
        }
    }
    end {
        #region return our collected $ReturnLog object. We do a 'select' to maintain property order
        $ReturnLog | Select-Object -Property Message, Component, Type, TimeStamp, Thread
        #endregion return our collected $ReturnLog object. We do a 'select' to maintain property order
    }
}


function Get-WmiRegistryProperty {
    <#
    .SYNOPSIS
        Return registry properties using the WMI StdRegProv

    .DESCRIPTION
        Relies on remote WMI and StdRegProv to allow for returning Registry Properties under a key,
        and you are able to provide pscredential

    .PARAMETER RegRoot
        The root key you want to search under
        ('HKEY_LOCAL_MACHINE', 'HKEY_USERS', 'HKEY_CURRENT_CONFIG', 'HKEY_DYN_DATA', 'HKEY_CLASSES_ROOT', 'HKEY_CURRENT_USER')
        
    .PARAMETER Key
        The key you want to return properties of. (ie. SOFTWARE\Microsoft\SMS\Client\Configuration\Client Properties)

    .PARAMETER Property
        The property name(s) you want to return the value of. This is an optional string array [string[]] and if it is not provided, all properties
        under the key will be returned

    .EXAMPLE
        PS> Get-WmiRegistryProperty -RegRoot HKEY_LOCAL_MACHINE -Key 'SOFTWARE\Microsoft\SMS\Client\Client Components\Remote Control' -Property "Allow Remote Control of an unattended computer"
        Name                           Value
        ----                           -----
        Computer123                 @{Allow Remote Control of an unattended computer=1}

    .OUTPUTS
        [System.Collections.Hashtable]

    .NOTES
        Returns a hashtable with the computername as the key, and the value is a pscustomobject of the properties
#>
    param (
        [parameter(Mandatory = $true)]
        [ValidateSet('HKEY_LOCAL_MACHINE', 'HKEY_USERS', 'HKEY_CURRENT_CONFIG', 'HKEY_DYN_DATA', 'HKEY_CLASSES_ROOT', 'HKEY_CURRENT_USER')]
        [string]$RegRoot,
        [parameter(Mandatory = $true)]
        [string]$Key,
        [parameter(Mandatory = $false)]
        [string[]]$Property,
        [parameter(Mandatory = $false, ValueFromPipelineByPropertyName)]
        [Alias('Computer', 'PSComputerName', 'IPAddress', 'ServerName', 'HostName', 'DNSHostName')]
        [string[]]$ComputerName = $env:COMPUTERNAME,
        [parameter(Mandatory = $false)]
        [PSCredential]$Credential
    )
    begin {
        #region create hash tables for translating values
        $RootKey = @{
            HKEY_CLASSES_ROOT   = 2147483648
            HKEY_CURRENT_USER   = 2147483649
            HKEY_LOCAL_MACHINE  = 2147483650
            HKEY_USERS          = 2147483651
            HKEY_CURRENT_CONFIG = 2147483653
            HKEY_DYN_DATA       = 2147483654
        }
        <#
            Maps the 'PropType' per property to the method we will invoke to get our return value.
            For example, if the 'type' is 1 (string) we have invoke the GetStringValue method to get our return data
        #>
        $RegPropertyMethod = @{
            1  = 'GetStringValue'
            2  = 'GetExpandedStringValue'
            3  = 'GetBinaryValue'
            4  = 'GetDWORDValue'
            7  = 'GetMultiStringValue'
            11 = 'GetQWORDValue'
        }

        <#
            Maps the 'PropType' per property to the property we will have to expand in our return value.
            For example, if the 'type' is 1 (string) we have to ExpandProperty sValue to get our return data
        #>
        $ReturnValName = @{
            1  = 'sValue'
            2  = 'sValue'
            3  = 'uValue'
            4  = 'uValue'
            7  = 'sValue'
            11 = 'uValue'
        }
        #endregion create hash tables for translating values

        # convert RootKey friendly name to the [uint32] equivalent so it can be used later
        $Root = $RootKey[$RegRoot]

        #region define our hash tables for parameters to pass to Get-WMIObject and our return hash table
        $GetWMI_Params = @{ }
        switch ($true) {
            $PSBoundParameters.ContainsKey('Credential') {
                $GetWMI_Params['Credential'] = $Credential
            }
        }
        $GetWMI_Params['List'] = $true
        $GetWMI_Params['Namespace'] = 'root\default'
        $GetWMI_Params['Class'] = "StdRegProv"
        #endregion define our hash tables for parameters to pass to Get-WMIObject and our return hash table
    }
    process {
        foreach ($Computer in $ComputerName) {
            $Return = @{ }

            try {
                #region establish WMI Connection
                $GetWMI_Params['ComputerName'] = $Computer
                $WMI_Connection = Get-WmiObject @GetWMI_Params
                #endregion establish WMI Connection
            }
            catch {
                Write-Error "Failed to establed WMI Connection to $Computer"
            }
            $EnumValues = $WMI_Connection.EnumValues($Root, $Key)
            switch ($PSBoundParameters.ContainsKey('Property')) {
                $true {
                    $PropertiesToReturn = $Property
                }
                $false {
                    $PropertiesToReturn = $EnumValues.sNames
                }
            }
            $PerPC_Reg = @{ }
            foreach ($PropertyName In $PropertiesToReturn) {
                $PropIndex = $EnumValues.sNames.IndexOf($PropertyName)
                switch ($PropIndex) {
                    -1 {
                        Write-Error ([string]::Format('Failed to find [Property = {0}] under [Key = {1}\{2}]', $PropertyName, $RootKey, $Key))
                    }
                    default {
                        $PropType = $EnumValues.Types[$PropIndex]
                        $Prop = $ReturnValName[$PropType]
                        $Method = $RegPropertyMethod[$PropType]
                        $PropertyValueQuery = $WMI_Connection.$Method($Root, $Key, $PropertyName)

                        switch ($PropertyValueQuery.ReturnValue) {
                            0 {
                                $PerPC_Reg.$PropertyName = $PropertyValueQuery.$Prop
                            }
                            default {
                                $Return[$Computer] = $null
                                Write-Error ([string]::Format('Failed to resolve value [Property = {0}] [Key = {1}\{2}]', $PropertyName, $RootKey, $Key))
                            }
                        }
                        $Return[$Computer] = $([pscustomobject]$PerPC_Reg)
                    }
                }
            }

            Write-Output $Return
        }
    }
}

function Get-CMClientDirectory {
    <#
    .SYNOPSIS
        Return the ConfigMgr Client Directory
    .DESCRIPTION
        Checks the registry of the local machine and will return the 'Local SMS Path' property of the 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SMS\Client\Configuration\Client Properties' registry key
        This function uses the Get-WmiRegistryProperty function which uses WMI to query the registry
    .PARAMETER ComputerName
        Optional ComputerName to pull the info from. Uses the WMI method of pulling registry info
    .PARAMETER Credential
        Optional PSCredential that will be used for the WMI cmdlets
    .EXAMPLE
        PS C:\> Get-CMClientDirectory
            Name                           Value
            ----                           -----
            LOUXDWTSSA1362                 C:\WINDOWS\CCM
    #>
    param (
        [parameter(Mandatory = $false, ValueFromPipelineByPropertyName)]
        [Alias('Computer', 'PSComputerName', 'IPAddress', 'ServerName', 'HostName', 'DNSHostName')]
        [string[]]$ComputerName = $env:COMPUTERNAME,
        [parameter(Mandatory = $false)]
        [PSCredential]$Credential
    )
    begin {
        $getWmiRegistryPropertySplat = @{
            Key      = "SOFTWARE\Microsoft\SMS\Client\Configuration\Client Properties"
            Property = "Local SMS Path"
            RegRoot  = 'HKEY_LOCAL_MACHINE'
        }
        switch ($true) {
            $PSBoundParameters.ContainsKey('Credential') {
                $GetWmiRegistryProperty['Credential'] = $Credential
            }
        }
    }
    process {
        foreach ($Computer in $ComputerName) {
            $getWmiRegistryPropertySplat['ComputerName'] = $ComputerName
            $ReturnHashTable = Get-WmiRegistryProperty @getWmiRegistryPropertySplat
            foreach ($PC in $ReturnHashTable.GetEnumerator()) {
                @{$PC.Key = $ReturnHashTable[$PC.Key].'Local SMS Path'.TrimEnd('\') }
            }
        }
    }
}

function Get-CMClientLogDirectory {
    <#
    .SYNOPSIS
        Return the ConfigMgr Client Log Directory
    .DESCRIPTION
        Checks the registry of the local machine and will return the 'LogDirectory' property of the 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\CCM\Logging\@Global' registry key
        This function uses the Get-WmiRegistryProperty function which uses WMI to query the registry
    .PARAMETER ComputerName
        Optional ComputerName to pull the info from. Uses the WMI method of pulling registry info
    .PARAMETER Credential
        Optional PSCredential that will be used for the WMI cmdlets
    .EXAMPLE
        PS C:\> Get-CMClientDirectory
            Name                           Value
            ----                           -----
            LOUXDWTSSA1362                 C:\WINDOWS\CCM\Logs
    #>
    param (
        [parameter(Mandatory = $false, ValueFromPipelineByPropertyName)]
        [Alias('Computer', 'PSComputerName', 'IPAddress', 'ServerName', 'HostName', 'DNSHostName')]
        [string[]]$ComputerName = $env:COMPUTERNAME,
        [parameter(Mandatory = $false)]
        [PSCredential]$Credential
    )
    begin {
        $getWmiRegistryPropertySplat = @{
            Key      = "SOFTWARE\Microsoft\CCM\Logging\@Global"
            Property = "LogDirectory"
            RegRoot  = 'HKEY_LOCAL_MACHINE'
        }
        switch ($true) {
            $PSBoundParameters.ContainsKey('Credential') {
                $GetWmiRegistryProperty['Credential'] = $Credential
            }
        }
    }
    process {
        foreach ($Computer in $ComputerName) {
            $getWmiRegistryPropertySplat['ComputerName'] = $ComputerName
            $ReturnHashTable = Get-WmiRegistryProperty @getWmiRegistryPropertySplat
            foreach ($PC in $ReturnHashTable.GetEnumerator()) {
                @{$PC.Key = $ReturnHashTable[$PC.Key].LogDirectory.TrimEnd('\') }
            }
        }
    }
}
#endregion functions

try {
    $StartedAt = Get-Date
    $CMLogDir = (Get-CMClientLogDirectory).$env:COMPUTERNAME
    $LogFilePath = Join-Path -Path $CMLogDir -ChildPath CMHttpsReadiness.log
    $CCMDir = (Get-CMClientDirectory).$env:COMPUTERNAME
    if ($LogFilePath -and $CCMDir) {
        $CMHTTPSReadiness = Get-Item -Path (Join-Path -Path $CCMDir -ChildPath 'CMHTTPSReadiness.exe')
        $null = Start-Process -FilePath $CMHTTPSReadiness.FullName -WindowStyle Hidden -Wait
        $Log = Get-CMLogFile -LogFilePath $LogFilePath
        $CompliantLogLine = $Log | Where-Object { $_.Message -match 'Client is ready for HTTPS communication.' -and $_.TimeStamp -ge $StartedAt }
        $null -ne $CompliantLogLine
    }
    else {
        $false
    }
}
catch {
    $false
}