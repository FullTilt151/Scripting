[CmdletBinding(SupportsShouldProcess = $true, 
	ConfirmImpact = 'Low')]
PARAM
(
	[Parameter(Mandatory = $false)]
	[String[]]$ComputerNames = [Array]$env:COMPUTERNAME
)

foreach($ComputerName in $ComputerNames)
{
	if (Test-Connection -ComputerName $ComputerName -Count 1 -ErrorAction SilentlyContinue)
	{
		try
		{
			Write-Output "Fixing $ComputerName"
            $Results = New-Object psobject
            $Results | Add-Member -MemberType NoteProperty -Name 'ComputerName' -Value $ComputerName
            $Results | Add-Member -MemberType NoteProperty -Name 'CurrentCacheLocation' -Value 'UnKnown'
            $Results | Add-Member -MemberType NoteProperty -Name 'UpdatedCacheLocation' -Value 'None'
            $Results | Add-Member -MemberType NoteProperty -Name 'Results' -Value 'Error'
			$Cache = Get-WmiObject -ComputerName $ComputerName -Namespace 'root/CCM/SoftMgmtAgent' -Class CacheConfig
            $Results.CurrentCacheLocation = $Cache.Location
			Write-Output "`tCurrent cache location - $($Cache.Location)"
			$CacheDrive = $Cache.Location.Substring(0,2)
			$Drives = [Array](Get-WmiObject -ComputerName $ComputerName -Query 'Select * from Win32_LogicalDisk where DriveType = 3' | Sort-Object -Property FreeSpace -Descending).DeviceID
			$CacheDriveExists = $false
			foreach($drive in $drives){if($CacheDrive -eq $drive){$CacheDriveExists = $true}}
			if(-not($CacheDriveExists))
			{
				Write-Output 'Cache drive doesn''t exist, looking for a new one.'
				$CCMCacheDir = "$($drives[0])\CCMCache"
				if($CCMCacheDir -eq 'C:\CCMCache'){$CCMCacheDir = 'C:\Windows\CCMCache'}
				Write-Output "New cache location is $CCMCacheDir"
                $Results.UpdatedCacheLocation = $CCMCacheDir
				$Cache.Location = $CacheLocation
				$Cache.put()
				Write-Output "Cache location is now $($Cache.Location)"
                $Results.Results = 'Updated'
				Get-Service -ComputerName $ComputerName -Name CcmExec | Restart-Service
			} # End if(-not($CacheDriveExists))
			else
            {
                Write-Output "`tCache location is good"
                $Results.Results = 'Good'
            }
            #$Results | Export-Csv -Path 'C:\Temp\Results.csv' -Append -NoTypeInformation
		}
		Catch [System.Exception]
		{
			Write-Output "`t!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
			Write-Output "`tUnable to fix $ComputerName"
            $Results.Results = 'Error'
            #$Results | Export-Csv -Path 'C:\Temp\Results.csv' -Append -NoTypeInformation
		}
    } # End if (Test-Connection -ComputerName $ComputerName -Count 1 -ErrorAction SilentlyContinue)
	Write-Output "------------------"
    $Results | Export-Csv -Path 'C:\Temp\Results.csv' -Append -NoTypeInformation
} # End foreach($ComputerName in $ComputerNames)