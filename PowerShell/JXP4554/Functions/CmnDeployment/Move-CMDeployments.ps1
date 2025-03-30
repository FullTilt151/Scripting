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
    [Parameter(Mandatory = $true, HelpMessage = "Collection where deployments are to be moved from")]
    [String]$FromCollectionID,
    [Parameter(Mandatory = $true, HelpMessage = "Collection where deployments are moving to")]
    [String]$ToCollectionID,
    [Parameter(Mandatory = $false, HelpMessage = "Move Required Deployments")]
    [Switch]$MoveRequired,
    [Parameter(Mandatory = $false, HelpMessage = "Move Programs")]
    [Switch]$MovePrograms,
    [Parameter(Mandatory = $false, HelpMessage = "Move Application")]
    [Switch]$MoveApplications,
    [Parameter(Mandatory = $false, HelpMessage = "Move Software Update")]
    [Switch]$MoveSoftwareUpdate,
    [Parameter(Mandatory = $false, HelpMessage = "Move BaseLine (Compliance)")]
    [Switch]$MoveBaseLine,
    [Parameter(Mandatory = $false, HelpMessage = "Copy programs instead of move")]
    [Switch]$CopyDeployment,
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

Function Move-CMDeployment {
    Param
    (
        [Parameter(Mandatory = $true)]
        [PSObject]$MoveDeployment
    )

    New-LogEntry "Working on $($MoveDeployment.SoftwareName)" 1 'Move-CMDeployment'

    Switch ($MoveDeployment.FeatureType) {
        1 {
            if ($MoveApplications) {
                <#
                General Tab
                Software -
                Collection -
                Automatically sitribute content for dependincies
                Comments

                Deployment Settings Tab
                Action (Install/Uninstall)
                Purpose (Required/Available)
                Require Administrators approval if users request this application

                Scheduling Tab
                Time based on
                Scheule this applciation available
                AvailableDateTime

                User Experience Tab
                User Notifications
                Software Installation (Outside MW)
                System Restart (Outside MW)
                Commit changes at deadline (Embedded Device)

                Alerts Tab
                Create a deployment alert
                Percent success
                AfterDateTime
                Create a deployment alert when the failed threshold is higher than
                Enable SCOM Maintenance Mode
                Generate SCOM alert when install fails.
                #>
                New-LogEntry 'It''s an Application' 1 'Move-CMDeployment'
                #DeploymentType 1 = install, 2=uninstall
                $objApplication = Get-CMApplication -Id $MoveDeployment.CI_ID
                New-LogEntry "objApplication - $objApplication" 1 'Move-CMDeployment'
                $objDeployment = Get-WmiObject @WMIQueryParameters -class SMS_DeploymentInfo -Filter "DeploymentID = '$($MoveDeployment.DeploymentID)'"
                $objDeployment.Get()
                if ($MoveApplications -and ($objDeployment.DeploymentIntent -eq 2 -or ($objDeployment.DeploymentIntent -eq 3 -and $MoveRequired))) {
                    if ($CopyDeployment) {
                        try {
                            $NewDeployment = ([WMICLASS]"\\$($SiteServer)\root\sms\site_$($SiteCode):SMS_DeploymentInfo").CreateInstance()
                            $NewDeployment.CollectionID = $ToCollectionID;
                            $NewDeployment.CollectionName = $MoveDeployment.CollectionName;
                            $NewDeployment.DeploymentIntent = $objDeployment.DeploymentIntent;
                            $NewDeployment.DeploymentType = $objDeployment.DeploymentType;
                            $NewDeployment.TargetID = $objDeployment.TargetID;
                            $NewDeployment.TargetName = $objDeployment.TargetName
                            $NewDeployment.TargetSecurityTypeID = $objDeployment.TargetSecurityTypeID;
                            $NewDeployment.TargetSubName = $objDeployment.TargetSubName;
                            $NewDeployment.Put() | Out-Null
                            New-LogEntry "NewDeployment = $NewDeployment" 1 'move-Deployment'
                        }
                        catch [system.exception] {
                            New-LogEntry "Had an error - Not copying deployment $($objAdvertisment.PackageID) - $($objAdvertisment.AdvertisementID)." 3 'Copy-CMDeployment'
                            New-LogEntry "$Error[0]" 3 'Copy-CMDeployment'
                            Write-Error "Had an error - Not copying deployment $($objAdvertisment.PackageID) - $($objAdvertisment.AdvertisementID)."
                        }
                    }
                    else {
                        try {
                            $objDeployment.CollectionID = $ToCollectionID
                            $objDeployment.put() | Out-Null
                            New-LogEntry 'Deployment Moved'
                        }
                        catch [system.exception] {
                            New-LogEntry "Had an error - Not moving deployment $($objDeployment.DeploymentID) - $($objAdvertisment.AdvertisementID)." 3 'Move-CMDeployment'
                            New-LogEntry "$Error[0]" 3 'Move-CMDeployment'
                            Write-Error "Had an error - Not moving deployment $($objDeployment.DeploymentID) - $($objAdvertisment.AdvertisementID)."
                        }
                    }
                }
            }
        }

        2 {
            if ($MovePrograms) {
                $objAdvertisment = Get-WmiObject @WMIQueryParameters -class SMS_Advertisement -Filter "AdvertisementID = '$($MoveDeployment.DeploymentID)'"
                $objAdvertisment.Get()
                if (-not (Get-WmiObject @WMIQueryParameters -Class SMS_Advertisement -Filter "CollectionID = '$ToCollectionID' and PackageID = '$($objAdvertisment.PackageID)'")) {
                    if ($MovePrograms -and ($OfferTypes[$objAdvertisment.OfferType] -eq 'Available' -or ($OfferTypes[$objAdvertisment.OfferType] -eq 'Required' -and $MoveRequired))) {
                        if ($CopyDeployment) {
                            try {
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
                                New-LogEntry "NewDeployment = $NewDeployment" 1 'move-Deployment'
                            }
                            catch [system.exception] {
                                New-LogEntry "Had an error - Not copying deployment $($objAdvertisment.PackageID) - $($objAdvertisment.AdvertisementID)." 3 'Copy-CMDeployment'
                                New-LogEntry "$Error[0]" 3 'Copy-CMDeployment'
                                Write-Error "Had an error - Not copying deployment $($objAdvertisment.PackageID) - $($objAdvertisment.AdvertisementID)."
                            }
                        }
                        else {
                            try {
                                $objAdvertisment.CollectionID = $ToCollectionID
                                $objAdvertisment.put() | Out-Null
                                New-LogEntry 'Deployment Moved'
                            }
                            catch [system.exception] {
                                New-LogEntry "Had an error - Not moving deployment $($objAdvertisment.PackageID) - $($objAdvertisment.AdvertisementID)." 3 'Move-CMDeployment'
                                New-LogEntry "$Error[0]" 3 'Move-CMDeployment'
                                Write-Error "Had an error - Not moving deployment $($objAdvertisment.PackageID) - $($objAdvertisment.AdvertisementID)."
                            }
                        }
                    }
                }
            }
        }

        5 {
            if ($MoveSoftwareUpdate) {
                New-LogEntry 'Software Update' 1 'Move-CMDeployment'
            }
        }

        6 {
            if ($MoveBaseLine) {
                New-LogEntry 'Baseline' 1 'Move-CMDeployment'
            }
        }
    }
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

#SCCM Import Module
#import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager\ConfigurationManager.psd1')
import-module "$($env:SMS_ADMIN_UI_PATH)\..\ConfigurationManager\ConfigurationManager.psd1"

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

Push-Location
Set-Location "$($SiteCode):"

#Begin validate parameters

#Make sure they aren't the same collection
if ($FromCollectionID -eq $ToCollectionID) {
    New-LogEntry 'From and To collection ID''s are the same, please use two different collections' 3
    Pop-Location
    throw 'From and To collection ID''s are the same, please use two different collections'
}

#Verify CollectionID's exist

try {
    $Error.Clear()
    New-LogEntry "Getting Collection information for $FromCollectionID"
    $Collection = Get-CMDeviceCollection -CollectionId $FromCollectionID

    New-LogEntry "Getting deployments for $($Collection.Name)"
    $Deployments = Get-CMDeployment -CollectionName $Collection.Name
}
catch [system.exception] {
    New-LogEntry 'Having issues with the collecitons' 3
    New-LogEntry "Error - $Error" 3
    Pop-Location
    throw 'Having issues with collecitons'
}

New-LogEntry 'Starting to move deployments'
foreach ($Deployment in $Deployments) {
    #Is it required and need to be moved?
    if ((($Deployment.DeploymentIntent -eq 1) -and $MoveRequired) -or ($Deployment.DeploymentIntent -eq 2)) {
        Move-CMDeployment $Deployment
    }
}

New-LogEntry 'Finished Script!'
Pop-Location