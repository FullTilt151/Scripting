<#
.Synopsis
	This script will move or copy deployments from one collection to another.
.DESCRIPTION
	This script will move or copy deployments from one collection to another. You have the choice of:
	* Moving Programs
	* Moving Applications
	* Moving Software updates
	* Moving Baselines (Compliance)
	* Moving Required Deployments
	* Copying instead of moving (doesn't delete original deployment)
.PARAMETER SiteServer
	This is the Server with the SMS Provider installed for the site

.PARAMETER FromCollectionID
	This is the CollecitonID of the source collection

.PARAMETER ToCollectionID
	This is the CollecitonID of the destination colleciton

PARAMTER MoveRequired
	This will move/copy any required deployment

PARAMETER MovePrograms
	This will move/copy any program (package) deployments

PARAMETER MoveApplications
	This will move/copy any application deployments

PARAMETER MoveSoftwareUpdate
	This will move/copy software update deployments

PARAMETER MoveBaseLine
	This will move/copy baseline (Compliance) deployments

PARAMETER CopyDeployment
	This will cause the deployments to be copied instead of moved

PARAMETER LogLevel
	This is the minimum logging level you want for the logfile, nothing below this level will be logged. It defaults to 2. The levels are:
    1 - Informational
    2 - Warning
    3 - Error

.PARAMETER LogFileDir
    This is the directory where the log will be created. It defaults to C:\Temp

.PARAMETER ClearLog
	This will cause the existing log to be deleted (if exists)

.EXAMPLE

.LINK
    http://configman-notes.com

.NOTES
    need to add check to see if deployment exists.
#>

Param(
    [Parameter(Mandatory = $true, HelpMessage = "Site server where the SMS Provider is installed")]
    [ValidateScript( {Test-Connection -ComputerName $_ -Count 1 -Quiet})]
    [String]$SiteServer,
    [Parameter(Mandatory = $true, HelpMessage = "Collection where deployments are moving to")]
    [String]$CollectionID,
    [Parameter(Mandatory = $false, HelpMessage = "Sets the Log Level, 1 - Informational, 2 - Warning, 3 - Error")]
    [Int32]$LogLevel = 2,
    [Parameter(Mandatory = $false, HelpMessage = "Log File Directory")]
    [String]$LogFileDir = 'C:\Temp\',
    [Parameter(Mandatory = $false, HelpMessage = "Clear any existing log file")]
    [Switch]$ClearLog
)

#Begin New-LogEntry Function
Function New-LogEntry {
    # Writes to the log file
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [String] $Entry,
        [Parameter(Position = 1, Mandatory = $false)]
        [INT32] $type = 1,
        [Parameter(Position = 2, Mandatory = $false)]
        [String] $component = $ScriptName
    )
    if ($type -ge $Script:LogLevel) {
        if ($Entry.Length -eq 0) {
            $Entry = 'N/A'
        }
        $TZOffset = ([TimeZoneInfo]::Local).BaseUTcOffset.TotalMinutes
        $TZOffset = "$(Get-Date -Format "HH:mm:ss.fff")+$(-$TZOffset)"
        $Entry = "<![LOG[{0}]LOG]!><time=""{2}"" date=""{1}"" component=""{5}"" context="""" type=""{4}"" thread=""{3}"">" -f $Entry, (Get-Date -Format "MM-dd-yyyy"), $TZOffset, $pid, $type, $component
        $Entry | Out-File $Script:LogFile -Append -Encoding ascii
    }
}
#End New-LogEntry

Function ConvertDateString([string]$DateTimeString) {
    if ($DateTimeString -ne $null) {
        $format = "yyyyMMddHHmm"
        $return = [datetime]::ParseExact(([string]($DateTimeString.Substring(0, 12))), $format, $null).ToString()
    }
    else {
        $return = (Get-Date -Format $format).ToString()
    }
    return $return
}

Function Get-QuotedVersion {
    Param
    (
        [Parameter(Mandatory = $true)]
        [String]$Text
    )
    return $Text -Replace '((?:'')/w*)', '$1'''''
    #    return $Text -Replace '(.*)''', '$1'''''
}

Function New-CMPackageDeployment {
    Param
    (
        [Parameter(Mandatory = $true)]
        [PSObject]$MoveDeployment
    )
    if (-not (Get-WmiObject @WMIQueryParameters -Class SMS_Advertisement -Filter "CollectionID = '$ToCollectionID' and PackageID = '$($MoveDeployment.PackageID)'")) {
        try {
            $NewDeployment = ([WMICLASS]"\\$($SiteServer)\root\sms\site_$($SiteCode):SMS_Advertisement").CreateInstance()
            $NewDeployment.ActionInProgress = 2;
            <#IMMEDIATE = "0x00000020"; True
			ONSYSTEMSTARTUP = "0x00000100";
			ONUSERLOGON = "0x00000200";
			ONUSERLOGOFF = "0x00000400";
			WINDOWS_CE = "0x00008000";
			ENABLE_PEER_CACHING = "0x00010000";
			DONOT_FALLBACK = "0x00020000";
			ENABLE_TS_FROM_CD_AND_PXE = "0x00040000";
			OVERRIDE_SERVICE_WINDOWS = "0x00100000";
			REBOOT_OUTSIDE_OF_SERVICE_WINDOWS = "0x00200000";
			WAKE_ON_LAN_ENABLED = "0x00400000";
			SHOW_PROGRESS = "0x00800000";
			NO_DISPLAY = "0x02000000";
			ONSLOWNET = "0x04000000";   #>
            $NewDeployment.AdvertFlags = $MoveDeployment.AdvertFlags;
            $NewDeployment.AdvertisementName = $MoveDeployment.AdvertisementName;
            $NewDeployment.AssignedSchedule = $MoveDeployment.AssignedSchedule;
            $NewDeployment.AssignedScheduleEnabled = $MoveDeployment.AssignedScheduleEnabled;
            $NewDeployment.AssignedScheduleIsGMT = $MoveDeployment.AssignedScheduleIsGMT;
            $NewDeployment.CollectionID = $MoveDeployment;
            $NewDeployment.Comment = $MoveDeployment.Comment;
            $NewDeployment.DeviceFlags = $MoveDeployment.DeviceFlags;
            $NewDeployment.ExpirationTime = $MoveDeployment.ExpirationTime;
            $NewDeployment.ExpirationTimeEnabled = $MoveDeployment.ExpirationTimeEnabled;
            $NewDeployment.HierarchyPath = $MoveDeployment.HierarchyPath
            $NewDeployment.IncludeSubCollection = $MoveDeployment.IncludeSubCollection;
            $NewDeployment.ISVData = $MoveDeployment.ISVData;
            $NewDeployment.ISVDataSize = $MoveDeployment.ISVDataSize;
            $NewDeployment.IsVersionCompatible = $MoveDeployment.IsVersionCompatible;
            $NewDeployment.MandatoryCountdown = $MoveDeployment.MandatoryCountdown;
            $NewDeployment.OfferType = $MoveDeployment.OfferType;
            $NewDeployment.PackageID = $MoveDeployment.PackageID;
            $NewDeployment.PresentTime = $MoveDeployment.PresentTime;
            $NewDeployment.PresentTimeEnabled = $MoveDeployment.PresentTimeEnabled;
            $NewDeployment.PresentTimeIsGMT = $MoveDeployment.PresentTimeIsGMT;
            $NewDeployment.Priority = $MoveDeployment.Priority;
            $NewDeployment.ProgramName = $MoveDeployment.ProgramName;
            <#BATTERY_POWER = "0x00000001";
			RUN_FROM_CD	= "0x00000002";
			DOWNLOAD_FROM_CD = "0x00000004";
			RUN_FROM_LOCAL_DISPPOINT = "0x00000008";
			DOWNLOAD_FROM_LOCAL_DISPPOINT = "0x00000010"; True
			DONT_RUN_NO_LOCAL_DISPPOINT = "0x00000020";
			DOWNLOAD_FROM_REMOTE_DISPPOINT = "0x00000040"; True
			RUN_FROM_REMOTE_DISPPOINT = "0x00000080";
			DOWNLOAD_ON_DEMAND_FROM_LOCAL_DP = "0x00000100";
			DOWNLOAD_ON_DEMAND_FROM_REMOTE_DP = "0x00000200";
			BALLOON_REMINDERS_REQUIRED = "0x00000400";
			RERUN_ALWAYS = "0x00000800";
			RERUN_NEVER = "0x00001000";
			RERUN_IF_FAILED = "0x00002000"; True
			RERUN_IF_SUCCEEDED = "0x00004000";
			PERSIST_ON_WRITE_FILTER_DEVICES	 = "0x00008000";
			DONT_FALLBACK = "0x00020000";
			DP_ALLOW_METERED_NETWORK = "0x00040000";#>
            $NewDeployment.RemoteClientFlags = $MoveDeployment.RemoteClientFlags;
            $NewDeployment.SourceSite = $MoveDeployment.SourceSite;
            <#ENABLE_PRESENT = '0x00000001'; True
			ENABLE_EXPIRATION = '0x00000002';
			ENABLE_AVAILABLE = '0x00000004';
			ENABLE_UNAVAILABLE = '0x00000008';
			ENABLE_MANDATORY = '0x00000010';
			GMT_PRESENT = '0x00000020';
			GMT_EXPIRATION = '0x00000040';
			GMT_AVAILABLE = '0x00000080';
			GMT_UNAVAILABLE = '0x00000100';
			GMT_MANDATORY = '0x00000200';#>
            $NewDeployment.TimeFlags = $MoveDeployment.TimeFlags
            $NewDeployment.Put() | Out-Null
            New-LogEntry "NewDeployment = $NewDeployment" 1 'move-Deployment'
        }
        catch [system.exception] {
            New-LogEntry "Had an error - Not copying deployment $($MoveDeployment.PackageID) - $($MoveDeployment.AdvertisementID)." 3 'Copy-CMDeployment'
            New-LogEntry "$Error[0]" 3 'Copy-CMDeployment'
            Write-Error "Had an error - Not copying deployment $($MoveDeployment.PackageID) - $($MoveDeployment.AdvertisementID)."
        }
    }
    <#else
	{
		try
		{
			$objAdvertisment.CollectionID = $ToCollectionID
			$objAdvertisment.put() | Out-Null
			New-LogEntry 'Deployment Moved'
		}
		catch [system.exception]
		{
			New-LogEntry "Had an error - Not moving deployment $($objAdvertisment.PackageID) - $($objAdvertisment.AdvertisementID)." 3 'Move-CMDeployment'
			New-LogEntry "$Error[0]" 3 'Move-CMDeployment'
			Write-Error "Had an error - Not moving deployment $($objAdvertisment.PackageID) - $($objAdvertisment.AdvertisementID)."
		}
	}#>
}

Function Get-BitFlagsSet($FlagsProp, $BitFlagHashTable) {
    $ReturnHashTable = @{}
    $BitFlagHashTable.Keys | ForEach-Object { if (($FlagsProp -band $BitFlagHashTable.Item($_)) -ne 0 ) {$ReturnHashTable.Add($($_), $true)}else {$ReturnHashTable.Add($($_), $false)}}
    $ReturnHashTable
}

Function Set-BitFlagForControl($IsControlEnabled, $BitFlagHashTable, $KeyName, $CurrentValue) {
    if ($IsControlEnabled) {
        $CurrentValue = $CurrentValue -bor $BitFlagHashTable.Item($KeyName)
    }
    elseif ($CurrentValue -band $BitFlagHashTable.Item($KeyName)) {
        $CurrentValue = ($CurrentValue -bxor $BitFlagHashTable.Item($KeyName))
    }
    return $CurrentValue
}

Function IsBitFlagSet($BitFlagHashTable, $KeyName, $CurrentValue) {
    if ($CurrentValue -band $BitFlagHashTable.Item($KeyName)) {
        return $True
    }
    else {
        return $False
    }
}

Function ConvertDateString([string]$DateTimeString) {
    if ($DateTimeString -ne $null) {
        $format = "yyyyMMddHHmm"
        $return = [datetime]::ParseExact(([string]($DateTimeString.Substring(0, 12))), $format, $null).ToString()
    }
    else {
        $return = (Get-Date -Format $format).ToString()
    }
    return $return
}

#End Functions

#Begin Constants

#Feature types:
$FeatureTypes = @()
$FeatureTypes += "Unknown"
$FeatureTypes += "Application"
$FeatureTypes += "Program"
$FeatureTypes += "Invalid"
$FeatureTypes += "Invalid"
$FeatureTypes += "Software Update"
$FeatureTypes += "Invalid"
$FeatureTypes += "Task Sequence"

$OfferTypes = @("Required", "Not Used", "Available")

#hash table with bit flag definitions - sms_advertisement.advertflags
$AdvertFlags = @{
    IMMEDIATE                         = "0x00000020";
    ONSYSTEMSTARTUP                   = "0x00000100";
    ONUSERLOGON                       = "0x00000200";
    ONUSERLOGOFF                      = "0x00000400";
    WINDOWS_CE                        = "0x00008000";
    ENABLE_PEER_CACHING               = "0x00010000";
    DONOT_FALLBACK                    = "0x00020000";
    ENABLE_TS_FROM_CD_AND_PXE         = "0x00040000";
    OVERRIDE_SERVICE_WINDOWS          = "0x00100000";
    REBOOT_OUTSIDE_OF_SERVICE_WINDOWS = "0x00200000";
    WAKE_ON_LAN_ENABLED               = "0x00400000";
    SHOW_PROGRESS                     = "0x00800000";
    NO_DISPLAY                        = "0x02000000";
    ONSLOWNET                         = "0x04000000";
}

# sms_advertisement.RemoteClientFlags
$RemoteClientFlags = @{
    BATTERY_POWER                     = "0x00000001";
    RUN_FROM_CD                       = "0x00000002";
    DOWNLOAD_FROM_CD                  = "0x00000004";
    RUN_FROM_LOCAL_DISPPOINT          = "0x00000008";
    DOWNLOAD_FROM_LOCAL_DISPPOINT     = "0x00000010";
    DONT_RUN_NO_LOCAL_DISPPOINT       = "0x00000020";
    DOWNLOAD_FROM_REMOTE_DISPPOINT    = "0x00000040";
    RUN_FROM_REMOTE_DISPPOINT         = "0x00000080";
    DOWNLOAD_ON_DEMAND_FROM_LOCAL_DP  = "0x00000100";
    DOWNLOAD_ON_DEMAND_FROM_REMOTE_DP = "0x00000200";
    BALLOON_REMINDERS_REQUIRED        = "0x00000400";
    RERUN_ALWAYS                      = "0x00000800";
    RERUN_NEVER                       = "0x00001000";
    RERUN_IF_FAILED                   = "0x00002000";
    RERUN_IF_SUCCEEDED                = "0x00004000";
    PERSIST_ON_WRITE_FILTER_DEVICES   = "0x00008000";
    DONT_FALLBACK                     = "0x00020000";
    DP_ALLOW_METERED_NETWORK          = "0x00040000";
}

$RerunBehaviors = @{
    RERUN_ALWAYS       = 'AlwaysRerunProgram';
    RERUN_NEVER        = 'NeverRerunDeployedProgra';
    RERUN_IF_FAILED    = 'RerunIfFailedPreviousAttempt';
    RERUN_IF_SUCCEEDED = 'RerunIfSucceededOnpreviousAttempt';
}

#SMS_Addvertisement.TimeFlags
$TimeFlags = @{
    ENABLE_PRESENT     = '0x00000001';
    ENABLE_EXPIRATION  = '0x00000002';
    ENABLE_AVAILABLE   = '0x00000004';
    ENABLE_UNAVAILABLE = '0x00000008';
    ENABLE_MANDATORY   = '0x00000010';
    GMT_PRESENT        = '0x00000020';
    GMT_EXPIRATION     = '0x00000040';
    GMT_AVAILABLE      = '0x00000080';
    GMT_UNAVAILABLE    = '0x00000100';
    GMT_MANDATORY      = '0x00000200';
}

$FastDPOptions = @(
    'RunProgramFromDistributionPoint',
    'DownloadContentFromDistributionPointAndRunLocally'
)

$SlowDPOptions = @(
    'DoNotRunProgram'
    'DownloadContentFromDistributionPointAndLocally',
    'RunProgramFromDistributionPoint'
)

#End Constants

#Build variables for New-LogEntry Function

$ScriptName = $MyInvocation.MyCommand.Name
if (-not ($LogFileDir -match '\\$')) {$LogFileDir = "$LogFileDir\"}
$LogFile = $ScriptName -replace '(.*)\.ps1', '$1'
$LogFile = $LogFileDir + $LogFile + '.log'
if ($ClearLog) {
    if (Test-Path $Logfile) {Remove-Item $LogFile}
}

New-LogEntry 'Starting script'
New-LogEntry "FromCollectionID - $FromCollectionID"
New-LogEntry "ToCollectionID - $ToCollectionID"
New-LogEntry "MoveRequired - $MoveRequired"
New-LogEntry "MovePrograms - $MovePrograms"
New-LogEntry "MoveApplications - $MoveApplications"
New-LogEntry "MoveSoftwareUpdate - $MoveSoftwareUpdate"
New-LogEntry "MoveBaseLine - $MoveBaseLine"
New-LogEntry "LogLevel - $LogLevel"
New-LogEntry "LogFileDir - $LogFileDir"
New-LogEntry "ClearLog -$ClearLog"

try {
    $Error.Clear()
    $SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode
}
catch [System.exception] {
    Write-Host "Unable to connect to $SiteServer"
    New-LogEntry "Unable to connect to $SiteServer" 3
    New-LogEntry "Error - $Error" 3
    Pop-Location
    throw "Unable to connect to $SiteServer"
}

$WMIQueryParameters = @{
    ComputerName = $SiteServer
    Namespace    = "root\sms\site_$SiteCode"
}