#region function Remove-CMNTSPackageReference
Function Remove-CMNTSPackageReference {
    <#
    .SYNOPSIS 

    .DESCRIPTION
        Remove all references to the specified package in any Task Sequence

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
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('PKGID', 'ID', 'RefPackageID')]
        [ValidateLength(8, 8)]
        [string[]]$PackageID,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(8, 8)]
        [string[]]$TSPackageID,

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
        }
        #Build splat for WMIQueries
        $WMIQueryParameters = $sccmConnectionInfo.WMIQueryParameters

        if ($logEntries) {
            New-CMNLogEntry -entry "Starting Function $FunctionName"  @NewLogEntry -type 1
        }
    }

    process {
        if ($logEntries) {
            New-CMNLogEntry -entry 'Beginning process loop'  @NewLogEntry -type 1
        }

        foreach ($Instance in $TSPackageID) {
            $TSAllGroups = Get-CMTaskSequenceGroup -TaskSequenceId $Instance
            $TSAllStep = Get-CMTaskSequenceStep -TaskSequenceId $Instance
            $TSPackageStep = $TSAllStep | Where-Object { $_.PackageID -eq $PackageID }
            foreach ($Step in $TSPackageStep) {
                $TSGroup = $TSAllGroups | Where-Object { $_.steps.Name -contains $Step.Name }
                foreach ($Group in $TSGroup) {
                    switch -Regex ($(Read-Host -Prompt "Are you sure you want to delete the PackageID $PackageID reference from The Task sequence $Instance with Step Name $($Step.Name)? Enter Y/y or N/n" )) {
                        '^Y$|^y$' {
                            try {
                                Remove-CMTaskSequenceStep -TaskSequenceId $Instance -StepName $Step.Name -Confirm:$false -Force -ErrorAction Stop
                                New-CMNLogEntry -entry "The step $($Step.Name) has been removed from Task Sequence $Instance" @NewLogEntry -type 1
                                $TSGroupStepCount = Get-CMTaskSequenceGroup -TaskSequenceId $Instance -StepName $Group.Name | Select-Object -ExpandProperty Steps | Measure-Object | Select-Object -ExpandProperty Count
                                if ($TSGroupStepCount -eq 0) {
                                    switch -Regex ($(Read-Host -Prompt "Found that Group $($Group.Name) is empty after step removal. Would you like to remove the group? Enter Y/y or N/n" )) {
                                        '^Y$|^y$' {
                                            try {
                                                Remove-CMTaskSequenceGroup -TaskSequenceId $Instance -StepName $Group.Name -Confirm:$false -Force -ErrorAction Stop
                                                New-CMNLogEntry -entry "The group $($Group.Name) has been removed from Task Sequence $Instance" @NewLogEntry -type 1
                                            }
                                            catch {
                                                New-CMNLogEntry -entry "Failed to remove group $($Group.Name) from Task Sequence $Instance" -type 3 @NewLogEntry
                                            }
                                        }
                                        default {
                                            continue
                                        }
                                    }        
                                }
                            }
                            catch {
                                New-CMNLogEntry -entry "Failed to remove step $($Step.Name) from Task Sequence $Instance" -type 3 @NewLogEntry
                            }
                        }
                        default {
                            continue
                        }
                    }
                }
            }
        }
    }

    End {
        if ($logEntries) {
            #$References | ForEach-Object { New-CMNLogEntry -entry $_ @NewLogEntry }
            New-CMNLogEntry -entry "Completing Function $FunctionName"  @NewLogEntry -type 1
        }
        #Return $References	
    }
}
#endregion function Remove-CMNTSPackageReference