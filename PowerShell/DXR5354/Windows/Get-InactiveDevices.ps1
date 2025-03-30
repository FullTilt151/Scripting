function Get-ADComputers {
    $Server = 'SIMADMWPS06.humad.com'
    $SearchBase = 'DC=HUMAD,DC=com'

    # List of operating systems
    $OS = ('Windows Embedded Standard', 'Windows Workstation','Windows NT','Windows XP Professional', 'Windows 7 Professional', 'Windows 7 Ultimate', 'Windows 7 Enterprise', 
            'Windows 8.1 Enterprise', 'Windows 10 Pro', 'Windows 10 Pro for Workstations', 'Windows 10 Enterprise')

    # Full computer lists
    $Computers = Get-ADComputer -SearchBase $SearchBase -Server $Server -Filter * -Properties Name, DistinguishedName, OperatingSystem, LastLogonDate
    $Workstations = $Computers.Where({$_.OperatingSystem -in $OS -and $_.Enabled -eq $true})
    $Workstations | Select-Object Name, DistinguishedName, OperatingSystem, LastLogonDate
}

function Get-ConfigMgrComputers {
    $SiteCode = "WP1" # Site code 
    $ProviderMachineName = "LOUAPPWPS1658.rsc.humad.com" # SMS Provider machine name

    if($null -eq (Get-Module ConfigurationManager)) {
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"
    }

    # Connect to the site's drive if it is not already present
    if($null -eq (Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue)) {
        New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName
    }

    # Set the current location to be the site code.
    Push-Location "$($SiteCode):\"
    Get-CMDevice | Where-object{$_.IsClient -eq 1 -and $_.Domain -eq 'HUMAD'} | Select-Object Name, Domain, LastActiveTime
    Pop-Location
}

function Get-AzureADComputers {
    Install-Module AzureAD
    Connect-AzureAD -TenantId 56c62bbe-8598-4b85-9e51-1ca753fa50f2
    Get-AzureADDevice -All $true -Filter "DeviceOSType eq 'Windows' and AccountEnabled eq true" | Select-Object DisplayName, DeviceId, AccountEnabled, DeviceOSVersion, DeviceOSType, ApproximateLastLogonTimeStamp
}

#TODO Add all ConfigMgr sites
#TODO Add IP info
#TODO Add MDE data
#TODO Add Intune data

Get-ADComputers | Export-Csv c:\temp\ADComputers.csv -NoTypeInformation
Get-ConfigMgrComputers | Export-Csv c:\temp\ConfigMgrComputers.csv -NoTypeInformation
Get-AzureADComputers | Export-Csv c:\temp\AzureADComputers.csv -NoTypeInformation