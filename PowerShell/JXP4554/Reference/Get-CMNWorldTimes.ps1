$nowUTC = [system.timezoneinfo]::ConvertTimeToUtc((Get-Date))
$times = @()
[system.timezoneinfo]::GetSystemTimeZones() | ForEach-Object {
    $offset = [system.timezoneinfo]::FindSystemTimeZoneById($_.id).baseUtcOffset
    $time = New-Object psobject -Property @{'TimeZone'=$_.id; 'Time' =  ($nowUTC + $offset) } 
    $times += $time
    } # end foreach-object

$times | select timezone, time | sort timezone | Out-GridView -Title "Times around the World"