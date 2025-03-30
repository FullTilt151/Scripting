Function Export-CMNSUPSettings {
    [CmdletBinding(ConfirmImpact = 'Low')]
	
    PARAM
    (
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $false, HelpMessage = 'Export file name')]
        [String]$exportPath = 'C:\Temp\WSUSSettings.xml'
    )

    Begin {
        #Build splats for WMIQueries
        $WMIQueryParameters = $sccmConnectionInfo.WMIQueryParameters
        Write-Output 'Starting Function'
        Write-Output "sccmConnectionInfo = $sccmConnectionInfo"
        Write-Output "exportPath = $exportPath"
    }
	
    Process {
        Write-Output 'Beginning processing loop'
        # Main code part goes here
        $wsusSettings = Get-WmiObject -Class SMS_UpdateCategoryInstance @WMIQueryParameters
        Write-Output 'Saving settings'
        Export-Clixml -InputObject $wsusSettings -Path $exportPath	
    }

    End {
        Write-Output 'Completing Function'
    }
} #End Export-CMNSUPSettings

Function Import-CMNSUPSettings {
    [CmdletBinding(ConfirmImpact = 'Low')]
	
    PARAM
    (
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $false, HelpMessage = 'Export file name')]
        [String]$exportPath = 'C:\Temp\WSUSSettings.xml'
    )

    Begin {
        $WMIQueryParameters = $sccmConnectionInfo.WMIQueryParameters
        Write-Output 'Starting Function'
        Write-Output "sccmConnectionInfo = $sccmConnectionInfo"
        Write-Output "exportPath = $exportPath"
    }
	
    Process {
        Write-Output 'Beginning processing loop'
        # Main code part goes here
        $sourceSettings = Import-Clixml -Path $exportPath
        $destinationSettings = Get-WmiObject -Class SMS_UpdateCategoryInstance @WMIQueryParameters
        foreach ($sourceSetting in $sourceSettings) {
            $foundMatch = $false
            Write-Output "Checking $($sourceSetting.LocalizedCategoryInstanceName)"
            #Loop through destination settings
            foreach ($destinationSetting in $destinationSettings) {
                if ($sourceSetting.LocalizedCategoryInstanceName -eq $destinationSetting.LocalizedCategoryInstanceName) {
                    $foundMatch = $true
                    if ($sourceSetting.IsSubscribed -ne $destinationSetting.IsSubscribed) {
                        Write-Output "`tSetting $($sourceSetting.LocalizedCategoryInstanceName) is being set to $($sourceSetting.IsSubscribed)"
                        $destinationSetting.IsSubscribed = $sourceSetting.IsSubscribed
                        $destinationSetting.Put() | Out-Null
                    }
                }
            }
            if (-not($foundMatch)) {Write-Output "`tSetting $($sourceSetting.LocalizedCategoryInstanceName) does not appear to be on the destination site."}
            if ($sourceSetting.IsSubscribed) {Write-Output "`tIt needs to be subscribed to"}
            else {Write-Output "`tIt was not subscribed to."}
        }
    }	

    End {
        Write-Output 'Completing Function'
    }
} #End Import-CMNSUPSettings