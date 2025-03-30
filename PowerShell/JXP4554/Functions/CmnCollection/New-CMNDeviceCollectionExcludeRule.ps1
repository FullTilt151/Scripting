Function New-CMNDeviceCollectionExcludeRule {
    <#
		.SYNOPSIS

		.DESCRIPTION

		.PARAMETER Text

		.PARAMETER logFile
			File for writing logs to

		.PARAMETER logEntries
			Switch to say whether or not to create a log file

		.EXAMPLE

		.NOTES

		.LINK
			http://configman-notes.com
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM
    (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true)]
        [String]$CollectionID,

        [Parameter(Mandatory = $true)]
        [String]$excludeCollectionID,

        [Parameter(Mandatory = $true)]
        [String]$ruleName,

        [Parameter(Mandatory = $false)]
        [String]$logFile,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries')]
        [Switch]$logEntries = $false
    )
    begin {
        $NewLogEntry = @{
            LogFile = $logFile;
            Component = 'New-CMNDeviceCollectionExcludeRule'
        }
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry}
    }

    process {
        if ($PSCmdlet.ShouldProcess($query)) {
            $colQuery = "Select * from SMS_Collection where CollectionID = '$CollectionID'"
            $collection = Get-WmiObject -Query $colQuery -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
            if ($collection) {
                $excludeRule = ([WMIClass]"//$($sccmConnectionInfo.ComputerName)/$($sccmConnectionInfo.NameSpace):SMS_CollectionRuleExcludeCollection").CreateInstance()
                $excludeRule.ExcludeCollectionID = $excludeCollectionID
                $excludeRule.RuleName = $ruleName
                $collection.AddMembershipRule($excludeRule)
            }
            else {
                if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Unable to add $ruleName to $CollectionID" -Type 1 @NewLogEntry}
            }
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Completing function' -type 1 @NewLogEntry}
    }
} #End New-CMNDeviceCollectionExcludeRule
