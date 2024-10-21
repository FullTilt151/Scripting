$log = Get-Content E:\logs\Nomad_not_downloading\8_glendale_working\u_ex140325.log | Select-String "193.46.142.166" | select-string "CAS" | Select-String "GET"
$list = @()

foreach ($line in $log) {
    $line = $line.ToString()
    $pkgid = $line.substring(($line.ToString()).IndexOf("CAS"), 8)
    $ip = $line.Substring(($line.ToString()).IndexOf("193.46.142."), 14)
    $split = $line.Split(" ")
    $bytes = "{0:N2}" -f ($split[13]/1024/1024)
    $list += $pkgid + " - " + $ip + " - " + $split[9] + " - " + $split[5] + " - " + $bytes + " MB"
}

$list | Select-Object -unique | Sort-Object