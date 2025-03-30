Function New-CMNProgram {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'Package ID')]
        [String]$packageID,

        [Parameter(Mandatory = $true, HelpMessage = 'Command Line')]
        [String]$commandLine,

        #User Description
        [Parameter(Mandatory = $false)]
        [String]$comment,

        #Category
        [Parameter(Mandatory = $false)]
        [String]$description,

        #Format NNN SS where N is number and S is a size (MB, KB, GB)
        [Parameter(Mandatory = $true, HelpMessage = 'Disk Space Required')]
        [String]$diskSpaceReq,

        [Parameter(Mandatory = $false)]
        [String]$driveLetter,

        [Parameter(Mandatory = $true, HelpMessage = 'Duration')]
        [Int32]$duration,

        [Parameter(Mandatory = $true, HelpMessage = 'Program Name')]
        [String]$programName,

        [Parameter(Mandatory = $true, HelpMessage = 'Operating Systems Supported')]
        [String[]]$supportedOperatingSystems,

        [Parameter(Mandatory = $false)]
        [String]$workingDirectory,

        [Parameter(Mandatory = $false)]
        [Switch]$authorizedDynamicInstall = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$useCustomProgressMsg = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$defaultProgram = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$disableMomAlertOnRunning = $true,

        [Parameter(Mandatory = $false)]
        [Switch]$momAlertOnFail = $true,

        [Parameter(Mandatory = $false)]
        [Switch]$runDependantAlways = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$windowsCE = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$countdown = $true,

        #Suppress Notifications
        [Parameter(Mandatory = $false)]
        [Switch]$unattended = $true,

        [Parameter(Mandatory = $false)]
        [Switch]$usercontext = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$adminrights = $true,

        [Parameter(Mandatory = $false)]
        [Switch]$everyuser = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$nouserloggedin = $false,

        #Program Restart Computer
        [Parameter(Mandatory = $false)]
        [Switch]$oktoquit = $false,

        #ConfMGR Restarts Computer
        [Parameter(Mandatory = $false)]
        [Switch]$oktoreboot = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$useuncpath = $true,

        [Parameter(Mandatory = $false)]
        [Switch]$persistconnection = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$runminimized = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$runmaximized = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$hidewindow = $false,

        #ConfigMGR logs user off
        [Parameter(Mandatory = $false)]
        [Switch]$oktologoff = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$anyPlatform = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$supportUninstall = $false
    )

    begin {
        $Package = Get-WmiObject -Class SMS_Package -Filter "PackageID = '$packageID'" -ComputerName $sccmConnectionInfo.ComputerName -Namespace "root\sms\site_$($sccmConnectionInfo.SiteCode)"
    }

    process {
        $NewProgram = ([wmiclass] "\\$($sccmConnectionInfo.ComputerName)\root\SMS\SITE_$($($sccmConnectionInfo.SiteCode)):SMS_Program").CreateInstance()
        $NewProgram.PackageID = $packageID
        $NewProgram.CommandLine = $commandLine
        $NewProgram.Comment = $comment
        $NewProgram.Description = $description
        $NewProgram.DiskSpaceReq = $diskSpaceReq
        $NewProgram.DriveLetter = $driveLetter
        $NewProgram.Duration = $duration
        $NewProgram.ProgramName = $programName
        $NewProgram.WorkingDirectory = $workingDirectory
        $NewProgram.PackageName = $Package.Name
        $NewProgram.PackageType = 0

        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $authorizedDynamicInstall.IsPresent -KeyName Authorized_Dynamic_Install
        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $useCustomProgressMsg.IsPresent -KeyName useCustomProgressMsg
        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $defaultProgram.IsPresent -KeyName Default_Program
        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $disableMomAlertOnRunning.IsPresent -KeyName disableMomAlertOnRunning
        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $momAlertOnFail.IsPresent -KeyName momAlertOnFail
        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $runDependantAlways.IsPresent -KeyName Run_Dependant_Always
        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $WindowsCE.IsPresent -KeyName Windows_CE
        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $countdown.IsPresent -KeyName countdown
        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $unattended.IsPresent -KeyName unattended
        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $usercontext.IsPresent -KeyName usercontext
        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $adminrights.IsPresent -KeyName adminrights
        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $everyuser.IsPresent -KeyName everyuser
        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $nouserloggedin.IsPresent -KeyName nouserloggedin
        $NewProgram.ProgramFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Program_ProgramFlags -CurrentValue $NewProgram.ProgramFlags -ProposedValue $oktoquit.IsPresent -KeyName oktoquit
    }

    end {
        try {
            $NewProgram.Put() | Out-Null
            $NewProgram.get()
        }

        Catch {
            Write-Error 'Unable to create program'
        }
    }
} #End New-CMNProgram
