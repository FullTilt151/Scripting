$outFile = "C:\Temp\ADToSCCM.csv"
$WMIQueryParametersSP1 = @{
	ComputerName = 'LOUAPPWPS1825';
	NameSpace = 'Root/SMS/Site_SP1';}
$WMIQueryParametersSQ1 = @{
	ComputerName = 'LOUAPPWQS1150';
	NameSpace = 'Root/SMS/Site_SQ1';}
$WMIQueryParametersWP1 = @{
	ComputerName = 'LOUAPPWPS1658';
	NameSpace = 'Root/SMS/Site_WP1';}
$WMIQueryParametersWQ1 = @{
	ComputerName = 'LOUAPPWQS1151';
	NameSpace = 'Root/SMS/Site_WQ1';}
$WMIQueryParametersMT1 = @{
	ComputerName = 'LOUAPPWTS1140';
	NameSpace = 'Root/SMS/Site_MT1';}

if(Test-Path $outFile){Remove-Item $outFile}

$Domains = ('humad.com','DMZAD.hum')
$Servers = New-Object System.Collections.ArrayList
foreach($Domain in $Domains)
{
    Write-Output "Scanning $Domain"
    $Servers += Get-ADComputer -Filter * -SearchBase "" -Server "$($Domain):3268" | Select-Object -Property Name, DNSHostName
}
Write-Output "Sorting Server variable"
$Servers = $Servers | Sort-Object -Property Name -Unique
$Count = 0
Foreach($Server in $Servers)
{
    Write-Progress -ID 1 -Activity 'Scanning Sheet' -Status 'Progress->' -PercentComplete (($Count / $Servers.Count) * 100) -CurrentOperation "$Count /$($Servers.Count)"
    $Count++
	$query = "Select * from SMS_R_System where NetBiosName = '$($Server.Name)' and Client =  1"
	$deviceSP1 = Get-WmiObject -Query $query @WMIQueryParametersSP1
	$deviceSQ1 = Get-WmiObject -Query $query @WMIQueryParametersSQ1
	$deviceWP1 = Get-WmiObject -Query $query @WMIQueryParametersWP1
	$deviceWQ1 = Get-WmiObject -Query $query @WMIQueryParametersWQ1
	$deviceMT1 = Get-WmiObject -Query $query @WMIQueryParametersMT1
	if($deviceSP1 -or $deviceSQ1 -or $deviceWP1 -or $deviceWQ1 -or $deviceMT1)
	{
		Write-Host -ForegroundColor Green "$($Server.DNSHostName) is a client"
		if($deviceSP1){$Message = 'SP1'}
		elseif($deviceSQ1){$Message = 'SQ1'}
		elseif($deviceWP1){$Message = 'WP1'}
		elseif($deviceWQ1){$Message = 'WQ1'}
		elseif($deviceMT1){$Message = 'MT1'}
		else{$Message = 'Error'}
	}
    else{$Message = 'No Client'}
	"$($Server.Name), $($Server.DNSHostName), $Message" | Out-File -FilePath $outFile -Encoding ascii -Append
}
Write-Progress -ID 1 -Activity 'Scanning Sheet' -Completed