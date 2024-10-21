param(
    [string]$CurrentClientBuild,
    [Parameter(Mandatory=$true)]
    [ValidateSet('Client','Server','Client&Server')]
    [string]$InstallationType,
    [switch]$CopyOnly
)

Import-Module 'C:\Program Files (x86)\ConfigMgr10\bin\ConfigurationManager.psd1'
$WIMPath = '\\lounaswps08\PDRIVE\Dept907.CIT\OSD\images\OS\VLMedia'
$OSPackagePath = '\\lounaswps08\PDRIVE\Dept907.CIT\OSD\images\OS\VLMedia'

#TODO Add check for disk space
#TODO Build out WindowsOSBuild module https://github.com/AshleyHow/WindowsOSBuild to compare versions
#TODO Replace Copy-Item with something more robust w/error checking

Add-MpPreference -ExclusionPath "%localappdata%\temp"

Save-OSDBuilderDownload -ContentDownload 'OneDriveSetup Enterprise'

if (!$CopyOnly) {
    Write-Output 'CopyOnly not specified, updating images...'
    if ($CurrentClientBuild -ne '') {
        Write-Output "Client Build specified as $CurrentClientBuild..."
        Get-OSMedia -Revision OK -Updates Update -OSReleaseId $CurrentClientBuild | 
        ForEach-Object {
            Write-Output "Updating OS Media: $($_.Name)"
            Update-OSMedia -Name $_.Name -Download -Execute -SkipUpdatesPE
        }
    } else {
        Write-Output 'Client Build not specified...'
        Get-OSMedia -Revision OK -Updates Update | 
        ForEach-Object {
            Write-Output "Updating OS Media: $($_.Name)"
            Update-OSMedia -Name $_.Name -Download -Execute -SkipUpdatesPE
        }
    }
}

if ($InstallationType -in ('Client','Client&Server')) {
    Write-Output 'Copying Client images...'
    Get-OSMedia -Revision OK -OSInstallationType Client |
    ForEach-Object {
        if ($_.InstallationType -eq 'Client') {
            $NewWimName = "Win_10_$($_.ReleaseID)_64BIT_QA.wim"
            $NewOSPackageName = "Windows_Enterprise_10_$($_.ReleaseID)_64BIT_QA"
            Write-Output "WIM source: $($_.FullName)\OS\sources\install.wim"
            Write-Output "WIM destination: $WIMPath\$NewWimName"
            $WimDestination = "$WIMPath\$NewWimName"
            $OSPackageDestination = "$OSPackagePath\$NewOSPackageName"
            Copy-Item "$($_.FullName)\OS\sources\install.wim" -Destination $WimDestination -Force
            Remove-Item -Path "$OSPackageDestination\*" -Recurse -Force
            Copy-Item -Path "$($_.FullName)\OS\*" -Destination $OSPackageDestination -Recurse -Force
            if (!(Test-Path WP1:)) {
                New-PSDrive -Name WP1 -PSProvider CMSite -Root CMWPPSS.humad.com
            }
            Push-Location WP1:
            
            $(Get-CMOperatingSystemImage).where({$_.PkgSourcePath -eq $WimDestination}) | ForEach-Object {
                Write-Output 'Updating ConfigMgr DPs for OS image...'
                Invoke-CMContentRedistribution -InputObject $_
                $_.ExecuteMethod('ReloadImageProperties',$null)
            }
            
            (Get-CMOperatingSystemInstaller).where({$_.PkgSourcePath -eq $OSPackageDestination}) | ForEach-Object {
                Write-Output 'Updating ConfigMgr DPs for OS package...'
                Invoke-CMContentRedistribution -InputObject $_
                $_.ExecuteMethod('ReloadImageProperties',$null)
            }
            Pop-Location
        }
    }
}

if ($InstallationType -in ('Server','Client&Server')) {
    Write-Output 'Copying Server images...'
    Get-OSMedia -Revision OK -OSInstallationType Server |
    ForEach-Object {
        if ($_.InstallationType -in ('Server','Server Core')) {
            $OSVersion = $($_.ImageName).Replace('Windows Server ','').replace(' Standard (Desktop Experience)','')
            switch ($_.InstallationType) {
                'Server' {$OSEdition = 'Std'}
                'Server Core' {$OSEdition = 'Std_Core'}
            }
            $NewWimName = "Win_Svr_$($OSVersion)_$($OSEdition)_64BIT.wim"
            $WimDestination = "$WIMPath\$NewWimName"
            Write-Output "WIM source: $($_.FullName)\OS\sources\install.wim"
            Write-Output "WIM destination: $WIMPath\$NewWimName" {
                
            }
            Copy-Item "$($_.FullName)\OS\sources\install.wim" -Destination $WimDestination -Force
            if (!(Test-Path SP1:)) {
                New-PSDrive -Name SP1 -PSProvider CMSite -Root CMSPPSS.humad.com
            }
            Push-Location SP1:
            $(Get-CMOperatingSystemImage).where({$_.PkgSourcePath -eq $WimDestination}) | ForEach-Object {
                Write-Output 'Updating ConfigMgr DPs for OS image...'
                Invoke-CMContentRedistribution -InputObject $_
                $_.ExecuteMethod('ReloadImageProperties',$null)
            }
            Pop-Location
        }
    }
}

Get-OSMedia -Revision OK -OSInstallationType Client |
ForEach-Object {
    $_.Name
    $Line = Get-Content "$($_.FullName)\info\Get-WindowsCapability.txt" | Select-String 'NetFX3' | Select-Object -ExpandProperty LineNumber
    if ($Line -ne "") {
        (Get-Content "$($_.FullName)\info\Get-WindowsCapability.txt")[$Line]
    }
}

Remove-MpPreference -ExclusionPath "%localappdata%\temp"