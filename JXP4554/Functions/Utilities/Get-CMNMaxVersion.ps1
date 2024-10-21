Function Get-CMNMaxVersion {
    <#
	.SYNOPSIS
 
	.DESCRIPTION
 
	.PARAMETER SCCMConnectionInfo
			This is a connection object used to know how to connect to the site. The best way to get this is storing the results of 
			Get-CMNSCCMConnectionInfo in a variable and passing that variable.
		
	.PARAMETER logFile
		File for writing logs to

    .PARAMETER logEntries
        Switch to say whether or not to create a log file

	.EXAMPLE
     
	.LINK
		http://configman-notes.com

	.NOTES
		FileName:    FileName.ps1
		Author:      James Parris
		Contact:     jim@ConfigMan-Notes.com
		Created:     2016-03-22
		Updated:     2016-03-22
		Version:     1.0.0
	#>

    [CmdletBinding()]
	
    PARAM
    (
        [Parameter(Mandatory = $true,
            HelpMessage = 'SCCM Connection Info',
            Position = 1)]
        [Alias('computerName')]
        [Alias('hostName')]
        [PSObject]$SCCMConnectionInfo,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Array of versions to determine the max',
            Position = 2)]
        [Array]$versions,

        [Parameter(Mandatory = $false,
            HelpMessage = 'LogFile Name',
            Position = 3)]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries',
            Position = 4)]
        [Switch]$logEntries
    )
    Begin {
        # Disable Fast parameter usage check for Lazy properties
        $CMPSSuppressFastNotUsedCheck = $true
        $NewLogEntry = @{
            LogFile   = $logFile;
            Component = 'Get-CMNMaxVersion'
        }
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry}
    }
	
    Process {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry}
        $x = 1
        [Int32]$maxVersion = 0
        do {
            $max = $versions[$maxVersion] -split '\.'
            $test = $versions[$x] -split '\.'
            $switch = $true
            $y = 0
            do {
                if ($switch) {
                    if ([Int32]$max[$y] -gt [Int32]$test[$y]) {
                        $switch = $false
                    }
                }
                $y++
            } while ($y -lt $test.Count)
            if ($switch) {
                [Int32]$maxVersion = $x
                $max = $versions[$x] -split '\.'
            }
            $x++
        } While ($x -lt $versions.Count - 1)
    }

    End {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
        return $versions[$maxVersion]
    }
} #End Get-CMNMaxVersion

$sccmCN = Get-CMNSCCMConnectionInfo -SiteServer LOUAPPWPS1658
$sccmCS = Get-CMNConnectionString -DatabaseServer $sccmCN.SCCMDBServer -Database $sccmCN.SCCMDB
$query = "Select Distinct DriverVersion0
from v_GS_PNP_SIGNED_DRIVER_CUSTOM
where HardwareID0 = 'PCI\VEN_8086&DEV_1E14&SUBSYS_21F617AA&REV_C4'"
$versions = Get-CMNDatabaseData -connectionString $sccmCS -query $query -isSQLServer
$versions
$max = Get-CMNMaxVersion -SCCMConnectionInfo $sccmCN -versions $versions.DriverVersion0 -logFile C:\Temp\MaxVersion.log -logEntries
Write-Output "Max = $max"