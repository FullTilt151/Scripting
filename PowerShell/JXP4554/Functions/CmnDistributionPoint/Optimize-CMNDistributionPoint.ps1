Function Optimize-CMNDistributionPoint {
    <#
    .SYNOPSIS
        This function will check the supplied PackageID, and based on the criteria supplied, either remove the content from the DP's, 
        put the content on a DP, or split the content between DP's based on package ID (even or odd)

	.DESCRIPTION

	.PARAMETER SCCMConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.

 	.PARAMETER logFile
		File for writing logs to

	.PARAMETER logEntries
		Switch to say whether or not to create a log file

	.PARAMETER maxLogSize
		Max size for the log. Defaults to 5MB.

	.PARAMETER maxHistory
			Specifies the number of history log files to keep, default is 5

 	.EXAMPLE

	.LINK
		http://configman-notes.com

	.NOTES
		FileName:    Optimize-CMNDistributionPoint.ps1
		Author:      James Parris
		Contact:     Jim@ConfigMan-Notes.com
		Created:     2016-03-22
		Updated:     2016-03-22
		Version:     1.0.0
	#>

    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true,
            HelpMessage = 'SCCM Connection Info')]
        [PSObject]$SCCMConnectionInfo,

        [Parameter(Mandatory = $true,
            HelpMessage = 'PacakgeID(s) to be processed')]
        [String]$PackageID,

        [Parameter(Mandatory = $false,
            HeplpMessage = 'Specifies if you should keep the content on the DP''s for packages in active deployment(s)')]
        [Switch]$keepActivePackage,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Sepcifies if you should keep the content on the DP''s for packages referenced by Task Sequence(s)')]
        [Switch]$keepReferencedPackage,

        [Parameter(Mandatory = $false,
            HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Max Log size')]
        [Int32]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Max number of history logs')]
        [Int32]$maxHistory = 5
    )

    Begin {
        # Disable Fast parameter usage check for Lazy properties
        $CMPSSuppressFastNotUsedCheck = $true
        #Build splat for log entries
        $NewLogEntry = @{
            LogFile    = $logFile;
            Component  = 'Optimize-CMNDistributionPoint';
            maxLogSize = $maxLogSize;
            maxHistory = $maxHistory;
        }
        # Build splats for WMIQueries
        $WMIQueryParameters = $SCCMConnectionInfo.WMIQueryParameters
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "SCCMConnectionInfo = $SCCMConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "PackageID = $PackageID" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "KeepActivePage = $keepActivePackage" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "KeepReferencedPackage = $keepReferencedPackage" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxHistory = $maxHistory" -type 1 @NewLogEntry
            New-CMNLogEntry -entry 'First, we get the package'
        }
        $package = Get-WmiObject -Query = "Select * from SMS_Packages where PackageID = '$packageID'" @WMIQueryParameters
        if ($package.PackageID -ne $packageID) {
            New-CMNLogEntry -entry "Could not retrieve PackageID $packageID" -type 3 @NewLogEntry
            throw "Could not retrieve PackageID $packageID"
        }
    }

    Process {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry}
        if($PSCmdlet.ShouldProcess('Do you want to process the content?','Title')){
            Write-Output 'Testing 1 2 3'
        }
    }

    End {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
    }
} #End Optimize-CMNDistributionPoint