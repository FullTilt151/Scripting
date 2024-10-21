#-Determine and set path to this script.
$ScriptLocation = $MyInvocation.Mycommand.Path
$ScriptPath = Split-Path $ScriptLocation
Set-Location $ScriptPath
$hostnames = @()

$inputfile = "$ScriptPath\servers.txt"
$outputfile = "$ScriptPath\serversResults.txt"
"Server `t ccmcache location `t Free Space on disk `t Disk size" | Out-File $outputfile -Force
"" | Out-File $outputfile -Append

Get-Content $inputfile | Foreach-Object {$hostnames += $_} 
foreach ( $line in $hostnames ) {
    #$line | Out-File $outputfile -Append
    if (Test-Connection -ComputerName $Line -Quiet) {
        $ccmcache = Get-WmiObject -Namespace root\ccm\softmgmtagent -Class cacheconfig -ComputerName $line
        $driveletter, $junk = $($ccmcache.Location).split('\')
        $drive = Get-WmiObject Win32_LogicalDisk -ComputerName $line -Filter "DeviceID='$driveletter'"
        $free = ((($drive.freespace / 1MB) / ($drive.size / 1MB)) * 100).ToString(".00")
        "$line $($ccmcache.Location) `t $($ccmcache.Size) $(($drive.freespace/1MB).ToString(".00")) out of $([int]($drive.size/1GB)) `t %free $free" | Out-File $outputfile -Append
        "" | Out-File $outputfile -Append
    }
    else { 
        "$line did not respond" | Out-File $outputfile -Append
        "" | Out-File $outputfile -Append
    }
}