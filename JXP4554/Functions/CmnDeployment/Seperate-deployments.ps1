Function FunctionName
{
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

	.PARAMETER maxLogSize
		Max size for the log. Defaults to 5MB.

	.PARAMETER maxHistory
			Specifies the number of history log files to keep, default is 5

 	.EXAMPLE
     
	.LINK
		http://configman-notes.com

	.NOTES
		FileName:    FunctionName.ps1
		Author:      James Parris
		Contact:     Jim@ConfigMan-Notes.com
		Created:     2016-03-22
		Updated:     2016-03-22
		Version:     1.0.0
	#>

	[CmdletBinding(SupportsShouldProcess = $true, 
		ConfirmImpact = 'Low')]
	
	PARAM
	(
		[Parameter(Mandatory = $true,
			HelpMessage = 'SCCM Connection Info',
			Position = 1)]
		[PSObject]$SCCMConnectionInfo,

 		[Parameter(Mandatory = $false,
			HelpMessage = 'LogFile Name',
			Position = )]
		[String]$logFile = 'C:\Temp\Error.log',

		[Parameter(Mandatory = $false,
			HelpMessage = 'Log entries',
			Position = )]
		[Switch]$logEntries,

		[Parameter(Mandatory = $false,
			HelpMessage = 'Max Log size',
			Position = )]
		[Int32]$maxLogSize = 5242880,

		[Parameter(Mandatory = $false,
            HelpMessage = 'Max number of history logs',
            Position = )]
        [Int32]$maxHistory = 5
	)

	Begin 
	{
		# Disable Fast parameter usage check for Lazy properties
		$CMPSSuppressFastNotUsedCheck = $true
		#Build splat for log entries 
		$NewLogEntry = @{
			LogFile = $logFile;
			Component = 'FunctionName';
			maxLogSize = $maxLogSize;
			maxHistory = $maxHistory;
		}
		#Build splats for WMIQueries
        $WMIQueryParameters = @{
            ComputerName = $SCCMConnectionInfo.ComputerName;
            NameSpace = $SCCMConnectionInfo.NameSpace;
        }
		if($PSBoundParameters['logEntries'])
		{
			New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
			New-CMNLogEntry -entry "SCCMConnectionInfo = $SCCMConnectionInfo" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "maxHistory = $maxHistory" -type 1 @NewLogEntry
		}
	}
	
	Process 
	{
		if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry}
		if ($PSBoundParameters['showProgress']) 
		{
			$ProgressCount = 0
		}
		# Main code part goes here
		foreach($objDeployment in $objDeployments)
		{
			$Error.Clear()
			Switch ($objDeployment.DeploymentType)
			{
				<#1
				{
					if($CopyDeployment)
					{
						try
						{
							$NewDeployment = ([WMICLASS]"\\$($SiteServer)\root\sms\site_$($SiteCode):SMS_Advertisement").CreateInstance()
							$NewDeployment.ActionInProgress = $objAdvertisment.ActionInProgress
							$NewDeployment.AdvertFlags = $objAdvertisment.AdvertFlags;
							$NewDeployment.AdvertisementName = $objAdvertisment.AdvertisementName;
							$NewDeployment.AssignedSchedule = $objAdvertisment.AssignedSchedule;
							$NewDeployment.AssignedScheduleEnabled = $objAdvertisment.AssignedScheduleEnabled;
							$NewDeployment.AssignedScheduleIsGMT = $objAdvertisment.AssignedScheduleIsGMT;
							$NewDeployment.CollectionID = $ToCollectionID;
							$NewDeployment.Comment = $objAdvertisment.Comment;
							$NewDeployment.DeviceFlags = $objAdvertisment.DeviceFlags;
							$NewDeployment.ExpirationTime = $objAdvertisment.ExpirationTime;
							$NewDeployment.ExpirationTimeEnabled = $objAdvertisment.ExpirationTimeEnabled;
							$NewDeployment.HierarchyPath = $objAdvertisment.HierarchyPath
							$NewDeployment.IncludeSubCollection = $objAdvertisment.IncludeSubCollection;
							$NewDeployment.ISVData = $objAdvertisment.ISVData;
							$NewDeployment.ISVDataSize = $objAdvertisment.ISVDataSize;
							$NewDeployment.IsVersionCompatible = $objAdvertisment.IsVersionCompatible;
							$NewDeployment.MandatoryCountdown = $objAdvertisment.MandatoryCountdown;
							$NewDeployment.OfferType = $objAdvertisment.OfferType;
							$NewDeployment.PackageID = $objAdvertisment.PackageID;
							$NewDeployment.PresentTime = $objAdvertisment.PresentTime;
							$NewDeployment.PresentTimeEnabled = $objAdvertisment.PresentTimeEnabled;
							$NewDeployment.PresentTimeIsGMT = $objAdvertisment.PresentTimeIsGMT;
							$NewDeployment.Priority = $objAdvertisment.Priority;
							$NewDeployment.ProgramName = $objAdvertisment.ProgramName;
							$NewDeployment.RemoteClientFlags = $objAdvertisment.RemoteClientFlags;
							$NewDeployment.SourceSite = $objAdvertisment.SourceSite;
							$NewDeployment.TimeFlags = $objAdvertisment.TimeFlags
							$NewDeployment.Put() | Out-Null
						}
						catch [system.exception]
						{
							$Error | Out-File "C:\Temp\CopyDeployment.log"
							Throw "Had an error - Not copying deployment $($objAdvertisment.PackageID) - $($objAdvertisment.AdvertisementID)."
						}
					}
					else
					{
						try
						{
							$objAdvertisment.CollectionID = $ToCollectionID
							$objAdvertisment.put() | Out-Null
						}
						catch [system.exception]
						{
							$Error | Out-File "C:\Temp\CopyDeployment.log"
							Throw "Had an error - Not copying deployment $($objAdvertisment.PackageID) - $($objAdvertisment.AdvertisementID)."
						}
					}
				}#>
				2
				{
					#Validate that there isn't already a deployment from that package to that collection

					$objAdvertisment = Get-WmiObject @WMIQueryParameters -class SMS_Advertisement -Filter "AdvertisementID = '$($objDeployment.DeploymentID)'"
					$objAdvertisment.Get()
					if (-not (Get-WmiObject @WMIQueryParameters -Class SMS_Advertisement -Filter "CollectionID = '$ToCollectionID' and PackageID = '$($objAdvertisment.PackageID)'"))
					{
						if($CopyDeployment)
						{
							try
							{

								$NewDeployment = ([WMICLASS]"\\$($SiteServer)\root\sms\site_$($SiteCode):SMS_Advertisement").CreateInstance()
								$NewDeployment.ActionInProgress = $objAdvertisment.ActionInProgress
								$NewDeployment.AdvertFlags = $objAdvertisment.AdvertFlags;
								#Set to install outside of service window
								if($IgnoreMaintenanceWindow) {$NewDeployment.AdvertFlags = Set-BitFlagForControl -IsControlEnabled $true -BitFlagHashTable $AdvertFlags -KeyName 'OVERRIDE_SERVICE_WINDOWS' -CurrentValue $NewDeployment.AdvertFlags}
								$NewDeployment.AdvertisementName = $objAdvertisment.AdvertisementName;
								$NewDeployment.AssignedSchedule = $objAdvertisment.AssignedSchedule;
								$NewDeployment.AssignedScheduleEnabled = $objAdvertisment.AssignedScheduleEnabled;
								$NewDeployment.AssignedScheduleIsGMT = $objAdvertisment.AssignedScheduleIsGMT;
								$NewDeployment.CollectionID = $ToCollectionID;
								$NewDeployment.Comment = $objAdvertisment.Comment;
								$NewDeployment.DeviceFlags = $objAdvertisment.DeviceFlags;
								$NewDeployment.ExpirationTime = $objAdvertisment.ExpirationTime;
								$NewDeployment.ExpirationTimeEnabled = $objAdvertisment.ExpirationTimeEnabled;
								$NewDeployment.HierarchyPath = $objAdvertisment.HierarchyPath
								$NewDeployment.IncludeSubCollection = $objAdvertisment.IncludeSubCollection;
								$NewDeployment.ISVData = $objAdvertisment.ISVData;
								$NewDeployment.ISVDataSize = $objAdvertisment.ISVDataSize;
								$NewDeployment.IsVersionCompatible = $objAdvertisment.IsVersionCompatible;
								$NewDeployment.MandatoryCountdown = $objAdvertisment.MandatoryCountdown;
								$NewDeployment.OfferType = $objAdvertisment.OfferType;
								$NewDeployment.PackageID = $objAdvertisment.PackageID;
								$NewDeployment.PresentTime = $objAdvertisment.PresentTime;
								$NewDeployment.PresentTimeEnabled = $objAdvertisment.PresentTimeEnabled;
								$NewDeployment.PresentTimeIsGMT = $objAdvertisment.PresentTimeIsGMT;
								$NewDeployment.Priority = $objAdvertisment.Priority;
								$NewDeployment.ProgramName = $objAdvertisment.ProgramName;
								$NewDeployment.RemoteClientFlags = $objAdvertisment.RemoteClientFlags;
								#If $isDNR - Set 
								#DOWNLOAD_FROM_REMOTE_DISPPOINT to true
								#DOWNLOAD_FROM_LOCAL_DISPPOINT to true
								#RUN_FROM_REMOTE_DISPPOINT to false
								#RUN_FROM_LOCAL_DISPPOINT to false
								if($isDNR)
								{
									$NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $true -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'DOWNLOAD_FROM_REMOTE_DISPPOINT' 
									$NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $true -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'DOWNLOAD_FROM_LOCAL_DISPPOINT'
									$NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'RUN_FROM_REMOTE_DISPPOINT'
									$NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'RUN_FROM_LOCAL_DISPPOINT'
								}
								#if $isRDP - Set DOWNLOAD_FROM_REMOTE_DISPPOINT to false
								#DOWNLOAD_FROM_REMOTE_DISPPOINT to false
								#DOWNLOAD_FROM_LOCAL_DISPPOINT to false
								#RUN_FROM_REMOTE_DISPPOINT to true
								#RUN_FROM_LOCAL_DISPPOINT to true
								if($isRDP)
								{
									$NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'DOWNLOAD_FROM_REMOTE_DISPPOINT' 
									$NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'DOWNLOAD_FROM_LOCAL_DISPPOINT'
									$NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $true -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'RUN_FROM_REMOTE_DISPPOINT'
									$NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $true -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'RUN_FROM_LOCAL_DISPPOINT'
								}
								$NewDeployment.SourceSite = $objAdvertisment.SourceSite;
								$NewDeployment.TimeFlags = $objAdvertisment.TimeFlags
								#Now for some cleanup
								#We want to allow fallback
								$NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'DONT_FALLBACK'

								#Set DONT_RUN_NO_LOCAL_DISPPOINT to false
								$NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'DONT_RUN_NO_LOCAL_DISPPOINT'

								#We don't want to Allow Peer Caching
								$NewDeployment.AdvertFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $NewDeployment.AdvertFlags -BitFlagHashTable $AdvertFlags -KeyName 'ENABLE_PEER_CACHING'
								$NewDeployment.AdvertFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $NewDeployment.AdvertFlags -BitFlagHashTable $AdvertFlags -KeyName 'DONOT_FALLBACK'

								#Make sure we only rerun if failed
								if(IsBitFlagSet -BitFlagHashTable $TimeFlags -KeyName 'ENABLE_MANDATORY' -CurrentValue $NewDeployment.TimeFlags)
								{
									$NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'RERUN_ALWAYS'
									$NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'RERUN_NEVER'
									$NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'RERUN_IF_SUCCEEDED'
									$NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $true -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'RERUN_IF_FAILED'
								}
								$NewDeployment.Put() | Out-Null
							}
							catch [system.exception]
							{
								$Error | Out-File "C:\Temp\CopyDeployment.log"
								Throw "Had an error - Not copying deployment $($objAdvertisment.PackageID) - $($objAdvertisment.AdvertisementID)."
							}
						}
						else
						{
							try
							{
								$objAdvertisment.CollectionID = $ToCollectionID
								#If $isDNR - Set 
								#DOWNLOAD_FROM_REMOTE_DISPPOINT to true
								#DOWNLOAD_FROM_LOCAL_DISPPOINT to true
								#RUN_FROM_REMOTE_DISPPOINT to false
								#RUN_FROM_LOCAL_DISPPOINT to false
								if($isDNR)
								{
									$objAdvertisment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $true -CurrentValue $objAdvertisment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'DOWNLOAD_FROM_REMOTE_DISPPOINT' 
									$objAdvertisment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $true -CurrentValue $objAdvertisment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'DOWNLOAD_FROM_LOCAL_DISPPOINT'
									$objAdvertisment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $objAdvertisment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'RUN_FROM_REMOTE_DISPPOINT'
									$objAdvertisment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $objAdvertisment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'RUN_FROM_LOCAL_DISPPOINT'
								}
								#if $isRDP - Set DOWNLOAD_FROM_REMOTE_DISPPOINT to false
								#DOWNLOAD_FROM_REMOTE_DISPPOINT to false
								#DOWNLOAD_FROM_LOCAL_DISPPOINT to false
								#RUN_FROM_REMOTE_DISPPOINT to true
								#RUN_FROM_LOCAL_DISPPOINT to true
								if($isRDP)
								{
									$objAdvertisment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $objAdvertisment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'DOWNLOAD_FROM_REMOTE_DISPPOINT' 
									$objAdvertisment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $objAdvertisment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'DOWNLOAD_FROM_LOCAL_DISPPOINT'
									$objAdvertisment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $true -CurrentValue $objAdvertisment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'RUN_FROM_REMOTE_DISPPOINT'
									$objAdvertisment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $true -CurrentValue $objAdvertisment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'RUN_FROM_LOCAL_DISPPOINT'
								}
								if($IgnoreMaintenanceWindow){$objAdvertisment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $true -BitFlagHashTable $AdvertFlags -KeyName 'OVERRIDE_SERVICE_WINDOWS' -CurrentValue $objAdvertisment.AdvertFlags}
								#Now for some cleanup
								#We want to allow fallback
								$objAdvertisment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $objAdvertisment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'DONT_FALLBACK'

								#Set DONT_RUN_NO_LOCAL_DISPPOINT to false
								$objAdvertisment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $objAdvertisment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'DONT_RUN_NO_LOCAL_DISPPOINT'

								#We don't want to Allow Peer Caching
								$objAdvertisment.AdvertFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $objAdvertisment.AdvertFlags -BitFlagHashTable $AdvertFlags -KeyName 'ENABLE_PEER_CACHING'
								$objAdvertisment.AdvertFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $objAdvertisment.AdvertFlags -BitFlagHashTable $AdvertFlags -KeyName 'DONOT_FALLBACK'

								#Make sure we only rerun if failed
								if(IsBitFlagSet -BitFlagHashTable $TimeFlags -KeyName 'ENABLE_MANDATORY' -CurrentValue $objAdvertisment.TimeFlags)
								{
									$objAdvertisment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $objAdvertisment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'RERUN_ALWAYS'
									$objAdvertisment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $objAdvertisment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'RERUN_NEVER'
									$objAdvertisment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $objAdvertisment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'RERUN_IF_SUCCEEDED'
									$objAdvertisment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $true -CurrentValue $objAdvertisment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'RERUN_IF_FAILED'
								}
								$objAdvertisment.put() | Out-Null
							}
							catch [system.exception]
							{
								$Error | Out-File "C:\Temp\CopyDeployment.log"
								Throw "Had an error - Not copying deployment $($objAdvertisment.PackageID) - $($objAdvertisment.AdvertisementID)."
							}
						}
					}
				}
				5
				{
					if($MoveSoftwareUpdate)
					{
						New-LogEntry 'Software Update' 1 'Move-CMDeployment'
					}
				}
				6
				{
					if($MoveBaseLine)
					{
						New-LogEntry 'Baseline' 1 'Move-CMDeployment'
					}
				}
			}
		}
	}

	End
	{
		if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
	}
} #End FunctionName

