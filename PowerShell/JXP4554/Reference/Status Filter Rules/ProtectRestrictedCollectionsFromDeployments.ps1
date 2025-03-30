<#
.DESCRIPTION
   Sends email alerts if required packages are sent to a certain number of targets
.EXAMPLE
   ProtectRestrictedCollectionsFromDeployments.ps1 %sc  %sitesvr  %msgis01  %msgis02  %msgis03  %msgis04  %msgsys
   F:\scripts\ProtectRestrictedCollections.cmd 
#>

#region Email Lists and Constants

$global:SMTPServer = "pobox.humana.com"
$global:SMTPSender = "no-reply@humana.com"

#The lower threshold
$EmailAlertLimit = 2500

#The higher threshold
$TextAlertLimit = 5000 

$alertList = @(
"dratliff@humana.com",
"jparris@humana.com",
"jluckey@humana.com",
"shublar@humana.com",
"jmattingly3@humana.com",
"ohouston@humana.com",
"jerryb@humana.com",
"dbramer@humana.com"
)

# Verizon = @vtext.com
# Sprint = @messaging.sprintpcs.com
# AT&T = @txt.att.net

$textAlertList = @(
"5028076382@vtext.com",
"5027275150@messaging.sprintpcs.com",
"5023869047@txt.att.net",
"5022356967@txt.att.net",
"5023774480@vtext.com",
"5027974242@txt.att.net"
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

#endregion

#region Gather Deployment Information
$advertisement = Get-WmiObject -ComputerName $SiteServer -Namespace "root\sms\site_$SiteCode" -class sms_advertisement -Filter "advertisementid = '$deploymentID'"
if($advertisement -ne $null){
    $deploymentOfferType = $OfferTypes[$($advertisement.OfferType)]
    $IsAvailableEnforced = [bool]($advertisement.PresentTimeEnabled)
    $adv1 = [wmi]"$($advertisement.__PATH)"
    $deployAssignmentDates = @()
    $schedTokens = $adv1.AssignedSchedule
    foreach($sched in $schedTokens) {
    $deployAssignmentDates += ([string]$sched.StartTime).Substring(0,12)
}
    $deployAssignmentDates | Sort-Object -OutVariable deployAssignmentDates | Out-Null
    $deploymentTime = ConvertDateString -DateTimeString "$($deployAssignmentDates[0])"
}

$deploymentSummary = Get-WmiObject -ComputerName $SiteServer -Namespace "root\sms\site_$SiteCode" -class sms_deploymentsummary -Filter "deploymentid = '$deploymentID'"

$softwareName = $deploymentSummary.SoftwareName

$availableTime = ConvertDateString -DateTimeString "$($deploymentSummary.DeploymentTime)"

$collectionID = $deploymentSummary.CollectionID

$numberTargeted = (Get-WmiObject -ComputerName $SiteServer -Namespace "root\sms\site_$($SiteCode)" -Query "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='$($collectionID)'" | Measure-Object).count

$featureType = $FeatureTypes[$($deploymentSummary.FeatureType)]

#Gather deployed object information based on what was deployed
switch ($featureType)
    {
        "Program" {
            $packageID = $deploymentSummary.PackageID
            $package = Get-WmiObject -ComputerName $SiteServer -Namespace "root\sms\site_$SiteCode" -class sms_package -Filter "packageid = '$packageID'"
            $packageSize = "$([math]::Round(($package.PackageSize / 1024), 1)) MB"
        }
        "Application" {
            
            
            $CI_ID = $deploymentSummary.CI_ID
            $application = Get-WmiObject -ComputerName $SiteServer -Namespace "root\sms\site_$SiteCode" -class sms_applicationlatest -Filter "ci_id = $($CI_ID)"
            $ModelName = $application.ModelName

            $objContentInfo = Get-WmiObject -ComputerName $SiteServer -Namespace "root\sms\site_$SiteCode" -class sms_objectcontentinfo -Filter "objectid = '$($ModelName)'"
            $objContentInfo | ForEach-Object {        
                $SUMFileSize += ($_).SourceSize
                $packageID = $objContentInfo.PackageID
            }
            $packageSize = "$([math]::Round(($SUMFileSize / 1024), 1)) MB"
        }
        "SoftwareUpdate" {
            $updateGroupAssignment = Get-WmiObject -ComputerName $SiteServer -Namespace "root\sms\site_$SiteCode" -class sms_updategroupassignment -Filter "assignmentuniqueid = '$deploymentID'"
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
            $tasksequence = Get-WmiObject -ComputerName $SiteServer -Namespace "root\sms\site_$SiteCode" -class sms_tasksequencepackage -Filter "packageid = '$packageID'"
            $packageSize = "N/A"
        }
    }
    $packagesizeflat = $packagesize.Replace(" MB","")
#endregion

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
"@
#endregion

#region Conditional Send
if ($deploymentOfferType -eq "Required"){
    if ($numberTargeted -ge $TextAlertLimit){
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