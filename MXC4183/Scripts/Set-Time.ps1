Write-Output "This needs to be ran with Administrative rights"
#12
$machines = Get-Content -Path "C:\temp\machines.txt"
$OutputPath = "C:\temp\SetTimeOutfile"
#
$startDate = Get-Date -Format MMddyyyy
Write-Output "Name, Start Time, End Time, Result, Source" >> "$OutputPath\w32tm_$startDate.log"
Write-Output 'Total number of machines' $machines.Count
$machines |
    ForEach-Object {
    Write-Output $_
    $startTime = Get-Date -Format HH:mm:ss:ff
    IF (Test-Connection -Computername $_ -count 2 -ErrorAction SilentlyContinue) {
        $results = w32tm /config /syncfromflags:domhier /update /computer:$_
        $TimeSource = w32tm /query /computer:$_ /source
        If ($TimeSource -notmatch "humad.com") {
            Start-Sleep -Seconds 3
            Clear-Variable results -ErrorAction SilentlyContinue
            Clear-Variable TimeSource -ErrorAction SilentlyContinue
            $results = w32tm /config /syncfromflags:domhier /update /computer:$_
            $TimeSource = w32tm /query /computer:$_ /source
            If ($TimeSource -match "Local CMOS Clock") {
                Start-Sleep -Seconds 10
                Clear-Variable results -ErrorAction SilentlyContinue
                Clear-Variable TimeSource -ErrorAction SilentlyContinue
                $TimeSource = w32tm /query /computer:$_ /source
            }
            If ($TimeSource -match "Local CMOS Clock") {
                $Fail = "Failed on $_"
                Restart-Computer -ComputerName $_ -Confirm:$false
                Clear-Variable results -ErrorAction SilentlyContinue
            }
        }
    }
    Else {$Offline = "$_ is offline"}
    $endTime = Get-Date -Format HH:mm:ss:ff
    Write-Output "$_, $startTime, $endTime, $results $Fail $Offline , $TimeSource" >> "$OutputPath\w32tm_$startDate.log"
    Clear-Variable startTime -ErrorAction SilentlyContinue
    Clear-Variable endTime -ErrorAction SilentlyContinue
    Clear-Variable results -ErrorAction SilentlyContinue
    Clear-Variable Fail -ErrorAction SilentlyContinue
    Clear-Variable TimeSource -ErrorAction SilentlyContinue
    Clear-Variable Offline -ErrorAction SilentlyContinue
}