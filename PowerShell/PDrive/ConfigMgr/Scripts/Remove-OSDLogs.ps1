param(
[Parameter(Mandatory=$true)]
[int]$Days,
[switch]$NoPrompt
)

$path = "\\lounaswps08.rsc.humad.com\pdrive\dept907.cit\osd\logs"
$day = (get-date -day 1) - (New-TimeSpan -days $days)
$logs = Get-ChildItem -Path $path | Where-Object {$_.Lastwritetime -lt $day}
Write-Output "Log folders: $($logs.Count)"

Write-Warning "This script removes all logs from $path before $day!"

if (!$noprompt) {
    Write-Output "Are you sure you want to continue?"
    $continue = read-host -Prompt "Press Y to continue"

    if ($continue -eq "Y") {
        ForEach ($logfolder in $logs) {
            Write-Output "Removing: $($logfolder.FullName)"
            Remove-Item $logfolder.FullName -Recurse -Force
        }
    }
} else {
    ForEach ($logfolder in $logs) {
        Write-Output "Removing: $($logfolder.FullName)"
        Remove-Item $logfolder.FullName -Recurse -Force
    }
}