<#
.DESCRIPTION
   Does not let any deployments go to a collection limited by All Systems or any required deployments to collections in the limiting collections folder.
   It will send out notification if the deployment is a task sequence, or if the deployment is going to a collection of more that 2500 machines.

.PARAMETER SiteCode
    Site code for site

.PARAMETER SiteServer
    Site Server

.PARAMETER UserID

.PARAMETER deploymentID

.PARAMETER deploymentName

.PARAMETER ProgramName

.PARAMETER WorkstationID

.EXAMPLE
   Check-LimitingCollectionForDeployment.ps1 %sc  %sitesvr  %msgis01  %msgis02  %msgis03  %msgis04  %msgsys
   F:\scripts\Check-LimitingCollectionForDeployment.cmd 
#>

#Begin Function EmailAlert 
Function EmailAlert($to, $subject, $body, $IsHtml)
{
    if($IsHtml)
    {
        Send-MailMessage -To $to -From $global:SMTPSender -SmtpServer $global:SMTPServer -Subject $subject -Body $body -BodyAsHtml -Priority High
    }
    else 
    {
        Send-MailMessage -To $to -From $global:SMTPSender -SmtpServer $global:SMTPServer -Subject $subject -Body $body
    }
}
#End Function EmailAlert 

#Begin Function Add-BodyItem
Function Add-BodyItem($name, $value)
{
    $global:rowcount ++
    if((($global:rowcount) % 2) -eq 0)
    {
        $class = "evenrowcolor"
    }
    else
    {
        $class = "oddrowcolor"
    }
    $global:bodyHtml += "<tr class=""$($class)""><td>$($name)<td>$($value)</td></tr>"
}
#End Function Add-BodyItem

