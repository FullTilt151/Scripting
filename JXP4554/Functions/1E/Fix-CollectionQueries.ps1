PARAM(
    #Parameters in script for New-LogEntry
    [Parameter(Mandatory = $false, HelpMessage = 'Sets the Log Level, 1 - Informational, 2 - Warning, 3 - Error')]
    [ValidateSet(1, 2, 3)]
    [Int32]$LogLevel = 1,
    [Parameter(Mandatory = $false, HelpMessage = 'Log File Directory')]
    [String]$LogFileDir = 'C:\Temp\',
    [Parameter(Mandatory = $false, HelpMessage = 'Clear any existing log file')]
    [Switch]$ClearLog
)
#Build variables for New-LogEntry Function

$ScriptName = $MyInvocation.MyCommand.Name
if (-not ($LogFileDir -match '\\$')) {$LogFileDir = "$LogFileDir\"}
$LogFile = $ScriptName -replace '(.*)\.ps1', '$1'
$LogFile = $LogFileDir + $LogFile + '.log'
if ($ClearLog) {
    if (Test-Path $Logfile) {Remove-Item $LogFile}
}

$SiteServer = 'LOUAPPWPS875'
$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

$WMIQueryParameters = @{
    ComputerName = $SiteServer
    Namespace    = "root\sms\site_$SiteCode"
}

$DNRQuery = ([WMIClass]"\\$SiteServer\root\sms\site_$($SiteCode):SMS_CollectionRuleQuery").CreateInstance()
$DNRQuery.QueryExpression = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.IsVirtualMachine = 'False' or SMS_R_System.IsVirtualMachine is null or SMS_R_System.OperatingSystemNameandVersion like '%server%' or SMS_R_System.OperatingSystemNameandVersion like '%MAC%' or SMS_R_System.OperatingSystemNameandVersion like '%Linux%' or SMS_R_System.OperatingSystemNameandVersion like '%AIX%'"
$DNRQuery.RuleName = 'DNR'

$RDPQuery = ([WMIClass]"\\$SiteServer\root\sms\site_$($SiteCode):SMS_CollectionRuleQuery").CreateInstance()
$RDPQuery.QueryExpression = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.IsVirtualMachine = 'True' or SMS_R_System.OperatingSystemNameandVersion like '%server%' or SMS_R_System.OperatingSystemNameandVersion like '%MAC%' or SMS_R_System.OperatingSystemNameandVersion like '%Linux%' or SMS_R_System.OperatingSystemNameandVersion like '%AIX%'"
$RDPQuery.RuleName = 'RDP'
New-LogEntry 'Starting Script - Getting info'

$ContainerID = Get-CMNObjectContainerNodeID -Name 'Deployment Collections - Do Not Modify' -ObjectTypeID 5000
$CollectionIDs = Get-CMNObjectIDsBelowFolder -ObjectiD $ContainerID -ObjectTypeID 5000 | Sort-Object
[Int32]$Counter = 1
foreach ($CollectionID in $CollectionIDs) {
    $RuleMatch = $false
    $DelRule = $false
    $Collection = Get-WmiObject -Class SMS_Collection -Filter "CollectionID = '$CollectionID'" @WMIQueryParameters
    $Collection.Get()
    New-LogEntry "Checking $CollectionID - $($Collection.Name) ($Counter of $($CollectionIDs.Count))"
    $Counter ++
    if ($Collection.Name -match '_DNR$') {
        if ($Collection.CollectionRules.Count -ne 0) {
            foreach ($ColRule in $Collection.CollectionRules) {
                if (($ColRule.QueryExpression -ne $DNRQuery.QueryExpression) -or ($RuleMatch)) {
                    New-LogEntry 'Deleting DNR Query on Collection'
                    $DelRule = $true
                    $Collection.DeleteMembershipRule($ColRule) | Out-Null
                    $Collection.Get()
                }
                else {
                    $RuleMatch = $true
                }
            }
        }
        if (!$RuleMatch) {
            New-LogEntry 'Adding DNR Query'
            $Collection.AddMembershipRule($DNRQuery) | Out-Null
            $Collection.Get()
            $Collection.Put() | Out-Null
        }
    }
    else {
        if ($Collection.CollectionRules.Count -ne 0) {
            foreach ($ColRule in $Collection.CollectionRules) {
                if (($ColRule.QueryExpression -ne $RDPQuery.QueryExpression) -or ($RuleMatch)) {
                    New-LogEntry 'Deleting RDP Query on Collection'
                    $DelRule = $true
                    $Collection.DeleteMembershipRule($ColRule) | Out-Null
                    $Collection.Get()
                }
                else {
                    $RuleMatch = $true
                }
            }
        }
        if (!$RuleMatch) {
            New-LogEntry 'Adding RDP Query'
            $Collection.AddMembershipRule($RDPQuery) | Out-Null
            $Collection.Get()
        }
        if ($DelRule -or $RuleMatch) {
            $Collection.Put() | Out-Null
        }
    }
}

New-LogEntry 'Finished Script'