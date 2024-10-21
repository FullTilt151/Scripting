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

#region Function Definitions
function EmailAlert($to, $subject, $body, $IsHtml){
    if($IsHtml){
        Send-MailMessage -To $to -From $global:SMTPSender -SmtpServer $global:SMTPServer -Subject $subject -Body $body -BodyAsHtml -Priority High
    }else {
        Send-MailMessage -To $to -From $global:SMTPSender -SmtpServer $global:SMTPServer -Subject $subject -Body $body
    }
}

function AddBodyItem($name, $value){
    $global:rowcount ++
    if((($global:rowcount) % 2) -eq 0){
        $class = "evenrowcolor"
    }else{
        $class = "oddrowcolor"
    }
    $global:bodyHtml += "<tr class=""$($class)""><td>$($name)<td>$($value)</td></tr>"
}

function ConvertDateString([string]$DateTimeString){
    $format = "yyyyMMddHHmm"
    $return = [datetime]::ParseExact(([string]($DateTimeString.Substring(0,12))), $format, $null).ToString()
    return $return
}

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
#endregion

#region Email Lists and Constants

$global:SMTPServer = "pobox.humana.com"
$global:SMTPSender = "no-reply@humana.com"

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
#endregion

#region Get Passed Arguments
$SiteCode = $args[0]
$SiteServer = $args[1]
$UserID = $args[2]
$deploymentID = $args[3]
$deploymentName = $args[4]
$programName = $args[5]
$workstationID = $args[6]
#endregion

#region Static Array Definitions
$OfferTypes = @("Required", "Not Used", "Available")
$FeatureTypes = @("None",
"Application",
"Program",
"MobileProgram",
"Script",
"SoftwareUpdate",
"Baseline",
"TaskSequence",
"ContentDistribution",
"DistributionPointGroup",
"DistributionPointHealth",
"ConfigurationPolicy")
#endregion

$WMIQueryParameters = @{
    ComputerName = $SiteServer
    Namespace = "root\sms\site_$SiteCode"
}
$LogLevel = 1
$ScriptName = $MyInvocation.MyCommand.Name
$LogFile = $ScriptName -replace '(.*)\.ps1', '$1'
$LogFile = 'F:\SCCMLogs\' + $LogFile + '.log'

New-LogEntry 'Starting Script'
New-LogEntry "SiteCode - $SiteCode"
New-LogEntry "SiteServer - $SiteServer"
New-LogEntry "UserID - $UserID"
New-LogEntry "DeploymentID - $deploymentID"
New-LogEntry "DeploymentName - $deploymentName"
New-LogEntry "ProgramName - $programName"
New-LogEntry "WorkstationID - $workstationID"

#Get Limiting Collections Folder ID

$LimitingFolderID = Get-WmiObject -Class SMS_ObjectContainerNode @WMIQueryParameters | Where-Object {$_.Name -eq 'Limiting Collections'} | Select-Object -ExpandProperty ContainerNodeID

New-LogEntry "LimitingFolderID - $LimitingFolderID"

#region Gather Deployment Information
$advertisement = Get-WmiObject -class sms_advertisement -Filter "advertisementid = '$deploymentID'" @WMIQueryParameters
if($advertisement -ne $null)
{
    $deploymentOfferType = $OfferTypes[$($advertisement.OfferType)]
    $IsAvailableEnforced = [bool]($advertisement.PresentTimeEnabled)
    $adv1 = [wmi]"$($advertisement.__PATH)"
    $deployAssignmentDates = @()
    $schedTokens = $adv1.AssignedSchedule
    foreach($sched in $schedTokens) 
    {
        $deployAssignmentDates += ([string]$sched.StartTime).Substring(0,12)
    }
    $deployAssignmentDates | Sort-Object -OutVariable deployAssignmentDates | Out-Null
    $deploymentTime = ConvertDateString -DateTimeString "$($deployAssignmentDates[0])"
}

$deploymentSummary = Get-WmiObject -class sms_deploymentsummary -Filter "deploymentid = '$deploymentID'" @WMIQueryParameters

