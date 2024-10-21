Function Set-CMNScriptTimeout {
    <#
	.SYNOPSIS - Test

	.DESCRIPTION

	.PARAMETER

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
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'What computer name would you like to target?',
            Position = 1)]
        [Alias('host')]
        [ValidateLength(3, 30)]
        [string[]]$computername
    )

    begin {
        $NewLogEntry = @{
            LogFile = $logFile;
            Component = 'FunctionName';
            maxLogSize = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry}
    }

    process {
        write-verbose "Beginning process loop"
        $class = Get-CimInstance -ClassName SMS_SCI_ClientComp -ComputerName LOUAPPWPS1825 -Namespace root/sms/site_sp1 -Filter "ItemName = 'Configuration Management Agent' and ItemType = 'Client Component'"
        if ($class) {
            foreach ($item in $class.Props) {
                if ($item.PropertyName -eq 'ScriptExecutionTimeout') {
                    $item.Value = 600
                }
            }
        }
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
            }
            Write-Output (New-Object ?TypenamePSObject ?Prop $returnHashTable)
            $obj = New-Object -TypeName PSObject -Property $ReturnHashTable
            $obj.PSObject.TypeNames.Insert(0, 'CMN.ObjectType')
            Return $obj
        }
    }

    end {
    }
} # End Set-CMNScriptTimeout
