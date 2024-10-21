#-Setup Logfile
$ScriptPath = Split-Path $MyInvocation.MyCommand.Path
$APPN = "TimeServers"
$Logfile = "$Env:SystemDrive\Temp\$APPN.log"
$CurrDate = (Get-Date)
if (!(Test-Path -Path "$Env:SystemDrive\Temp")) {
    new-item $Env:SystemDrive\Temp -itemtype directory
}
#-Start Logfile
"" | Out-File $Logfile -Force
"$APPN initiated" | Out-File $Logfile -Append
"$Currdate" | Out-File $Logfile -Append
"" | Out-File $Logfile -Append
#End Setup logfile
$inputfile= "$ScriptPath\hosts.txt"
$outputfile= "$ScriptPath\hostResults.txt"
$machinenames=Get-Content -path $inputfile
foreach ( $machine in $machinenames )
{
$machine | Out-File $outputfile -Append
if(Test-Connection -ComputerName $machine -Quiet){
    w32tm /config /syncfromflags:domhier /update /computer:$machine
    "Setting Timserve source of $machine " | Out-File $outputfile -Append
    $TimeServer = w32tm /query /computer:$machine /source
    "Timeserver on $machine set to $Timeserver" | Out-File $outputfile -Append
    If ($TimeServer -eq "Local CMOS Clock"){
    "Failed to set timeserver on $machine" | Out-File $outputfile -Append
    }
    Write-Host "[$(Get-Date -format g)]: Server $($machine) gets its time from $($TimeServer)"
    "[$(Get-Date -format g)]: Server $($machine) gets its time from $($TimeServer)"  | Out-File $Logfile -append
}
else{
    { 
    "$machine...did not respond" | Out-File $outputfile -Append
    "" | Out-File $outputfile -Append
    }
    }
}