$softwareName = $deploymentSummary.SoftwareName

$availableTime = ConvertDateString -DateTimeString "$($deploymentSummary.DeploymentTime)"

$collectionID = $deploymentSummary.CollectionID

$LimitingCollectionID = Get-WmiObject -Class SMS_Collection -Filter "CollectionID = '$CollectionID'" @WMIQueryParameters | Select-Object -ExpandProperty LimitToCollectionID

$Query = "SELECT ocn.* FROM `
    SMS_ObjectContainerNode AS ocn JOIN SMS_ObjectContainerItem `
    AS oci ON ocn.ContainerNodeID=oci.ContainerNodeID WHERE `
    oci.InstanceKey='$collectionID'"
$CollectionFolderID = Get-WmiObject -Query $Query @WMIQueryParameters | Select-Object -ExpandProperty ContainerNodeID
New-LogEntry "CollectionFolderID = $CollectionFolderID"

$numberTargeted = (Get-WmiObject -ComputerName $SiteServer -Namespace "root\sms\site_$($SiteCode)" -Query "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='$($collectionID)'" | Measure-Object).count

$featureType = $FeatureTypes[$($deploymentSummary.FeatureType)]

New-LogEntry "OfferType - $deploymentOfferType"
New-LogEntry "IsAvailableEnforced = $IsAvailableEnforced"

#Gather deployed object information based on what was deployed
switch ($featureType)
{
    "Program" {
        $packageID = $deploymentSummary.PackageID
        $package = Get-WmiObject -class sms_package -Filter "packageid = '$packageID'" @WMIQueryParameters
        $packageSize = "$([math]::Round(($package.PackageSize / 1024), 1)) MB"
    }
    "Application" {
            
            
        $CI_ID = $deploymentSummary.CI_ID
        $application = Get-WmiObject -class sms_applicationlatest -Filter "ci_id = $($CI_ID)" @WMIQueryParameters
        $ModelName = $application.ModelName

        $objContentInfo = Get-WmiObject @WMIQueryParameters -class sms_objectcontentinfo -Filter "objectid = '$($ModelName)'"
        $objContentInfo | ForEach-Object {        
            $SUMFileSize += ($_).SourceSize
            $packageID = $objContentInfo.PackageID
        }
        $packageSize = "$([math]::Round(($SUMFileSize / 1024), 1)) MB"
        $CollectionID = Get-WmiObject @WMIQueryParameters -Class SMS_ApplicationAssignment -Filter "AssignmentID = '$($deploymentID)'" | Select-Object -ExpandProperty TargetCollectionID
    }
    "SoftwareUpdate" {
        $updateGroupAssignment = Get-WmiObject -class sms_updategroupassignment -Filter "assignmentuniqueid = '$deploymentID'" @WMIQueryParameters
        $enforcementDeadline = $updateGroupAssignment.EnforcementDeadline
        if($enforcementDeadline -eq $null){
            $deploymentOfferType = "Available"
        } else {
            $deploymentOfferType = "Required"
            $IsAvailableEnforced = $true
            $deploymentTime = ConvertDateString -DateTimeString "$($enforcementDeadline)"
        }
        $CIs = $updateGroupAssignment.AssignedCIs
        $CIs | ForEach-Object {
            $ContentID = (Get-WmiObject -ComputerName $SiteServer -Namespace "root\sms\site_$SiteCode" -class sms_CIToContent -Filter "ci_id = $($_)").ContentID
            if($ContentID -ne $null){
                $CIFileSize = (Get-WmiObject -ComputerName $SiteServer -Namespace "root\sms\site_$SiteCode" -Class sms_CIContentFiles -Filter "ContentID=$ContentID").FileSize
                $SUMFileSize += $CIFileSize
            }
        }
        $packageSize = "$([math]::Round(($SUMFileSize / 1024), 1)) MB"
    }
    "TaskSequence" {
        $packageID = $deploymentSummary.PackageID
        $tasksequence = Get-WmiObject-class sms_tasksequencepackage -Filter "packageid = '$packageID'" @WMIQueryParameters
        $packageSize = "N/A"
    }
}

