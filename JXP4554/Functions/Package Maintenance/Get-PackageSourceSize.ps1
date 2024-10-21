Param(
    $SiteServer = "LOUAPPWPS875",
    $SiteCode = "CAS"
)

#import assemblies
[System.Reflection.Assembly]::LoadFrom(“C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\Microsoft.ConfigurationManagement.ApplicationManagement.dll”)
[System.Reflection.Assembly]::LoadFrom(“C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\Microsoft.ConfigurationManagement.ApplicationManagement.Extender.dll”)
[System.Reflection.Assembly]::LoadFrom(“C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\Microsoft.ConfigurationManagement.ApplicationManagement.MsiInstaller.dll")

$EmptyArray = @()
$ResultsArray = @()
$Location = Get-Location |Select-Object -ExpandProperty Path


##############
#process applications
$i = 0
$ApplicationsQuery = Get-WmiObject -Namespace Root\sms\Site_$SiteCode -Query "select CI_UniqueID,LocalizedDisplayName,SoftwareVersion,__PATH from SMS_Application where sourcesite='$SiteCode' and IsLatest='true'" -computerName $SiteServer


gwmi -ComputerName $SiteServer -Namespace root\sms\site_$SiteCode -class sms_application | ? {$_.IsLatest -eq $true} | % {
    $i++
    Write-Progress -Activity "Processing Application sources" -Status "Added: $i of $($ApplicationsQuery.count) " -PercentComplete (($i / $ApplicationsQuery.Count) * 100)
    #get the instance of the application
    $app = [wmi]$_.__PATH
    #deserialize the XML data
    $appXML = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($app.SDMPackageXML, $true)
    #loop through the deployment types
    foreach ($dt in $appXML.DeploymentTypes) {
        #find the installer element of the XML
        $installer = $dt.Installer
        #the content for each installer is stored as an single element array
        $content = $installer.Contents[0]
        $DObject = New-Object PSObject
        $DObject |Add-Member -MemberType NoteProperty -Name "Package" -Value $($_.CI_UniqueID)
        $DObject |Add-Member -MemberType NoteProperty -Name "Source" -Value $($content.Location)
        $DObject |Add-Member -MemberType NoteProperty -Name "Name" -Value $($_.LocalizedDisplayName)
        $DObject |Add-Member -MemberType NoteProperty -Name "Version" -Value $($_.SoftwareVersion)
        $EmptyArray += $DObject
    }
}

#$ApplicationsQuery = Get-WmiObject -Namespace Root\sms\Site_$SiteCode -Query "select CI_UniqueID,LocalizedDisplayName,SoftwareVersion,__PATH from SMS_Application where sourcesite='$SiteCode'" -computerName $SiteServer
#$i = 0

#Foreach($item in $ApplicationsQuery)
#{
#    $i++
#    Write-Progress -Activity "Processing Application sources" -Status "Added: $i of $($ApplicationsQuery.count) " -PercentComplete (($i / $ApplicationsQuery.Count)*100)
 
$EmptyArray | Export-Csv "$Location\AppSources.csv" -NoTypeInformation  
 
$Sources = Import-Csv "$Location\AppSources.csv"
$EmptyArray = @()
$d = 0
Foreach ($source in $Sources) {
    $d++
    Write-Progress -Activity "Processing Application source sizes" -Status "Processed: $d of $($Sources.Count)" -PercentComplete (($d / $Sources.Count) * 100)

    if (($source.Source.Length -gt 8) -and ($source.Package -notin ('FAKE00331', 'FAKE00373')) -and (test-path $source.Source)) {
        '---------------------------------------------------------'
        $($source.Name + ' ' + $source.Version)
        $source.Package
        $source.Source
 
        $SourceSizeQuery = Get-ChildItem $source.Source -Recurse| Measure-Object -property length -sum |Select-Object -ExpandProperty SUM
        $DObject = New-Object PSObject
        $DObject |Add-Member -MemberType NoteProperty -Name "Name" -Value $($source.Name)
        $DObject |Add-Member -MemberType NoteProperty -Name "Version" -Value $($source.Version)
        $DObject |Add-Member -MemberType NoteProperty -Name "Package" -Value $($source.Package)
        $DObject |Add-Member -MemberType NoteProperty -Name "Type" -Value 'Application'
        $DObject |Add-Member -MemberType NoteProperty -Name "Size" -Value ($SourceSizeQuery / 1MB)
        $DObject |Add-Member -MemberType NoteProperty -Name "Source" -Value $($source.Source)
        $ResultsArray += $DObject
    }
}

#process packages 
$PackagesQuery = Get-WmiObject -Namespace Root\sms\Site_$SiteCode -Query "select Pkgsourcepath,PackageID,Name,Version from SMS_Package where sourcesite='$SiteCode' order by Pkgsourcepath" -computerName $SiteServer
$EmptyArray = @()
$i = 0

Foreach ($item in $PackagesQuery) {
    $i++
    Write-Progress -Activity "Processing Package sources" -Status "Added: $i of $($PackagesQuery.count) " -PercentComplete (($i / $PackagesQuery.Count) * 100)
 
    $DObject = New-Object PSObject
    $DObject |Add-Member -MemberType NoteProperty -Name "Package" -Value $($item.PackageID)
    $DObject |Add-Member -MemberType NoteProperty -Name "Source" -Value $($item.pkgsourcepath)
    $DObject |Add-Member -MemberType NoteProperty -Name "Name" -Value $($item.Name)
    $DObject |Add-Member -MemberType NoteProperty -Name "Version" -Value $($item.Version)
    $EmptyArray += $DObject
}
$EmptyArray | Export-Csv "$Location\PackageSources.csv" -NoTypeInformation  
 
$Sources = Import-Csv "$Location\PackageSources.csv"
$EmptyArray = @()
$d = 0
Foreach ($source in $Sources) {
    $d++
    Write-Progress -Activity "Processing Package source sizes" -Status "Processed: $d of $($Sources.Count)" -PercentComplete (($d / $Sources.Count) * 100)

    if (($source.Source.Length -gt 8) -and ($source.Package -notin ('HUM00331', 'HUM00373')) -and (test-path $source.Source)) {
        '---------------------------------------------------------'
        $($source.Name + ' ' + $source.Version)
        $source.Package
        $source.Source
 
        $SourceSizeQuery = Get-ChildItem $source.Source -Recurse| Measure-Object -property length -sum |Select-Object -ExpandProperty SUM
        $DObject = New-Object PSObject
        $DObject |Add-Member -MemberType NoteProperty -Name "Name" -Value $($source.Name)
        $DObject |Add-Member -MemberType NoteProperty -Name "Version" -Value $($source.Version)
        $DObject |Add-Member -MemberType NoteProperty -Name "Package" -Value $($source.Package)
        $DObject |Add-Member -MemberType NoteProperty -Name "Type" -Value 'Package'
        $DObject |Add-Member -MemberType NoteProperty -Name "Size" -Value ($SourceSizeQuery / 1MB)
        $DObject |Add-Member -MemberType NoteProperty -Name "Source" -Value $($source.Source)
        $ResultsArray += $DObject
    }
}

#process images 
$ImagesQuery = Get-WmiObject -Namespace Root\sms\Site_$SiteCode -Query "select Pkgsourcepath,PackageID,Name,Version from SMS_ImagePackage where sourcesite='$SiteCode' order by Pkgsourcepath" -computerName $SiteServer
$EmptyArray = @()
$i = 0

Foreach ($item in $ImagesQuery) {
    $i++
    Write-Progress -Activity "Processing Image sources" -Status "Added: $i of $($ImagesQuery.count) " -PercentComplete (($i / $ImagesQuery.Count) * 100)
 
    $DObject = New-Object PSObject
    $DObject |Add-Member -MemberType NoteProperty -Name "Package" -Value $($item.PackageID)
    $DObject |Add-Member -MemberType NoteProperty -Name "Source" -Value $($item.pkgsourcepath)
    $DObject |Add-Member -MemberType NoteProperty -Name "Name" -Value $($item.Name)
    $DObject |Add-Member -MemberType NoteProperty -Name "Version" -Value $($item.Version)
    $EmptyArray += $DObject
}
$EmptyArray | Export-Csv "$Location\ImageSources.csv" -NoTypeInformation  
 
$Sources = Import-Csv "$Location\ImageSources.csv"
$EmptyArray = @()
$d = 0
Foreach ($source in $Sources) {
    $d++
    Write-Progress -Activity "Processing Image source sizes" -Status "Processed: $d of $($Sources.Count)" -PercentComplete (($d / $Sources.Count) * 100)

    if (($source.Source.Length -gt 8) -and ($source.Package -notin ('FAKE00331', 'FAKE00373')) -and (test-path $source.Source)) {
        '---------------------------------------------------------'
        $($source.Name + ' ' + $source.Version)
        $source.Package
        $source.Source
 
        $SourceSizeQuery = Get-ChildItem $source.Source -Recurse| Measure-Object -property length -sum |Select-Object -ExpandProperty SUM
        $DObject = New-Object PSObject
        $DObject |Add-Member -MemberType NoteProperty -Name "Name" -Value $($source.Name)
        $DObject |Add-Member -MemberType NoteProperty -Name "Version" -Value $($source.Version)
        $DObject |Add-Member -MemberType NoteProperty -Name "Package" -Value $($source.Package)
        $DObject |Add-Member -MemberType NoteProperty -Name "Type" -Value 'Image'
        $DObject |Add-Member -MemberType NoteProperty -Name "Size" -Value ($SourceSizeQuery / 1MB)
        $DObject |Add-Member -MemberType NoteProperty -Name "Source" -Value $($source.Source)
        $ResultsArray += $DObject
    }
}

#process drivers
$DriversQuery = Get-WmiObject -Namespace Root\sms\Site_$SiteCode -Query "select Pkgsourcepath,PackageID,Name,Version from SMS_DriverPackage where sourcesite='$SiteCode' order by Pkgsourcepath" -computerName $SiteServer
$EmptyArray = @()
$i = 0

Foreach ($item in $DriversQuery) {
    $i++
    Write-Progress -Activity "Processing Driver sources" -Status "Added: $i of $($DriversQuery.count) " -PercentComplete (($i / $DriversQuery.Count) * 100)
 
    $DObject = New-Object PSObject
    $DObject |Add-Member -MemberType NoteProperty -Name "Package" -Value $($item.PackageID)
    $DObject |Add-Member -MemberType NoteProperty -Name "Source" -Value $($item.pkgsourcepath)
    $DObject |Add-Member -MemberType NoteProperty -Name "Name" -Value $($item.Name)
    $DObject |Add-Member -MemberType NoteProperty -Name "Version" -Value $($item.Version)
    $EmptyArray += $DObject
}
$EmptyArray | Export-Csv "$Location\DriverSources.csv" -NoTypeInformation  
 
$Sources = Import-Csv "$Location\DriverSources.csv"
$EmptyArray = @()
$d = 0
Foreach ($source in $Sources) {
    $d++
    Write-Progress -Activity "Processing Driver source sizes" -Status "Processed: $d of $($Sources.Count)" -PercentComplete (($d / $Sources.Count) * 100)

    if (($source.Source.Length -gt 8) -and ($source.Package -notin ('FAKE00331', 'FAKE00373')) -and (test-path $source.Source)) {
        '---------------------------------------------------------'
        $($source.Name + ' ' + $source.Version)
        $source.Package
        $source.Source
 
        $SourceSizeQuery = Get-ChildItem $source.Source -Recurse| Measure-Object -property length -sum |Select-Object -ExpandProperty SUM
        $DObject = New-Object PSObject
        $DObject |Add-Member -MemberType NoteProperty -Name "Name" -Value $($source.Name)
        $DObject |Add-Member -MemberType NoteProperty -Name "Version" -Value $($source.Version)
        $DObject |Add-Member -MemberType NoteProperty -Name "Package" -Value $($source.Package)
        $DObject |Add-Member -MemberType NoteProperty -Name "Type" -Value 'Driver'
        $DObject |Add-Member -MemberType NoteProperty -Name "Size" -Value ($SourceSizeQuery / 1MB)
        $DObject |Add-Member -MemberType NoteProperty -Name "Source" -Value $($source.Source)
        $ResultsArray += $DObject
    }
}

#final results export
$ResultsArray |Export-Csv PackageSourceSizes.csv -NoTypeInformation