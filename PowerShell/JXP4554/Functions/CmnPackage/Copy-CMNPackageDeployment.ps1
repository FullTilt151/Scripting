Function Copy-CMNPackageDeployment {
    <#
		.SYNOPSIS
            Copies a deployment from one site to another

		.DESCRIPTION
            Copies a deployment from one site to another. You provide the source connection, packageID, program name, also the
            destination connection, packageID, and collection ID. This will copy the deployment to that collection ID.

		.PARAMETER SCCMSourceConnectionInfo
			This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
			Get-CMNSCCMConnectionInfo in a variable and passing that variable.

		.PARAMETER SCCMDestinationConnectionInfo
			This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
			Get-CMNSCCMConnectionInfo in a variable and passing that variable.

        .PARAMETER srcPackageID
            Package ID in source site

        .PARAMETER programName
            Program name to be used in the deployment

        .PARAMETER dstPackageID
            Destination package ID

        .PARAMETER dstCollectionID
            Destination collection ID

		.PARAMETER logFile
			File for writing logs to

		.PARAMETER logEntries
			Switch to say whether or not to create a log file

		.PARAMETER clearlog
			Switch to clear the log file

		.PARAMETER maxLogSize
			Max size for the log. Defaults to 5MB.

		.PARAMETER maxLogHistory
				Specifies the number of history log files to keep, default is 5

		.EXAMPLE

		.LINK
			http://configman-notes.com

		.NOTES
			FileName:    Copy-CMNPackageDeployment.ps1
			Author:      James Parris
			Contact:     jim@ConfigMan-Notes.com
			Created:     2016-03-22
			Updated:     2016-03-22
			Version:     1.0.0

            SMS_Advertisement
            SMS_Package
            SMS_Program
	#>

    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Low')]

    PARAM
    (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Source SCCM Connection Info',
            Position = 1)]
        [PSObject]$SCCMSourceConnectionInfo,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Destination SCCM Connection Info',
            Position = 2)]
        [PSObject]$SCCMDestinationConnectionInfo,

        [Parameter(Mandatory = $true,
            HelpMessage = 'PackageId(s)',
            Position = 3)]
        [String]$srcPackageID,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Program Name',
            Position = 4)]
        [String]$programName,

        [Parameter(Mandatory = $true,
            HelpMessage = 'PackageId(s)',
            Position = 5)]
        [String]$dstPackageID,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Destination Collection ID',
            Position = 6)]
        [String]$dstCollectionID,

        [Parameter(Mandatory = $false,
            HelpMessage = 'LogFile Name',
            Position = 7)]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries',
            Position = 8)]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Clear Log File',
            Position = 9)]
        [Switch]$clearLog,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Max Log size',
            Position = 10)]
        [Int32]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Max number of history logs',
            Position = 11)]
        [Int32]$maxLogHistory = 5
    )

    begin {
        $NewLogEntry = @{
            logFile = $logFile;
            component = 'Copy-CMNPackageDeployment';
            maxLogSize = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }
        $WMISourceQueryParameters = @{
            ComputerName = $SCCMSourceConnectionInfo.ComputerName;
            NameSpace = $SCCMSourceConnectionInfo.NameSpace;
        }
        $WMIDestinationQueryParameters = @{
            ComputerName = $SCCMDestinationConnectionInfo.ComputerName;
            NameSpace = $SCCMDestinationConnectionInfo.NameSpace;
        }
        if ($PSBoundParameters['clearLog']) {if (Test-Path -Path $logFile) {Remove-Item -Path $logFile}}
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry}
    }

    process {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry}
        if ($PSCmdlet.ShouldProcess($packageID)) {
            #Verify Source Pacakge
            if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Verifying source package' -type 1 @NewLogEntry}
            $query = "Select * from SMS_Package where PackageID = '$srcPackageID'"
            $srcPackage = Get-WmiObject -Query $query @WMISourceQueryParameters
            if ($srcPackage) {
                if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Source package exists, checking that program exists' -type 1 @NewLogEntry}
                $query = "SELECT * from SMS_Program where PackageID = '$srcPackageID' and ProgramName = '$programName'"
                $srcProgram = Get-WmiObject -Query $query @WMISourceQueryParameters
                if ($srcProgram) {
                    #Verify Destination Package
                    if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Program exists, verifying destination package' -type 1 @NewLogEntry}
                    $query = "Select * from SMS_Package where PackageID = '$dstPackageID'"
                    $dstPackage = Get-WmiObject -Query $query @WMISourceQueryParameters
                    if ($dstPackage) {
                        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Destination package exists, creating deployment' -type 1 @NewLogEntry}
                        $query = "Select * from SMS_Advertisement where PackageID = '$dstPackageID' and ProgramName = '$programName'"
                        $dstDeployment = Get-WmiObject -Query $query @WMIDestinationQueryParameters
                        if (-not ($dstDeployment)) {
                            #Copy deployments to destination
                            $dstDeployment = ([WMIClass]"\\$($SCCMDestinationConnectionInfo.ComputerName)\$($SCCMDestinationConnectionInfo.NameSpace):SMS_Advertisement").CreateInstance()
                            $dstDeployment.ActionInProgress = $srcDeployment.ActionInProgress
                            $dstDeployment.AdvertFlags = $srcDeployment.AdvertFlags
                            $dstDeployment.AdvertisementName = $srcDeployment.AdvertisementName
                            $dstDeployment.AssignedScheduleEnabled = $srcDeployment.AssignedScheduleEnabled
                            $dstDeployment.AssignedScheduleIsGMT = $srcDeployment.AssignedScheduleIsGMT
                            $dstDeployment.CollectionID = $dstCollectionID
                            $dstDeployment.Comment = $srcDeployment.Comment
                            $dstDeployment.ExpirationTime = $srcDeployment.ExpirationTime
                            $dstDeployment.MandatoryCountdown = $srcDeployment.MandatoryCountdown
                            $dstDeployment.PackageID = $dstPackageID
                            $dstDeployment.PresentTime = $srcDeployment.PresentTime
                            $dstDeployment.PresentTimeEnabled = $srcDeployment.PresentTimeEnabled
                            $dstDeployment.PresentTimeIsGMT = $srcDeployment.PresentTimeIsGMT
                            $dstDeployment.Priority = $srcDeployment.Priority
                            $dstDeployment.ProgramName = $programName
                            $dstDeployment.RemoteClientFlags = $srcDeployment.RemoteClientFlags
                            $dstDeployment.TimeFlags = $srcDeployment.TimeFlags
                            $dstDeployment.Put() | Out-Null
                        }
                        else {
                            if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Deployment already exists on collection $dstCollectionID" -type 2 @NewLogEntry}
                            Throw 'Already exists'
                        }
                    }
                    else {
                        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Destination package does not exist' -type 3 @NewLogEntry}
                        Throw 'Destination Package does not exist'
                    }
                }
                else {
                    if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Program does not exist on source package' -type 3 @NewLogEntry}
                    Throw 'Program does not exist on source'
                }
            }
            else {
                if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Package $srcPackageID does not exist on source" -type 3 @NewLogEntry}
                Throw 'Source Package does not exist'
            }
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
    }
} #End Copy-CMNPackageDeployment