$packagesizeflat = $packagesize.Replace(" MB","")
New-LogEntry "CollectionID - $collectionID"
#endregion

#Expire deployment if:
$DoExpire = $false

#Deployed to All Systems
if ($collectionID -eq 'SMS00001') 
{
    New-LogEntry 'Deployed to All Systems, going to expire'
    $DoExpire = $true
}

#Deployed as required to a colleciton in the limiting collection folder
if (($deploymentOfferType -eq 'Required') -and ($CollectionFolderID -eq $LimitingFolderID)) 
{
    New-LogEntry 'Deloyed as required to a limiting colleciton, going to expire'
    $DoExpire = $true
}

if ($DoExpire)
{
    switch ($featureType)
    {
        'Program' {
            New-LogEntry "Getting advertisement info for AdvertisementID $deploymentID"
            $Advertisement = Get-WmiObject -Class SMS_Advertisement -Filter "AdvertisementID = '$deploymentID'" @WMIQueryParameters
            $advertisement.Get()
            $Advertisement.ExpirationTimeEnabled = $true
            $Advertisement.put()
            New-LogEntry 'Expired Deployment'
        }
        'Application' {
            New-LogEntry "Getting advertisement info for AdvertisementID $deploymentID"
            $Advertisement = Get-WmiObject -Class SMS_ApplicationAssignment  -Filter "AssignmentID = '$deploymentID'" @WMIQueryParameters
            $advertisement.Get()
            $Advertisement.Enabled = $false
            $Advertisement.put()
            New-LogEntry 'Expired Deployment'
        }
    }
}

#region Create HTML email body

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
AddBodyItem -name "Target Count" -value $numberTargeted
AddBodyItem -name  "DeploymentID" -value $deploymentID
AddBodyItem -name  "Deployment Name" -value $deploymentName
if($IsAvailableEnforced){
    AddBodyItem -name  "Available Time" -value $availableTime
}else{
    AddBodyItem -name  "Available Time" -value "[Not Enforced]"    
}
AddBodyItem -name  "Deployment Time" -value $deploymentTime
AddBodyItem -name  "Package Name" -value $softwareName
AddBodyItem -name  "Package Size" -value $packageSize
AddBodyItem -name  "CollectionID" -value $collectionID
AddBodyItem -name  "UserID" -value $UserID
AddBodyItem -name  "Workstation" -value $workstationID
AddBodyItem -name  'Expired Deployment' -value $DoExpire
$global:bodyHtml += "</table></body></html>"
$body = $global:header + $global:bodyHtml

#endregion

#region Create short text body
$userIDParts = ([string]$UserID).Split("\")
$workstationIDParts = ([string]$workstationID).Split(".")
$bodyShort = @"
Package $softwareName [$($packageSize)]
Targets $numberTargeted
ID $deploymentID
User $($userIDParts[-1])
Wkstn $($workstationIDParts[0])
Expired $($DoExpire)
"@
#endregion

#region Conditional Send
if (($deploymentOfferType -eq "Required") -or ($DoExpire)) {
    if (($numberTargeted -ge $TextAlertLimit) -or ($DoExpire)){
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
        EmailAlert -to "trussell@humana.com" -subject "SCCM Application Deployment Alert - $deploymentID" -body $body -IsHtml $true
        EmailAlert -to "dratliff@humana.com" -subject "SCCM Application Deployment Alert - $deploymentID" -body $body -IsHtml $true
    
    }
    elseif ($featureType -eq "SoftwareUpdate" -and $packagesizeflat -gt 99) {
        EmailAlert -to "dratliff@humana.com" -subject "SCCM Software Update Deployment Alert - $deploymentID" -body $body -IsHtml $true
        EmailAlert -to "jparris@humana.com" -subject "SCCM Software Update Deployment Alert - $deploymentID" -body $body -IsHtml $true
    }
}
#endregion