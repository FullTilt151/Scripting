get-childitem p:\dept907.cit\osd\logs ztigather.log -recurse | where {$_.lastwritetime -like "03/05/2014*"} | 

foreach {
    $wkid = $_.DirectoryName.Split("\")[4]
    $ip = (get-content $_.FullName | select-string "IPAddress001" | Select-Object -First 1).tostring().Substring(38,15).split("]")[0]
    write-host $wkid" - "$ip
}