#Begin New-LogEntry Function
Function New-LogEntry 
{
    # Writes to the log file
    Param
    (
        [Parameter(Position=0,Mandatory=$true)]
        [String] $Entry,
               
        [Parameter(Position=1,Mandatory=$false)]
        [INT32] $type = 1,
       
        [Parameter(Position=2,Mandatory=$false)]
        [String] $component = $ScriptName
    )
    Write-Verbose $Entry
    if ($type -ge $Script:LogLevel)
    {
        if ($Entry.Length -eq 0)
        {
            $Entry = 'N/A'
        }
        $TZOffset = ([TimeZoneInfo]::Local).BaseUTcOffset.TotalMinutes
        $TZOffset = "$(Get-Date -Format "HH:mm:ss.fff")+$(-$TZOffset)"
        $Entry = "<![LOG[{0}]LOG]!><time=""{2}"" date=""{1}"" component=""{5}"" context="""" type=""{4}"" thread=""{3}"">" -f $Entry, (Get-Date -Format "MM-dd-yyyy"), $TZOffset, $pid, $type, $component
        $Entry | Out-File $Script:LogFile -Append -Encoding ascii
    }
}
#End New-LogEntry

#Begin Function Convert-DateString
Function Convert-DateString
{
    PARAM
    (
        [PARAMETER(Mandatory=$true)]
        [string]$DateTimeString
    )
    $format = "yyyyMMddHHmm"
    $return = [datetime]::ParseExact(([string]($DateTimeString.Substring(0,12))), $format, $null).ToString()
    return $return
}
#End Function Convert-DateString

#Begin Function Get-DeploymentInfo
Function Get-DeploymentInfo
{
    PARAM
    (
        [PARAMETER(Mandatory=$true)]
        [String]$DeploymentID
    )

    #Begin Variable Definintions
    $WMIQueryParameters = @{
        ComputerName = $SiteServer
        Namespace = "root\sms\site_$SiteCode"
    }
    $OfferTypes = @("Required", "Not Used", "Available")
    $FeatureTypes = @("None","Application","Program","MobileProgram","Script","SoftwareUpdate","Baseline","TaskSequence","ContentDistribution","DistributionPointGroup","DistributionPointHealth","ConfigurationPolicy")
    $DeploymentInfo = New-Object PSObject
    $DeploymentInfo | Add-Member -MemberType NoteProperty -Name DeploymentID -Value $DeploymentID
    #End Variable Definitions

    $Advertisement = Get-WmiObject -class sms_advertisement -Filter "advertisementid = '$DeploymentID'" @WMIQueryParameters
    New-LogEntry "SMS_Advertismenet ID $DeploymentID = $Advertisement"
    if($Advertisement -ne $null)
    {
        $Advertisement.Get()
        $DeploymentInfo | Add-Member -MemberType NoteProperty -Name OfferType -Value ($OfferTypes[$($Advertisement.OfferType)])
        $DeploymentInfo | Add-Member -MemberType NoteProperty -Name IsAvailableEnforced -Value ([bool]($Advertisement.PresentTimeEnabled))
        $deployAssignmentDates = @()
        $schedTokens = $Advertisement.AssignedSchedule
        foreach($sched in $schedTokens) 
        {
            $deployAssignmentDates += ([string]$sched.StartTime).Substring(0,12)
        }
        $DeployAssignmentDates | Sort-Object -OutVariable deployAssignmentDates | Out-Null
        if ($DeployAssignmentDates) {$DeploymentInfo | Add-Member -MemberType NoteProperty -Name DeploymentTime -Value (Convert-DateString -DateTimeString "$($deployAssignmentDates[0])")}
        $DeploymentSummary = Get-WmiObject -class sms_deploymentsummary -Filter "DeploymentID = '$($DeploymentInfo.DeploymentID)'" @WMIQueryParameters
        $DeploymentInfo | Add-Member -MemberType NoteProperty -Name SoftwareName -Value ($DeploymentSummary.SoftwareName)
        $DeploymentInfo | Add-Member -MemberType NoteProperty -Name AvailableTime -Value (Convert-DateString -DateTimeString "$($DeploymentSummary.DeploymentTime)")
        $DeploymentInfo | Add-Member -MemberType NoteProperty -Name CollectionID -Value $DeploymentSummary.CollectionID
        $DeploymentInfo | Add-Member -MemberType NoteProperty -Name FeatureType -Value $FeatureTypes[$($deploymentSummary.FeatureType)]
    }
    else #Application
    {
        New-LogEntry 'Checking if it is an advertisement'
        $Advertisement = Get-WmiObject -class SMS_ApplicationAssignment -Filter "AssignmentID = '$DeploymentID'" @WMIQueryParameters
        if ($Advertisement -ne $null)
        {
            $Advertisement.Get()
            New-LogEntry "Looks like it's an application"
            New-LogEntry "SMS_ApplicationAssignment $DeploymentID = $Advertisement"
            $DeploymentInfo | Add-Member -MemberType NoteProperty -Name CollectionID -Value ($Advertisement.TargetCollectionID)
            $DeploymentInfo | Add-Member -MemberType NoteProperty -Name SoftwareName -Value ($Advertisement.ApplicationName)
            $DeploymentInfo | Add-Member -MemberType NoteProperty -Name AvailableTime -Value (Convert-DateString -DateTimeString "$($Advertisement.StartTime)")
            $DeploymentInfo | Add-Member -MemberType NoteProperty -Name FeatureType -Value 'Application'
            if ($Advertisement.EnforcementDeadline) 
            {
                $DeploymentInfo | Add-Member -MemberType NoteProperty -Name OfferType -Value 'Required'
                $DeploymentInfo | Add-Member -MemberType NoteProperty -Name DeploymentTime -Value (Convert-DateString -DateTimeString "$($Advertisement.EnforcementDeadline)")
                $DeploymentInfo | Add-Member -MemberType NoteProperty -Name IsAvailableEnforced -Value $true
            }
            else
            {
                $DeploymentInfo | Add-Member -MemberType NoteProperty -Name OfferType -Value 'Available'
                $DeploymentInfo | Add-Member -MemberType NoteProperty -Name IsAvailableEnforced -Value $false
            }
        }
        else #Software Update
        {
            New-LogEntry 'Looks like it''s a software update.'
            $Advertisement = Get-WmiObject -class SMS_UpdateGroupAssignment -Filter "AssignmentID = '$DeploymentID'" @WMIQueryParameters
            New-LogEntry "SMS_UpdateGroupAssignment $DeploymentID = $Advertisement"
            $DeploymentInfo | Add-Member -MemberType NoteProperty -Name CollectionID -Value ($Advertisement.TargetCollectionID)
            $DeploymentInfo | Add-Member -MemberType NoteProperty -Name SoftwareName -Value ($Advertisement.AssignmentName)
            $DeploymentInfo | Add-Member -MemberType NoteProperty -Name AvailableTime -Value (Convert-DateString -DateTimeString "$($Advertisement.StartTime)")
            $DeploymentInfo | Add-Member -MemberType NoteProperty -Name FeatureType -Value 'SoftwareUpdate'
            if ($Advertisement.EnforcementDeadline) 
            {
                $DeploymentInfo | Add-Member -MemberType NoteProperty -Name OfferType -Value 'Required'
            }
            else
            {
                $DeploymentInfo | Add-Member -MemberType NoteProperty -Name OfferType -Value 'Available'
            }
        }
        $DeploymentSummary = Get-WmiObject -class sms_deploymentsummary -Filter "AssignmentID = '$($DeploymentInfo.DeploymentID)'" @WMIQueryParameters
    }
    
    New-LogEntry "Getting ready to do the switch on $($DeploymentInfo.FeatureType)" 
    switch ($DeploymentInfo.FeatureType)
    {
        "Program" {
            New-LogEntry 'It''s a program'
            $DeploymentInfo | Add-Member -MemberType NoteProperty -Name PackageID -Value ($DeploymentSummary.PackageID)
            $package = Get-WmiObject -class sms_package -Filter "packageid = '$($DeploymentInfo.packageID)'" @WMIQueryParameters
            $DeploymentInfo | Add-Member -MemberType NoteProperty -Name PackageSize -Value "$([math]::Round(($package.PackageSize / 1024), 1)) MB"
        }
        "Application" {
            New-LogEntry 'It''s an application'
            $CI_ID = $DeploymentSummary.CI_ID
            $application = Get-WmiObject -class sms_applicationlatest -Filter "ci_id = $($CI_ID)" @WMIQueryParameters
            $ModelName = $application.ModelName

            $objContentInfo = Get-WmiObject @WMIQueryParameters -class sms_objectcontentinfo -Filter "objectid = '$($ModelName)'"
            $objContentInfo | ForEach-Object {        
                $SUMFileSize += ($_).SourceSize
                $packageID = $objContentInfo.PackageID
            }
            $DeploymentInfo | Add-Member -MemberType NoteProperty -Name PackageSize -Value "$([math]::Round(($SUMFileSize / 1024), 1)) MB"
            $DeploymentInfo | Add-Member -MemberType NoteProperty -Name CollectionID -Value (Get-WmiObject @WMIQueryParameters -Class SMS_ApplicationAssignment -Filter "AssignmentID = '$($deploymentID)'" | Select-Object -ExpandProperty TargetCollectionID)
        }
        "SoftwareUpdate" {
            New-LogEntry 'It''s a  software update'
            $updateGroupAssignment = Get-WmiObject -class SMS_UpdateGroupAssignment -Filter "AssignmentID = '$($DeploymentInfo.deploymentID)'" @WMIQueryParameters
            $CIs = $updateGroupAssignment.AssignedCIs
            $CIs | ForEach-Object {
                $ContentID = (Get-WmiObject @WMIQueryParameters -class sms_CIToContent -Filter "ci_id = $($_)").ContentID
                if($ContentID -ne $null){
                    $CIFileSize = (Get-WmiObject @WMIQueryParameters -Class sms_CIContentFiles -Filter "ContentID=$ContentID").FileSize
                    $SUMFileSize += $CIFileSize
                }
            }
            $packageSize = "$([math]::Round(($SUMFileSize / 1024), 1)) MB"
            $DeploymentInfo | Add-Member -MemberType NoteProperty -Name PackageSize -Value "$([math]::Round(($SUMFileSize / 1024), 1)) MB"
        }
        "TaskSequence" {
            New-LogEntry 'It''s a task sequence'
            $DeploymentInfo | Add-Member -MemberType NoteProperty -Name PackageID -Value $deploymentSummary.PackageID
            $tasksequence = Get-WmiObject -class sms_tasksequencepackage -Filter "packageid = '$($DeploymentInfo.PackageID)'" @WMIQueryParameters
            $DeploymentInfo | Add-Member -MemberType NoteProperty -Name PackageSize -Value "N/A"
        }
    }

    $DeploymentInfo | Add-Member -MemberType NoteProperty -Name packagesizeflat -value ($DeploymentInfo.Packagesize.Replace(" MB",""))
    $Query = "SELECT ocn.* FROM `
    SMS_ObjectContainerNode AS ocn JOIN SMS_ObjectContainerItem `
    AS oci ON ocn.ContainerNodeID=oci.ContainerNodeID WHERE `
    oci.InstanceKey='$($DeploymentInfo.CollectionID)'"
    $DeploymentInfo | Add-Member -MemberType NoteProperty -Name CollectionFolderID -Value (Get-WmiObject -Query $Query @WMIQueryParameters | Select-Object -ExpandProperty ContainerNodeID)
    $DeploymentInfo | Add-Member -MemberType NoteProperty -Name TargetCount -Value ((Get-WmiObject @WMIQueryParameters -Query "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='$($DeploymentInfo.CollectionID)'" | Measure-Object).count)
    New-LogEntry "Get-DeploymentInfo returning $DeploymentInfo"
    Return $DeploymentInfo
}
#End Function Get-DeploymentInfo

#Email Lists and Constants

$global:SMTPServer = "pobox.humana.com"
$global:SMTPSender = "ConfigMgrSupport@humana.com"

#This is the threshold, any deployments to more than these machines will cause the 
#deployment to be delayed/expired/disabled and require someone to renable.
$MaxDeviceForDeployment =- 50 

#The lower threshold
$EmailAlertLimit = 2500

#The higher threshold
$TextAlertLimit = 5000 

$alertList = @(
#"dratliff@humana.com",
"jparris@humana.com"
#"jluckey@humana.com",
#"shublar@humana.com",
#"jmattingly3@humana.com",
#"ohouston@humana.com",
#"jerryb@humana.com",
#"MCook9@humana.com",
#"dbramer@humana.com"
)

# Verizon = @vtext.com
# Sprint = @messaging.sprintpcs.com
# AT&T = @txt.att.net

$textAlertList = @(
#"5028076382@vtext.com",
#"5027275150@messaging.sprintpcs.com",
#"5023869047@txt.att.net",
#"5022356967@txt.att.net",
#"5028517555@messaging.sprintpcs.com",
"5023774480@vtext.com"
#"5027974242@txt.att.net"
)

#Get Passed Arguments
$SiteCode = $args[0]
$SiteServer = $args[1]
$UserID = $args[2]
$DeploymentID = $args[3]
$DeploymentName = $args[4]
$ProgramName = $args[5]
$WorkstationID = $args[6]

$WMIQueryParameters = @{
    ComputerName = $SiteServer
    Namespace = "root\sms\site_$SiteCode"
}
$LogLevel = 2
$ScriptName = $MyInvocation.MyCommand.Name
$LogFile = $ScriptName -replace '(.*)\.ps1', '$1'
$LogFile = 'F:\SCCMLogs\' + $LogFile + '.log'
$LimitingFolderID = Get-WmiObject -Class SMS_ObjectContainerNode @WMIQueryParameters | Where-Object {$_.Name -eq 'Limiting Collections'} | Select-Object -ExpandProperty ContainerNodeID

New-LogEntry 'Starting Script'
New-LogEntry "SiteCode - $SiteCode"
New-LogEntry "SiteServer - $SiteServer"
New-LogEntry "UserID - $UserID"
New-LogEntry "DeploymentID - $DeploymentID"
New-LogEntry "DeploymentName - $DeploymentName"
New-LogEntry "ProgramName - $ProgramName"
New-LogEntry "WorkstationID - $WorkstationID"

$Deployment = Get-DeploymentInfo -DeploymentID $DeploymentID
$Deployment | Add-Member -MemberType NoteProperty -Name UserID -Value $UserID
$Deployment | Add-Member -MemberType NoteProperty -Name WorkstationID -Value $WorkstationID

New-LogEntry "LimitingFolderID - $LimitingFolderID"
New-LogEntry "CollectionFolderID = $($Deployment.CollectionFolderID)"
New-LogEntry "OfferType - $($Deployment.OfferType)"
New-LogEntry "IsAvailableEnforced = $($Deployment.IsAvailableEnforced)"
New-LogEntry "CollectionID - $($Deployment.CollectionID)"

#Expire deployment if:
if ($($Deployment.TargetCount) -ge $MaxDeviceForDeployment)
{
    New-LogEntry "Deployment is targeting $($Deployment.TargetCount) machines will be expired"
    $DoExpire = $true
}
else
{
    $DoExpire = $false

    #Deployed to All Systems
    if ($($Deployment.CollectionID -eq 'SMS00001')) 
    {
        New-LogEntry 'Deployed to All Systems, going to expire'
        $DoExpire = $true
    }

    #Deployed as required to a colleciton in the limiting collection folder
    if (($($Deployment.OfferType) -eq 'Required') -and ($($Deployment.CollectionFolderID) -eq $LimitingFolderID)) 
    {
        New-LogEntry 'Deployed as required to a limiting colleciton, going to expire'
        $DoExpire = $true
    }
}
if ($DoExpire)
{
    New-LogEntry "Expiring Deployment - $($Deployment.FeatureType)"
    switch ($($Deployment.FeatureType))
    {
        'Program' {
            New-LogEntry "Getting advertisement info for AdvertisementID $($Deployment.DeploymentID)"
            $Advertisement = Get-WmiObject -Class SMS_Advertisement -Filter "AdvertisementID = '$($Deployment.DeploymentID)'" @WMIQueryParameters
            $advertisement.Get()
            $Advertisement.ExpirationTimeEnabled = $true
            $Advertisement.put()
            $Deployment | Add-Member -MemberType NoteProperty -Name DoExpire -Value $true
            $Deployment | Add-Member -MemberType NoteProperty -Name Notice -Value 'This Package was expired, please notify the person who created it'
            New-LogEntry "Expired $($Deployment.FeatureType) Deployment" 2
        }
        'Application' {
            New-LogEntry "Getting advertisement info for AdvertisementID $($Deployment.DeploymentID)"
            $Advertisement = Get-WmiObject -Class SMS_ApplicationAssignment  -Filter "AssignmentID = '$($Deployment.DeploymentID)'" @WMIQueryParameters
            $Advertisement.Get()
            $Deployment | Add-Member -MemberType NoteProperty -Name DoExpire -Value $true
            $Deployment | Add-Member -MemberType NoteProperty -Name Notice -Value 'Application was delayed 1 year, please notify the person who created it'
            New-LogEntry "Delaying Deployment $($Deployment.FeatureType) for 1 year" 2
            $Advertisement.StartTime = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($([System.Management.ManagementDateTimeConverter]::ToDateTime($Advertisement.StartTime)).AddDays(365)))
            $Advertisement.EnforcementDeadline = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($([System.Management.ManagementDateTimeConverter]::ToDateTime($Advertisement.EnforcementDeadline)).AddDays(365)))
            $Advertisement.Put()
        }
        'TaskSequence' {
            New-LogEntry "Getting advertisement info for AdvertsiementID $($Deployment.DeploymentID)"
            $Advertisement = Get-WmiObject -Class SMS_Advertisement -Filter "AdvertisementID = '$($Deployment.DeploymentID)'" @WMIQueryParameters
            $Advertisement.Get()
            $Advertisement.ExpirationTimeEnabled = $true
            $Advertisement.put()
            $Deployment | Add-Member -MemberType NoteProperty -Name DoExpire -Value $true
            $Deployment | Add-Member -MemberType NoteProperty -Name Notice -Value 'This Task Sequence was expired, please notify the person who created it'
            New-LogEntry "Expired $($Deployment.FeatureType) Deployment" 2
        }
        'SoftwareUpdate' {
            New-LogEntry "Getting advertisement info for AdvertsiementID $($Deployment.DeploymentID)"
            $Advertisement = Get-WmiObject -class SMS_UpdateGroupAssignment -Filter "AssignmentID = '$($Deployment.DeploymentID)'" @WMIQueryParameters
            $Advertisement.Get()
            $Advertisement.Enabled = $false
            $Advertisement.Put()
            $Deployment | Add-Member -MemberType NoteProperty -Name DoExpire -Value $true
            $Deployment | Add-Member -MemberType NoteProperty -Name Notice -Value 'This Software Update was disabled, please notify the person who created it'
            New-LogEntry "Disabling deployment $($Deployment.FeatureType)" 2
        }
    }
}

#Create HTML email body
$global:header = "<html><head>
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
</style>
</head><body>"
$global:bodyHtml = "<table class=""TFtable"">"
$global:rowcount = 0
$Deployment.PSObject.Properties | ForEach-Object{
    if ($($_.Value))
    {
        Add-BodyItem -Name $($_.Name) -Value $($_.Value)
    }
}

$global:bodyHtml += "</table></body></html>"
$body = $global:header + $global:bodyHtml

#Create short text body
$userIDParts = ([string]$UserID).Split("\")
$workstationIDParts = ([string]$workstationID).Split(".")
$bodyShort = @"
Package $($Deployment.SoftwareName) [$($Deployment.PackageSize)]
Targets $($Deployment.TargetCount)
ID $DeploymentID
User $($userIDParts[-1])
Wkstn $($workstationIDParts[0])
Expired $($DoExpire)
"@

#Conditional Send
if (($deploymentOfferType -eq "Required") -or ($DoExpire)) {
    if ($DoExpire)
    {
        EmailAlert -to $textAlertList -subject "SCCM" -body $bodyShort
        EmailAlert -to $alertList -subject "SCCM Expired Deployment - $deploymentID" -body $body -IsHtml $true
    }
    elsif ($numberTargeted -ge $TextAlertLimit)
    {
        EmailAlert -to $textAlertList -subject "SCCM" -body $bodyShort
        EmailAlert -to $alertList -subject "SCCM Large Deployment Alert - $deploymentID" -body $body -IsHtml $true
    }
    elseif ($numberTargeted -ge $EmailAlertLimit){
        EmailAlert -to $alertList -subject "SCCM Large Deployment Alert - $deploymentID" -body $body -IsHtml $true
    }
    elseif ($featureType -eq "TaskSequence"){
        EmailAlert -to $textAlertList -subject "SCCM Req TS!" -body $bodyShort
        EmailAlert -to $alertList -subject "SCCM Required Task Sequence!" -body $body -IsHtml $true
    }
    elseif ($featureType -eq "Application"){
        EmailAlert -to $global:SMTPSender -subject "SCCM Application Deployment Alert - $deploymentID" -body $body -IsHtml $true
    
    }
    elseif ($featureType -eq "SoftwareUpdate" -and $packagesizeflat -gt 99) {
        EmailAlert -to $global:SMTPSender -subject "SCCM Software Update Deployment Alert - $deploymentID" -body $body -IsHtml $true
    }
}