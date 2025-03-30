Function New-CMNPackage {
    [cmdletbinding()]
    PARAM
    (
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection info, can be set with Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $false, HelpMessage = 'Package Description')]
        [String]$description,

        [Parameter(Mandatory = $false, HelpMessage = 'Language')]
        [String]$language = 'English',

        [Parameter(Mandatory = $false, HelpMessage = 'Manufacturer')]
        [String]$manufacturer,

        [Parameter(Mandatory = $true, HelpMessage = 'Package Name')]
        [String]$name,

        [Parameter(Mandatory = $false, HelpMessage = 'Package Source Path')]
        [String]$pkgSourcePath,

        [Parameter(Mandatory = $false, HelpMessage = 'Version')]
        [String]$version,

        #Copy Content Flag
        [Parameter(Mandatory = $false)]
        [Switch]$copyContent = $false,

        #Prestage
        [Parameter(Mandatory = $false)]
        [Switch]$doNotDownload = $false,

        #Pesist in cache
        [Parameter(Mandatory = $false)]
        [Switch]$persistInCache = $false,

        #Enable Binary Replication
        [Parameter(Mandatory = $false)]
        [Switch]$useBinaryDeltaRep = $true,

        #Source Files
        [Parameter(Mandatory = $false)]
        [Switch]$noPackage = $false,

        #Use special MIF's
        [Parameter(Mandatory = $false)]
        [Switch]$useSpecialMif = $false,

        #Distribute on demand
        [Parameter(Mandatory = $false)]
        [Switch]$distributOnDemand = $false,

        #Enable nomad
        [Parameter(Mandatory = $false)]
        [Switch]$enableNomad = $true,

        #OSD Package
        [Parameter(Mandatory = $false)]
        [Switch]$isOSD
    )
    $NewPackage = ([wmiclass] "\\$($sccmConnectionInfo.ComputerName)\root\SMS\SITE_$($($sccmConnectionInfo.SiteCode)):SMS_Package").CreateInstance()
    $NewPackage.Description = $description
    $NewPackage.Language = $language
    $NewPackage.Manufacturer = $manufacturer
    $NewPackage.Name = $name
    $NewPackage.PkgSourcePath = $pkgSourcePath
    $NewPackage.Version = $version
    $NewPackage.PackageType = 0
    $NewPackage.Priority = 2
    $NewPackage.PkgSourceFlag = 2
    $NewPackage.PkgFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Package_PkgFlags -CurrentValue $NewPackage.PkgFlags -ProposedValue $($copyContent.IsPresent) -KeyName Copy_Content
    $NewPackage.PkgFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Package_PkgFlags -CurrentValue $NewPackage.PkgFlags -ProposedValue $doNotDownload.IsPresent -KeyName Do_Not_Download
    $NewPackage.PkgFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Package_PkgFlags -CurrentValue $NewPackage.PkgFlags -ProposedValue $persistInCache.IsPresent -KeyName Persist_In_Cache
    $NewPackage.PkgFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Package_PkgFlags -CurrentValue $NewPackage.PkgFlags -ProposedValue $useBinaryDeltaRep.IsPresent -KeyName Use_Binary_Delta_Rep
    $NewPackage.PkgFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Package_PkgFlags -CurrentValue $NewPackage.PkgFlags -ProposedValue $noPackage.IsPresent -KeyName No_Package
    $NewPackage.PkgFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Package_PkgFlags -CurrentValue $NewPackage.PkgFlags -ProposedValue $useSpecialMif.IsPresent -KeyName Use_Special_Mif
    $NewPackage.PkgFlags = Set-CMNBitFlagForControl -BitFlagHashTable $SMS_Package_PkgFlags -CurrentValue $NewPackage.PkgFlags -ProposedValue $distributOnDemand.IsPresent -KeyName Distribute_On_Demand
    if ($enableNomad.IsPresent) {$NewPackage.AlternateContentProviders = '<AlternateDownloadSettings SchemaVersion="1.0"><Provider Name="NomadBranch"><Data><ProviderSettings /><pc>1</pc></Data></Provider></AlternateDownloadSettings>'}
    if ($isOSD.IsPresent) {$NewPackage.AlternateContentProviders = '<AlternateDownloadSettings SchemaVersion="1.0"><Provider Name="NomadBranch"><Data><ProviderSettings /><pc>9</pc><mc /></Data></Provider></AlternateDownloadSettings>'}
    $NewPackage.Put()
    $NewPackage.Get()

    Return $NewPackage
} #End New-CMNPackage
