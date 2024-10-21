param(
[Parameter(Mandatory=$true)]
$ComputerName
)
if (Test-Connection -ComputerName $ComputerName -Count 1) {
    $events = Get-WinEvent -FilterHashtable @{LogName="Application";ID="1001";Data="WinSetupDiag02"} -ComputerName $ComputerName -ErrorAction SilentlyContinue
}
if ($events -ne $null) {
    $event = [xml]$events[0].ToXml()
    $event.Event.EventData.Data
} else {
    Write-Output "No logs found on $ComputerName"
}