Import-Module UpdateServices

$Updates = Import-Csv D:\Scripts\SupersededUpdates07182018.csv
$Server = Get-WsusServer -Name LOUAPPWPS1642 -PortNumber 8530

$Updates |
ForEach-Object {
    Get-WsusUpdate -UpdateServer $Server -UpdateId $_.UpdateID -RevisionNumber $_.RevisionNumber | Approve-WsusUpdate -Action NotApproved -TargetGroupName 'Unassigned Computers' -Verbose
}