# This script is designed to make comparisons between all softwareupdate deployment packages and all
# software update groups.
#
# Each software update deployment package will be scanned against all configured software update
# groups and where an update remains in a given deployment package that is not a part of any
# software update group then that update will be removed from the deployment package.  After
# a given update deployment package completes processing and if there are deletions detected for
# the software update group then the package will be updated to all associated distribution points.
# Note:  It is very easy to reconfigure the script to NOT update the distribution points - see comments 
# in script.
#
# In addition, each software update group will be scanned against all configured software update
# deployment packages.  Where an update is found to exist in an update group but not in a deployment
# package the update will be called out for potential administrative action.
# Note:  This script will not add software updates to a deployment package if they are missing.  That
# action should be handled by an administrator to ensure proper deployment packages are selected for a
# given update or group.  In addition, this script assumes that only software update groups are being
# leveraged for deployment of updates to the environment.  If an update has been deployed individually
# without being included in a software update group then this script will consider such an update as a 
# candidate for deletion fromt the update deployment package.
#
# Note that in ConfigMgr 2012 when an update is removed from a deployment package the source content for
# the update is automatically removed as well so no specific handling to remove source content is used in
# the script.

Param(
    [Parameter(Mandatory = $true)]
    $SiteProviderServerName
    )

Function New-LogEntry {
    # Writes to the log file
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [STRING] $Entry,
        
        [Parameter(Position=1,Mandatory=$False)]
        [INT32] $type = 1,

        [Parameter(Position=2,Mandatory=$False)]
        [STRING] $component = $ScriptName
        )

        if ($Entry.Length -eq 0)
        {
            $Entry = 'N/A'
        }
        $TZOffset = ([TimeZoneInfo]::Local).BaseUTcOffset.TotalMinutes
        $TZOffset = "$(Get-Date -Format "HH:mm:ss.fff")+$(-$TZOffset)"
        $Entry = "<![LOG[{0}]LOG]!><time=""{2}"" date=""{1}"" component=""{5}"" context="""" type=""{4}"" thread=""{3}"">" -f $Entry, (Get-Date -Format "MM-dd-yyyy"), $TZOffset, $pid, $type, $component
        $Entry | Out-File $LogFile -Append -Encoding ascii
}


$ScriptName = $MyInvocation.MyCommand.Name
$LogFile = $ScriptName -replace '(.*)\.ps1', '$1'
$LogFile = 'C:\Temp\' + $LogFile + '.log'

New-LogEntry 'Starting Script'

# Connect to discovered top level site
$SiteCode = $(Get-WmiObject -ComputerName $SiteProviderServerName -Namespace root\SMS -Class SMS_ProviderLocation).SiteCode
Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')
Push-Location
cd $SiteCode":"

New-LogEntry "SiteProviderServerName - $SiteProviderServerName"
New-LogEntry "SiteCode - $SiteCode"

New-LogEntry "Retrieve all software update deployment packages and softare update groups" 1 "MaintenanceSoftwareUpdateGroupDeploymentPackages"
$SoftwareUpdateDeploymentPackages = Get-CMSoftwareUpdateDeploymentPackage
$SoftwareUpdateGroups = Get-cmsoftwareupdategroup

# Declare hashtables that will be used to keep track of items for comparison and various arrays that will hold 
# temporary values during processing.
$HTUpdateGroupsandUpdates = @{}
$HTUpdateGroupsandUpdatestoRemove = @{}
$HTUpdateDeploymentPackagesandUpdates = @{}
$HTUpdateDeploymentPackagesandUpdatestoRemove = @{}
$TempArray = @()
$TempDepPkgCIRemovalArray = @()
$TempUpdGrpCIRemovalArray = @()
$TempPkgCIArray = @()
$TempUpdCIArray = @()

# Pull and store a list of all configuration items for each deployment package in a hash table.
New-LogEntry "Pull and store a list of all configuration items for each deployment package in a hash table." 1 "MaintenanceSoftwareUpdateGroupDeploymentPackages"
ForEach ($DeploymentPackage in $SoftwareUpdateDeploymentPackages)
{
    New-LogEntry "Building list from $($DeploymentPackage)." 1 "BuildList"
    # Need to convert the Package ID from the deployment package object to a string
    $PkgID = [System.Convert]::ToString($DeploymentPackage.PackageID)
    # The query pulls a list of all software updates in the current package.  This query doesn't
    # pull back a clean value so will store it and then manipulate the string to just get the CI
    # information we need a bit later.
    $Query="SELECT DISTINCT su.* FROM SMS_SoftwareUpdate AS su JOIN SMS_CIToContent AS cc ON  SU.CI_ID = CC.CI_ID JOIN SMS_PackageToContent AS  pc ON pc.ContentID=cc.ContentID  WHERE  pc.PackageID='$PkgID' AND su.IsContentProvisioned=1 ORDER BY su.DateRevised Desc"
    $QueryResults=@(Get-WmiObject -ComputerName $SiteProviderServerName -Namespace root\sms\site_$($SiteCode) -Query $Query)

    # Work one by one through every CI that is part of the package adding each to the array to be
    # stored in the hash table.
    ForEach ($CI in $QueryResults)
    {
        # Need to convert the CI information to a string
        $IndividualCIinDeploymentPackage = [System.Convert]::ToString($CI)
        # Since the converted string has more text than just the CI value need to
        # manipulate it to strip off the unneeded parts.
        $Index = $IndividualCIinDeploymentPackage.IndexOf("=")
        $IndividualCIinDeploymentPackage = $IndividualCIinDeploymentPackage.remove(0, ($Index + 1))
        New-LogEntry "CI $($IndividualCIinDeploymentPackage)" 1 "QueryResults"
        $TempPkgCIArray += $IndividualCIinDeploymentPackage
    }
    # Add the entry to the hashtable in the format (DeploymentPackageName, Array of CI values) and then
    # reset the array for the next batch of values.
    $HTUpdateDeploymentPackagesandUpdates.Add($DeploymentPackage.Name, $TempPkgCIArray)
    $TempPkgCIArray = @()
}

# Pull and store a list of all configuration items for each software update group in a hash table.

New-LogEntry "Pull and store a list of all configuration items for each software update group in a hash table." 1 "MaintenanceSoftwareUpdateGroupDeploymentPackages"

ForEach ($UpdateGroup in $SoftwareUpdateGroups)
{
    # Work one by one through every CI that is part of the update group adding each to the array to be
    # stored in the hash table.
    ForEach ($UpdateID in $UpdateGroup.Updates)
    {
        $TempUpdCIArray += $UpdateID 
    }
    # Add the entry to the hashtable in the format (SoftwareUpdateGroupName, Array of CI values) and then
    # reset the array for the next batch of values.
    $HTUpdateGroupsandUpdates.Add($UpdateGroup.LocalizedDisplayName, $TempUpdCIArray)
    $TempUpdCIArray = @()
}

New-LogEntry "Check Deployment Packages to see if there are any updates that are not currently in an update group." 1 "MaintenanceSoftwareUpdateGroupDeploymentPackages"
# Start by examining each package in the hashtable.
foreach($Package in $HTUpdateDeploymentPackagesandUpdates.Keys)
{
    New-LogEntry "Checking $Package" 1 "MaintenanceSoftwareUpdateGroupDeploymentPackages"
    # Loop through each CI that has been stored in the array associated with the deployment package
    # entry and compare to see if there is a matching item in any of the software update groups.
    foreach($PkgCI in $HTUpdateDeploymentPackagesandUpdates["$Package"])
    {
        # Flag variable to note whether a match has occurred.  Reset for every loop of a new
        # CI being tested.
        $PkgCIMatch = $false 
        # Now loop through the array of CI's in software update group hashtable and see if a match
        # is detected in any of them.
        foreach($UpdGrpCI in $HTUpdateGroupsandUpdates.Values)
        {
            # This final loop tests individual CI's inside the array pulled from the software updates 
            # group hashtable.
            foreach ($UpdCI in $UpdGrpCI)
            {
                # If a match is detected break out of the loop and move on to the next CI.  Set the
                # PkgCIMatch flag variable to $true indicating a match.
                if ($PkgCI -eq $UpdCI)
                {
                    $PkgCIMatch=$true
                    break
                }
            }
        }
        # If no match is detected then that means there is an update CI in the deployment package that is not
        # found in any software update group.  This update needs to be added to another hash table that will 
        # be used to track updates that need further handling.  The flag variable is not reset here because it
        # is already false.  Note also that no adition is made to the hashtable here becasuse the inner loop
        # needs to fully complete and the flag variable remain false in order to meet the conditions to be added
        # to the hashtable.
        If ($PkgCIMatch -eq $false)
        {
            New-LogEntry "Package $PkgCI will be removed" 1 "MaintenanceSoftwareUpdateGroupDeploymentPackages"
            $TempDepPkgCIRemovalArray += $PkgCI
        }
        $PkgCIMatch = $false
    }
    # Add the package and any mismatched CI's to the hash table for further processing and reinitilize the temporary
    # array for the next pass.
    $HTUpdateDeploymentPackagesandUpdatestoRemove.Add($Package, $TempDepPkgCIRemovalArray)
    # Reinitialize the array for the next pass.
    $TempDepPkgCIRemovalArray = @()
}

New-LogEntry "Check Software Update groups to see if there are any updates that are not currently in a deployment package.." 1 "MaintenanceSoftwareUpdateGroupDeploymentPackages"
# Start by examining each updategroup in the hashtable.
foreach($UpdateGroup in $HTUpdateGroupsandUpdates.Keys)
{
    New-LogEntry "Checking $UpdateGroup." 1 "MaintenanceSoftwareUpdateGroupDeploymentPackages"
    # Loop through each CI that has been stored in the array associated with the software update group
    # and compare to see if there is a matching item in any of the deployment packages.
    foreach($UpdCI in $HTUpdateGroupsandUpdates["$UpdateGroup"])
    {
        # Flag variable to note whether a match has occurred.  Reset for every loop of a new
        # CI being tested.
        $UpdCIMatch = $false
        # Now loop through the array of CI's in software update deployment package hashtable and see if a match
        # is detected in any of them.
        foreach($PkgCI in $HTUpdateDeploymentPackagesandUpdates.values)
        {
            # This final loop tests individual CI's inside the array pulled from the software updates deployment
            # package hashtable.
            foreach ($CI in $PkgCI)
            {
                # If a match is detected break out of the loop and move on to the next CI.  Set the
                # PkgCIMatch flag variable to $true indicating a match.
                if ($UpdCI -eq $CI)
                {
                    $UpdCIMatch=$true
                    break
                }
            }
        }
        # If no match is detected then that means there is a CI in the software update group that is not
        # found in any deployment package.  This update needs to be added to another hash table that will 
        # be used to track updates that need further handling.  The flag variable is not reset here because it
        # is already false.  Note also that no adition is made to the hashtable here becasuse the inner loop
        # needs to fully complete and the flag variable remain false in order to meet the conditions to be added
        # to the hashtable.
        If ($UpdCIMatch -eq $false)
        {
            New-LogEntry "Found $UpdCI" 1 "MaintenanceSoftwareUpdateGroupDeploymentPackages"
            $TempUpdGrpCIRemovalArray += $UpdCI
        }
        $UpdCIMatch = $false
    }
    $HTUpdateGroupsandUpdatestoRemove.Add($UpdateGroup, $TempUpdGrpCIRemovalArray)
    # Reinitialize array for next loop.
    $TempUpdGrpCIRemovalArray = @()
}


# Have seen some discussion that the removecontent method may error erroneously sometimes so setting to
# silently continue in that section just in case.
$ErrorActionPreference = "Continue"

# No process any remove hashtables that were created and remove updates that are part of a deployment package 
# but not part of any update group.
# Start looping through by package.
New-LogEntry "Start looping through by package." 1 "MaintenanceSoftwareUpdateGroupDeploymentPackages"
foreach ($Package in $HTUpdateDeploymentPackagesandUpdatestoRemove.Keys)
{
    # Reinitialize the array
    $ContentIDArray = @()
    # Check to verify there are CI's in the array associated to the package.  If no CI's then break and continue
    # loop.
    If ($HTUpdateDeploymentPackagesandUpdatestoRemove["$Package"] -ne $Null)
    {
        # Retrieve the specific package from WMI
        $GetPackage = Get-WmiObject -ComputerName $SiteProviderServerName -Namespace root\sms\site_$($SiteCode) -Class SMS_SoftwareUpdatesPackage -Filter "Name ='$Package'"
        # Content removal is done by Content ID and NOT by CI_ID.
        # Declare an array to hold ContentIDs associated with each CI associated with the package.
        $ContentIDArray = @()
        # Loop through each CI associated with the package in the hashtable
        foreach($PkgCI in $HTUpdateDeploymentPackagesandUpdatestoRemove["$Package"])
        {
            # Retrieve the Content ID associated with each CI and store the value in the ContentID array just created.
            $ContentIDtoContent = Get-WMIObject -ComputerName $SiteProviderServerName -NameSpace root\sms\site_$($SiteCode) -Class SMS_CItoContent -Filter "CI_ID='$PkgCI'"
            $ContentIDArray += $ContentIDtoContent.ContentID
        }
        # Call the RemoveContent method on the SMS_SoftwareUpdatesPackage WMI class to remove the content from the specific
        # deployment package currently being processed.  This removal will remove the CI from the deployment package and will
        # also delete the source files from the source directory.
        write-host "Processing package " $Package " and removing these Content IDs " $ContentIDArray
        $GetPackage.RemoveContent($ContentIDArray,$true)
        $ContentIDArray = @()
    }
}

# Resetting for normal error handling
$ErrorActionPreference = "Stop"

# List updates that are part of an update group but not part of any deployment package
# This is similar to the above loops but much easier since there is no content removal.
foreach ($UpdateGroup in $HTUpdateGroupsandUpdatestoRemove.Keys)
{
    If ($HTUpdateGroupsandUpdatestoRemove["$UpdateGroup"] -ne $Null)
    {
        foreach($UpdCI in $HTUpdateGroupsandUpdatestoRemove["$UpdateGroup"])
        {
            write-host "CI ID $UpdCI is in software update group $UpdateGroup but is not in any software update deployment package!"
        }
    }
}

New-LogEntry 'Finished script'
Pop-Location