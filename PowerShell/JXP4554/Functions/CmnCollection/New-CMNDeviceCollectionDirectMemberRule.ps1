Function New-CMNDeviceCollectionDirectMemberRule {
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
        [String]$collectionID,

        [Parameter(Mandatory = $true)]
        [String[]]$netbiosNames,

        [Parameter(Mandatory = $false)]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries')]
        [Switch]$logEntries = $false
    )
    begin {
        $NewLogEntry = @{
            LogFile = $logFile;
            Component = 'New-CMNDeviceCollectionDirectMemberRule'
        }
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Starting Function' -Type 1 @NewLogEntry}
        $query = "Select * from SMS_Collection where CollectionID = '$collectionID'"
        $collection = Get-WmiObject -Query $query -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
    }

    process {
        foreach ($netbiosName in $netbiosNames) {
            if ($PSCmdlet.ShouldProcess($netbiosName)) {
                if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Adding $netbiosName" -type 1 @NewLogEntry}
                $query = "Select ResourceID from SMS_R_System where NetbiosName = '$netbiosName' and Active = 1 and Client = 1 and Obsolete = 0"
                $system = Get-WmiObject -Query $query -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
                if ($system) {
                    try {
                        $directMemberRule = ([WMIClass]"//$($sccmConnectionInfo.ComputerName)/$($sccmConnectionInfo.NameSpace):SMS_CollectionRuleDirect").CreateInstance()
                        $directMemberRule.ResourceClassName = 'SMS_R_System'
                        $directMemberRule.ResourceID = ($System.ResourceID)
                        $directMemberRule.RuleName = $NetbiosName
                        $addRules += [Array]$directMemberRule
                    }
                    catch {
                        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Unable to add $($System.ResourceID) - $NetbiosName" -Type 3 @NewLogEntry}
                        Write-Error "Unable to add $($System.ResourceID) - $NetbiosName"
                    }
                }
                else {
                    if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Unable to add $NetbiosName to $($Collection.Name)" -type 3 @NewLogEntry}
                }
            }
        }
    }

    end {
        if ($addRules) {
            if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Adding Rules to $($collection.Name)" -Type 1 @NewLogEntry}
            $collection.AddMemberShipRules($addRules)
        }
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Finished Function' -Type 1 @NewLogEntry}
    }
} #End New-CMNDeviceCollectionDirectMemberRule
