#Check Nomad service
Get-Content "C:\temp\Nomad.txt" | ForEach-Object{
    Get-Service -ComputerName $_ -Name "Nomadbranch"
}



$servers = Get-Content C:\temp\servers.txt
ForEach($server in $servers){
    try {
        #Test-Connection $server -Quiet -count 1
        (Get-ADComputer -Identity $server <#-Server lourscwps01#>).enabled
        }catch{"$server not in AD."}
} 

$Computers = Get-Content C:\temp\Nomad.txt
Get-Service -Name "NomadBranch" -computername $Computers | Select machinename, Status |sort machinename |format-table -autosize


$Computers = Get-Content C:\temp\Nomad.txt
$Service = "NomadBranch"
foreach ($computer in $computers) {
   #$Servicestatus = get-service -name $Service -ComputerName $computer
   Write-Output $computer #$Servicestatus
}