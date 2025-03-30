#Requires -Version 7.0
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Windows.Forms.MessageBox]::Show('Paste the WKIDs in the notepad that will open automatically.')
$InputPath = "filesystem::C:\Temp\WKIDs.txt"
Start-Process notepad C:\Temp\WKIDs.txt -Wait

$wkids = Get-Content -Path $InputPath
#ForEach ($_ in $wkids) {
$wkids | ForEach-Object -Parallel {
    If (Test-Connection -ComputerName $_ -Count 2 -Quiet -ErrorAction SilentlyContinue) {
        $FS = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'" -ComputerName $_ | Select-Object -ExpandProperty FreeSpace
        IF ($FS -lt 21474836480) {
            $date1 = Get-Date -Format "MM/dd/yyyy HH:mm"
            $PreRun = Get-CimInstance -ComputerName $_ win32_logicaldisk -Filter "DeviceID='C:'"  -ErrorAction SilentlyContinue | ForEach-Object { "$_ $($_.DeviceID) - $( $_.Freespace/1GB)" }
            #Start-Process -filepath '\\lounaswps08\pdrive\Dept907.CIT\Windows\Software\Delprof2 1.6.0\DelProf2.exe' -Verb runAs -ArgumentList "/u /i /d:15 /c:\\$_"
            Invoke-Command -ComputerName $_ -ScriptBlock {

                function GetCacheElements {
                    $UIResourceMgr = New-Object -ComObject UIResource.UIResourceMgr
                    $global:Cache = $UIResourceMgr.GetCacheInfo()
                    $global:CacheElements = $Cache.GetCacheElements()
                    $global:CacheElements | Sort-Object ContentID, ContentVersion #| Format-Table -AutoSize
                }

                GetCacheElements

                foreach ($element in $global:CacheElements) {
                    $elementid = $element.cacheelementid
                    write-host "Deleting: $elementid"
                    $cache.DeleteCacheElement($elementid)
                }

                if (test-path 'C:\Program Files\1E\Client\Extensibility\NomadBranch\NomadBranch.exe' -erroraction silentlycontinue) {
                    Write-Host "Cleanup Nomad cache"
                    & 'C:\Program Files\1E\Client\Extensibility\NomadBranch\CacheCleaner.exe' -DeleteAll -Force=8
                    & 'C:\Program Files\1E\Client\Extensibility\NomadBranch\NomadBranch.exe' -ActivateAll
                }

                # Clear prior Cleanmgr settings
                Write-Host "Clear prior Cleanmgr settings"
                Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\*' -Name StateFlags0012 -ErrorAction SilentlyContinue | Remove-ItemProperty -Name StateFlags0001 -ErrorAction SilentlyContinue

                # Set new CleanMgr settings
                Set-ItemProperty -path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Active Setup Temp Folders' -name StateFlags0012 -type DWORD -Value 2 -ErrorAction SilentlyContinue
                Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Downloaded Program Files' -name StateFlags0012 -type DWORD -Value 2 -ErrorAction SilentlyContinue
                Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Internet Cache Files' -name StateFlags0012 -type DWORD -Value 2 -ErrorAction SilentlyContinue
                Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Memory Dump Files' -name StateFlags0012 -type DWORD -Value 2 -ErrorAction SilentlyContinue
                Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Old ChkDsk Files' -name StateFlags0012 -type DWORD -Value 2 -ErrorAction SilentlyContinue
                Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Previous Installations' -name StateFlags0012 -type DWORD -Value 2 -ErrorAction SilentlyContinue
                Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin' -name StateFlags0012 -type DWORD -Value 2 -ErrorAction SilentlyContinue
                Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Service Pack Cleanup' -name StateFlags0012 -type DWORD -Value 2 -ErrorAction SilentlyContinue
                Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Setup Log Files' -name StateFlags0012 -type DWORD -Value 2 -ErrorAction SilentlyContinue
                Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error memory dump files' -name StateFlags0012 -type DWORD -Value 2 -ErrorAction SilentlyContinue
                Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error minidump files' -name StateFlags0012 -type DWORD -Value 2 -ErrorAction SilentlyContinue
                Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files' -name StateFlags0012 -type DWORD -Value 2 -ErrorAction SilentlyContinue
                Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Setup Files' -name StateFlags0012 -type DWORD -Value 2 -ErrorAction SilentlyContinue
                Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Sync Files' -name StateFlags0012 -type DWORD -Value 2 -ErrorAction SilentlyContinue
                Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache' -name StateFlags0012 -type DWORD -Value 2 -ErrorAction SilentlyContinue
                Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup' -name StateFlags0012 -type DWORD -Value 2 -ErrorAction SilentlyContinue
                Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Upgrade Discarded Files' -name StateFlags0012 -type DWORD -Value 2 -ErrorAction SilentlyContinue
                Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Archive Files' -name StateFlags0012 -type DWORD -Value 2 -ErrorAction SilentlyContinue
                Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Queue Files' -name StateFlags0012 -type DWORD -Value 2 -ErrorAction SilentlyContinue
                Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting System Archive Files' -name StateFlags0012 -type DWORD -Value 2 -ErrorAction SilentlyContinue
                Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting System Queue Files' -name StateFlags0012 -type DWORD -Value 2 -ErrorAction SilentlyContinue
                Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Upgrade Log Files' -name StateFlags0012 -type DWORD -Value 2 -ErrorAction SilentlyContinue

                Start-Process -FilePath CleanMgr.exe -ArgumentList '/sagerun:12' -WindowStyle Hidden

                # Remove temp files
                Write-Host "Remove temp files"
                Remove-Item -Path C:\temp\6* -Recurse -Verbose -ErrorAction SilentlyContinue
                if (!((Get-ItemProperty -Path HKLM:\SYSTEM\Setup -Name cmdline).cmdline -like "c:\temp\dg*")) {
                    Remove-Item -Path C:\temp\DG* -Recurse -Verbose -ErrorAction SilentlyContinue
                }
                Remove-Item -Path C:\temp\Humana* -Recurse -Verbose -ErrorAction SilentlyContinue
                Remove-Item -Path C:\temp\Xerox* -Recurse -Verbose -ErrorAction SilentlyContinue
                Remove-Item -Path C:\windows\Temp -Verbose -Recurse -Force -ErrorAction SilentlyContinue

                # Remove .NET temp files
                Write-Host "Remove .NET temp files"
                Remove-Item "C:\Windows\Microsoft.NET\Framework\v2.0.50727\Temporary ASP.NET Files" -Verbose -Force -Recurse -ErrorAction SilentlyContinue
                Remove-Item "C:\Windows\Microsoft.NET\Framework\v4.0.30319\Temporary ASP.NET Files" -Verbose -Force -Recurse -ErrorAction SilentlyContinue
                Remove-Item "C:\Windows\Microsoft.NET\Framework64\v2.0.50727\Temporary ASP.NET Files" -Verbose -Force -Recurse -ErrorAction SilentlyContinue
                Remove-Item "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files" -Verbose -Force -Recurse -ErrorAction SilentlyContinue
                
                IF (Test-Path -Path 'C:\Program Files\Microsoft SQL Server') {
                    Write-Host "Cleanup SQL Server"
                    $SQLKB = Get-ChildItem 'C:\Program Files\Microsoft SQL Server' -Recurse | Where-Object { $_.PSIsContainer -eq $True -and $_.Name -match 'Update Cache' } | Select-Object -ExpandProperty FullName
                    Remove-Item $SQLKB\*.* -Recurse -Verbose -Force 
                }
                if ((Get-ItemProperty C:\ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.edb).Length -gt 1000000000) {
                    Write-Host "Cleanup Windows Search"
                    Stop-Service 'Windows Search' -Verbose -Force
                    Start-Sleep -Seconds 5
                    Remove-Item C:\ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.edb -Force -Verbose
                    Start-Sleep -Seconds 5
                    Start-Service 'Windows Search' -Verbose -ErrorAction SilentlyContinue
                }
                $FS = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object -ExpandProperty FreeSpace
                IF ($FS -lt 16106127360) {
                    Write-Host "StartComponentCleanup"
                    & dism /online /cleanup-image /StartComponentCleanup /ResetBase
                }
            }
            $PostRun = Get-CimInstance -ComputerName $_ win32_logicaldisk -Filter "DeviceID='C:'"  -ErrorAction SilentlyContinue | ForEach-Object { "$_ $($_.DeviceID) - $( $_.Freespace/1GB)" }
            IF (-Not (Test-Path -Path 'C:\Automate\CleanDiskSpace')) {
                New-Item -Name 'Automate' -Path C:\ -ItemType Directory -Force -ErrorAction SilentlyContinue
                New-Item -Name 'CleanDiskSpace' -Path C:\Automate -ItemType Directory -Force -ErrorAction SilentlyContinue
               }
            $date2 = Get-Date -Format "MM/dd/yyyy HH:mm"
            Write-Output "Before Cleanup = $PreRun - $date1" | Out-File C:\Automate\CleanDiskSpace\CleanDiskSpace.log -Append -NoClobber
            Write-Output "After Cleanup = $PostRun - $date2" | Out-File C:\Automate\CleanDiskSpace\CleanDiskSpace.log -Append -NoClobber
        }
    }
}
Remove-Item -Path C:\temp\wkids.txt