$Date = Get-Date -UFormat %m%d%Y
$Path = "\\lounaswps08\pdrive\dept907.cit\osd\TaskSequences\Backup\$Date"

New-Item $Path -ItemType directory -ErrorAction SilentlyContinue

Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
New-PSDrive -Name WP1 -PSProvider CMSite -Root LOUAPPWPS1658
Set-Location WP1:

Get-CMTaskSequence | 
ForEach-Object {
    $ExportFile = "$Path\$($_.PackageID)_$($_.Name).zip"
    Export-CMTaskSequence -InputObject $_ -ExportFilePath $ExportFile
}