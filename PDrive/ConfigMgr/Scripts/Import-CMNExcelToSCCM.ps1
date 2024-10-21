<#
.SYNOPSIS

.DESCRIPTION
		
.PARAMETER ObjectID

.EXAMPLE

.LINK
	http://configman-notes.com

.NOTES
	Author:	Jim Parris
	Email:	Jim@ConfigMan-Notes
	Date:	
	PSVer:	2.0/3.0
	Updated: 
    http://www.connectionstrings.com/excel/
    CAS Limiting Collection - CAS0191C
    SP1 Limiting Collection - SP100020
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [parameter(Mandatory=$true,HelpMessage="Site server where the SMS Provider is installed")]
    [ValidateScript({Test-Connection -ComputerName $_ -Count 1 -Quiet})]
    [string]$SiteServer,

    [Parameter(Mandatory=$true, HelpMessage = 'Limiting Collection ID')]
    [String]$LimitingCollectionID,

    [parameter(Mandatory=$false,HelpMessage="Logging Level")]
    [ValidateSet(1, 2, 3)]
    [Int32]$LogLevel = 2,

    [parameter(Mandatory=$false,HelpMessage="Log File Directory")]
    [string]$LogFileDir = 'C:\Temp\',

    [parameter(Mandatory=$false,HelpMessage="Clear any existing log file")]
    [switch]$ClearLog
)

