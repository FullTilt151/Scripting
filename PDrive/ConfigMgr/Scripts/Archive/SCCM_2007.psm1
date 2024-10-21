function Connect-SCCMServer { 

    [CmdletBinding()] 
    PARAM 
    ( 
        [Parameter(Position=1)] $serverName, 
        [Parameter(Position=2)] $siteCode 
    ) 

    # Clear the results from any previous execution 

    Clear-Variable -name sccmServer -errorAction SilentlyContinue 
    Clear-Variable -name sccmNamespace -errorAction SilentlyContinue 
    Clear-Variable -name sccmSiteCode -errorAction SilentlyContinue 
    Clear-Variable -name sccmConnection -errorAction SilentlyContinue 

    # If the $serverName is not specified, use "." 

    if ($serverName -eq $null -or $serverName -eq "") 
    { 
        $serverName = "." 
    } 

    # Get the pointer to the provider for the site code 

    if ($siteCode -eq $null -or $siteCode -eq "") 
    { 
        Write-Verbose "Getting provider location for default site on server $serverName" 
        $providerLocation = get-wmiobject -query "select * from SMS_ProviderLocation where ProviderForLocalSite = true" -namespace "root\sms" -computername $serverName -errorAction Stop 
    } 
    else 
    { 
        Write-Verbose "Getting provider location for site $siteName on server $serverName" 
        $providerLocation = get-wmiobject -query "select * from SMS_ProviderLocation where SiteCode = '$siteCode'" -namespace "root\sms" -computername $serverName -errorAction Stop 
    } 

    # Split up the namespace path 

    $parts = $providerLocation.NamespacePath -split "\\", 4 
    Write-Verbose "Provider is located on $($providerLocation.Machine) in namespace $($parts[3])" 
    $global:sccmServer = $providerLocation.Machine 
    $global:sccmNamespace = $parts[3] 
    $global:sccmSiteCode = $providerLocation.SiteCode 

     # Make sure we can get a connection 

    $global:sccmConnection = [wmi]"${providerLocation.NamespacePath}" 
    Write-Verbose "Successfully connected to the specified provider" 
} 

function Get-SCCMObject { 

    [CmdletBinding()] 
    PARAM 
    ( 
        [Parameter(Position=1)] $class, 
        [Parameter(Position=2)] $filter 
    ) 

    if ($filter -eq $null -or $filter -eq "") 
    { 
        get-wmiobject -class $class -computername $sccmServer -namespace $sccmNamespace 
    } 
    else 
    { 
        get-wmiobject -query "select * from $class where $filter" -computername $sccmServer -namespace $sccmNamespace 
    } 
} 

function Get-SCCMPackage { 

    [CmdletBinding()] 
    PARAM 
    ( 
        [Parameter(Position=1)] $filter 
    ) 

    Get-SCCMObject SMS_Package $filter 
} 

function Get-SCCMCollection { 

    [CmdletBinding()] 
    PARAM 
    ( 
        [Parameter(Position=1)] $filter 
    ) 

    Get-SCCMObject SMS_Collection $filter 
} 

function Get-SCCMAdvertisement { 

    [CmdletBinding()] 
    PARAM 
    ( 
        [Parameter(Position=1)] $filter 
    ) 

    Get-SCCMObject SMS_Advertisement $filter 
} 

function Get-SCCMDriver { 

    [CmdletBinding()] 
    PARAM 
    ( 
        [Parameter(Position=1)] $filter 
    ) 

    Get-SCCMObject SMS_Driver $filter 
} 

function Get-SCCMDriverPackage { 

    [CmdletBinding()] 
    PARAM 
    ( 
        [Parameter(Position=1)] $filter 
    ) 

    Get-SCCMObject SMS_DriverPackage $filter 
} 

function Get-SCCMTaskSequence { 

    [CmdletBinding()] 
    PARAM 
    ( 
        [Parameter(Position=1)] $filter 
    ) 

    Get-SCCMObject SMS_TaskSequence $filter 
} 

function Get-SCCMSite { 

    [CmdletBinding()] 
    PARAM 
    ( 
        [Parameter(Position=1)] $filter 
    ) 

    Get-SCCMObject SMS_Site $filter 
} 

function Get-SCCMImagePackage { 

    [CmdletBinding()] 
    PARAM 
    ( 
        [Parameter(Position=1)] $filter 
    ) 

    Get-SCCMObject SMS_ImagePackage $filter 
} 

function Get-SCCMOperatingSystemInstallPackage { 

    [CmdletBinding()] 
    PARAM 
    ( 
        [Parameter(Position=1)] $filter 
    ) 

    Get-SCCMObject SMS_OperatingSystemInstallPackage $filter 
} 

function Get-SCCMBootImagePackage { 

    [CmdletBinding()] 
    PARAM 
    ( 
        [Parameter(Position=1)] $filter 
    ) 

    Get-SCCMObject SMS_BootImagePackage $filter 
} 

function Get-SCCMSiteDefinition { 

    # Refresh the site control file 

    Invoke-WmiMethod -path SMS_SiteControlFile -name RefreshSCF -argumentList $sccmSiteCode -computername $sccmServer -namespace $sccmNamespace 

    # Get the site definition object for this site 

    $siteDef = get-wmiobject -query "select * from SMS_SCI_SiteDefinition where SiteCode = '$sccmSiteCode' and FileType = 2" -computername $sccmServer -namespace $sccmNamespace 

    # Return the Props list 
    $siteDef | foreach-object { $_.Props } 
} 

function Get-SCCMIsR2 { 

    $result = Get-SCCMSiteDefinition | ? {$_.PropertyName -eq "IsR2CapableRTM"} 
    if (-not $result) 
    { 
        $false 
    } 
    elseif ($result.Value = 31) 
    { 
        $true 
    } 
    else 
    { 
        $false 
    } 
}