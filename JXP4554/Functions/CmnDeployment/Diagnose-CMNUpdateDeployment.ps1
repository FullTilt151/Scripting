PARAM
(
    [Parameter(Mandatory=$true)]
    [Array]$CollectionName
)


$SiteServer = 'LOUAPPWPS875'
$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

$WMIQueryParameters = @{
    ComputerName = $SiteServer
    Namespace = "root\sms\site_$SiteCode"
}

$CollectionID = (Get-WmiObject -Class SMS_Collection -Filter "Name = '$CollectionName'" @WMIQueryParameters).CollectionID
$ResourceIDs = (Get-WmiObject -Class SMS_FullCollectionMembership -Filter "CollectionID = '$CollectionID'" @WMIQueryParameters).ResourceID

foreach($ResourceID in $ResourceIDs)
{
    $ComputerName = (Get-WmiObject -Class SMS_R_System -Filter "ResourceID = '$ResourceID'" @WMIQueryParameters).NetbiosName
    Write-Host "Working on $ComputerName"
    $OutFile = "C:\Temp\$ComputerName.log"
    $CCMLogFIle = "\\$ComputerName\c`$\windows\ccm\logs\UpdatesDeployment.log"

    $CCMLogLines = Get-Content $CCMLogFIle | Where-Object {$_ -match 'Assignment.*has total'}
    foreach($CCMLogLine in $CCMLogLines)
    {
        $CCMLogLine -match '<!\[LOG\[(.*)\]LOG\]!><time="(.*)" date="([\d\-]*)".*' | Out-Null
        $Time = $Matches[2]
        $Date = $Matches[3]
        $Time -match '([0-9]*:[0-9]*:[0-9\.]*)([\+\-][0-9]*)' | Out-Null
        $LocalTime = $Matches[1]
        [Int32]$Offset = $Matches[2] 
        $UTCTime = get-date "$Date $LocalTime"
        $UTCTime = $UTCTime.AddMinutes($Offset)
        $LocalTime = $UTCTime.AddMinutes(-300)
        $CCMLogLine -match '({.*})' | Out-Null
        $AssignemntUniqueID = $Matches[1]
        $UpdatesAssignment = Get-WmiObject -Class SMS_UpdatesAssignment -Filter "AssignmentUniqueID = '$AssignemntUniqueID'" @WMIQueryParameters
        $UpdateGroupAssignment = Get-WmiObject -Class SMS_UpdateGroupAssignment  -Filter "AssignmentID = '$($UpdatesAssignment.AssignmentID)'" @WMIQueryParameters
        "$LocalTime - $($UpdateGroupAssignment.AssignmentName) ** Original Line $CCMLogLine" | Out-File -FilePath $OutFile -Append -Encoding ascii
    }
}