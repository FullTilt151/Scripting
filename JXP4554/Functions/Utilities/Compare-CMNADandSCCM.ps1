$outFile = "C:\Temp\ADToSCCM.csv"
$MaxThreads = 32
$Domains = ('humad.com','DMZAD.hum','Adea.hum','Hmhschamp.humad.com','Loudcu.humad.com','Rsc.humad.com','Ts.humad.com','Wap.humad.com','Loumom.hum','Crmad.hum','Aso.hum','Icmad.hum','Rx1ad.hum','Humvit.nc1','Cumulus.hum','Vitdad.dom','Vitad.dom','Prtpa.local','Humana.forest','Hmhstest.loutms.tree','Loutap.loutms.tree','Loutms.tree','Tmt.loutms.tree')
$Servers = New-Object System.Collections.ArrayList
[System.Management.Automation.ScriptBlock]$GetClientSiteSB = {
    PARAM
	(
		[Parameter(Mandatory=$true)]
		[String]$MachineName
	)
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
    $MachineName = [regex]::Replace($MachineName,'(?<SingleQuote>'')','${SingleQuote}''')
	$query = "Select * from SMS_R_System where NetBiosName = '$MachineName' and Client =  1 and Obsolete = 0"
	$deviceSP1 = Get-WmiObject -Query $query @WMIQueryParametersSP1
	$deviceSQ1 = Get-WmiObject -Query $query @WMIQueryParametersSQ1
	$deviceWP1 = Get-WmiObject -Query $query @WMIQueryParametersWP1
	$deviceWQ1 = Get-WmiObject -Query $query @WMIQueryParametersWQ1
	$deviceMT1 = Get-WmiObject -Query $query @WMIQueryParametersMT1
	if($deviceSP1 -or $deviceSQ1 -or $deviceWP1 -or $deviceWQ1 -or $deviceMT1)
	{
		if($deviceSP1){$Message = 'SP1'}
		elseif($deviceSQ1){$Message = 'SQ1'}
		elseif($deviceWP1){$Message = 'WP1'}
		elseif($deviceWQ1){$Message = 'WQ1'}
		elseif($deviceMT1){$Message = 'MT1'}
		else{$Message = 'Error'}
	}
    else{$Message = 'No Client'}
    return $Message
}

if(Test-Path $outFile){Remove-Item $outFile}
$Count = 1
foreach($Domain in $Domains)
{
    Write-Progress -Id 1 'Scanning Domains' -Status "$Domain" -PercentComplete(($Count / $Domains.Count) * 100) -CurrentOperation "$Count /$($Domains.Count)"
    $Count++
    Write-Output "Getting list of computers in $domain"
    $Servers = Get-ADComputer -Filter {(Enabled -eq $true)} -SearchBase "" -Server "$($Domain):3268" | Select-Object -Property Name, DNSHostName

    Write-Output "Sorting Server variable"
    $Servers = $Servers | Sort-Object -Property Name -Unique
    For($x = 0;$x -lt $Servers.Count;$x++)
    {
        Write-Progress -ID 2 -Activity 'Scanning List' -Status 'Progress->' -PercentComplete (($x / $Servers.Count) * 100) -CurrentOperation "$x /$($Servers.Count)" -ParentId 1
        if($Servers[$x].Name.Length -le 16){Start-Job -Name $x -ScriptBlock $GetClientSiteSB -ArgumentList $Servers[$x].Name | Out-Null}
        Do
        {
            $running = Get-Job | Where-Object { $_.State -eq ‘Running’ } | Measure-Object
            if($running.Count -ge $MaxThreads){Start-Sleep -Milliseconds 10}
        }while($running.Count -ge $MaxThreads)
        $jobs = Get-Job | Where-Object {$_.State -eq 'Completed'}
        foreach($job in $jobs)
        {
            $message = Receive-Job -Name $job.Name
	        "$($Servers[$Job.Name].Name), $($Servers[$Job.Name].DNSHostName), $Message" | Out-File -FilePath $outFile -Encoding ascii -Append
            Remove-Job -Name $job.Name
        }
    }
    Write-Progress -Id 2 -Activity 'Scanning List' -Completed
}
Write-Progress -ID 1 -Activity 'Scanning Domains' -Completed