#Build variables for New-LogEntry Function
$ScriptName = $MyInvocation.MyCommand.Name
if(-not ($LogFileDir -match '\\$')){$LogFileDir = "$LogFileDir\"}
$LogFile = $ScriptName -replace '(.*)\.ps1', '$1'
$LogFile = $LogFileDir + $LogFile + '.log'
if($ClearLog)
{
    if(Test-Path $Logfile) {Remove-Item $LogFile}
}
$NewLogEntry = @{
	LogFile = $logFile;
	Component = 'Add-CMNRoleOnObject'
}

#Get SCCMConnection Info
$SccmConnectInfo = Get-CMNSCCMConnectionInfo -SiteServer $SiteServer
$WMIPath = "\\$($SccmConnectInfo.ComputerName)\$($SccmConnectInfo.NameSpace)"

#Hash Tables
$TargetCollections = @{} #This will hold the information from the spreadsheet
$Excel=new-object -com excel.application
$File = 'http://teams.humana.com/sites/NWO/NWO%20Doc%20Library/SCCM/SCCM%20-%20Device%20Collections%20-%20Servers.xlsm'
$Workbook = $excel.workbooks.open($File)
$Sheet = $Workbook.Sheets.Item(1)
New-CMNLogEntry -entry 'Starting Script' -type 1 @NewLogEntry
New-CMNLogEntry -entry "SCCMConnection Info - $SccmConnectInfo" -type 1 @NewLogEntry
New-CMNLogEntry -entry "File - $File" -type 1 @NewLogEntry

#Start by building a hash table with the collection name as the key, and an array of WKID's for the value
$TotalRows = $Sheet.UsedRange.Rows.Count-1
For($y=2;$y -le $Sheet.UsedRange.rows.Count;$y++)
{
    Write-Progress -Activity 'Import Excel Info' -PercentComplete ((($y-1) / $TotalRows) * 100) -CurrentOperation "$($y-1)/$TotalRows"
    $Collection = $Sheet.Cells.Item($y,1).Value2
    if($Collection)
    {
        $CurrentCollection = $Collection
        New-CMNLogEntry -entry "$CurrentCollection is now selected" -type 1 @NewLogEntry
    }
    $Server = $Sheet.Cells.Item($y,2).Value2
    if($Server)
    {
        $TargetCollections[$CurrentCollection] += [Array]$Server
    }
}
Write-Progress -Activity 'Import Excel Info' -Completed
$Workbook.Close()
$Excel.Quit()

$LimitingCollection = Get-WmiObject -Class SMS_Collection -Filter "CollectionID = 'CAS0191C'" -ComputerName $SccmConnectInfo.ComputerName -Namespace $SccmConnectInfo.NameSpace
$LimitingCollection.Get()
$CollectionFolder = Get-WmiObject -Class SMS_ObjectContainerNode -Filter "name = 'Maintenance Windows'" -ComputerName $SccmConnectInfo.ComputerName -Namespace $SccmConnectInfo.NameSpace
#Cycle through each of the collections
$CollectionProgress = 1
$CollectionTotalTargets = $TargetCollections.Count
foreach($TargetCollection in $TargetCollections.GetEnumerator())
{
    Write-Progress -Activity 'Cycling through collections' -Status "Collection $($TargetCollection.Key)" -PercentComplete (($CollectionProgress++ / $CollectionTotalTargets) * 100) -CurrentOperation "$CollectionProgress/$CollectionTotalTargets"
    #Does Collection Exist?
    $AddRules = @()
    $RemoveRules = @()
    $SCCMCollection = Get-WmiObject -Class SMS_Collection -Filter "Name = '$($TargetCollection.Key)'" -ComputerName $SccmConnectInfo.ComputerName -Namespace $SccmConnectInfo.NameSpace 
    if($SCCMCollection)
    {
        $SCCMCollection.Get()
        $CollectionMembers.Add($SCCMCollection.Name,$SCCMCollection.CollectionRules)
    }
    Else
    {
        New-CMNLogEntry -entry "Creating collection $($TargetCollection.Key)." -type 1 @NewLogEntry
        $SCCMCollection = ([WMIClass]"\\$($SccmConnectInfo.ComputerName)\$($SccmConnectInfo.NameSpace):SMS_Collection").CreateInstance()
        $SCCMCollection.CollectionType = 2
        $SCCMCollection.Name = ($TargetCollection.Key)
        $SCCMCollection.LimitToCollectionID = ($LimitingCollection.CollectionID)
        $SCCMCollection.LimitToCollectionName = ($LimitingCollection.Name)
        $SCCMCollection.Put()
        $SCCMCollection.Get()
        [Array]$DeviceCollectionID = ($SCCMCollection.CollectionID)
        $TargetFolderID = ($CollectionFolder.ContainerNodeID)
        Invoke-WmiMethod -Class SMS_ObjectContainerItem -Name MoveMembers -ArgumentList 0, $($SCCMCollection.CollectionID), 5000,($CollectionFolder.ContainerNodeID) -ComputerName $SccmConnectInfo.ComputerName -Namespace $SccmConnectInfo.NameSpace
    }

    #Cycle through the existing members, and build a list of members to remove.
    $ExtraMemberCount = 1
    $ExtraMemberTotalRules = $SCCMCollection.CollectionRules.Count
    foreach($CollectionMember in $SCCMCollection.CollectionRules)
    {
        Write-Progress -Activity 'Checking for extra members' -Status "Checking $($CollectionMember.RuleName)" -Id 1 -PercentComplete (($ExtraMemberCount++ / $ExtraMemberTotalRules) * 100) -CurrentOperation "$ExtraMemberCount/$ExtraMemberTotalRules"
        $IsMember = $false
        foreach($Target in $TargetCollection.Value)
        {
            
            if($Target -eq $CollectionMember.RuleName){$IsMember = $true}
        }
        If(-not $IsMember)
        {
            New-CMNLogEntry -entry "We need to delete $($CollectionMember.RuleName)" -type 1 @NewLogEntry
            $RemoveRules += [Array]$CollectionMember
        }
    }
    Write-Progress -Activity 'Checking for extra members' -Id 1 -Completed

    #Cycle through list of target members and make a list of members to add
    $ExistingMemberCount = 1
    $ExistingMemberTargets = $TargetCollection.Value.Count
    foreach($Target in $TargetCollection.Value)
    {
        Write-Progress -Activity 'Checking for missing members' -Status "Checking $Target" -Id 1 -PercentComplete (($ExistingMemberCount++ / $ExistingMemberTargets) * 100) -CurrentOperation "$ExistingMemberCount/$ExistingMemberTargets"
        $IsMember = $false
        foreach($CollectionMember in $SCCMCollection.CollectionRules)
        {
            if($Target -eq $CollectionMember.RuleName){$IsMember = $true}
        }
        if(-not $IsMember)
        {
            New-CMNLogEntry -entry "Need to add $Target to $($TargetCollection.Key)" -type 1 @NewLogEntry
            $Query = "Select ResourceID from SMS_R_System where NetbiosName = '$Target' and Active = 1 and Client = 1 and Obsolete = 0"
            $System = Get-WmiObject -Query $Query -ComputerName $SccmConnectInfo.ComputerName -Namespace $SccmConnectInfo.NameSpace
            if($System)
            {
                $DirectMemberRule = ([WMIClass]"\\$($SccmConnectInfo.ComputerName)\$($SccmConnectInfo.NameSpace):SMS_CollectionRuleDirect").CreateInstance()
                $DirectMemberRule.ResourceClassName = 'SMS_R_System'
                $DirectMemberRule.ResourceID = $System.ResourceID
                $DirectMemberRule.RuleName = $Target
                $AddRules += [Array]$DirectMemberRule
                $AllComputers[$Target] = $DirectMemberRule
            }
            else
            {
                New-CMNLogEntry -entry "Unable to add $Target to $($TargetCollection.Key)" -type 2 @NewLogEntry
            }
        }
    }
    Write-Progress -Activity 'Checking for missing members' -Id 1 -Completed
    if($RemoveRules)
    {
        New-CMNLogEntry -entry "Removing items from $($SCCMCollection.Name)" -type 1 @NewLogEntry
        $Results = $SCCMCollection.DeleteMembershipRules($RemoveRules) | Out-Null
        $SCCMCollection.Get()
    }
    if($AddRules)
    {
        New-CMNLogEntry -entry "Adding items to $($SCCMCollection.Name)" -type 1 @NewLogEntry
        $Results = $SCCMCollection.AddMembershipRules($AddRules) | Out-Null
        $SCCMCollection.Get()
    }
}
Write-Progress -Activity 'Cycling through collections' -Completed

#Finished!!
New-CMNLogEntry -entry 'Finished Script' -type 1 @NewLogEntry