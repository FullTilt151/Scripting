<#
$SiteServer = '\`d.T.~Vb/{29DB4FCF-9969-49BA-AE37-FD8581475AC9}\`d.T.~Vb/'
$CollectionID = '\`d.T.~Ed/{0E13A69D-CAA2-4FF6-8514-4AC9E49CA0C2}.DNRCollectionID\`d.T.~Ed/'
$ApplicationName = '\`d.T.~Ed/{95C7F85D-D818-4927-AF43-BA529508C047}.PackageID/Application Name\`d.T.~Ed/'
$ProgramName = '\`d.T.~Ed/{95C7F85D-D818-4927-AF43-BA529508C047}.ProgramName/Purpose\`d.T.~Ed/'
$Purpose = '\`d.T.~Ed/{95C7F85D-D818-4927-AF43-BA529508C047}.Purpose\`d.T.~Ed/'
$RequiredTime= '\`d.T.~Ed/{95C7F85D-D818-4927-AF43-BA529508C047}.RequiredTime\`d.T.~Ed/'
$AvailableTime = '\`d.T.~Ed/{95C7F85D-D818-4927-AF43-BA529508C047}.AvailableTime\`d.T.~Ed/'
#>

$SiteServer = 'LOUAPPWPS875'
$CollectionID = 'CAS02515'
$ApplicationName = 'System Center Configuration Manager Cmdlet Library 5.00.8328.1155'
$ProgramName = 'Install'
$Purpose = 'Available (Pull)'
$RequiredTime= '2/1/2016 08:00:00AM'
$AvailableTime = Get-Date

Function New-CMNApplicationDeployment
{
    PARAM
    (
        [Parameter(Mandatory=$true)]
        [String]$CollectionID,
        [Parameter(Mandatory=$true)]
        [String]$ApplicationName,
        [Parameter(Mandatory=$true,HelpMessage='Install or Uninstall')]
        [String]$Purpose,
        [Parameter(Mandatory=$true,HelpMessage='Available/Required')]
        [String]$OfferType,
        [Parameter(Mandatory=$false)]
        [String]$EnforcementDeadline
    )

    $Query = "SELECT * FROM SMS_Application WHERE LocalizedDisplayName = '$ApplicationName'"
    $Application = Get-WmiObject -ComputerName $SiteServer -Namespace root/sms/site_$SiteCode -Query $Query

    $Query = "Select * from SMS_ApplicationAssignment where TargetCollectionID = '$CollectionID' and AssignedCIs = '$($Application[$Application.count - 1].CI_ID)'"
    $Deployments = Get-WmiObject -ComputerName $SiteServer -Namespace root/SMS/Site_$SiteCode -Query $Query
    if($Deployments)
    {
        Throw "Already a deployment to that collection"
    }
    else
    {
        $Query = "select * from SMS_Collection where CollectionID = '$CollectionID'"
        $Collection = Get-WmiObject -ComputerName $SiteServer -Namespace root/sms/site_$SiteCode -Query $Query

        $ApplicationAssignmentClass = [wmiclass] "\\$SiteServer\root\SMS\SITE_$($SiteCode):SMS_ApplicationAssignment"
        $newApplicationAssingment = $ApplicationAssignmentClass.CreateInstance()
        $newApplicationAssingment.ApplicationName = $Application[$Application.count - 1].localizedDisplayName
        $newApplicationAssingment.AssignmentName = "$($Application[$Application.count - 1].LocalizedDisplayName) to $($Collection.Name)"
        $newApplicationAssingment.AssignedCIs = $Application[$Application.count - 1].CI_ID
        $newApplicationAssingment.AssignmentType = 2
        $newApplicationAssingment.AssignmentDescription = 'Created by Orcestrator'
        $newApplicationAssingment.CollectionName = $Collection.Name
        $newApplicationAssingment.CreationTime = $newApplicationAssingment.ConvertFromDateTime($(Get-Date))
        $newApplicationAssingment.LocaleID = 1033
        $newApplicationAssingment.SourceSite = $SiteCode
        $newApplicationAssingment.StartTime = $newApplicationAssingment.ConvertFromDateTime($(Get-Date))
        $newApplicationAssingment.SuppressReboot = $true
        $newApplicationAssingment.NotifyUser = $true
        $newApplicationAssingment.TargetCollectionID = $($Collection.CollectionID)
        $newApplicationAssingment.WoLEnabled = $false
        $newApplicationAssingment.RebootOutsideOfServiceWindows = $false
        $newApplicationAssingment.OverrideServiceWindows = $false
        $newApplicationAssingment.UseGMTTimes = $false
        if($OfferType -match 'Available')
        {
            $newApplicationAssingment.OfferTypeID = 2
        }
        else
        {
            $newApplicationAssingment.OfferTypeID = 0
            $newApplicationAssingment.EnforcementDeadline = $newApplicationAssingment.ConvertFromDateTime($EnforcementDeadline)
        }

        [void] $newApplicationAssingment.Put()
        Return $newApplicationAssingment.AssignmentID
    }
}

try
{
	$Error.Clear()
	$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode
}
catch [System.exception]
{
    throw "Unable to connect to $SiteServer"
}

New-CMNApplicationDeployment $CollectionID $ApplicationName $ProgramName $Purpose $RequiredTime