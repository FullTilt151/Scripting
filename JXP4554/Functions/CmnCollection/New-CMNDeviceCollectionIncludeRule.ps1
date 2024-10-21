Function New-CMNDeviceCollectionIncludeRule {
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
        [Parameter(Mandatory = $true,HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true)]
        [String]$CollectionID,

        [Parameter(Mandatory = $true)]
        [String]$includeCollectionID,

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
            Component = 'New-CMNDeviceCollectionIncludeRule'
        }
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Starting Function' -Type 1 @NewLogEntry}
    }

    process {
        if ($PSCmdlet.ShouldProcess($ruleName)) {
            if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Processing $ruleName" -Type 1 @NewLogEntry}
            $colQuery = "Select * from SMS_Collection where CollectionID = '$CollectionID'"
            $collection = Get-WmiObject -Query $colQuery -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
            if ($collection) {
                $includeRule = ([WMIClass]"//$($sccmConnectionInfo.ComputerName)/$($sccmConnectionInfo.NameSpace):SMS_CollectionRuleIncludeCollection").CreateInstance()
                $includeRule.IncludeCollectionID = $includeCollectionID
                $includeRule.RuleName = $ruleName
                $collection.AddMembershipRule($includeRule)
            }
            else {
                if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Unable to add $ruleName to $CollectionID" -Type 3 @NewLogEntry}
            }
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Finished Function' -Type 1 @NewLogEntry}
    }
} #End New-CMNDeviceCollectionIncludeRule
