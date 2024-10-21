#region function Get-CMNTSPackageReference
Function Get-CMNTSPackageReference {
    <#
    .SYNOPSIS 

    .DESCRIPTION
        Get all references to the specified package in any Task Sequence

    .PARAMETER sccmConnectionInfo
        SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo
        
    .PARAMETER PackageID
        Name of computer to run function-name against

    .PARAMETER PackageName
        Name of computer to run function-name against

    .PARAMETER logFile
        File for writing logs to, default is C:\Temp\Error.log

    .PARAMETER logEntries
         Switch to say if we write to the log file. Otherwise, it will just be write-verbose

    .PARAMETER maxLogSize
        Max size for the log. Defaults to 5MB.

    .PARAMETER maxLogHistory
            Specifies the number of history log files to keep, default is 5

    .EXAMPLE


    .NOTES
        Author:	    Cody Mathis
        Email:	    cmathis8@humana.com
        Date:	    08/16/2019
        PSVer:	    2.0/3.0
        Updated:    08/16/2019
        Version:    1.0.0		
	#>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    Param(
        [Parameter(Mandatory = $true)]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByID')]
        [Alias('PKGID', 'ID')]
        [ValidateLength(8, 8)]
        [string[]]$PackageID,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByName')]
        [Alias('PKGName', 'Name', 'LocalizedDisplayName')]
        [string[]]$PackageName,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int]$maxLogHistory = 5
    )

    begin {
        $FunctionName = $MyInvocation.MyCommand.Name
        # Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = $FunctionName;
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxHistory;
            type          = 1;
        }
        #Build splat for WMIQueries
        $WMIQueryParameters = $sccmConnectionInfo.WMIQueryParameters

        if ($logEntries) {
            New-CMNLogEntry -entry "Starting Function $FunctionName" @NewLogEntry
        }
        $TSNameLookup = Get-WmiObject -Query "SELECT Name, PackageID FROM SMS_TaskSequencePackage" @WMIQueryParameters | ForEach-Object {
            @{$_.PackageID = $_.Name }
        }
    }

    process {
        if ($logEntries) {
            New-CMNLogEntry -entry 'Beginning process loop' @NewLogEntry
        }

        $VarToLoop = switch ($PSCmdlet.ParameterSetName) {
            'ByID' {
                'PackageID'
            }
            'ByName' {
                'PackageName'
            }
        }
        $References = foreach ($Instance in (Get-Variable -Name $VarToLoop -ValueOnly)) {
            $Query = switch ($PSCmdlet.ParameterSetName) {
                'ByName' {
                    [string]::Format("SELECT RefPackageID, ObjectName, PackageID FROM SMS_TaskSequencePackageReference_Flat WHERE ObjectName='{0}' AND ObjectType = 0", $Instance)
                }
                'ByID' {
                    [string]::Format("SELECT RefPackageID, ObjectName, PackageID FROM SMS_TaskSequencePackageReference_Flat WHERE ObjectID='{0}' AND ObjectType = 0", $Instance)
                }
            }
            Get-WmiObject -Query $Query @WMIQueryParameters | Select-Object -Property RefPackageID, @{ name = 'RefPackageName'; expression = { $_.ObjectName } }, @{name = 'TSPackageID'; expression = { $_.PackageID } }, @{ name = 'TSName'; expression = { $TSNameLookup.$($_.PackageID) } }        
        }
    }

    End {
        if ($logEntries) {
            $References | ForEach-Object { New-CMNLogEntry -entry $_ @NewLogEntry }
            New-CMNLogEntry -entry "Completing Function $FunctionName"  @NewLogEntry
        }
        Return $References	
    }
}
#endregion function Get-CMNTSPackageReference