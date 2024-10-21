<#
.SYNOPSIS
	This script sets non-repeating maintenance windows for patches that are realtive to Patch Tuesday on collections in a folder based on their name for the current month.

.DESCRIPTION
	This script will get all the collections in a folder, if they match a naming convention of "Patch Day NN ??? Reboot NN:NN AM" it will set a non-repeating maintenance window on the collection.
 
	Considerations:
		The maintenance window will ALWAYS start on the relative day, so if you put Patch Day 01, the maintenance window will start on Patch Tuesday.
		If the reboot time is at 3:00am and you are using a 4 hour MaintenanceWindowDurration, the window will start on the relative day and reboot 
		at 3:00am on the FOLLOWING day.
		I confess I haven't tried every possible combination for the collection names, so errors could result, but if you follow the pattern shown here, you should be succesfull
		I log the setting of the maintenance windows as a warning, so if use the defaults, only the Maintenance window changes would be logged.
		When the maintenance window is set, any existing maintenance windows will be deleted.+

.PARAMETER SiteServer
    ConfigMGR site server. This is where the SMS Provider is installed to connect to the site database

.PARAMETER MaintenanceWindowDuration
	Duration, in hours, to make the maintenance window. The default is 4, but can be from 1 to 6 hours

.PARAMETER LogLevel
    Sets the minimum logging level, default is 1.
    1 - Informational
    2 - Warning
    3 - Error

.PARAMETER LogFileDir
    Directory where you want the log file. Defaults to C:\Temp\

.PARAMETER ClearLog
    This will clear the log if it exists

.EXAMPLE
	Set-CMNSUMaintenanceWindow -SiteServer CMNSVR01 -MaintenanceWindowDuration 5 -ClearLog
	This would work on CMNSVR01 and set the maintenance windows that are 5 hours long. It would also clear the log file if it existed

.NOTES

.LINK
	http://configman-notes.com
#>

