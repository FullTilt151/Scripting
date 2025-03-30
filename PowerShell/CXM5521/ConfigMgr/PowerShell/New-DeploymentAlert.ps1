<#
    .SYNOPSIS
        Send email, or text alerts for required package deployments based on Thresholds
    .DESCRIPTION
        Sends email alerts if required packages are sent to a certain number of targets
    .PARAMETER EmailThreshold
        Threshold of targeted devices that triggers an email alert
    .PARAMETER TextThreshold
        Threshold of targeted devices that triggers a text alert
    .PARAMETER SiteCode
        SiteCode that will be used as part of CIM based queries

        Status Filter Rule variable is %sc
    .PARAMETER SiteServer
        SiteServer that will be used as part of CIM based queries

        Status Filter Rule variable is %sitesvr
    .PARAMETER InsStr1
        Status Filter Rule variable is %msgis01
    .PARAMETER InsStr2
        Status Filter Rule variable is %msgis02
    .PARAMETER InsStr3
        Status Filter Rule variable is %msgis03
    .PARAMETER InsStr4
        Status Filter Rule variable is %msgis04
    .PARAMETER MachineName
        System that the message originated from

        Status Filter Rule variable is %msgsys
    .PARAMETER Program
        Switch that tells the script to process a Program OR Task Sequence Deployment - they share the same status message ID
    .PARAMETER Application
        Switch that tells the script to process a Application Deployment
    .PARAMETER SoftwareUpdate
        Switch that tells the script to process a Software Update deployment
    .EXAMPLE
        C:\PS > New-DeploymentAlert.ps1 -SiteCode %sc -SiteServer %sitesvr -InsStr1 "%msgis01" -InsStr2 "%msgis02" -InsStr3 "%msgis03" -InsStr4 "%msgis04" -MachineName %msgsys
#>
param (
    [Parameter(Mandatory = $false)]
    [int]$EmailThreshold = 2500,
    [Parameter(Mandatory = $false)]
    [int]$TextThreshold = 5000,
    [Parameter(Mandatory = $true)]
    [string]$SiteCode,
    [Parameter(Mandatory = $true)]
    [string]$SiteServer,
    [Parameter(Mandatory = $true, ParameterSetName = 'Program')]
    [Parameter(Mandatory = $true, ParameterSetName = 'Application')]
    [Parameter(Mandatory = $true, ParameterSetName = 'SoftwareUpdate')]
    [string]$InsStr1,
    [Parameter(Mandatory = $true, ParameterSetName = 'Program')]
    [Parameter(Mandatory = $true, ParameterSetName = 'Application')]
    [Parameter(Mandatory = $true, ParameterSetName = 'SoftwareUpdate')]
    [string]$InsStr2,
    [Parameter(Mandatory = $true, ParameterSetName = 'Program')]
    [Parameter(Mandatory = $true, ParameterSetName = 'SoftwareUpdate')]
    [string]$InsStr3,
    [Parameter(Mandatory = $false)]
    [string]$InsStr4,
    [Parameter(Mandatory = $true)]
    [string]$MachineName,
    [Parameter(Mandatory = $true, ParameterSetName = 'Program')]
    [switch]$Program,
    [Parameter(Mandatory = $true, ParameterSetName = 'Application')]
    [switch]$Application,
    [Parameter(Mandatory = $true, ParameterSetName = 'SoftwareUpdate')]
    [switch]$SoftwareUpdate
)
#region Email Lists and Constants
$mailMessageSplat = @{
    SmtpServer = "pobox.humana.com"
    From       = "ConfigMgrSupport@humana.com"
}

$alertList = @(
    'dratliff@humana.com'
)

# Verizon = @vtext.com
# Sprint = @messaging.sprintpcs.com
# AT&T = @txt.att.net
# TMobile = @tmomail.net
# Spectrum = @vtext.com
# Google Fi = @msg.fi.google.com

$textAlertList = @(
    '5028076382@tmomail.net'
    'dratliff@humana.com'
)

