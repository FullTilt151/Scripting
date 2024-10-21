$SCCMConnectionInfo = Get-CMNSCCMConnectionInfo -SiteServer LOUAPPWPS1658
$GB = [math]::pow(2,30)
$DPs = Get-WmiObject -Class SMS_SiteSystemSummarizer -Filter "Role = 'SMS Distribution Point'" @WMIQueryParameters
foreach($DP in $DPs)
{
    $Name = $DP -replace '.*\\\\([A-Z0-9_.]+)\\.*', '$+'
    if(!($Name -match 'LOUAPPWPS44'))
    {
        $Drive = Get-WmiObject -Class WIN32_LogicalDisk -Filter "DeviceID = 'D:'" -ComputerName $Name
	    $FreeSpace = "{0:P2}" -f ($Drive.FreeSpace / $Drive.Size)
        $Size = "{0:N2}" -f ($Drive.Size / $GB)
        $MinFree = $Drive.Size * .1
        if($MinFree -ge $Drive.FreeSpace)
        {
            $Need = "Needs {0:N2}" -f (($Drive.Size * .1 - $Drive.FreeSpace) / $GB)
        }
        Else
        {
            $Need = 'is All Good'
        }
	    Write-Output "$Name has $Size F: Drive with $FreeSpace Free. F: Drive $Need"
    }
}