PARAM(
    [Parameter(Mandatory = $true, HelpMessage = 'Site Server')]
    [ValidateScript( {Test-Connection -ComputerName $_ -Count 1 -Quiet})]
    [String]$SiteServer,
    [Parameter(Mandatory = $true, HelpMessage = 'Container to set schedules in')]
    [String]$ContainerName,
    [Parameter(Mandatory = $false, HelpMessage = 'Duration of maintenance window in hours (1 to 12)')]
    [ValidateRange(1, 12)]
    [Int32]$MaintenanceWindowDuration = 4,
    [Parameter(Mandatory = $false, HelpMessage = 'End all maintenance windows at this time')]
    [String]$AllEndTime,
    [Parameter(Mandatory = $false, HelpMessage = 'Show progress')]
    [Switch]$ShowProgress,
    [Parameter(Mandatory = $false, HelpMessage = 'Start previous day')]
    [Switch]$StartPreviousDay,
    #Parameters in script for New-LogEntry
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
    Write-Verbose $Entry
    if ($type -ge $Script:LogLevel) {
        if ($Entry.Length -eq 0) {
            $Entry = 'N/A'
        }
        $TZOffset = ([TimeZoneInfo]::Local).BaseUTcOffset.TotalMinutes
        $TZOffset = "$(Get-Date -Format "HH:mm:ss.fff")+$(-$TZOffset)"
        $Entry = "<![LOG[{0}]LOG]!><time=""{2}"" date=""{1}"" component=""{5}"" context="""" type=""{4}"" thread=""{3}"">" -f $Entry, (Get-Date -Format "MM-dd-yyyy"), $TZOffset, $pid, $type, $component
        $Entry | Out-File $Script:LogFile -Append -Encoding ascii
    }
}#End New-LogEntry

Function Get-CMNMWStartTime {
    <#
	.SYNOPSIS
		This function will calculate the Maintenance Window Start Time

	.DESCRIPTION
		Using the collection name, it will start the Maintenance Window on the day relative to Patch Tuesday. It will set it to end on the time
		the collection reboot time.

	.PARAMETER Collection
		Collection name to figure out the maintenance window for.

	.PARAMETER MaintenanceWindowDuration
		This is how long, in hours, your maintenance window is. This can be from 1 to 6 hours, default is 4. The validation check is done in the initial set of parameters,
		I did not do it here also. 

	.PARAMETER PatchTuesday
		The date for Patch Tuesday

	.EXAMPLE
		$StartDateTime = Get-CMNMWStartTime 'Patch Day 03 - Reboot 03:00' 4 $PatchTuesday
		
		This will get the startdate for a collection Named Patch Day 03 - Reboot 03:00. It will have a four hour duration and end at 3:00AM
	#>
	
    PARAM
    (
        [Parameter(Mandatory = $True)]
        [String]$Collection,
        [Parameter(Mandatory = $True)]
        [Int32]$MaintenanceWindowDuration,
        [Parameter(Mandatory = $True)]
        [DateTime]$PatchTuesday,
        [Parameter(Mandatory = $false)]
        [String]$AllEndTime
    )

    if ($AllEndTime.Length -gt 1) {
        $AllEndTime -match '\d{1,2}:\d{1,2}.?([AP]M)' | Out-Null
    }
    else {
        $Collection -match '\d{1,2}:\d{1,2}.?([AP]M)' | Out-Null
    }
    $Meridian = $Matches[1]

    $Collection -match 'Patch Day ([0-9]*).*' | Out-Null
    [int32]$Day = $Matches[1]
    
    if ($AllEndTime.Length -gt 1) {
        $AllEndTime -match '(\d{1,2}):(\d{1,2})' | Out-Null
    }
    else {
        $Collection -match '(\d{1,2}):(\d{1,2})' | Out-Null
    }
    [Single]$Mn = $Matches[2]
    [Single]$Hr = $Matches[1]
    if (($Hr -lt 12) -and ($Meridian -eq 'PM')) {
        $Hr += 12
        if ($Hr -ge 24) {$Hr -= 24}
    }
    $DecTime = $Hr + ($Mn / 60)
    $StartDateTIme = $PatchTuesday.AddDays($Day)
    $StartDateTIme = $StartDateTIme.AddHours($Hr - $MaintenanceWindowDuration)
    $StartDateTIme = $StartDateTIme.AddMinutes($Mn)
    if (($DecTime -ge $MaintenanceWindowDuration) -or $StartPreviousDay) {$StartDateTIme = $StartDateTIme.AddDays(-1)}
    Return $StartDateTIme
}#End Get-CMNMWStartTime

Function Get-CMNPatchTuesday {
    <#
	.SYNOPSIS
		Calculates Patch Tuesday for the current month
	
	.DESCRIPTION
		See Synopsis
	
	.EXAMPLE
		$PatchTuesday = Get-CMNPatchTuesday
	#>

    #Calculate Patch Tuesday Date
    [DateTime]$StrtDate = Get-date("$((Get-Date).Month)/1/$((Get-Date).Year)")
    While ($StrtDate.DayOfWeek -ne 'Tuesday') {$StrtDate = $StrtDate.AddDays(1)}
    #Now that we know when the first Tuesday is, let's get the second.
    $StrtDate = $StrtDate.AddDays(7)
    Return $StrtDate
}#End Get-CMNPatchTuesday

Function Get-CMNObjectContainerNodeID {
    <#
	.SYNOPSIS
		Returns the ContainerNodeID for the requested Container

	.DESCRIPTION
		Passing the ContainerName and the Conainer type (See notes for various types), this will return the ConatinerNodeID.
		WARNING - May return more than one ID! This would usually indicate you have the same folder name in two different locations.

	.EXAMPLE
		Get-CMNObjectContainerNodeID -Name 'FolderName' -ObjectTypeID 5000

		This will retreive the ContainerNodeID for the Device Collection folder 'FolderName'

	.PARAMETER Name
		This is the name of the Conatiner you are trying to get the ID of.
	
	.PARAMETER ObjectTypeID
		This is the ObjectTypeID (See note below) to filter the type of container you are looking for.

	.NOTES
		SMS_ObjectContainerNode - Maps Folder name to ConatainerNodeID
			ObjectTypes:	
				2 - SMS_Package
				3 - SMS_Advertisement
				7 - SMS_Query
				8 - SMS_Report
				9 - SMS_MeteredProductRule
				11 - SMS_ConfigurationItem
				14 - SMS_OperatingSystemInstallPackage
				17 - SMS_StateMigration
				18 - SMS_ImagePackage
				19 - SMS_BootImagePackage
				20 - SMS_TaskSequencePackage
				21 - SMS_DeviceSettingPackage
				23 - SMS_DriverPackage
				25 - SMS_Driver
				1011 - SMS_SoftwareUpdate
				2011 - SMS_ConfigurationBaselineInfo
				5000 - SMS_Collection_Device
				5001 - SMS_Collection_User
				6000 - SMS_ApplicationLatest
				6001 - SMS_ConfigurationItemLatest

		SMS_ObjectContainerItem - Maps ContainerNodeID to CollectionID

	.LINK
		http://configman-notes.com
	#>
    PARAM
    (
        [Parameter(Mandatory = $true, HelpMessage = 'Name of container to locate')]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [ValidateSet('2', '3', '7', '8', '9', '11', '14', '17', '18', '19', '20', '21', '23', '25', '1011', '2011', '5000', '5001', '6000', '6001')]
        [String]$ObjectTypeID
    )
    $ContainerNodeID = (Get-WmiObject -Class SMS_ObjectContainerNode -Filter "Name = '$Name' and ObjectType = '$ObjectTypeID'" @WMIQueryParameters).ContainerNodeID

    Return $ContainerNodeID

}#End Get-CMNObjectContainerNodeID

#Build variables for New-LogEntry Function

$ScriptName = $MyInvocation.MyCommand.Name
if (-not ($LogFileDir -match '\\$')) {$LogFileDir = "$LogFileDir\"}
$LogFile = $ScriptName -replace '(.*)\.ps1', '$1'
$LogFile = $LogFileDir + $LogFile + '.log'
if ($ClearLog) {
    if (Test-Path $Logfile) {Remove-Item $LogFile}
}

New-LogEntry 'Starting Script' 2
New-LogEntry "SiteServer - $SiteServer" 2
New-LogEntry "ContainerName - $ContainerName" 2
New-LogEntry "MaintenanceWindowDuration - $MaintenanceWindowDuration" 2
New-LogEntry "LogLevel - $LogLevel" 2
New-LogEntry "LogFileDir - $LogFileDir" 2
New-LogEntry "ClearLog - $ClearLog" 2

#Get the SiteCode
$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

#Build the WMIQueryParameters Hash Table for later use.
$WMIQueryParameters = @{
    ComputerName = $SiteServer
    Namespace    = "root\sms\site_$SiteCode"
}

$PatchTuesday = Get-CMNPatchTuesday
New-LogEntry "Patch Tuesday is on the $PatchTuesday"

#Get the ContainerNodeID, if we have an error, we want to catch that.
try {
    #Get list of Collection ID's 
    $FolderID = Get-CMNObjectContainerNodeID $ContainerName 5000
}

catch [System.Exception] {
    New-LogEntry "Unable to find Container $ContainerName" 3
    throw "Unknown Container - $ContainerName"
}

#Now, get the CollectionID's of all the collections in that folder.
$CollectionIDs = (Get-WmiObject -Class SMS_ObjectContainerItem -Filter "ContainerNodeID = '$FolderID' and ObjectType = 5000" @WMIQueryParameters).InstanceKey
$CurrentCollection = 0

#Cycle through list
foreach ($CollectionID in $CollectionIDs) {
    #Get a Collection in an object, check the name to see if it meets our requirements
    $Collection = Get-WmiObject -Class SMS_Collection -Filter "CollectionID = '$CollectionID'" @WMIQueryParameters
    $CurrentCollection++
    if ($ShowProgress) {
        Write-Progress -Activity 'Setting Maintenance Windows' -Status "Setting $($Collection.Name)" -PercentComplete ($CurrentCollection / ($CollectionIDs.Count) * 100) -CurrentOperation "$CurrentCollection/$($CollectionIDs.Count)"
    }
    if (($Collection.Name -match 'Patch Day ([0-9]*).*') -and ($collection.Name -match 'Reboot\s?(\d+:\d+)')) {
        try {
            #Get MW Start Time
            $StartDateTime = Get-CMNMWStartTime $Collection.Name $MaintenanceWindowDuration $PatchTuesday $AllEndTime
            #Create CMSchedule and ServiceWindow Objects
            $CMSchedule = ([WMIClass]"\\$($SiteServer)\Root\sms\site_$($SiteCode):SMS_ST_NonRecurring").CreateInstance()
            $ServiceWindow = ([WMIClass]"\\$($SiteServer)\Root\sms\site_$($SiteCode):SMS_ServiceWindow").CreateInstance()
            #Specify Schedule
            $CMSchedule.DayDuration = 0
            $CMSchedule.HourDuration = $MaintenanceWindowDuration
            $CMSchedule.IsGMT = $false
            $CMSchedule.MinuteDuration = 0
            $CMSchedule.StartTime = $ServiceWindow.ConvertFromDateTime($StartDateTIme)
            #We need to get the SMS_CollectionSettings instance for this collection, however, if it's never had a schedule, it won't have one
            try {
                $CollectionSettings = Get-WmiObject -Class SMS_CollectionSettings -Filter "CollectionID = '$CollectionID'" @WMIQueryParameters
                $CollectionSettings.Get()
            }
            
            #This will catch the ones that haven't had a MW.
            catch [System.Exception] {
                New-LogEntry "Creating $($Collection.Name) Collection Settings instance" 2
                $CollectionSettings = ([WMIClass]"\\$($SiteServer)\Root\sms\site_$($SiteCode):SMS_CollectionSettings").CreateInstance()
                $CollectionSettings.CollectionID = "$CollectionID"
            }
            $ServiceWindow.Name = ($Collection.Name)
            $ServiceWindow.Description = ($Collection.Name)
            $ServiceWindow.IsEnabled = $true
            $ServiceWindow.ServiceWindowSchedules = (Invoke-WmiMethod -Name WriteToString -Class SMS_ScheduleMethods @WMIQueryParameters $CMSchedule).StringData
            #Now, we're duplicating some data, but such is life.
            $ServiceWindow.Duration = ($MaintenanceWindowDuration * 60)
            #This says non-repeating
            $ServiceWindow.RecurrenceType = 1
            #This is for updates only
            $ServiceWindow.ServiceWindowType = 1 #1 = General, 4 = Software Updates
            $ServiceWindow.StartTime = $ServiceWindow.ConvertFromDateTime($StartDateTIme)
            #And we set it
            $CollectionSettings.ServiceWindows = $ServiceWindow.PSObject.BaseObject
            New-LogEntry "Setting $($Collection.Name) - Maintenance Window. Starts at $StartDateTIme and goes for $MaintenanceWindowDuration hours for Software Updates only." 2
			
            #Final step, it's just like we're hitting the "OK" button!
            $CollectionSettings.put() | Out-Null
        }

        #We hope this never runs!
        catch [System.Exception] {
            New-LogEntry "Unable to update $($Collection.Name)" 3
            New-LogEntry $Error[0].ToString()
        }
    }
}

if ($ShowProgress) {Write-Progress -Activity 'Setting Maintenance Windows' -Completed}

New-LogEntry 'Finished Script!' 2