$SMS_Advertisement_AdvertFlags = @{
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
#endregion

#region DB Query Splat
$dbaQuerySplat = @{
    SqlInstance = Get-ItemPropertyValue -Path 'registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SMS\SQL Server\' -Name Server
    Database    = [string]::Format('CM_{0}', $SiteCode)
}
#endregion DB Query Splat

#region Function Definitions
function AddBodyItem {
    param(
        [parameter(Mandatory = $true)]
        [string]$name,
        [parameter(Mandatory = $true)]
        [string[]]$value,
        [parameter(Mandatory = $true)]
        [string[]]$Problems
    ) 
    $global:rowcount ++
    switch ($Name -in $Problems) {
        $true {
            $class = 'problemColor'
        }
        $false {
            if ((($global:rowcount) % 2) -eq 0) {
                $class = "evenrowcolor"
            }
            else {
                $class = "oddrowcolor"
            }
        }
    }
    $script:bodyHTML += "<tr class=""$($class)""><td>$($name)<td>$($value)</td></tr>"
}

Function ConvertFrom-CCMSchedule {
    <#
    .SYNOPSIS
        Convert Configuration Manager Schedule Strings
    .DESCRIPTION
        This function will take a Configuration Manager Schedule String and convert it into a readable object, including
        the calculated description of the schedule
    .PARAMETER ScheduleString
        Accepts an array of strings. This should be a schedule string in the SCCM format
    .EXAMPLE
        PS C:\> ConvertFrom-CCMSchedule -ScheduleString 1033BC7B10100010
        SmsProviderObjectPath : SMS_ST_RecurInterval
        DayDuration           : 0
        DaySpan               : 2
        HourDuration          : 2
        HourSpan              : 0
        IsGMT                 : False
        MinuteDuration        : 59
        MinuteSpan            : 0
        StartTime             : 11/19/2019 1:04:00 AM
        Description           : Occurs every 2 days effective 11/19/2019 1:04:00 AM
    .NOTES
        This function was created to allow for converting SCCM schedule strings without relying on the SDK / Site Server
        It also happens to be a TON faster than the Convert-CMSchedule cmdlet and the CIM method on the site server
    #>
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Schedules')]
        [string[]]$ScheduleString
    )
    begin {
        #region TypeMap for returning readable window type
        $TypeMap = @{
            1 = 'SMS_ST_NonRecurring'
            2 = 'SMS_ST_RecurInterval'
            3 = 'SMS_ST_RecurWeekly'
            4 = 'SMS_ST_RecurMonthlyByWeekday'
            5 = 'SMS_ST_RecurMonthlyByDate'
        }
        #endregion TypeMap for returning readable window type

        #region function to return a formatted day such as 1st, 2nd, or 3rd
        function Get-FancyDay {
            <#
                .SYNOPSIS
                Convert the input 'Day' integer to a 'fancy' value such as 1st, 2nd, 4d, 4th, etc.
            #>
            param(
                [int]$Day
            )
            $Suffix = switch -regex ($Day) {
                '1(1|2|3)$' {
                    'th'
                    break
                }
                '.?1$' {
                    'st'
                    break
                }
                '.?2$' {
                    'nd'
                    break
                }
                '.?3$' {
                    'rd'
                    break
                }
                default {
                    'th'
                    break
                }
            }
            [string]::Format('{0}{1}', $Day, $Suffix)
        }
        #endregion function to return a formatted day such as 1st, 2nd, or 3rd
    }
    process {
        # we will split the schedulestring input into 16 characters, as some are stored as multiple in one
        foreach ($Schedule in ($ScheduleString -split '(\w{16})' | Where-Object { $_ })) {
            $MW = [System.Collections.Specialized.OrderedDictionary]::new()

            # the first 8 characters are the Start of the MW, while the last 8 characters are the recurrence schedule
            $Start = $Schedule.Substring(0, 8)
            $Recurrence = $Schedule.Substring(8, 8)

            # Convert to binary string and pad left with 0 to ensure 32 character length for consistent parsing
            $binaryRecurrence = [Convert]::ToString([int64]"0x$Recurrence".ToString(), 2).PadLeft(32, 48)

            [bool]$IsGMT = [Convert]::ToInt32($binaryRecurrence.Substring(31, 1), 2)

            switch ($Start) {
                '00012000' {
                    # this is as 'simple' schedule, such as a CI that 'runs once a day' or 'every 8 hours'
                }
                default {
                    # Convert to binary string and pad left with 0 to ensure 32 character length for consistent parsing
                    $binaryStart = [Convert]::ToString([int64]"0x$Start".ToString(), 2).PadLeft(32, 48)

                    # Collect timedata and ensure we pad left with 0 to ensure 2 character length
                    [string]$StartMinute = ([Convert]::ToInt32($binaryStart.Substring(0, 6), 2).ToString()).PadLeft(2, 48)
                    [string]$MinuteDuration = [Convert]::ToInt32($binaryStart.Substring(26, 6), 2).ToString()
                    [string]$StartHour = ([Convert]::ToInt32($binaryStart.Substring(6, 5), 2).ToString()).PadLeft(2, 48)
                    [string]$StartDay = ([Convert]::ToInt32($binaryStart.Substring(11, 5), 2).ToString()).PadLeft(2, 48)
                    [string]$StartMonth = ([Convert]::ToInt32($binaryStart.Substring(16, 4), 2).ToString()).PadLeft(2, 48)
                    [String]$StartYear = [Convert]::ToInt32($binaryStart.Substring(20, 6), 2) + 1970

                    # set our StartDateTimeObject variable by formatting all our calculated datetime components and piping to Get-Date
                    $Kind = switch ($IsGMT) {
                        $true {
                            [DateTimeKind]::Utc
                        }
                        $false {
                            [DateTimeKind]::Local
                        }
                    }
                    $StartDateTimeObject = [datetime]::new($StartYear, $StartMonth, $StartDay, $StartHour, $StartMinute, '00', $Kind)
                }
            }

            <#
                Day duration is found by calculating how many times 24 goes into our TotalHourDuration (number of times being DayDuration)
                and getting the remainder for HourDuration by using % for modulus
            #>
            $TotalHourDuration = [Convert]::ToInt32($binaryRecurrence.Substring(0, 5), 2)

            switch ($TotalHourDuration -gt 24) {
                $true {
                    $Hours = $TotalHourDuration % 24
                    $DayDuration = ($TotalHourDuration - $Hours) / 24
                    $HourDuration = $Hours
                }
                $false {
                    $HourDuration = $TotalHourDuration
                    $DayDuration = 0
                }
            }

            $RecurType = [Convert]::ToInt32($binaryRecurrence.Substring(10, 3), 2)

            $MW['SmsProviderObjectPath'] = $TypeMap[$RecurType]
            $MW['DayDuration'] = $DayDuration
            $MW['HourDuration'] = $HourDuration
            $MW['MinuteDuration'] = $MinuteDuration
            $MW['IsGMT'] = $IsGMT
            $MW['StartTime'] = $StartDateTimeObject

            Switch ($RecurType) {
                1 {
                    $MW['Description'] = [string]::Format('Occurs on {0}', $StartDateTimeObject)
                }
                2 {
                    $MinuteSpan = [Convert]::ToInt32($binaryRecurrence.Substring(13, 6), 2)
                    $Hourspan = [Convert]::ToInt32($binaryRecurrence.Substring(19, 5), 2)
                    $DaySpan = [Convert]::ToInt32($binaryRecurrence.Substring(24, 5), 2)
                    if ($MinuteSpan -ne 0) {
                        $Span = 'minutes'
                        $Interval = $MinuteSpan
                    }
                    elseif ($HourSpan -ne 0) {
                        $Span = 'hours'
                        $Interval = $HourSpan
                    }
                    elseif ($DaySpan -ne 0) {
                        $Span = 'days'
                        $Interval = $DaySpan
                    }

                    $MW['Description'] = [string]::Format('Occurs every {0} {1} effective {2}', $Interval, $Span, $StartDateTimeObject)
                    $MW['MinuteSpan'] = $MinuteSpan
                    $MW['HourSpan'] = $Hourspan
                    $MW['DaySpan'] = $DaySpan
                }
                3 {
                    $Day = [Convert]::ToInt32($binaryRecurrence.Substring(13, 3), 2)
                    $WeekRecurrence = [Convert]::ToInt32($binaryRecurrence.Substring(16, 3), 2)
                    $MW['Description'] = [string]::Format('Occurs every {0} weeks on {1} effective {2}', $WeekRecurrence, $([DayOfWeek]($Day - 1)), $StartDateTimeObject)
                    $MW['Day'] = $Day
                    $MW['ForNumberOfWeeks'] = $WeekRecurrence
                }
                4 {
                    $Day = [Convert]::ToInt32($binaryRecurrence.Substring(13, 3), 2)
                    $ForNumberOfMonths = [Convert]::ToInt32($binaryRecurrence.Substring(16, 4), 2)
                    $WeekOrder = [Convert]::ToInt32($binaryRecurrence.Substring(20, 3), 2)
                    $WeekRecurrence = switch ($WeekOrder) {
                        0 {
                            'Last'
                        }
                        default {
                            $(Get-FancyDay -Day $WeekOrder)
                        }
                    }
                    $MW['Description'] = [string]::Format('Occurs the {0} {1} of every {2} months effective {3}', $WeekRecurrence, $([DayOfWeek]($Day - 1)), $ForNumberOfMonths, $StartDateTimeObject)
                    $MW['Day'] = $Day
                    $MW['ForNumberOfMonths'] = $ForNumberOfMonths
                    $MW['WeekOrder'] = $WeekOrder
                }
                5 {
                    $MonthDay = [Convert]::ToInt32($binaryRecurrence.Substring(13, 5), 2)
                    $MonthRecurrence = switch ($MonthDay) {
                        0 {
                            # $Today = [datetime]::Today
                            # [datetime]::DaysInMonth($Today.Year, $Today.Month)
                            'the last day'
                        }
                        default {
                            "day $PSItem"
                        }
                    }
                    $ForNumberOfMonths = [Convert]::ToInt32($binaryRecurrence.Substring(18, 4), 2)
                    $MW['Description'] = [string]::Format('Occurs {0} of every {1} months effective {2}', $MonthRecurrence, $ForNumberOfMonths, $StartDateTimeObject)
                    $MW['ForNumberOfMonths'] = $ForNumberOfMonths
                    $MW['MonthDay'] = $MonthDay
                }
                Default {
                    Write-Error "Parsing Schedule String resulted in invalid type of $RecurType"
                }
            }

            [pscustomobject]$MW
        }
    }
}

