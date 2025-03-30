<#
.SYNOPSIS
 
.DESCRIPTION
    This script will ping multiple hosts that are in a text file.
    Create a .txt file named 'servers' in C:\temp
	

.NOTES
	FileName:    Ping-Hosts
	Author:      Mike Cook
	Contact:     mcook9@humana.com
	Created:     2017-03-22
	Updated:     2017-03-22
	Version:     1.0.0
#>

Get-Content C:\Temp\Servers.txt | ForEach-Object {
	If (Test-Connection $_ -Quiet -Count 1){
	    Write-Output "$_,UP" -ForegroundColor Green
	} Else {
	    Write-Output "$_,Down" -ForegroundColor Red
	}
}  #| out-file C:\temp\Pings.txt -Append


#Check AD and ping.
$servers = Get-Content C:\temp\servers.txt
ForEach($server in $servers){
    try {
        #Test-Connection $server -Quiet -count 1
        (Get-ADComputer -Identity $server <#-Server lourscwps01#>).enabled
        }catch{"$server not in AD."}
} 


#Check for active clients in SQ1
$clients = Get-Content C:\temp\servers.txt
foreach($client in $clients){
   try {
   (Get-CMDevice -Name $client).name
   }catch{"$client does not have an active client."}
}

