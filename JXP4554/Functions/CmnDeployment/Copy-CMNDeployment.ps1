Function Copy-CMNDeployment {
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
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:
		PSVer:	2.0/3.0
		Updated:
	#>

    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Low')]
    param
    (
        [Parameter(Mandatory = $true,
            HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'What computer name would you like to target?')]
        [Alias('host')]
        [ValidateLength(3, 30)]
        [string[]]$computername,

        [Parameter(Mandatory = $true,
            HelpMessage = 'LogFile name')]
        [string]$logfile,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries')]
        [Switch]$logEntries = $false
    )

    begin {
        $NewLogEntry = @{
            LogFile = $logFile;
            Component = 'Copy-CMNDeployment'
        }
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry}
    }

    process {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry}

        foreach ($computer in $computername) {
            # create a hashtable with your output info
            $returnHashTable = @{
                'info1' = $value1;
                'info2' = $value2;
                'info3' = $value3;
                'info4' = $value4
            }
            $LimitingCollection = Get-WmiObject -Class SMS_Collection -Filter "CollectionID = '$LimitToCollectionID'" -Namespace root/sms/site_$($sccmConnectionInfo.SiteCode) -ComputerName $sccmConnectionInfo.ComputerName
            Write-Verbose "Processing $computer"
            # use $computer to target a single computer

            if ($PSCmdlet.ShouldProcess($CIID)) {
                Write-Output (New-Object �TypenamePSObject �Prop $returnHashTable)
                $obj = New-Object -TypeName PSObject -Property $returnHashTable
                $obj.PSObject.TypeNames.Insert(0, 'CMN.ObjectType')
            }
        }
    }

    end {
        Return $obj
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Completing Function' -type 1 @NewLogEntry}
    }
} #End Copy-CMNDeployment
