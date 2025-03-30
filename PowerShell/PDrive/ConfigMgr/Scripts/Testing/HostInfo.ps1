<#
.SYNOPSIS
 
.DESCRIPTION
    This script will:
    1. Ping multiple hosts from text file. C:\temp\servers.xt
    2. Check AD for computer account.
    3. Check CM for active client.	

.NOTES
	FileName:    Ping-Hosts
	Author:      Mike Cook
	Contact:     mcook9@humana.com
	Created:     2017-03-22
	Updated:     2018-09-12
	Version:     1.1.0
#>

#Ping hosts from text file. Write to file if you want. I'm not the boss of you.
Get-Content C:\Temp\Servers.txt | ForEach-Object {
	If (Test-Connection $_ -Quiet -Count 1){
	    Write-Output "$_,UP"
	} Else {
	    Write-Output "$_,Down"
	}
}  #| out-file C:\temp\Pings.txt -Append


#Check AD for computer account. Default DC is set to RSC to look for servers.
$servers = Get-Content C:\temp\servers.txt
ForEach($server in $servers){
    try {
        #Test-Connection $server -Quiet -count 1
        (Get-ADComputer -Identity $server -Server LOURSCWPS01).enabled
        }catch{"$server not in AD."}
} 


#Check for active clients in SQ1
#Import CM module.
Import-Module 'C:\Program Files (x86)\ConfigMGR\bin\ConfigurationManager.psd1'

#Connect to SP1 site.
cd SP1:

$clients = Get-Content C:\temp\servers.txt
foreach($client in $clients){
   try {
   (Get-CMDevice -Name $client).name
   }catch{"$client does not have an active client."}
}


