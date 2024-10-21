#Humana Models
$models = ('L440','L450','L460','M700','M710','M720','M800','M83','M900','M910','M920','M93','P330','P50','P500','P51','P510','P52','P520','P70','P72','P910','T460','T470','T480','T490','T540','T550','T560','T570','T580','Twist','W540','W541','X1','Yoga')
# Site configuration
$SiteCode = "WP1" # Site code 
$ProviderMachineName = "LOUAPPWPS1658.rsc.humad.com" # SMS Provider machine name

# Customizations
$initParams = @{}
#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

$cimSession = New-CimSession -ComputerName $ProviderMachineName
$baseFileDir = 'C:\Temp\'
$customCatalogURL = 'https://download.lenovo.com/luc/LenovoCustomPackageData.cab'
$customCatalogCabFile = "$($baseFileDir)LenovoCustomPackageData.cab"
$customCatalogXMLFile = "$($baseFileDir)LenovoCustomPackageData.xml"
Invoke-WebRequest -Uri $customCatalogURL -OutFile $customCatalogCabFile
$cmd = 'C:\Windows\System32\extrac32.exe'
$args = @("/y", $customCatalogCabFile, $customCatalogXMLFile)
& $cmd $args
Start-Sleep -Seconds 5
[xml]$customXML = Get-Content -Path $customCatalogXMLFile
$progressCount = 1
$sugInfo = @{}
foreach ($customNode in $customXML.CustomPackageData.Package) {
    Write-Progress -Activity 'Processing Lenovo Names' -Id 1 -PercentComplete ($progressCount / $customXML.CustomPackageData.Package.Count * 100) -CurrentOperation "Processing $progressCount of $($customXML.CustomPackageData.Package.Count)"
    $progressCount++
    #Write-Output "$($customNode.PackageID) = $($customNode.Custom.'#text')"
    $update = Get-CimInstance -CimSession $cimSession -ClassName SMS_SoftwareUpdate -Namespace "root/sms/site_$SiteCode" -Filter "CI_UniqueID = '$($customNode.PackageID)'"
    if ($update) {
        #Split $customNode.Custom.'#text' and note models
        if ((New-TimeSpan -Start ($update.DateCreated) -End (Get-Date)).Days -le 30) {
            # $updateDate = Get-Date -Date $update.DateCreated -Format 'yyMM'
            $updateDate = Get-Date -Format 'yyMM'
            $items = $customNode.Custom.'#text'.Split(',')
            foreach ($item in $items) {
                $sugName = "Lenovo-$updateDate-$($item.Trim())"
                $sugInfo[$sugName] += [Array]$update.CI_ID
            }
        }
    }
    else {
        #Write-Output 'Not downloaded'
    }
}
Remove-CimSession -CimSession $cimSession
Write-Progress -Activity 'Processing Lenovo Names' -ID 1 -Completed

# Import the ConfigurationManager.psd1 module 
if ((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
if ((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Push-Location
Set-Location "$($SiteCode):\" @initParams
#Now to cycle through the hash table and create/update the SUG's

$progressCount = 1
foreach ($item in $sugInfo.GetEnumerator()) {
    Write-Progress -Activity 'Processing Software Update Groups' -Id 1 -PercentComplete ($progressCount / $sugInfo.Count * 100) -CurrentOperation "Processing $($Item.Name): $progressCount/$($sugInfo.Count)"
    $progressCount++
    $sug = Get-CMSoftwareUpdateGroup -Name ($item.Name)
    if ($sug) {
        $sug.Updates = $item.Value
        $sug.Put()
    }
    else {
        $sug = New-CMSoftwareUpdateGroup -Name ($item.Name) -Description "Lenovo updates" -SoftwareUpdateId ($item.Value)
    }
}
Write-Progress -Activity 'Processing Software Update Groups' -Id 1 -Completed
Pop-Location