$SiteServer = '\`d.T.~Vb/{29DB4FCF-9969-49BA-AE37-FD8581475AC9}\`d.T.~Vb/'
$FromCollectionID = '\`d.T.~Ed/{04692546-B8F9-484F-9DF5-B52DD4D09CE2}.{96C19125-D424-4425-A33D-C6412060C822}\`d.T.~Ed/'
$ToCollectionID='\`d.T.~Ed/{04692546-B8F9-484F-9DF5-B52DD4D09CE2}.{A1FD9D01-25C3-4AA0-8242-7CB67C52D4E3}\`d.T.~Ed/'
$CopyDeployment=$\`d.T.~Ed/{04692546-B8F9-484F-9DF5-B52DD4D09CE2}.{B7A98D54-D681-4795-AAB0-1F70A3238375}\`d.T.~Ed/
$isDNR=$\`d.T.~Ed/{04692546-B8F9-484F-9DF5-B52DD4D09CE2}.{78D30ADA-35D1-4F0E-B21A-617E20FAF1B6}\`d.T.~Ed/
$isRDP=$\`d.T.~Ed/{04692546-B8F9-484F-9DF5-B52DD4D09CE2}.{AEBB4A28-C452-4376-A1B1-4552590E32E1}\`d.T.~Ed/
$IgnoreMaintenanceWindow = $\`d.T.~Ed/{04692546-B8F9-484F-9DF5-B52DD4D09CE2}.{397D2FD6-1E48-424A-950A-B6A51D6FDA0F}\`d.T.~Ed/

try
{
    $SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode
}

catch [System.Exception]
{
    $Error | Out-File "C:\Temp\CopyDeployment.log"
    throw "Unable to connect to server $SiteServer"
}

$WMIQueryParameters = @{
    ComputerName = $SiteServer
    Namespace = "root\sms\site_$SiteCode"
}

$objDeployments = Get-WmiObject -Class SMS_DeploymentInfo -Filter "CollectionID = '$FromCollectionID'" @WMIQueryParameters

#Make sure both $isDNR and $isRDP are not set
if($isDNR -and $isRDP) {Throw "Can not have both isDNR and isRDP set, please correct"}

