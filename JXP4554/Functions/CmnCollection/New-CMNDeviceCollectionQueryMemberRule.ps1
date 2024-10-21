Function New-CMNDeviceCollectionQueryMemberRule {
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
        [String]$query,

        [Parameter(Mandatory = $true)]
        [String]$ruleName,

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
        $NewLogEntry = @{
            LogFile = $logFile;
            Component = 'New-CMNDeviceCollectionQueryMemberRule'
        }
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Starting Function' -Type 1 @NewLogEntry}
    }

    process {
        if ($PSCmdlet.ShouldProcess($query)) {
            if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Processing $query" -Type 1 @NewLogEntry}
            $colQuery = "Select * from SMS_Collection where CollectionID = '$CollectionID'"
            $collection = Get-WmiObject -Query $colQuery -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
            if ($collection) {
                $queryMemberRule = ([WMIClass]"\\$($sccmConnectionInfo.ComputerName)\$($sccmConnectionInfo.NameSpace):SMS_CollectionRuleQuery").CreateInstance()
                $queryMemberRule.QueryExpression = $query
                $queryMemberRule.RuleName = $ruleName
                $collection.AddMembershipRule($queryMemberRule)
            }
            else {
                if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Unable to add $NetbiosName to $($Collection.Name)" -Type 3 @NewLogEntry}
            }
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
    }
} #End New-CMNDeviceCollectionQueryMemberRule
