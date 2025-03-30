param(
[Parameter(Mandatory=$True)]
$PackageID
)

$deployment = Get-WmiObject -Namespace ROOT\ccm\Policy\Machine\ActualConfig -Class CCM_SoftwareDistribution -Filter "PKG_PackageID = '$PackageID'"


if ($deployment -ne $null) {
    write-host "Deployment exists..." -ForegroundColor Green
    write-host "Package Name: "$deployment.PKG_Name
    write-host "Program Name: "$deployment.PRG_ProgramName
    $ScheduledMessageID = (get-wmiobject -query "SELECT ScheduledMessageID FROM CCM_Scheduler_ScheduledMessage WHERE ScheduledMessageID LIKE '%$packageid%'" -namespace "root\CCM\Policy\Machine\ActualConfig" -Authentication PacketPrivacy -Impersonation Impersonate).ScheduledMessageID
    
    if ($ScheduledMessageID -ne $null) {
        write-host "Found ScheduledMessageID: $scheduledMessageID " -ForegroundColor Green
        #Get-WmiObject -Query "SELECT * FROM CCM_Scheduler_ScheduledMessage WHERE ScheduledMessageID='$ScheduledMessageID'" -Namespace "ROOT\ccm\policy\machine\actualconfig"
        write-host "Triggering Deployment..." -ForegroundColor Yellow
        $deployment.ADV_RepeatRunBehavior='RerunAlways';
        $deployment.ADV_MandatoryAssignments=$True;
        $deployment.put() | Out-Null
        ([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule($ScheduledMessageID) | out-null
    } else {
        Write-Error "Unable to get Schedule ID!"
    } 
} else {
    write-error "No deployments exist!"
}