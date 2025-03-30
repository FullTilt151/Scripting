<#    
.SYNOPSIS   Parse thru IIS log files for unique client IP addresses and convert to NETBIOS name. 
.NOTES      Define more than one log directories and also how far back you want to go. 
#> 
 
# Working with a log directory or more 
$varLogLocation = ("\\louappwps610\f$\temp\IISLogs", "\\louappwps862\f$\temp\IISLogs") 
$varLastWriteTime = "6/13/2014" 
$pattern = '^(?:\s*\S*){8}(?:\s*)(\S*).*'
$ip = @{}
foreach ($loc in $varLogLocation) { 
    $varLogFiles += gci $loc | where-object {$_.lastwritetime -ge $($varLastWriteTime)} | ForEach-Object -Process {$_.FullName} 
} 
 
if ($varLogFiles.count -gt 0 ) { 
 
    Write-Host "Found $($varLogFiles.count) logs and will begin to parse them..." 
 
    $count = 1 
    foreach ($log in $varLogFiles) { 
        Write-Host "Parsing log $($count) of $($varLogFiles.count)..."
        $file = New-Object System.IO.StreamReader -Arg $log
		$linecount = 0
		while ($line = $file.ReadLine()) {
		
		  if(($linecount % 5000) -eq 0)
		  {
		  	Write-Host -NoNewline "."

		  }
		  if($line -match '/SMS_MP/\.sms_pol')
		  {
			  if($line -match $pattern)
			  {
			  	if($ip.ContainsKey($matches[1]))
			  	{
			  		$ip.Set_Item($matches[1], ($ip.Get_item($matches[1]) + 1))
			  	}
			  	else
			  	{
			  		$ip.Add($matches[1], 1)
			  	}
			  }
		  }
		  
		$linecount++ 
		
		}
		$file.close()
		Write-Host "."
        ###$varAllLogs += gc $log |%{$_ -replace '#Fields: ', ''} |?{$_ -notmatch '^#'} | ConvertFrom-Csv -Delimiter ' ' 
        ##gc $log |?{$_ -notmatch '^#'} |?{$_ -match $pattern} $ip.Add($matches[1], 1)
        
        $count++ 
    } 
 	Write-Host "Unique IP addresses: $($ip.count)"
 	$ip > "IISLogs-uniqueIP.txt"
#    Write-Host "Completed parsing logs, extracting unique client IPs..."
    
#    $varUniqueResults = $varAllLogs | select c-ip -unique 
#    Write-Host "There are $($varUniqueResults.count) unique client IPs, starting to convert them to NETBIOS names..." 
#    $varFinalResults = $varUniqueResults | ForEach-Object {([system.net.dns]::GetHostByAddress($_."c-ip")).hostname} 
#    $varFinalResults > "IISLogs-Clienthostname.txt" 
 
} else { 
    Write-Host "Did not find any log files to parse, exiting." 
}
