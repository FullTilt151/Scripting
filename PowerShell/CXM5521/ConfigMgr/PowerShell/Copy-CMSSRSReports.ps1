function Copy-CMSSRSReports {
    <#
    .SYNOPSIS
        Copies all reports, data sources, and data sets from one SSRS server to another.
    .DESCRIPTION
        This function will copy all reports, data sources, and data sets from one SSRS server to another. It relies on the
        ReportingServicesTools PowerShell module. This script was created to simplify the migration to new SSRS servers
        for the SCCM Tier 0 Project. 
    .PARAMETER SiteCode
        The SCCM Site Code for the site. this is used to identify the SSRS ConfigMgr_<SiteCode> directory
    .PARAMETER SourceCM_SSRS
        The source SSRS server which we will use to export all the various SSRS resources
    .PARAMETER DestinationCM_SSRS
        The destination SSRS server which will be the target for all the imports
    .PARAMETER TempFileStorageROOT
        The temp directory to store the exported information
    .EXAMPLE
        PS C:\> Copy-CMSSRSReports -SiteCode MT1 -SourceCM_SSRS 'LOUSRSWTS18.RSC.HUMAD.COM' -DestinationCM_SSRS 'LOUSRSWTS27.RSC.HUMAD.COM'
        Copy all SSRS info from 'LOUSRSWTS18.RSC.HUMAD.COM' to 'LOUSRSWTS27.RSC.HUMAD.COM'
    .NOTES
        This function will throw a fair amount of 'errors' which are transient. The function will perform clean up after the fact
        to restore all the references to various data sources and data sets
        You MUST set the credentials and appropriate connection strings on the custom Data Sources after the fact
    #>
    param(
        [parameter(Mandatory = $true)]
        [ValidateSet('WP1', 'SP1', 'WQ1', 'SQ1', 'MT1')]
        [string]$SiteCode,
        [parameter(Mandatory = $true)]
        [string]$SourceCM_SSRS = 'LOUSRSWTS18.RSC.HUMAD.COM',
        [parameter(Mandatory = $true)]
        [string]$DestinationCM_SSRS = 'LOUSRSWTS27.RSC.HUMAD.COM',
        [parameter(Mandatory = $false)]
        [string]$TempFileStorageROOT = "$env:SystemDrive\Temp"
    )
    $SourceCM_URI = [string]::Format('http://{0}:8081/reportserver', $SourceCM_SSRS)
    $DestinationCM_URI = [string]::Format('http://{0}:8081/reportserver', $DestinationCM_SSRS)

    $null = [System.IO.Directory]::CreateDirectory($TempFileStorageROOT)
    $TempStorage = Join-Path -Path $TempFileStorageROOT -ChildPath "SSRS_Migration_$SiteCode"
    $null = [System.IO.Directory]::CreateDirectory($TempStorage)

    $SourceSSRS = Get-RsFolderContent -RsFolder / -Recurse -ReportServerUri $SourceCM_URI
    $DestinationSSRS = Get-RsFolderContent -RsFolder / -Recurse -ReportServerUri $DestinationCM_URI

    $SourceDatasets = $SourceSSRS.where( { $_.TypeName -eq 'DataSet' -and $_.CreatedBy -ne 'NT AUTHORITY\SYSTEM' })
    $SourceDataSources = $SourceSSRS.where( { $_.TypeName -eq 'DataSource' -and $_.CreatedBy -ne 'NT AUTHORITY\SYSTEM' })
    $SourceReports = $SourceSSRS.where( { $_.TypeName -eq 'Report' -and $_.CreatedBy -ne 'NT AUTHORITY\SYSTEM' })
    $SourceFolders = $SourceSSRS.where( { $_.TypeName -eq 'Folder' -and $_.CreatedBy -ne 'NT AUTHORITY\SYSTEM' })

    $DestinationDatasets = $DestinationSSRS.where( { $_.TypeName -eq 'DataSet' -and $_.CreatedBy -ne 'NT AUTHORITY\SYSTEM' })
    $DestinationDataSources = $DestinationSSRS.where( { $_.TypeName -eq 'DataSource' -and $_.CreatedBy -ne 'NT AUTHORITY\SYSTEM' })
    $DestinationReports = $DestinationSSRS.where( { $_.TypeName -eq 'Report' -and $_.CreatedBy -ne 'NT AUTHORITY\SYSTEM' })
    $DestinationFolders = $DestinationSSRS.where( { $_.TypeName -eq 'Folder' -and $_.CreatedBy -ne 'NT AUTHORITY\SYSTEM' })

    $PSDefaultParameterValues['Write-CCMLogEntry:Folder'] = $TempStorage
    $PSDefaultParameterValues['Write-CCMLogEntry:FileName'] = "$SiteCode-SSRS_Migration.log"
    $PSDefaultParameterValues['Write-CCMLogEntry:Component'] = 'SSRS_Migration'
    $PSDefaultParameterValues['Write-CCMLogEntry:Enable'] = $true

    #region create folder structure
    $FoldersToCreate = (Compare-Object -ReferenceObject $SourceFolders -DifferenceObject $DestinationFolders -Property Path -PassThru).Where( { $_.SideIndicator -eq '<=' } )
    foreach ($Folder in $FoldersToCreate) {
        $FolderName = $Folder.Name
        $FolderPath = switch ($Folder.Path.TrimEnd($($FolderName))) {
            '/' {
                $PSItem
            }
            default {
                $PSItem.TrimEnd('/')
            }
        }
        $FolderDescription = $Folder.Description
        New-RsFolder -RsFolder $FolderPath -FolderName $FolderName -Description $FolderDescription -ReportServerUri $DestinationCM_URI
    }
    #endregion create folder structure


    #region create missing data data sources
    $DataSourcesToCreate = (Compare-Object -ReferenceObject $SourceDataSources -DifferenceObject $DestinationDataSources -Property Path -PassThru).Where( { $_.SideIndicator -eq '<=' } )
    foreach ($DataSource in $DataSourcesToCreate) {
        $DataSourceName = $DataSource.Name
        $DataSourcePath = switch ($DataSource.Path.TrimEnd($($DataSourceName))) {
            '/' {
                $PSItem
            }
            default {
                $PSItem.TrimEnd('/')
            }
        }
        Out-RsCatalogItem -RsItem $DataSource.Path -Destination $TempStorage -ReportServerUri $SourceCM_URI
        $FileToImport = Join-Path -Path $TempStorage -ChildPath "$DataSourceName.rsds"
        Write-RsCatalogItem -Path $FileToImport -RsFolder $DataSourcePath -ReportServerUri $DestinationCM_URI
    }
    #endregion create missing data data sources

    #region create missing data data sets and correct their Data Sources
    $DataSetsToCreate = (Compare-Object -ReferenceObject $SourceDatasets -DifferenceObject $DestinationDatasets -Property Path -PassThru).Where( { $_.SideIndicator -eq '<=' } )
    foreach ($DataSet in $DataSetsToCreate) {
        $Refs = Get-RsItemReference -Path $DataSet.Path -ReportServerUri $SourceCM_URI
        $DataSources = $Refs.where( { $_.ReferenceType -eq 'DataSource' })
        $DataSetName = $DataSet.Name
        $DataSetPath = switch ($DataSet.Path.TrimEnd($($DataSetName))) {
            '/' {
                $PSItem
            }
            default {
                $PSItem.TrimEnd('/')
            }
        }
        Out-RsCatalogItem -RsItem $DataSet.Path -Destination $TempStorage -ReportServerUri $SourceCM_URI
        $FileToImport = Join-Path -Path $TempStorage -ChildPath "$DataSetName.rsd"
        Write-RsCatalogItem -Path $FileToImport -RsFolder $DataSetPath -ReportServerUri $DestinationCM_URI
        if ($null -ne $DataSources) {
            foreach ($Source in $DataSources) {
                $setRsDataSourceReferenceSplat = @{
                    DataSourceName  = $Source.Name
                    Path            = $DataSet.Path
                    DataSourcePath  = $Source.Reference
                    ReportServerUri = $DestinationCM_URI
                }
                try {
                    Set-RsDataSourceReference @setRsDataSourceReferenceSplat
                }
                catch {
                    Write-Error "Failed to set $setRsDataSourceReferenceSplat"
                }
            }
        }
    }
    #endregion create missing data data sets and correct their Data Sources


    #region import missing reports, and fix missing dataset and datasource references
    $ReportsToMigrate = (Compare-Object -ReferenceObject $SourceReports -DifferenceObject $DestinationReports -Property Path -PassThru).Where( { $_.SideIndicator -eq '<=' } )
    foreach ($Report in $ReportsToMigrate) {
        $Refs = Get-RsItemReference -Path $Report.Path -ReportServerUri $SourceCM_URI
        $DataSources = $Refs.where( { $_.ReferenceType -eq 'DataSource' })
        $DataSets = $Refs.where( { $_.ReferenceType -eq 'DataSet' })
        Out-RsCatalogItem -RsItem $Report.Path -Destination $TempStorage -ReportServerUri $SourceCM_URI
        $FileToImport = Join-Path -Path $TempStorage -ChildPath "$($Report.Name).rdl"
        $Folder = $Report.Path.TrimEnd($($Report.Name)).TrimEnd('/')
        try {
            Write-RsCatalogItem -Path $FileToImport -RsFolder $Folder -ReportServerUri $DestinationCM_URI
        }
        catch {
            Write-Error "Failed to set Import [Report = '$($Report.Name)'] [ReportPath = '$($Report.Path)'] [File = '$FileToImport']"
            Write-CCMLogEntry -Value "Failed to set Import [Report = '$($Report.Name)'] [ReportPath = '$($Report.Path)'] [File = '$FileToImport']" -Severity 3
        }
        if ($null -ne $DataSources) {
            foreach ($Source in $DataSources) {
                $setRsDataSourceReferenceSplat = @{
                    DataSourceName  = $Source.Name
                    Path            = $Report.Path
                    DataSourcePath  = $Source.Reference
                    ReportServerUri = $DestinationCM_URI
                }
                try {
                    Set-RsDataSourceReference @setRsDataSourceReferenceSplat
                }
                catch {
                    Write-Error "Failed to set DataSource for [Report = '$($Report.Name)'] [DataSourceName = '$($Source.Name)'] [DataSourcePath = '$($Source.Reference)']"
                    Write-CCMLogEntry -Value "Failed to set DataSource for [Report = '$($Report.Name)'] [DataSourceName = '$($Source.Name)'] [DataSourcePath = '$($Source.Reference)']" -Severity 3
                }
            }
        }
        if ($null -ne $DataSets) {
            foreach ($Set in $DataSets) {
                $setRsDataSetReferenceSplat = @{
                    Path            = $Report.Path
                    ReportServerUri = $DestinationCM_URI
                    DataSetName     = $Set.Name
                    DataSetPath     = $Set.Reference
                }
                try {
                    Set-RsDataSetReference @setRsDataSetReferenceSplat
                }
                catch {
                    Write-Error "Failed to set DataSource for [Report = '$($Report.Name)'] [DataSetName = '$($Set.Name)'] [DataSetPath = '$($Set.Reference)']"
                    Write-CCMLogEntry -Value "Failed to set DataSource for [Report = '$($Report.Name)'] [DataSetName = '$($Set.Name)'] [DataSetPath = '$($Set.Reference)']" -Severity 3
                }
            }
        }
    }
    #endregion import missing reports, and fix missing dataset and datasource references

    #region fix references that were not able to be initially fixed
    $DestinationSSRS = Get-RsFolderContent -RsFolder / -Recurse -ReportServerUri $DestinationCM_URI
    $DestinationReports = $DestinationSSRS.where( { $_.TypeName -eq 'Report' -and $_.CreatedBy -ne 'NT AUTHORITY\SYSTEM' })

    $RefsToFix = foreach ($Report in $DestinationReports) {
        $Refs = Get-RsItemReference -Path $Report.Path -ReportServerUri $DestinationCM_URI | Where-Object { -not $_.reference }
        $SourceRef = Get-RsItemReference -Path $Report.Path -ReportServerUri $SourceCM_URI
        foreach ($Ref in $Refs) {
            [pscustomobject]@{
                ReportPath = $Report.Path
                RefName    = $Ref.Name
                RefType    = $Ref.ReferenceType
                SourceRef  = $SourceRef
            }
        }
    }

    $RefsToFix | Where-Object { $_.RefName -match 'collect' } | ForEach-Object {
        Set-RsDataSetReference -Path $_.ReportPath -DataSetName $_.RefName -DataSetPath '/DataSets/AllCollections' -ReportServerUri $DestinationCM_URI
    }
    $RefsToFix | Where-Object { $_.RefName -eq 'SCCM' } | ForEach-Object {
        Set-RsDataSourceReference -Path $_.ReportPath -DataSourceName 'SCCM' -DataSourcePath '/Data Sources/SCCM' -ReportServerUri $DestinationCM_URI
    }
    $RefsToFix | Where-Object { $_.RefName -eq 'Shopping2' } | ForEach-Object {
        Set-RsDataSourceReference -Path $_.ReportPath -DataSourceName 'Shopping2' -DataSourcePath '/Data Sources/Shopping2' -ReportServerUri $DestinationCM_URI
    }
    $RefsToFix | Where-Object { $_.RefName -eq 'AutoGen__5C6358F2_4BB6_4a1b_A16E_8D96795D8602_' } | ForEach-Object {
        Set-RsDataSourceReference -Path $_.ReportPath -DataSourceName 'AutoGen__5C6358F2_4BB6_4a1b_A16E_8D96795D8602_' -DataSourcePath "/ConfigMgr_$SiteCode/{5C6358F2-4BB6-4a1b-A16E-8D96795D8602}" -ReportServerUri $DestinationCM_URI
    }
    $RefsToFix | Where-Object { $_.RefName -match 'PkgQry' } | ForEach-Object {
        Set-RsDataSetReference -Path $_.ReportPath -DataSetName $_.RefName -DataSetPath '/DataSets/AllPackages' -ReportServerUri $DestinationCM_URI
    }
    $RefsToFix | Where-Object { $_.RefName -eq 'DSAllClientVersions' } | ForEach-Object {
        Set-RsDataSetReference -Path $_.ReportPath -DataSetName $_.RefName -DataSetPath '/DataSets/AllClientVersions' -ReportServerUri $DestinationCM_URI
    }
    $RefsToFix | Where-Object { $_.RefName -match 'DSAllSugs|All_SUGs' } | ForEach-Object {
        Set-RsDataSetReference -Path $_.ReportPath -DataSetName $_.RefName -DataSetPath '/DataSets/AllSUGs' -ReportServerUri $DestinationCM_URI
    }
    #endregion fix references that were not able to be initially fixed
}