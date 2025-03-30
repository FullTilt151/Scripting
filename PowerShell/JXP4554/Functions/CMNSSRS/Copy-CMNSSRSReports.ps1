Function Copy-CMNSSRSReports
{
	<#
		.SYNOPSIS

		.DESCRIPTION
		
		.PARAMETER SCCMConnectionInfo
			This is a connection object used to know how to connect to the site. The best way to get this is storing the results of 
			Get-CMNSCCMConnectionInfo in a variable and passing that variable.

		.PARAMETER logFile
			File for writing logs to

		.PARAMETER logEntries
			Switch to say whether or not to create a log file

		.EXAMPLE

		.LINK
			http://configman-notes.com
    
		.REFERENCES
			https://blogs.infosupport.com/managing-ssrs-reports-with-powershell/#
			http://hindenes.com/powershell/SQLReporting.psm1
			http://sqlblogcasts.com/blogs/sqlandthelike/archive/2013/02/12/deploying-ssrs-artefacts-using-powershell-simply.aspx
			http://www.sqlmusings.com/2012/02/04/resolving-ssrs-and-powershell-new-webserviceproxy-namespace-issue/comment-page-1/

		.NOTES
			Author:	Jim Parris
			Email:	Jim@ConfigMan-Notes
			Date:	
			PSVer:	2.0/3.0
			Updated: 		
	#>
 
	[CmdletBinding(SupportsShouldProcess = $true,
		ConfirmImpact = 'Low')]
	param
	(
        [Parameter(Mandatory = $true,
            HelpMessage = 'Source Site Server')]
        [String]$sourceSiteServer,

 		[Parameter(Mandatory = $true,
            HelpMessage = 'Destination Site Server')]
        [String]$destinationSSiteServer,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Folder to copy')]
        [String]$folder,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Recurse?')]
        [Switch]$doRecurse,

		[Parameter(Mandatory = $false,
			HelpMessage = 'LogFile Name')]
		[String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries')]
        [Switch]$logEntries = $false
	)

	begin 
	{
		$NewLogEntry = @{
			LogFile = $logFile;
			Component = 'Copy-CMNSSRSReports'
		}

        if($logEntries){New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry}
        $sSite = Get-CMNSCCMConnectionInfo -SiteServer $sourceSiteServer
        $dSite = Get-CMNSCCMConnectionInfo -SiteServer $destinationSSiteServer

        $query = "Select SiteSystem from SMS_SiteSystemSummarizer where role = 'SMS SRS Reporting Point'"
        $sSSRS = (Get-WmiObject -Query $query -ComputerName $sSite.ComputerName -Namespace $sSite.NameSpace).SiteSystem -replace '.*\\\\(.*)\\','$1'
        $dSSRS = (Get-WmiObject -Query $query -ComputerName $dSite.ComputerName -Namespace $dSite.NameSpace).SiteSystem -replace '.*\\\\(.*)\\','$1'


		$destinationReportServerUri = "http://$dSSRS`:8081/reportserver/ReportService2010.asmx?wsdl"
        $drs = New-WebServiceProxy -Uri $destinationReportServerUri -UseDefaultCredential #-Namespace "SSRS"
        $NameSpace = $drs.GetType().NameSpace
        $dConString = Get-CMNConnectionString -DatabaseServer $dSite.SCCMDBServer -Database 'ReportServer'
        $sourceReportServerUri = "http://$sSSRS`:8081/reportserver/ReportService2010.asmx?wsdl"
        $srs = New-WebServiceProxy -Uri $sourceReportServerUri -UseDefaultCredential #-Namespace "SSRS"
        $sConString = Get-CMNConnectionString -DatabaseServer $sSite.SCCMDBServer -Database 'ReportServer'

        $sFolder = "/ConfigMGR_$($sSite.SiteCode)/$folder"
        $dFolder = "/ConfigMGR_$($dSite.SiteCode)/$folder"

        #determine the Data Sources
        $sDS = $srs.ListChildren("/", $true) | Where-Object {$_.TypeName -eq 'DataSource'}
        $dDS = $drs.ListChildren("/", $true) | Where-Object {$_.TypeName -eq 'DataSource'}

        #determine the Data Sets

        $sDSs = $srs.ListChildren("/", $true) | Where-Object {$_.TypeName -eq 'DataSet'}
        $dDSS = $drs.ListChildren("/", $true) | Where-Object {$_.TypeName -eq 'DataSet'}

        #Now, to map the destination data sources to the source data sources
        $dsMap = @{}

        for($s = 0 ; $s -lt $sDS.Count ; $s++) #Loop for the source
        {
            $query = "Select ItemID from Catalog where Type = 5 and Path = '$($sDS[$s].Path)'"
            [String]$sID = (Get-CMNDatabaseData -connectionString $sConString -query $query -isSQLServer).ItemID
            Write-Output "Please select target Data Source for:"
            Write-Output "$($sDS[$s].Name)"
            for($d = 0 ; $d -lt $dDS.Count ; $d++) #Loop for the destination
            {
                Write-Output "$d) - $($dDs[$d].Name)"
            }
            Write-host "$($dDS.Count)) - Do Not Change"
            $map = $null
            do
            {
                $map = Read-Host "->"
            } while($map -lt 0 -or $map -gt $dDs.Count)
            if($map -eq $dDS.Count){$dID = 'Do Not Change'}
            else
            {
                $query = "Select ItemID from Catalog where Type = 5 and Path = '$($dDS[$map].Path)'"
                [String]$dID = (Get-CMNDatabaseData -connectionString $dConString -query $query -isSQLServer).ItemID
            }
            New-CMNLogEntry -entry "Mapping $($sDS[$s].Name) to $dID" -type 1 @NewLogEntry
            $dsMap.Add($sID,$dID)
        }
        $dsMap
	}

	process 
	{
		New-CMNLogEntry -entry "Beginning process loop" -type 1 @NewLogEntry
        New-CMNLogEntry -entry 'Copying Datasets' -type 1 @NewLogEntry
        #List datasets
        $dataSets = $srs.ListChildren("/", $true) | Where-Object {$_.TypeName -eq 'DataSet'}
        foreach($dataSet in $dataSets)
        {
            New-CMNLogEntry -entry "Working Dataset $($dataSet.Name)" -type 1 @NewLogEntry
            $pth = ConvertTo-CMNSingleQuotedString -text $dataSet.Path
            $query = "SELECT c2.itemid 
FROM   reportserver.dbo.datasource AS DS 
       INNER JOIN reportserver.dbo.catalog AS C 
               ON DS.itemid = C.itemid 
                  AND DS.link IN (SELECT itemid 
                                  FROM   reportserver.dbo.catalog 
                                  WHERE  type = 5) 
       FULL OUTER JOIN reportserver.dbo.catalog C2 
                    ON DS.link = C2.itemid 
WHERE  C2.type = 5 
       AND C.path = '$pth'"
            [String]$sItemID = (Get-CMNDatabaseData -connectionString $sConString -query $query -isSQLServer).ItemID
            $warnings = $null
            $bytes = $srs.GetItemDefinition($DataSet.Path)
            $results = $drs.CreateCatalogItem(
                "DataSet",      #Catalog item type
                $DataSet.Name,  #DataSet name
                '/Datasets',    #Destination folder
                $true,          #Overwrite if exists?
                $bytes,         #.rds contents
                $null,          #Properties to set
                [ref]$warnings) #Warnings
                $datasources = $drs.GetItemDataSources($results.Path)
                $datasources | ForEach-Object{
                    if($dsMap[$sItemID] -ne 'Do Not Update')
                    {
                        for($d = 0 ; $d -lt $dDS.Count ; $d++)
                        {
                            if($dDS[$d].ID -eq $dsMap[$sItemID]){break}
                        }
                        New-CMNLogEntry -entry "Updating Datasource to $($dds[$d].Name)" -type 1 @NewLogEntry
                        $datatype = ($NameSpace + '.DataSource')
                        $dataSource = New-Object ($datatype)
                        $dataSource.Name = $_.Name
                        $datatype = ($NameSpace + '.DataSourceReference')
                        $dataSource.Item = New-Object ($datatype)
                        $dataSource.Item.Reference = $dds[$d].Path
                        $_.Item = $dataSource.Item
                        $datatype = ($NameSpace + 'DataSource')
                        $drs.SetItemDataSources($results.Path,@($dataSource))
                    }
                    else
                    {
                        New-CMNLogEntry -entry "Not updating report $fileName" -type 1 @NewLogEntry
                    }
                }
        }
        $catalogItems = $srs.ListChildren("$sfolder", $doRecurse.IsPresent) | Where-Object {$_.TypeName -eq "Report" }
        foreach($catalogItem in $catalogItems)
        {
            New-CMNLogEntry -entry ("Downloading ""{0}""..." -f $catalogItem.Path) -type 1 @NewLogEntry
            $fileName = ("{0}.rdl" -f $catalogItem.Name)
            $bytes = $srs.GetItemDefinition($catalogItem.Path)
            $pth = ConvertTo-CMNSingleQuotedString -text $catalogItem.Path
            $query = "SELECT c2.itemid 
FROM   reportserver.dbo.datasource AS DS 
       INNER JOIN reportserver.dbo.catalog AS C 
               ON DS.itemid = C.itemid 
                  AND DS.link IN (SELECT itemid 
                                  FROM   reportserver.dbo.catalog 
                                  WHERE  type = 5) 
       FULL OUTER JOIN reportserver.dbo.catalog C2 
                    ON DS.link = C2.itemid 
WHERE  C2.type = 5 
       AND C.path = '$pth'"
            [String]$sItemID = (Get-CMNDatabaseData -connectionString $sConString -query $query -isSQLServer).ItemID
            $reportName = $catalogItem.Name
            $reportSearchName = [regex]::Replace($reportName,'(?<SingleQuote>\))','\${SingleQuote}')
            $reportSearchName = [regex]::Replace($reportSearchName,'(?<SingleQuote>\()','\${SingleQuote}')
            $targetFolderPath = $catalogItem.Path -replace "(.*)/$reportSearchName",'$1'
            $targetFolderPath = $targetFolderPath -replace $sFolder, $dFolder
            New-CMNLogEntry -entry "Verifying folder $targetFolderPath exists" -type 1 @NewLogEntry
            $tfExists = $drs.ListChildren('/', $true) | Where-Object {$_.TypeName -eq 'Folder' -and $_.Path -eq $targetFolderPath}
            if(-not($tfExists))
            {
                New-CMNLogEntry -entry 'Need to create' -type 1 @NewLogEntry
                $CurrentPath = ''
                foreach($container in $targetFolderPath -split '/')
                {
                    if($container -ne '')
                    {
                        $CurrentPath = ($currentPath + '/' + $container)
                        $cfExists = $drs.ListChildren('/', $true) | Where-Object {$_.TypeName -eq 'Folder' -and $_.Name -eq $container}
                        if(-not($cfExists))
                        {
                            $datatype = ($NameSpace + '.Property')
                            $property = New-Object ($datatype)
                            $property.Name = $container
                            $property.Value = $container
                            $numProperties = 1
                            $properties = New-Object ($datatype + '[]')$numProperties
                            $properties[0] = $property
                            $newFolder = $drs.CreateFolder($container, ($CurrentPath -replace "(.*)/$container",'$1'), $properties)
                            New-CMNLogEntry -entry "Created folder $CurrentPath" -type 1 @NewLogEntry
                        }
                    }
                }
            }
            else
            {
                New-CMNLogEntry -entry 'We have a folder!' -type 1 @NewLogEntry
            }
            $warnings = $null
            New-CMNLogEntry -entry "Uploading report ""$reportName"" to ""$targetFolderPath""..." -type 1 @NewLogEntry
            $report = $drs.CreateCatalogItem(
                "Report",         # Catalog item type
                $reportName,      # Report name
                $targetFolderPath,# Destination folder
                $true,            # Overwrite report if it exists?
                $bytes,           # .rdl file contents
                $null,            # Properties to set.
                [ref]$warnings)   # Warnings that occured while uploading.

            foreach($warning in $warnings)
            {
                Write-Output ("Warning: {0}" -f $warning.Message)
            }
            $datasources = $drs.GetItemDataSources($report.Path)
            $datasources | ForEach-Object{
                if($dsMap[$sItemID] -ne 'Do Not Update')
                {
                    for($d = 0 ; $d -lt $dDS.Count ; $d++)
                    {
                        if($dDS[$d].ID -eq $dsMap[$sItemID]){break}
                    }
                    New-CMNLogEntry -entry "Updating Datasource to $($dds[$d].Name)" -type 1 @NewLogEntry
                    $datatype = ($NameSpace + '.DataSource')
                    $dataSource = New-Object ($datatype)
                    $dataSource.Name = $_.Name
                    $datatype = ($NameSpace + '.DataSourceReference')
                    $dataSource.Item = New-Object ($datatype)
                    $dataSource.Item.Reference = $dds[$d].Path
                    $_.Item = $dataSource.Item
                    $datatype = ($NameSpace + 'DataSource')
                    $drs.SetItemDataSources($report.Path,$dataSource)
                }
                else
                {
                    New-CMNLogEntry -entry "Not updating report $fileName" -type 1 @NewLogEntry
                }
            }
        }
	}

	End
	{
        New-CMNLogEntry -entry 'Completing Function' -type 1 @NewLogEntry
	}
}
#End Copy-CMNSSRSReports

#Begin - Testing info

#$SiteServer = 'LOUAPPWQS1151'
#$SCCMConnectionInfo = Get-CMNSCCMConnectionInfo -SiteServer $SiteServer
$logFile = 'C:\Temp\TestScript.log'
#if(Test-Path $logFile){Remove-Item $logFile}

Copy-CMNSSRSReports -sourceSiteServer louappwps1825 -destinationSSiteServer LOUAPPWPS1658 -folder 'CIS Reports/Servers' -logFile $logFile -logEntries
#End - Testing infoaii
