param (
    [Parameter(Mandatory = $true)]
    $Model,
    [Parameter(Mandatory = $true)]
    $SourceCollectionID,   
    [Parameter(Mandatory = $true)]
    $Build
    )    

    $LOC = Get-Location | Select-Object -ExpandProperty Path
        If ($LOC -ne 'WP1:\') {
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" # Import the ConfigurationManager.psd1 module 
        Set-Location "WP1:" # Set the current location to be the site code.
    }
    $ModelColls = Get-CMDeviceCollection -Name "*$Model Targets"
    $ModelColls | Select-Object CollectionID, Name
    $CollName = Get-CMDeviceCollection -Id $SourceCollectionID | Select-Object -ExpandProperty Name

    $ModelColls | ForEach-Object {
        #$Model = $($_.Name).replace(' Win10 1809 Targets','')
        #$NewColl = New-CMDeviceCollection -LimitingCollectionId WP105CD3 -Name "ITI - $Model" -RefreshType Manual
        $NewColl = New-CMDeviceCollection -LimitingCollectionId $SourceCollectionID -Name "$CollName - $Model" -RefreshType Manual
        Add-CMDeviceCollectionIncludeMembershipRule -CollectionId $($NewColl.CollectionId) -IncludeCollectionId $_.CollectionID
        Move-CMObject -InputObject $NewColl -FolderPath "WP1:\DeviceCollection\CIS Device Collections\Windows 10\Servicing\Precache\$Build"
    }