$WKID = 'WKMJ07C29D'
$WKIDS = Get-Content -Path C:\CIS_Temp\WKIDs.txt

##PRECACHE
Invoke-Command -ComputerName $WKID { & cmd /c "C:\Program Files\1E\Client\Extensibility\NomadBranch\NomadBranch.exe" -ActivateAll }
Invoke-Command -ComputerName $WKID { & cmd /c "C:\Program Files\1E\Client\Extensibility\NomadBranch\NomadBranch.exe" -precache }

##DELETE PACKAGE
Invoke-Command -ComputerName $WKID { & cmd /c "C:\Program Files\1E\Client\Extensibility\NomadBranch\CacheCleaner.exe" -DeletePkg=WP100751 -PkgVer=2 }
Invoke-Command -ComputerName $WKID { & cmd /c "C:\Program Files\1E\Client\Extensibility\NomadBranch\CacheCleaner.exe" -DeletePkg=WP10058C -PkgVer=4 }

##DOWNLOAD PACKAGE
$DP = 'LOUAPPWPS'
$PKG = 'WP100485'
$PKGVER = '1'
Invoke-Command -ComputerName $WKID { & cmd /c "C:\Program Files\1E\Client\Extensibility\NomadBranch\SMSNomad.exe" --s --pp="http://$DP.rsc.humad.com/SMS_DP_SMSPKG$/$PKG" --prestage --ver=$PKGVER }

##DeleteAll = 8
Foreach ($WKID In $WKIDS) {
    Invoke-Command -ComputerName $WKID { & cmd /c "C:\Program Files\1E\Client\Extensibility\NomadBranch\CacheCleaner.exe" -DeleteAll -Force=9 }
}

##MaxCacheAge = 45
Foreach ($WKID In $WKIDS) {
    Invoke-Command -ComputerName $WKID { & cmd /c "C:\Program Files\1E\Client\Extensibility\NomadBranch\CacheCleaner.exe" -MaxCacheAge=45 }
}

##PURGE PXE F:
Foreach ($WKID In $WKIDS) {
    IF (Test-Connection -ComputerName $WKID -Count 1 -TimeToLive 120) {
        Invoke-Command -ComputerName $WKID -ScriptBlock {
            IF (!(Get-Item -Path HKLM:\Software\WinMagic)) {
                Write-Host "Performing clean on $env:COMPUTERNAME"
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
                Get-Date -Format HH:mm
                Stop-Service -Name CcmExec
                Set-Service -Name CcmExec -Status stopped -StartupType disabled
                Stop-Service -Name NomadBranch
                Set-Service -Name NomadBranch -Status stopped -StartupType disabled
                $DSKINFO = Get-Disk | Where-Object -Property Size -GT 900000000000
                $DSKNMBR = $DSKINFO.Number
                New-Item -Path C:\Temp\dkptconf.txt -Force
                Add-Content -Path C:\Temp\dkptconf.txt -Value "Select Disk $DSKNMBR"
                Add-Content -Path C:\Temp\dkptconf.txt -Value 'Clean'
                Add-Content -Path C:\Temp\dkptconf.txt -Value 'Create Partition Primary' 
                Add-Content -Path C:\Temp\dkptconf.txt -Value 'Select Partition 1'
                Add-Content -Path C:\Temp\dkptconf.txt -Value 'Format FS=NTFS Label="Cache" QUICK'
                Add-Content -Path C:\Temp\dkptconf.txt -Value 'Assign Letter=F'
                Add-Content -Path C:\Temp\dkptconf.txt -Value 'Exit'
                Start-Process -FilePath "C:\Windows\System32\Diskpart.exe" -ArgumentList "/s C:\Temp\dkptconf.txt" -NoNewWindow -Wait
                Remove-Item -Path C:\Temp\dkptconf.txt -Force
                sc.exe config CcmExec start= delayed-auto
                Start-Service -Name CcmExec
                sc.exe config NomadBranch start= delayed-auto
                Start-Service -Name NomadBranch
                }
        }
        Else {
            Write-Host "$WKID has WinMagic"
        }   
    }
    Else {
        Write-Host "$WKID is offline"
    }
}

#CCM Cache Delete
Invoke-Command -ComputerName $WKID -ScriptBlock {
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
}