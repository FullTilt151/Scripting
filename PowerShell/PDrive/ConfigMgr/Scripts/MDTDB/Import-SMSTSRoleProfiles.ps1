Import-Module \\lounaswps01\pdrive\dept907.cit\ConfigMgr\Scripts\MDTDB\MDTDB.psm1
Connect-MDTDatabase -sqlserver SIMMDTWPS01 -instance MDTDB -database MDTDB

$SiteCode = "WP1"
$ProviderMachineName = "LOUAPPWPS1658.rsc.humad.com"

if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"
}

if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName
}

<#
Get-ChildItem '\\connect.humana.com/sites/Windows10/Shared Documents/User Deployment Lists' | 
ForEach-Object {
    $file = $_.FullName
}
#>

$file = '\\connect.humana.com/sites/Windows10/Shared Documents/User Deployment Lists/ITSE workstations.xlsx'

$objExcel = New-Object -ComObject Excel.Application
$workbook = $objExcel.Workbooks.Open($file)
$sheet = ($workbook.Sheets) | Where-Object {$_.Index -eq 1}
$objExcel.Visible=$false

$rowMax = ($sheet.UsedRange.Rows).count
$columnrow = $sheet.UsedRange | Select-Object -ExpandProperty Row -First 1
$Columns = $sheet.UsedRange | Where-Object {$_.row -eq $columnrow} | Select-Object Text, Column

$ColWKID = $Columns.Where{$_.Text -eq 'Asset Name'}.Column
$ColChassis = $ColSoftwareProfile = $Columns.Where{$_.Text -eq 'Class'}.Column
$ColSoftwareProfile = $Columns.Where{$_.Text -eq 'Software Role'}.Column

for ($i=1; $i -le $rowMax-1; $i++){
    $wkid = $sheet.Cells.Item($columnrow+$i,$colWKID).text
    $softwareprofile = $sheet.Cells.Item($columnrow+$i,$ColSoftwareProfile).text
    $chassis = $sheet.Cells.Item($columnrow+$i,$ColChassis).text

    Push-Location "$($SiteCode):\"
    $ResourceID = (Get-CimInstance -ComputerName $ProviderMachineName -Namespace root\sms\site_$SiteCode -ClassName sms_r_system -Filter "Name = '$wkid'" -Property ResourceID).ResourceID
    $Serial = (Get-CimInstance -ComputerName $ProviderMachineName -Namespace root\sms\site_$SiteCode -ClassName sms_g_system_pc_bios -Filter "ResourceID = '$ResourceID'" -Property SerialNumber).SerialNumber
    Pop-Location

    switch ($softwareprofile) {
        '.NET Architect' {$SMSTSRole = 'NETArch'}
        '.NET Full Stack Developer' {$SMSTSRole = 'NETFullStackPro'}
        '.NET Full Stack Dev-Enterprise' {$SMSTSRole = 'NETFullStackEnt'}
        '.NET Full Stack Dev-Professional' {$SMSTSRole = 'NETFullStackPro'}
        '.NET PSM Developer' {$SMSTSRole = 'NETPSD'}
        '.NET Testing Consultant' {$SMSTSRole = 'NETTest'}
        '.NET Testing Engineer' {$SMSTSRole = 'NETTest'}
        '.NET QAL' {$SMSTSRole = 'NETQAL'}
        '.NET UX Developer' {$SMSTSRole = 'NETUXDev'}
        '.NET Web Developer' {$SMSTSRole = 'NETWebDev'}
        'Java Architect' {$SMSTSRole = 'JavaArch'}
        'Java Developer' {$SMSTSRole = 'JavaDev'}
        'Java QAL' {$SMSTSRole = 'JavaQAL'}
        'Java Testing Consultant' {$SMSTSRole = 'JavaTest'}
        'Java Testing Engineer' {$SMSTSRole = 'JavaTest'}
        'Mainframe Architect' {$SMSTSRole = 'BaseOnly'}
        'Mainframe Developer' {$SMSTSRole = 'BaseOnly'}
        'Mainframe PSM Developer' {$SMSTSRole = 'BaseOnly'}
        'Mainframe QAL' {$SMSTSRole = 'BaseOnly'}
        'Mainframe Testing Consultant' {$SMSTSRole = 'BaseOnly'}
        'Mainframe Testing Engineer' {$SMSTSRole = 'BaseOnly'}
        'Not Applicable' {$SMSTSRole = 'BaseOnly'}
        'Not Applicable - with App Mapping' {$SMSTSRole = 'W10Std'}
    }

    if ($chassis -in ('Workstation','Laptop') -and $Serial -ne $null -and $SMSTSRole -ne $null) {
        "$wkid / $Serial / $softwareprofile / $SMSTSRole"
        New-MDTComputer -serialNumber $Serial -settings @{OSInstall=’YES’; SMSTSRole="$SMSTSRole"}
    }

}

$objExcel.quit()

Get-MDTComputer | Group-Object SerialNumber | Where-Object {$_.Count -gt 1} | 
ForEach-Object {
    $IDs = Get-MDTComputer -serialNumber $_.Name | Select-Object id
    $IDs
    $IDs | Select-Object -First $(($IDs.length)-1) | ForEach-Object {
        Remove-MDTComputer -id $_.id
    }
}