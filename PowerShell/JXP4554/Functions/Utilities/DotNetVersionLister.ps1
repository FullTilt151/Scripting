function Get-DotNetVersion {
    <#
    .SYNOPSIS
        Get installed .NET versions from remote computers. Hardcoded .NET versions so the script will
        need to be updated when new versions are released.

    .DESCRIPTION
        Uses remote registry access or PSRemoting.

        Online documenation here:
        http://www.powershelladmin.com/wiki/List_installed_.NET_versions_on_remote_computers

    .PARAMETER ComputerName
        Target computers to retrieve .NET versions from via remote registry access or PSRemoting.
    .PARAMETER PSRemoting
        Use PowerShell remoting instead of remote registry access. Remote registry access requires RPC,
        which in turn requires lots of firewall openings.
    .PARAMETER ExportToCSV
        Export to a CSV file as well as files containing online and offline computers.
    .PARAMETER ContinueOnPingFail
        Try to gather even if the remote computer does not reply to ping.
    .PARAMETER NoSummary
        Do not display the end summary with Write-Host.
    .PARAMETER LocalHost
        Check the local computer. Cannot be used together with -ComputerName.
    .PARAMETER Clobber
        Only in use with -ExportToCSV. Overwrite potentially existing files without prompting.
        Date and time is in the file name by default.
    .EXAMPLE
        Get-DotNetVersion adminsrv1 -Verbose -nos
        VERBOSE: Script start time: 02/09/2017 13:28:44
        VERBOSE: adminsrv1 is online.
        VERBOSE: adminsrv1: Successfully connected to registry.

        ComputerName : adminsrv1
        >=4.x        : 4.5.2 or later
        v4\Client    : Installed
        v4\Full      : Installed
        v3.5         : Installed
        v3.0         : Installed
        v2.0.50727   : Installed
        v1.1.4322    : Not installed (no key)
        Ping         : True
        Error        :

    .EXAMPLE
        PS D:\> Get-DotNetVersion adminsrv1 -Verbose -PSRemoting -NoSummary
        VERBOSE: Script start time: 02/09/2017 13:36:48
        VERBOSE: adminsrv1 is online.

        ComputerName : adminsrv1
        >=4.x        : 4.5.2 or later
        v4\Client    : Installed
        v4\Full      : Installed
        v3.5         : Installed
        v3.0         : Installed
        v2.0.50727   : Installed
        v1.1.4322    : Not installed (no key)
        Ping         :
        Error        :

    #>
    [CmdletBinding()]
    param(
        [Alias('Cn', 'PSComputerName')][string[]] $ComputerName = @(), # not mandatory, not feeling the parameter set love..
        [switch] $PSRemoting,
        [switch] $ExportToCSV,
        [switch] $ContinueOnPingFail,
        [switch] $NoSummary,
        [switch] $LocalHost, # tacking/hacking on this too
        [switch] $Clobber,
        [PSCredential] $Credential)
    ## Author: Joakim Svendsen
    ## Copyright (C) 2011, Joakim Svendsen
    ## All rights reserved.
    ## BSD 3-clause license
    # 2016-01-13: v1.2 - Added support for .NET 4.6.1.
    # 2016-05-29: v1.3 - Code quality improvements, standardization.
    # 2016-10-10: v1.4 - Added support for .NET 4.6.2.
    # 2017-02-06: v1.5 - Making it a function and module, and more standards-compliant (return objects).
    #                    Adding the parameters -ExportToCSV, -PSRemoting, -ContinueOnPingFail and -NoSummary.
    #                    Lots of small changes and improvements. Properly closing and disposing registry objects.
    #                    Added a [gc]::Collect() in the end block.
    # 2017-04-20: v1.6 - Removed the Dispose() calls that caused errors.
    begin {
        #Set-StrictMode -Version Latest
        $MyEAP = 'Stop'
        $ErrorActionPreference = $MyEAP
        $StartTime = [datetime]::Now
        if ($PSRemoting -and $LocalHost) {
            Write-Error -Message "You can't use both the PSRemoting and LocalHost parameter at the same time." -ErrorAction Stop
        }
        if (-not $LocalHost -and $ComputerName.Count -eq 0) {
            Write-Error -Message "You need to specify a computer name or -LocalHost." -ErrorAction Stop
        }
        if ($LocalHost) {
            $ComputerName = @('localhost')
        }
        Write-Verbose -Message "Script start time: $StartTime" #-Verbose
        if ($ExportToCSV) {
            $Date = $StartTime.ToString('yyyy-MM-dd_HH.mm')
            $OutputOnlineFile = ".\DotNetOnline-${Date}.txt"
            $OutputOfflineFile = ".\DotNetOffline-${Date}.txt"
            $CsvOutputFile = ".\DotNet-Versions-${Date}.csv"
            if (-not $Clobber) {
                $FoundExistingLog = $false
                foreach ($File in $OutputOnlineFile, $OutputOfflineFile, $CsvOutputFile) {
                    if (Test-Path -PathType Leaf -Path $File) {
                        $FoundExistingLog = $true
                        "$File already exists"
                    }
                }
                if ($FoundExistingLog -eq $true) {
                    $Answer = Read-Host "The above mentioned log file(s) exist. Overwrite? [yes]"
                    if ($Answer -imatch '^n') {
                        Write-Error -Message 'User aborted due to not wanting to overwrite existing files' -ErrorAction Stop
                        exit 1 # should be redundant
                    }
                }
            }
            # Deleting existing log files if they exist (assume they can be deleted...)
            Remove-Item $OutputOnlineFile -ErrorAction SilentlyContinue
            Remove-Item $OutputOfflineFile -ErrorAction SilentlyContinue
            Remove-Item $CsvOutputFile -ErrorAction SilentlyContinue
        }
        $Counter = 0
        $DotNetData = @{}
        $DotNetVersionStrings = @("v4\Client", "v4\Full", "v3.5", "v3.0", "v2.0.50727", "v1.1.4322")
        function SetDataHashObject {
            [CmdletBinding()]
            param(
                [string] $Computer,
                [bool] $PSRemoting,
                [bool] $LocalHost,
                [string[]] $DotNetVersionStrings = @("v4\Client", "v4\Full", "v3.5", "v3.0", "v2.0.50727", "v1.1.4322"))
            if ($PSRemoting) {
                $DotNetData = @{}
                $DotNetData.$Computer = New-Object -TypeName PSObject -Property @{
                    ComputerName = $Computer
                }
            }
            $DotNetRegistryBase = 'SOFTWARE\Microsoft\NET Framework Setup\NDP'
            $ErrorActionPreference = 'Stop'
            $RegSuccess = $false
            try {
                if ($PSRemoting -or $LocalHost) {
                    # Open local registry
                    $Registry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', [string]::Empty)
                    $RegSuccess = $?
                }
                else {
                    $Registry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Computer)
                    $RegSuccess = $?
                }
            }
            catch {
                Write-Warning -Message "${Computer}: Unable to open $(if (-not $PSremoting) { 'remote ' })registry: $_"
                $DotNetData.$Computer | Add-Member -Name Error -Value "Unable to open remote registry: $_" -MemberType NoteProperty
                return $DotNetData.$Computer
            }
            $ErrorActionPreference = 'Continue'
            Write-Verbose -Message "${Computer}: Successfully connected to registry."
            foreach ($VerString in $DotNetVersionStrings) {
                if ($RegKey = $Registry.OpenSubKey("$DotNetRegistryBase\$VerString")) {
                    if ($RegKey.GetValue('Install') -eq '1') {
                        Add-Member -Name $VerString -Value 'Installed' -MemberType NoteProperty -InputObject $DotNetData.$Computer
                    }
                    else {
                        Add-Member -Name $VerString -Value 'Not installed' -MemberType NoteProperty -InputObject $DotNetData.$Computer
                    }
                }
                else {
                    Add-Member -Name $VerString -Value 'Not installed (no key)' -MemberType NoteProperty -InputObject $DotNetData.$Computer
                }
            }
            # https://msdn.microsoft.com/en-us/library/hh925568 - for release numbers
            # 2016-01-13: Adding 4.6.1.
            # 2016-10-10: Added 4.6.2. (rewrote parts earlier).
            # 2017-02-06: Changing to a switch statement as part of rewriting to a module/function and adding features.
            # 2017-02-11: Rewriting to use OpenRemoteBaseKey() with PSRemoting as well. Some other changes/improvements.
            #             Removing some redundant code after changes.
            if ($RegKey) {
                $RegKey.Close()
                #$RegKey.Dispose()
            }
            $RegKey = $null
            if ($RegKey = $Registry.OpenSubKey("SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full")) {
                if ($DotNet4xRelease = [int] $RegKey.GetValue('Release')) {
                    if ($DotNet4xRelease -ge 460798) {
                        $DotNetData.$Computer | Add-Member -MemberType NoteProperty -Name '>=4.x' -Value '4.7 or later'
                    }
                    elseif ($DotNet4xRelease -ge 394806) {
                        $DotNetData.$Computer | Add-Member -MemberType NoteProperty -Name '>=4.x' -Value '4.6.2'
                    }
                    elseif ($DotNet4xRelease -ge 394254) {
                        $DotNetData.$Computer | Add-Member -MemberType NoteProperty -Name '>=4.x' -Value '4.6.1'
                    }
                    elseif ($DotNet4xRelease -ge 393295) {
                        $DotNetData.$Computer | Add-Member -MemberType NoteProperty -Name '>=4.x' -Value '4.6'
                    }
                    elseif ($DotNet4xRelease -ge 379893) {
                        $DotNetData.$Computer | Add-Member -MemberType NoteProperty -Name '>=4.x' -Value '4.5.2'
                    }
                    elseif ($DotNet4xRelease -ge 378675) {
                        $DotNetData.$Computer | Add-Member -MemberType NoteProperty -Name '>=4.x' -Value '4.5.1'
                    }
                    elseif ($DotNet4xRelease -ge 378389) {
                        $DotNetData.$Computer | Add-Member -MemberType NoteProperty -Name '>=4.x' -Value '4.5'
                    }
                    else {
                        $DotNetData.$Computer | Add-Member -MemberType NoteProperty -Name '>=4.x' -Value 'Universe imploded'
                    }
                }
                else {
                    $DotNetData.$Computer | Add-Member -MemberType NoteProperty -Name '>=4.x' -Value "Error (no 'Release' key?)"
                }
            }
            else {
                $DotNetData.$Computer | Add-Member -MemberType NoteProperty -Name '>=4.x' -Value 'Not installed (no key)'
            }
            if ($RegKey) {
                $RegKey.Close()
                #$RegKey.Dispose()
            }
            if ($Registry) {
                $Registry.Close()
                #$Registry.Dispose()
            }
            $RegKey, $Registry = $null, $null
            if ($PSRemoting) {
                $DotNetData.$Computer # return this to the calling scope, populate the other data hash there, pretty hacky, this
            }
        }
    }
    process {
        foreach ($Computer in $ComputerName) {
            $Counter++
            $DotNetData.$Computer = New-Object -TypeName PSObject
            # This one is for the latched-on PSRemoting feature ...
            $PingReply = $false
            if (Test-Connection -Quiet -Count 1 $Computer) {
                $DotNetData.$Computer | Add-Member -MemberType NoteProperty -Name Ping -Value $true
                $PingReply = $true
                Write-Verbose -Message "$Computer is online."
                if ($ExportToCSV) {
                    $Computer | Add-Content $OutputOnlineFile
                }
            }
            else {
                $DotNetData.$Computer | Add-Member -MemberType NoteProperty -Name Ping -Value $false
                $PingReply = $false # explicitly..
                if ($ExportToCSV) {
                    $Computer | Add-Content $OutputOfflineFile
                }
                if (-not $ContinueOnPingFail) {
                    $DotNetData.$Computer | Add-Member -Name Error -Value "No ping reply" -MemberType NoteProperty
                    Write-Warning -Message "${Computer} is offline (no ping reply)."
                    continue
                }
            }
            # Monkey patching on PSRemoting to the existing design ...
            if ($PSRemoting) {
                try {
                    $PSRSplat = @{
                        ComputerName = $Computer
                        ScriptBlock  = (Get-Item function:\SetDataHashObject).ScriptBlock
                        ErrorAction  = "Stop"
                        ArgumentList = $Computer, $true
                    }
                    if ($Credential) {
                        $PSRSplat.Credential = $Credential
                    }
                    $DotNetData.$Computer = Invoke-Command @PSRSplat #-ComputerName $Computer -ScriptBlock (Get-Item function:\SetDataHashObject).ScriptBlock `
                    #-ArgumentList $Computer, $true -ErrorAction Stop
                    # -Verbose:$(if ($VerbosePreference -match 'Stop|Continue') { $true } else { $false })
                }
                catch {
                    $DotNetData.$Computer | Add-Member -MemberType NoteProperty -Name Error -Value "PSRemoting failure: $_"
                }
                $DotNetData.$Computer | Add-Member -MemberType NoteProperty -Name Ping -Value $PingReply -Force
            }
            else {
                SetDataHashObject -Computer $Computer -PSRemoting:$PSRemoting -LocalHost:$LocalHost
            }
        }
    }
    end {
        $CsvHeaders = @('>=4.x') + @($DotNetVersionStrings) + @('Ping', 'Error')
        #if ($LocalHost) {
        #    $CsvHeaders = $CsvHeaders | Where-Object { $_ -ne 'Ping' } # Remove ping .....
        #}
        $DotNetData.GetEnumerator() | Sort-Object -Property Name | ForEach-Object {
            $c = $_.Name
            $_.Value | Select-Object -Property $CsvHeaders
        } | Select-Object @{n = 'ComputerName'; e = {$c}}, * # pass to pipeline instead #| Export-Csv -Encoding UTF8 -LiteralPath $CsvOutputFile
        if ($ExportToCSV) {
            $DotNetData.GetEnumerator() | Sort-Object -Property Name | ForEach-Object {
                $c = $_.Name
                $_.Value | Select-Object -Property $CsvHeaders
            } | Select-Object @{n = 'ComputerName'; e = {$c}}, * | Export-Csv -Encoding UTF8 -LiteralPath $CsvOutputFile
        }
        [gc]::Collect()
        if (-not $NoSummary) {
            Write-Host -ForegroundColor Green @"
    Script start time: $StartTime
    Script end time:   $(Get-Date)
    $(if ($ExportToCSV) {
    "Output files: $CsvOutputFile, $OutputOnlineFile, $OutputOfflineFile"
    })
"@
        }
    }
}