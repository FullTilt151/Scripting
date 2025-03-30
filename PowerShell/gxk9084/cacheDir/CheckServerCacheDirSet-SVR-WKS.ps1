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
        $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $line
        $ccmcache = Get-WmiObject -Namespace root\ccm\softmgmtagent -Class cacheconfig -ComputerName $line
        $driveletter, $junk = $($ccmcache.Location).split('\')
        $drive = Get-WmiObject Win32_LogicalDisk -ComputerName $line -Filter "DeviceID='$driveletter'"
        $pctfree = ((($drive.freespace / 1MB) / ($drive.size / 1MB)) * 100).ToString(".00")
        "$line $($ccmcache.Location) `t $($ccmcache.Size) $(($drive.freespace/1MB).ToString(".00")) out of $([int]($drive.size/1GB)) `t %free $pctfree" | Out-File $outputfile -Append
        #$mbfree=$(($drive.freespace/1MB).ToString(".00"))
        $mbfree = $($drive.freespace / 1MB)
        "" | Out-File $outputfile -Append
        If ($mbfree -lt 5120) {
            "$mbfree is 5 GB or less, looking for another drive" | Out-File $outputfile -Append
            #Find new drive with more space ad move ccmcache##
            $Drives = [Array](Get-WmiObject -ComputerName $line -Query 'Select * from Win32_LogicalDisk where DriveType = 3' | Sort-Object -Property FreeSpace -Descending).DeviceID
            $CacheDriveExists = $false
            ############################################Something wring here..  not returning the need to set a new drive#####################3
            foreach ($drive in $drives) {if ($driveletter -eq $drive) {$CacheDriveExists = $true}}
            if (-not($CacheDriveExists)) {
                "Cache drive doesn''t exist, looking for a new one." | Out-File $outputfile -Append
                $CCMCacheDir = "$($drives[0])\CCMCache"
                if ($computerSystem.Domain -eq 'ts.humad.com') {
                    # Persistent VS Non
                    if ((($computerSystem.Name -notmatch '...[CX][MA][FH].*' -or $computerSystem.Name -match '...[CX][MA][ABCDFLNSPX].....S.*')) -and $computerSystem.Name -notmatch '......WP[VU].*') {
                        ## Persistent machines with cache on D:\Program Files\CCMCache
                        Write-Verbose "`tPersistent Citrix Server, setting cache to D:\Program Files\CCMCache"
                        $CCMCacheDir = 'D:\Program Files\CCMCache'
                    }
                    else {
                        ## Non-persistent machines
                        Write-Verbose "`tNon-persistent Citrix Server, setting cache to E:\Persistent\CCMCache"
                        $CCMCacheDir = 'E:\Persistent\CCMCache'
                    }
                }
                # End Persistent VS Non
                if ($CCMCacheDir -eq 'C:\CCMCache') {$CCMCacheDir = 'C:\Windows\CCMCache'}
                "New cache location is $CCMCacheDir" | Out-File $outputfile -Append
                #Put cache directory and restart service
                $Ccmcache.Location = $CCMCacheDir
                $Caccmche.put()
                "Cache location is now $($Ccmcache.Location)" | Out-File $outputfile -Append
                #$Results.Results = 'Updated'
                Get-Service -ComputerName $line -Name CcmExec | Restart-Service
                
            }
            # End if(-not($CacheDriveExists))
            else {
                "`tCache location is good" | Out-File $outputfile -Append
            }
            
        } # End of try
    }
    else { 
        "$line did not respond" | Out-File $outputfile -Append
        "" | Out-File $outputfile -Append
    }
}