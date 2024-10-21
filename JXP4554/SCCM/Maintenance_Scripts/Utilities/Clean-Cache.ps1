$scriptblock = {
    Start-Sleep -Seconds 30
    $Global:Result = @()
    $Global:ExclusionList = @()
    $ResultCSV = 'C:\Temp\Clean-CMClientCache.log'
    If (Test-Path $ResultCSV) {
        If ((Get-Item $ResultCSV).Length -gt 500KB) {
            Remove-Item $ResultCSV -Force | Out-Null
        }
    }
    [String]$ResultPath = Split-Path $ResultCSV -Parent
    If ((Test-Path $ResultPath) -eq $False) {
        New-Item -Path $ResultPath -Type Directory | Out-Null
    }
    
    $Date = Get-Date
    Function Write-Log {
        [CmdletBinding()]
        Param (
            [Parameter(Mandatory = $false, Position = 0)]
            [Alias('Name')]
            [string]$EventLogName = 'Configuration Manager',
            [Parameter(Mandatory = $false, Position = 1)]
            [Alias('Source')]
            [string]$EventLogEntrySource = 'Clean-CMClientCache',
            [Parameter(Mandatory = $false, Position = 2)]
            [Alias('ID')]
            [int32]$EventLogEntryID = 1,
            [Parameter(Mandatory = $false, Position = 3)]
            [Alias('Type')]
            [string]$EventLogEntryType = 'Information',
            [Parameter(Mandatory = $true, Position = 4)]
            [Alias('Message')]
            $EventLogEntryMessage = ''
        )
        if ($EventLogEntryMessage.Length -gt 0 -and $EventLogEntryMessage -ne $null) {
            If (([System.Diagnostics.EventLog]::Exists($EventLogName) -eq $false) -or ([System.Diagnostics.EventLog]::SourceExists($EventLogEntrySource) -eq $false )) {
                New-EventLog -LogName $EventLogName -Source $EventLogEntrySource
            }
        
            $ResultString = Out-String -InputObject $Result -Width 1000
            if ($ResultString.Length -gt 0) {Write-EventLog -LogName $EventLogName -Source $EventLogEntrySource -EventId $EventLogEntryID -EntryType $EventLogEntryType -Message $ResultString}
            else {
                Write-EventLog -LogName $EventLogName -Source $EventLogEntrySource -EventId $EventLogEntryID -EntryType $EventLogEntryType -Message $EventLogEntryMessage
            }
            #$EventLogEntryMessage | Export-Csv -Path $ResultCSV -Delimiter ';' -Encoding UTF8 -NoTypeInformation -Append -Force
            #$EventLogEntryMessage | Format-Table Name,TotalDeleted`(MB`)
        }
    }
    Function Remove-CacheItem {
        [CmdletBinding()]
        Param (
            [Parameter(Mandatory = $true, Position = 0)]
            [Alias('CacheTD')]
            [string]$CacheItemToDelete,
            [Parameter(Mandatory = $true, Position = 1)]
            [Alias('CacheN')]
            [string]$CacheItemName
        )
    
        If ($CacheItems.ContentID -contains $CacheItemToDelete) {
            $CacheItemLocation = $CacheItems | Where-Object {$_.ContentID -Contains $CacheItemToDelete} | Select- -ExpandProperty Location
            $CacheItemSize = Get-ChildItem $CacheItemLocation -Recurse -Force | Measure-Object -Property Length -Sum | Select-Object -ExpandProperty Sum
            If ($CacheItemSize -gt '0.00') {
                $CMObject = New-Object -ComObject 'UIResource.UIResourceMgr'
                $CMCacheObjects = $CMObject.GetCacheInfo()
                $CMCacheObjects.GetCacheElements() | Where-Object {$_.ContentID -eq $CacheItemToDelete} |
                    ForEach-Object {
                    $CMCacheObjects.DeleteCacheElement($_.CacheElementID)
                }
                $ResultProps = [ordered]@{
                    'Name'     = $CacheItemName
                    'ID'       = $CacheItemToDelete
                    'Location' = $CacheItemLocation
                    'Size(MB)' = '{0:N2}' -f ($CacheItemSize / 1MB)
                    'Status'   = 'Deleted!'
                }
                $Global:Result += New-Object PSObject -Property $ResultProps
            }
        }
        Else {
            Write-Log -Message "Already Deleted:$($CacheItemName) || ID:$($CacheItemToDelete)"
        }
    }
    Function Remove-CachedApplications {
        Try {
            $CM_Applications = Get-WmiObject -Namespace root\ccm\ClientSDK -Query 'SELECT * FROM CCM_Application' -ErrorAction Stop
        }
        Catch {
            Write-Log -Message 'Get SCCM Application List from WMI - Failed!'
        }
        Foreach ($Application in $CM_Applications) {
            $Application.Get()
            Foreach ($DeploymentType in $Application.AppDTs) {
                $AppType = 'Install', $DeploymentType.Id, $DeploymentType.Revision
                $AppContent = Invoke-WmiMethod -Namespace root\ccm\cimodels -Class CCM_AppDeliveryType -Name GetContentInfo -ArgumentList $AppType
                If ($Application.InstallState -eq 'Installed' -and $Application.IsMachineTarget -and $AppContent.ContentID) {
                    Remove-CacheItem -CacheTD $AppContent.ContentID -CacheN $Application.FullName
                }
                Else {
                    $Global:ExclusionList += $AppContent.ContentID
                }
            }
        }
    }
    Function Remove-CachedPackages {
        Try {
            $CM_Packages = Get-WmiObject -Namespace root\ccm\ClientSDK -Query 'SELECT PackageID,PackageName,LastRunStatus,RepeatRunBehavior FROM CCM_Program' -ErrorAction Stop
        }
        Catch {
            Write-Log -Message 'Get SCCM Package List from WMI - Failed!'
        }
        ForEach ($Program in $CM_Packages) {
            If ($Program.LastRunStatus -eq 'Succeeded' -and $Program.RepeatRunBehavior -ne 'RerunAlways' -and $Program.RepeatRunBehavior -ne 'RerunIfSuccess') {
                If ($Program.PackageID -NotIn $PackageIDDeleteTrue) {
                    [Array]$PackageIDDeleteTrue += $Program.PackageID
                }
            }
            Else {
                If ($Program.PackageID -NotIn $PackageIDDeleteFalse) {
                    [Array]$PackageIDDeleteFalse += $Program.PackageID
                }
            }
        }
        ForEach ($Package in $PackageIDDeleteTrue) {
            If ($CM_Packages.Count -ne $null) {
                Start-Sleep -Milliseconds 800
            }
            If ($Package -NotIn $PackageIDDeleteFalse) {
                Remove-CacheItem -CacheTD $Package.PackageID -CacheN $Package.PackageName
            }
            Else {
                $Global:ExclusionList += $Package.PackageID
            }
        }
    }
    Function Remove-CachedUpdates {
        Try {
            $CM_Updates = Get-WmiObject -Namespace root\ccm\SoftwareUpdates\UpdatesStore -Query 'SELECT UniqueID,Title,Status FROM CCM_UpdateStatus' -ErrorAction Stop
        }
        Catch {
            Write-Log -Message 'Get SCCM Software Update List from WMI - Failed!'
        }
        ForEach ($Update in $CM_Updates) {
            If ($Update.Status -eq 'Installed') {
                Remove-CacheItem -CacheTD $Update.UniqueID -CacheN $Update.Title
            }
            Else {
                $Global:ExclusionList += $Update.UniqueID
            }
        }
    }
    Function Remove-OrphanedCacheItems {
        ForEach ($CacheItem in $CacheItems) {
            If ($Global:ExclusionList -notcontains $CacheItem.ContentID) {
                Remove-CacheItem -CacheTD $CacheItem.ContentID -CacheN 'Orphaned Cache Item'
            }
        }
    }
    Try {
        $CacheItems = Get-WmiObject -Namespace root\ccm\SoftMgmtAgent -Query 'SELECT ContentID,Location FROM CacheInfoEx WHERE PersistInCache != 1' -ErrorAction Stop
    }
    Catch {
        Write-Log -Message 'Getting SCCM Cache Info from WMI - Failed! Check if SCCM Client is Installed!'
    }
    Remove-CachedApplications
    Remove-CachedPackages
    Remove-CachedUpdates
    Remove-OrphanedCacheItems
    $Result = $Global:Result | Sort-Object Size`(MB`) -Descending
    $TotalDeletedSize = $Result | Measure-Object -Property Size`(MB`) -Sum | Select-Object -ExpandProperty Sum
    If ($TotalDeletedSize -eq $null -or $TotalDeletedSize -eq '0.00') {
        $TotalDeletedSize = 'Nothing to Delete!'
    }
    Else {
        $TotalDeletedSize = '{0:N2}' -f $TotalDeletedSize
    }
    $ResultProps = [ordered]@{
        'Name'     = 'Total Size of Items Deleted in MB: ' + $TotalDeletedSize
        'ID'       = 'N/A'
        'Location' = 'N/A'
        'Size(MB)' = 'N/A'
        'Status'   = ' ***** Last Run Date: ' + $Date + ' *****'
    }
    $Result += New-Object PSObject -Property $ResultProps
    Write-Log -Message $Result
    Write-Log -Message 'Processing Finished!'
}
$session = New-PSSession
Invoke-Command -ScriptBlock $scriptblock -AsJob -Session $session