function Convert-UTCtoLocal {
    param(
        [parameter(Mandatory = $true)]
        [datetime]$UTCTime
    )
    $strCurrentTimeZone = (Get-CimInstance -ClassName Win32_TimeZone).StandardName
    $TZ = [System.TimeZoneInfo]::FindSystemTimeZoneById($strCurrentTimeZone)
    [System.TimeZoneInfo]::ConvertTimeFromUtc($UTCTime, $TZ)
}
#endregion

#region Gather Deployment Information based on what was deployed
switch ($PSCmdlet.ParameterSetName) {
    "Program" {
        $QueryDeviceTypeBreakdown = [string]::Format(@"
            DECLARE @CollectionID varchar(8) = (
                    SELECT CollectionID
                    FROM v_Advertisement adv
                    WHERE adv.AdvertisementID = '{0}'
                )
            SELECT SUM(CASE
                WHEN enc.ChassisTypes0 IN ('3','4','6','7','8','13','15','16','35') THEN 1
                    ELSE 0
                END) AS [DesktopCount]
                , SUM(CASE
                    WHEN enc.ChassisTypes0 IN ('5','9','10','11','12','14','18','21','30','31','32') THEN 1
                    ELSE 0
                END) AS [LaptopCount]
                , SUM(CAST(IsVirtualMachine AS int)) AS [VMCount]
            from v_FullCollectionMembership fcm
            JOIN v_GS_SYSTEM_ENCLOSURE enc ON enc.ResourceID = fcm.ResourceID
            WHERE fcm.CollectionID = @CollectionID
"@, $InsStr2)
        $dbaQuerySplat['Query'] = $QueryDeviceTypeBreakdown
        $DeviceTypeBreakdown = Invoke-DbaQuery @dbaQuerySplat

        $PackageQuery = [string]::Format(@"
        SELECT DISTINCT CASE
            WHEN depl.IsTaskSequenceDeployment = 1 THEN depl.PackageName
            WHEN depl.IsTaskSequenceDeployment = 0 THEN adv.ProgramName
            END AS [ProgramName]
        , CASE
            WHEN depl.IsTaskSequenceDeployment = 1 THEN (
                SELECT SUM(CASE
                        WHEN package2.SourceSize IS NOT NULL THEN package2.SourceSize
                        WHEN contp.SourceSize IS NOT NULL THEN contp.SourceSize
                        WHEN drvpkg.SourceSize IS NOT NULL THEN drvpkg.SourceSize
                        WHEN bootpkg.SourceSize IS NOT NULL THEN bootpkg.SourceSize
                        WHEN imgpkg.SourceSize IS NOT NULL THEN imgpkg.SourceSize
                    END) AS [SourceSize]
                FROM v_TaskSequencePackageReferences tsref
                        LEFT JOIN vPackage package2 ON package2.PkgID = tsref.RefPackageID
                        LEFT JOIN vSMS_ContentPackage contp ON contp.PkgID = tsref.RefPackageID
                        LEFT JOIN vSMS_DriverPackage drvpkg ON drvpkg.PkgID = tsref.RefPackageID
                        LEFT JOIN vSMS_BootImagePackage bootpkg ON bootpkg.PkgID = tsref.RefPackageID
                        LEFT JOIN vSMS_ImagePackage imgpkg ON imgpkg.PkgID = tsref.RefPackageID
                WHERE tsref.PackageID =  adv.PackageID
                )
            WHEN depl.IsTaskSequenceDeployment = 0 THEN (SELECT package.SourceSize FROM vPackage package WHERE package.PkgID = adv.PackageID)
            END AS [SourceSize]
        , adv.AdvertisementName
        , adv.AdvertisementID
        , col.CollectionName
        , adv.CollectionID
        , col.MemberCount AS [TargetedCount]
        , CASE
            WHEN depl.Purpose = 1 THEN 'Required'
            WHEN depl.Purpose = 2 THEN 'Available'
        END AS [OfferType]
        , adv.AssignedScheduleEnabled
		, adv.AdvertFlags
        , adv.PresentTime
        , adv.PresentTimeEnabled
        , adv.PresentTimeIsGMT
        , advrt.MandatorySched
        , depl.IsTaskSequenceDeployment
        FROM v_Advertisement adv
            JOIN vAdvertisement advrt ON advrt.OfferID = adv.AdvertisementID
            JOIN vClassicDeployments depl ON depl.DeploymentID = adv.AdvertisementID
            JOIN vCollections col ON col.SiteID = adv.CollectionID
            LEFT JOIN vPackage package ON package.PkgID = adv.PackageID
            LEFT JOIN v_TaskSequencePackageReferences tsref ON tsref.PackageID = adv.PackageID
            LEFT JOIN vPackage package2 ON package2.PkgID = tsref.RefPackageID
            LEFT JOIN vSMS_ContentPackage contp ON contp.PkgID = tsref.RefPackageID
        WHERE adv.AdvertisementID = '{0}'
"@, $InsStr2)
        $dbaQuerySplat['Query'] = $PackageQuery
        $DeployedPackageInfo = Invoke-DbaQuery @dbaQuerySplat

        $DeploymentType = switch ([bool]$DeployedPackageInfo.IsTaskSequenceDeployment) {
            $true {
                'TaskSequence'
            }
            $false {
                'Program'
            }
        }
        $PresentTimeIsGMT = [bool]$DeployedPackageInfo.PresentTimeIsGMT

        $enforcementDeadline = switch ([bool]$DeployedPackageInfo.AssignedScheduleEnabled) {
            $false {
                switch ($PresentTimeIsGMT) {
                    $true {
                        Convert-UTCtoLocal -UTCTime $DeployedPackageInfo.PresentTime
                    }
                    $false {
                        $DeployedPackageInfo.PresentTime
                    }
                }
            }
            $true {
                $Immediate = [bool]($DeployedPackageInfo.AdvertFlags -band $SMS_Advertisement_AdvertFlags['Immediate'])
                switch ($Immediate) {
                    $true {
                        switch ($PresentTimeIsGMT) {
                            $true {
                                Convert-UTCtoLocal -UTCTime $DeployedPackageInfo.PresentTime
                            }
                            $false {
                                $DeployedPackageInfo.PresentTime
                            }
                        }
                    }
                    $false {
                        $allEnforcementDeadline = foreach ($Schedule in (ConvertFrom-CCMSchedule -ScheduleString $DeployedPackageInfo.MandatorySched)) {
                            $isGMT = [bool]$Schedule.IsGMT
                            switch ($isGMT) {
                                $true {
                                    Convert-UTCtoLocal -UTCTime $Schedule.StartTime
                                }
                                $false {
                                    $Schedule.StartTime
                                }
                            }
                        }
                        $allEnforcementDeadline | Sort-Object | Select-Object -First 1
                    }
                }
            }
        }

        $softwareName = $DeployedPackageInfo.ProgramName
        $PackageSizeRaw = $DeployedPackageInfo.SourceSize
        $PackageSize = [string]::Format('{0} MB', [math]::Round(($PackageSizeRaw / 1024), 1))
        $deploymentOfferType = $DeployedPackageInfo.OfferType
        $IsAvailableEnforced = [bool]($DeployedPackageInfo.PresentTimeEnabled)
        $AvailableTime = switch ($PresentTimeIsGMT) {
            $true {
                Convert-UTCtoLocal -UTCTime $DeployedPackageInfo.PresentTime
            }
            $false {
                $DeployedPackageInfo.PresentTime
            }
        }
        $schedTokens = $DeployedPackageInfo.MandatorySched
        $DeployedAt = Get-Date
        $DeploymentName = $InsStr3
        $collectionID = $DeployedPackageInfo.CollectionID
        $collectionName = $DeployedPackageInfo.CollectionName
        $numberTargeted = $DeployedPackageInfo.TargetedCount
        $overrideMW = [bool]($DeployedPackageInfo.AdvertFlags -band $SMS_Advertisement_AdvertFlags['OVERRIDE_SERVICE_WINDOWS'])
        $overrideRebootMW = [bool]($DeployedPackageInfo.AdvertFlags -band $SMS_Advertisement_AdvertFlags['REBOOT_OUTSIDE_OF_SERVICE_WINDOWS'])
    }
    "Application" {
        $QueryDeviceTypeBreakdown = [string]::Format(@"
            DECLARE @CollectionID varchar(8) = (
                    SELECT col.SiteID
                    FROM v_DeploymentSummary summ
                    JOIN vCollections col ON col.SiteID = summ.CollectionID
                    WHERE summ.AssignmentID = {0}
                )
            SELECT SUM(CASE
                WHEN enc.ChassisTypes0 IN ('3','4','6','7','8','13','15','16','35') THEN 1
                    ELSE 0
                END) AS [DesktopCount]
                , SUM(CASE
                    WHEN enc.ChassisTypes0 IN ('5','9','10','11','12','14','18','21','30','31','32') THEN 1
                    ELSE 0
                END) AS [LaptopCount]
                , SUM(CAST(IsVirtualMachine AS int)) AS [VMCount]
            from v_FullCollectionMembership fcm
            JOIN v_GS_SYSTEM_ENCLOSURE enc ON enc.ResourceID = fcm.ResourceID
            WHERE fcm.CollectionID = @CollectionID
"@, $InsStr2)
        $dbaQuerySplat['Query'] = $QueryDeviceTypeBreakdown
        $DeviceTypeBreakdown = Invoke-DbaQuery @dbaQuerySplat

        $ApplicationQuery = [string]::Format(@"
            SELECT appAssign.ApplicationName
                , col.MemberCount AS [TargetedCount]
                , summ.CreationTime
                , summ.DeploymentTime
                , summ.EnforcementDeadline
                , CASE
                    WHEN summ.DeploymentIntent = 1 THEN 'Required'
                    WHEN summ.DeploymentIntent = 2 THEN 'Available'
                END AS [OfferType]
                , appAssign.OverrideServiceWindows
                , appAssign.RebootOutsideOfServiceWindows
                , summ.CollectionName
                , summ.CollectionID
                , appAssign.AssignmentName
                , content.SourceSize
            FROM v_DeploymentSummary summ
                JOIN v_ApplicationAssignment appAssign ON appAssign.AssignmentID = summ.AssignmentID
                JOIN vSMS_ContentPackage content ON summ.PackageID = content.PkgID
                JOIN vCollections col ON col.SiteID = summ.CollectionID
            WHERE summ.AssignmentID = {0}
"@, $InsStr2)
        $dbaQuerySplat['Query'] = $ApplicationQuery
        $DeployedApplicationInfo = Invoke-DbaQuery @dbaQuerySplat

        $DeploymentType = 'Application'
        $softwareName = $DeployedApplicationInfo.ApplicationName
        $PackageSizeRaw = $DeployedApplicationInfo.SourceSize
        $PackageSize = [string]::Format('{0} MB', [math]::Round(($PackageSizeRaw / 1024), 1))
        $deploymentOfferType = $DeployedApplicationInfo.OfferType
        $AvailableTime = $DeployedApplicationInfo.DeploymentTime
        $DeployedAt = $DeployedApplicationInfo.CreationTime
        $enforcementDeadline = $DeployedApplicationInfo.EnforcementDeadline
        $DeploymentName = $DeployedApplicationInfo.AssignmentName
        $collectionID = $DeployedApplicationInfo.CollectionID
        $collectionName = $DeployedApplicationInfo.CollectionName
        $numberTargeted = $DeployedApplicationInfo.TargetedCount
        $overrideMW = [bool]$DeployedApplicationInfo.OverrideServiceWindows
        $overrideRebootMW = [bool]$DeployedPackageInfo.RebootOutsideOfServiceWindows
    }
    "SoftwareUpdate" {
        $QueryDeviceTypeBreakdown = [string]::Format(@"
            DECLARE @CollectionID varchar(8) = (
                    SELECT col.SiteID
                    FROM v_DeploymentSummary summ
                    JOIN vCollections col ON col.SiteID = summ.CollectionID
                    WHERE summ.AssignmentID = {0}
                )
            SELECT SUM(CASE
                WHEN enc.ChassisTypes0 IN ('3','4','6','7','8','13','15','16','35') THEN 1
                    ELSE 0
                END) AS [DesktopCount]
                , SUM(CASE
                    WHEN enc.ChassisTypes0 IN ('5','9','10','11','12','14','18','21','30','31','32') THEN 1
                    ELSE 0
                END) AS [LaptopCount]
                , SUM(CAST(IsVirtualMachine AS int)) AS [VMCount]
            from v_FullCollectionMembership fcm
            JOIN v_GS_SYSTEM_ENCLOSURE enc ON enc.ResourceID = fcm.ResourceID
            WHERE fcm.CollectionID = @CollectionID
"@, $InsStr2)
        $dbaQuerySplat['Query'] = $QueryDeviceTypeBreakdown
        $DeviceTypeBreakdown = Invoke-DbaQuery @dbaQuerySplat

        $UpdateQuery = [string]::Format(@"
            SELECT sug.Title
                , COUNT(DISTINCT upd.CI_ID) [UpdateCount]
                , sugassign.AssignmentName
                , col.MemberCount AS [TargetedCount]
                , summ.CollectionName
                , summ.CollectionID
                , sugassign.UseGMTTimes
                , sugassign.CreationTime
                , sugassign.StartTime
                , sugassign.EnforcementDeadline
                , CASE
                    WHEN summ.DeploymentIntent = 1 THEN 'Required'
                    WHEN summ.DeploymentIntent = 2 THEN 'Available'
                END AS [OfferType]
                , sugassign.OverrideServiceWindows
                , sugassign.RebootOutsideOfServiceWindows
                , sugassign.Assignment_UniqueID
            FROM vSMS_UpdateGroupAssignment sugassign
                    JOIN v_DeploymentSummary summ ON summ.AssignmentID = sugassign.AssignmentID
                    JOIN vCollections col ON col.SiteID = sugassign.CollectionID
                    JOIN v_AuthListInfo sug ON sug.CI_ID = sugassign.AssignedUpdateGroup
                    JOIN vSMS_CIRelation cr ON cr.FromCIID = Sug.CI_ID
                    INNER JOIN fn_ListUpdateCIs(1033) upd ON upd.CI_ID = cr.ToCIID AND cr.RelationType = 1
            WHERE sugassign.Assignment_UniqueID = '{0}'
            GROUP BY sug.Title
                , sugassign.AssignmentName
                , col.MemberCount
                , summ.CollectionName
                , summ.CollectionID
                , sugassign.UseGMTTimes
                , sugassign.CreationTime
                , sugassign.StartTime
                , sugassign.EnforcementDeadline
                , CASE
                    WHEN summ.DeploymentIntent = 1 THEN 'Required'
                    WHEN summ.DeploymentIntent = 2 THEN 'Available'
                END
                , sugassign.OverrideServiceWindows
                , sugassign.RebootOutsideOfServiceWindows
                , sugassign.Assignment_UniqueID
"@, $InsStr3)
        $dbaQuerySplat['Query'] = $UpdateQuery
        $DeployedUpdateInfo = Invoke-DbaQuery @dbaQuerySplat

        $DeploymentType = 'SoftwareUpdate'
        $softwareName = $DeployedUpdateInfo.Title
        $updateCount = $DeployedUpdateInfo.UpdateCount
        $deploymentOfferType = $DeployedUpdateInfo.OfferType
        $isGMT = [bool]$DeployedUpdateInfo.UseGMTTimes
        $AvailableTime = switch ($isGMT) {
            $true {
                Convert-UTCtoLocal -UTCTime $DeployedUpdateInfo.StartTime
            }
            $false {
                $DeployedUpdateInfo.StartTime
            }
        }
        $DeployedAt = switch ($isGMT) {
            $true {
                Convert-UTCtoLocal -UTCTime $DeployedUpdateInfo.CreationTime
            }
            $false {
                $DeployedUpdateInfo.CreationTime
            }
        }
        $enforcementDeadline = switch ($isGMT) {
            $true {
                Convert-UTCtoLocal -UTCTime $DeployedUpdateInfo.EnforcementDeadline
            }
            $false {
                $DeployedUpdateInfo.EnforcementDeadline
            }
        }
        $DeploymentName = $DeployedUpdateInfo.AssignmentName
        $collectionID = $DeployedUpdateInfo.CollectionID
        $collectionName = $DeployedUpdateInfo.CollectionName
        $numberTargeted = $DeployedUpdateInfo.TargetedCount
        $overrideMW = [bool]$DeployedUpdateInfo.OverrideServiceWindows
        $overrideRebootMW = [bool]$DeployedUpdateInfo.RebootOutsideOfServiceWindows
    }
}

#endregion


$TargetedVMs = $DeviceTypeBreakdown.VMCount
$TargetedLaptops = $DeviceTypeBreakdown.LaptopCount
$TargetedDesktops = $DeviceTypeBreakdown.DesktopCount
$availToDeadlineDelta = New-TimeSpan -Start $AvailableTime -End $enforcementDeadline

#region determine if we need to send an alert
$SendEmail = $false
# NOTE - SendSMS implies SendEmail - when SendSMS = $true then an email will be sent as well
$SendSMS = $false

$Reasons = [System.Collections.Generic.List[string]]::new()
$Problems = [System.Collections.Generic.List[string]]::new()

switch -regex ($DeploymentType) {
    '^TaskSequence$' {
        # COMPLETE Task Sequence deployment deadline - desktops and VMs >= 50 during the day then alert
        $TargetedVMsAndDesktops = ($TargetedVMs + $TargetedDesktops)
        if ($TargetedVMsAndDesktops -ge 50 -and $enforcementDeadline.Hour -in (6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17)) {
            $SendSMS = $true
            $Reasons.Add("Daytime Task Sequence deployment to $TargetedVMsAndDesktops VMs and Desktops")
            foreach ($Problem in @('Deadline', 'Targeted VMs', 'Targeted Desktops')) {
                $Problems.Add($Problem)
            }
        }

        # COMPLETE Task Sequence deployment deadline - laptops >= 2000 during the day then alert
        if ($TargetedLaptops -ge 2000 -and $enforcementDeadline.Hour -in (6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17)) {
            $SendSMS = $true
            $Reasons.Add("Daytime Task Sequence deployment to $TargetedLaptops laptops")
            foreach ($Problem in @('Deadline', 'Targeted Laptops')) {
                $Problems.Add($Problem)
            }
        }
    }
    '^SoftwareUpdate$' {
        # COMPLETE Software update deployment - short download time (24 hours) depending on number of targeted VMs
        if ($availToDeadlineDelta.TotalHours -lt 24) {
            if ($TargetedVMs -ge 500 -and $TargetedVMs -lt 1000) {
                $SendEmail = $true
                $Reasons.Add("Software Update deployment with less than 24 hours of download time and $TargetedVMs VMs targeted")
                foreach ($Problem in @('Available Time', 'Deadline', 'Targeted VMs')) {
                    $Problems.Add($Problem)
                }    
            }
            elseif ($TargetedVMs -ge 1000) {
                $SendSMS = $true
                $Reasons.Add("Software Update deployment with less than 24 hours of download time and $TargetedVMs VMs targeted")
                foreach ($Problem in @('Available Time', 'Deadline', 'Targeted VMs')) {
                    $Problems.Add($Problem)
                }    
            }
        }
    }
    '^TaskSequence$|^SoftwareUpdate$|^Application$|^Program$' {
        switch ($true) {
            # COMPLETE ANY deployments to VMs that BYPASS MW that exceeds 500 machines
            (($overrideMW -or $overrideRebootMW) -and $TargetedVMs -ge 500) {
                $Problems.Add('Targeted VMs')
                $SendSMS = $true
                switch ($true) {
                    $overrideMW {
                        $Reasons.Add("$DeploymentType deployment targeting $TargetedVMs VMs with Override MW set")
                        $Problems.Add('Override MW')
                    }
                    $overrideRebootMW {
                        $Reasons.Add("$DeploymentType deployment targeting $TargetedVMs VMs with Override MW for reboots set")
                        $Problems.Add('Override MW for Reboot')
                    }
                }
            }
            # COMPLETE any required deployments DEADLINED between 6am and 5pm EASTERN meeting thresholds
            ($enforcementDeadline.Hour -in (6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17)) {
                if ($numberTargeted -ge $TextThreshold) {
                    $Reasons.Add("$DeploymentType deployment with deadline between 6am and 5pm Eastern and $numberTargeted devices targeted")
                    foreach ($Problem in @('Deadline', 'Targeted Total')) {
                        $Problems.Add($Problem)
                    }    
                    $SendSMS = $true
                }
                elseif ($numberTargeted -ge $EmailThreshold) {
                    $Reasons.Add("$DeploymentType deployment with deadline between 6am and 5pm Eastern and $numberTargeted devices targeted")
                    foreach ($Problem in @('Deadline', 'Targeted Total')) {
                        $Problems.Add($Problem)
                    }    
                    $SendEmail = $true
                }
            }
            # COMPLETE available = deadline AKA download+install at the same time
            ($availableTime -eq $enforcementDeadline) {
                if ($numberTargeted -ge $TextThreshold) {
                    $Reasons.Add("$DeploymentType deployment with available time = deadline time and $numberTargeted devices targeted")
                    foreach ($Problem in @('Available Time', 'Deadline', 'Targeted Total')) {
                        $Problems.Add($Problem)
                    }
                    $SendSMS = $true
                }
                elseif ($numberTargeted -ge $EmailThreshold) {
                    $Reasons.Add("$DeploymentType deployment with available time = deadline time and $numberTargeted devices targeted")
                    foreach ($Problem in @('Available Time', 'Deadline', 'Targeted Total')) {
                        $Problems.Add($Problem)
                    }
                    $SendEmail = $true
                }
                break
            }
            # COMPLETE available and DEADLINE is within 6 hours (normal deployments to anything meeting thresholds)
            ($availToDeadlineDelta.TotalHours -le 6) {
                if ($numberTargeted -ge $TextThreshold) {
                    $Reasons.Add("$DeploymentType deployment with available time and deadline time within 6 hours of eachother and $numberTargeted devices targeted")
                    foreach ($Problem in @('Available Time', 'Deadline', 'Targeted Total')) {
                        $Problems.Add($Problem)
                    }
                    $SendSMS = $true
                }
                elseif ($numberTargeted -ge $EmailThreshold) {
                    $Reasons.Add("$DeploymentType deployment with available time and deadline time within 6 hours of eachother and $numberTargeted devices targeted")
                    foreach ($Problem in @('Available Time', 'Deadline', 'Targeted Total')) {
                        $Problems.Add($Problem)
                    }
                    $SendEmail = $true
                }
                break
            }
        }
    }
}
#endregion determine if we need to send an alert


#region Create HTML email body
$header = @"
<html><head>
<style type=""text/css"">
	.TFtable{
		width:100%;
		border-collapse:collapse;
	}
	.TFtable td{
		padding:7px; border:#4e95f4 1px solid;
	}
	/* provide some minimal visual accomodation for IE8 and below */
	.TFtable tr{
		background: #b8d1f3;
	}
	/*  Define the background color for all the ODD background rows  */
	.TFtable .oddrowcolor{
		background: #b8d1f3;
	}
	/*  Define the background color for all the EVEN background rows  */
	.TFtable .evenrowcolor{
		background: #dae5f4;
    }
	/*  Define the background color for all the PROBLEMATIC rows  */
	.TFtable .problemColor{
		background: #C20000;
    }
</style>
</head><body>
"@
$script:bodyHTML = '<table class="TFtable">'
$global:rowcount = 0

$PSDefaultParameterValues['AddBodyItem:Problems'] = $Problems

foreach ($Reason in $Reasons) {
    AddBodyItem -name "Alert Reason" -value $Reason
}
AddBodyItem -name "$DeploymentType Name" -value $softwareName
switch -regex ($DeploymentType) {
    '^TaskSequence$' {
        AddBodyItem -name "Note" -value "Package size is a sum of ALL TS References"
    }
    '^Application$|^Program$|^TaskSequence$' {
        AddBodyItem -name "Package Size" -value $packageSize
        $SizeMetric = $PackageSize
    }
    '^SoftwareUpdate$' {
        AddBodyItem -name "Update Count" -value $updateCount
        $SizeMetric = "$updateCount updates"
    }
}
AddBodyItem -name "Targeted Total" -value $numberTargeted
AddBodyItem -name "Targeted VMs" -value $TargetedVMs
AddBodyItem -name "Targeted Laptops" -value $TargetedLaptops
AddBodyItem -name "Targeted Desktops" -value $TargetedDesktops
AddBodyItem -name "Collection Name" -value $CollectionName
AddBodyItem -name "Collection ID" -value $collectionID
AddBodyItem -name "DeploymentID" -value $InsStr2
AddBodyItem -name "Deployment Name" -value $DeploymentName
AddBodyItem -name "Deployed At" -value $DeployedAt
if ($PSCmdlet.ParameterSetName -eq 'Program') {
    if ($IsAvailableEnforced -and $null -ne $availableTime) {
        AddBodyItem -name "Available Time" -value $availableTime
    }
    else {
        AddBodyItem -name "Available Time" -value '[Not Available - only deadlined]'
    }
}
elseif ($PSCmdlet.ParameterSetName -ne 'Program' -and $null -ne $availableTime) {
    AddBodyItem -name "Available Time" -value $availableTime
}
if ($null -ne $enforcementDeadline) {
    AddBodyItem -name "Deadline" -value $enforcementDeadline
}
AddBodyItem -name "Override MW" -value $overrideMW
AddBodyItem -name "Override MW for Reboot" -value $overrideRebootMW
if (-not [string]::IsNullOrWhiteSpace($schedTokens)) {
    $tokenIndex = 1
    $allSchedules = ConvertFrom-CCMSchedule -ScheduleString $schedTokens
    foreach ($sched in $allSchedules) {
        AddBodyItem -Name "Schedule $(($tokenIndex++))" -value $sched.Description
    }
}
AddBodyItem -name "User ID" -value $InsStr1
AddBodyItem -name "Workstation" -value $MachineName
$script:bodyHTML += "</table></body></html>"
$body = $header + $script:bodyHTML
#endregion

#region Create short text body
$InsStr1Parts = ([string]$InsStr1).Split("\")
$MachineNameParts = ([string]$MachineName).Split(".")
$bodyShort = @"
Package $softwareName [$SizeMetric]
Targets $numberTargeted
ID $InsStr2
User $($InsStr1Parts[-1])
Wkstn $($MachineNameParts[0])
"@
#endregion

# TODO Consider conditions for disabling deployment


#region Conditional Send
if ($deploymentOfferType -eq 'Required') {
    if ($SendSMS) {
        Send-MailMessage @mailMessageSplat -To $textAlertList -Subject 'MEMCM' -Body $bodyShort
        Send-MailMessage @mailMessageSplat -To $alertList -Subject "MEMCM $DeploymentType Deployment Alert - $softwareName" -Body $body -BodyAsHtml
    }
    elseif ($SendEmail) {
        Send-MailMessage @mailMessageSplat -To $alertList -Subject "MEMCM $DeploymentType Deployment Alert - $softwareName" -Body $body -BodyAsHtml
    }
}
#endregion